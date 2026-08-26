local io = zune.io
local process = zune.process
local style = require("./style")
local ansi = require("./ansi")
local FinishPrompt = require("./finish-prompt")

export type Choice<T> = {
	label: string,
	value: T,
	hint: string?,
}

local function clearMenu(lineCount: number)
	io.stdout:write(ansi.clearUp(lineCount))
end

local function renderMenu<T>(choices: { Choice<T> }, cursor: number)
	for i, choice in choices do
		local isSelected = i == cursor
		local pointer = if isSelected then style.bold("> ", "cyan") else "  "
		local label = if isSelected then style.bold(choice.label, "cyan") else choice.label

		local line = pointer .. label
		if choice.hint then
			line ..= ` {ansi.DIM}— {choice.hint}{ansi.RESET}`
		end
		io.stdout:write(line .. "\r\n")
	end
end

local function readByte(): number?
	while true do
		local chunk = io.stdin:readSync(1, true) :: (buffer | string)?

		local len = 0
		if type(chunk) == "buffer" then
			len = buffer.len(chunk)
		elseif type(chunk) == "string" then
			len = #(chunk :: string)
		end

		if len > 0 then
			if type(chunk) == "buffer" then
				return buffer.readu8(chunk :: buffer, 0)
			else
				return (string.byte(chunk :: string, 1))
			end
		end

		zune.task.wait(0.001)
	end
end

local function readKey(): string
	local b = readByte()
	if b == nil then
		return "eof"
	end

	if b == 3 then
		return "ctrl-c"
	elseif b == 13 or b == 10 then
		return "enter"
	elseif b == 27 then
		local next1 = readByte()
		if next1 == 91 then
			local next2 = readByte()
			if next2 == 65 then
				return "up"
			elseif next2 == 66 then
				return "down"
			end
		end
		return "escape"
	end

	return string.char(b)
end

local function select<T>(promptText: string, choices: { Choice<T> }): T
	if not io.terminal.isTTY then
		error("select() requires an interactive terminal (stdin is not a TTY)")
	end

	io.stdout:write(style.bold("? ", "green") .. style.bold(promptText) .. "\r\n")

	local enabled = io.terminal.enableRawMode()
	if not enabled then
		error("Failed to enable raw mode on the terminal")
	end
	io.stdout:write(ansi.hideCursor())

	local cursor = 1
	local firstRender = true
	local finished = false

	--[[
        Restores terminal mode exactly once, regardless of which exit path
        (enter / cancel / error) triggers it. Sync-only
    ]]
	local function cleanup()
		if finished then
			return
		end
		finished = true
		io.terminal.restoreMode()
	end

	local function handleCancel()
		if finished then
			return
		end
		cleanup()
		FinishPrompt.cancelSync(promptText, #choices)
		process.exit(1)
	end

	if process and process.onSignal then
		process.onSignal("INT", handleCancel)
	end

	local ok, resultValue, resultLabel = pcall(function()
		while true do
			if not firstRender then
				clearMenu(#choices)
			end
			firstRender = false
			renderMenu(choices, cursor)

			local key = readKey()
			if key == "up" then
				cursor = if cursor == 1 then #choices else cursor - 1
			elseif key == "down" then
				cursor = if cursor == #choices then 1 else cursor + 1
			elseif key == "enter" then
				return choices[cursor].value, choices[cursor].label
			elseif key == "ctrl-c" or key == "eof" then
				handleCancel() -- fallback, in case byte 3 does get through
			end
		end
	end)

	cleanup()

	if not ok then
		error(resultValue, 0)
	end

	FinishPrompt.success(promptText, resultLabel, #choices)
	return resultValue
end

return {
	select = select,
}
