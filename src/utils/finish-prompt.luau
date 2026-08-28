local io = zune.io
local style = require("./style")
local ansi = require("./ansi")

local FinishPrompt = {}

-- Builds the full collapsed-line output
local function buildLine(
	symbol: string,
	color: style.COLORS,
	promptText: string,
	answerText: string?,
	extraLines: number
): string
	local out = ansi.showCursor() .. ansi.clearUp(extraLines + 1)
	out ..= style.normal(symbol .. " ", color) .. style.bold(promptText)
	if answerText then
		out ..= " " .. style.bold(answerText, color)
	end
	return out
end

--[[
    Clears the current line and replace with `promptText` and on the side `answerText` as success.

    @param promptText The text to replace the current text with.
    @param answerText Similar to promptText, placed on the side of the `promptText`.
    @param extraLines Number of additional line to be cleared.

    @return `void`
]]
function FinishPrompt.success(promptText: string, answerText: string?, extraLines: number)
	io.stdout:write(buildLine("✔", "green", promptText, answerText, extraLines) .. "\r\n")
end

-- Sync — used from a signal handler (process.onSignal).
--[[
    Synchronous <br>
    Clears the current line and replace with `promptText` as fail.

    @param promptText The text to replace the current text with.
    @param extraLines Number of additional line to be cleared.

    @return `void`
]]
function FinishPrompt.cancelSync(promptText: string, extraLines: number)
	io.stdout:writeSync(buildLine("✖", "red", promptText, nil, extraLines) .. "\r\n")
end

return FinishPrompt
