local io = zune.io

local function prompt(text: string, hint: string?): string
	io.stdout:write(text)

    if hint then
        io.stdout:write(`\n{hint}`)
        io.stdout:write(string.char(27) .. "[1F")
        io.stdout:write(string.char(27) .. `[{text:len()}C`)
    end
    

	local parts = {}
	while true do
		local chunk = io.stdin:read(1)
		if chunk == "" then
			break
		end
		if chunk == "\n" then
			break
		end
		table.insert(parts, chunk)
	end

    if hint then
        io.stdout:write(string.char(27) .. "[1E")
    end

	return (table.concat(parts):gsub("\r$", ""))
end

return prompt
