local ESC = "\27"

local Ansi = {
	ESC = ESC,
	DIM = ESC .. "[2m",
	RESET = ESC .. "[0m",
}

function Ansi.showCursor(): string
	return ESC .. "[?25h"
end

function Ansi.hideCursor(): string
	return ESC .. "[?25l"
end

--[[
    Builds the sequence to move the cursor up `lineCount` lines and
    clear everything from there to the end of the screen.
]]
function Ansi.clearUp(lineCount: number): string
	local seq = ""
	if lineCount > 0 then
		seq ..= ESC .. `[{lineCount}A`
	end
	seq ..= ESC .. "[J"
	return seq
end

return Ansi
