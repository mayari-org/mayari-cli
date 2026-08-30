local fs = zune.fs

local tomlpatch = {}

export type TomlValue = string | number | boolean

local function splitLines(source: string): {string}
	local lines = {}
	local pos = 1
	while true do
		local nl = source:find("\n", pos, true)
		if not nl then
			table.insert(lines, source:sub(pos))
			break
		end
		table.insert(lines, source:sub(pos, nl - 1))
		pos = nl + 1
	end
	return lines
end

local function escapeBasicString(s: string): string
	local out = s:gsub("\\", "\\\\")
	out = out:gsub('"', '\\"')
	out = out:gsub("\t", "\\t")
	out = out:gsub("\n", "\\n")
	out = out:gsub("\r", "\\r")
	return out
end

local function serializeValue(value: TomlValue): string
	local t = type(value)
	if t == "string" then
		return '"' .. escapeBasicString(value :: string) .. '"'
	elseif t == "boolean" then
		return value and "true" or "false"
	elseif t == "number" then
		if value :: number % 1 == 0 and math.abs(value :: number) < 2 ^ 53 then
			return string.format("%d", value :: number)
		end
		return tostring(value)
	end
	error(`tomlpatch: unsupported value type "{t}"`)
end

local function splitValueAndTrailing(rest: string): (string, string)
	local inString = false
	local quoteChar = ""
	local escaped = false
	local valueEnd = 0

	local i = 1
	local n = #rest
	while i <= n do
		local c = rest:sub(i, i)
		if inString then
			valueEnd = i
			if escaped then
				escaped = false
			elseif quoteChar == '"' and c == "\\" then
				escaped = true
			elseif c == quoteChar then
				inString = false
			end
		elseif c == '"' or c == "'" then
			inString = true
			quoteChar = c
			valueEnd = i
		elseif c == "#" then
			break
		elseif c ~= " " and c ~= "\t" then
			valueEnd = i
		end
		i += 1
	end

	return rest:sub(1, valueEnd), rest:sub(valueEnd + 1)
end

local function matchKeyLine(line: string): (string?, string?, string?)
	local indent, keyraw, eqspacing, rest = line:match("^(%s*)([%w_%-]+)(%s*=%s*)(.*)$")
	if not keyraw then
		indent, keyraw, eqspacing, rest = line:match('^(%s*)("[^"]*")(%s*=%s*)(.*)$')
	end
	if not keyraw then
		indent, keyraw, eqspacing, rest = line:match("^(%s*)('[^']*')(%s*=%s*)(.*)$")
	end
	if not keyraw then
		return nil, nil, nil
	end

	local keyName = keyraw:match('^"(.*)"$') or keyraw:match("^'(.*)'$") or keyraw
	return keyName, (indent :: string) .. (keyraw :: string) .. (eqspacing :: string), rest
end

local function parseSectionHeader(line: string): {string}?
	local inner = line:match("^%s*%[([^%[%]]+)%]%s*$")
	if not inner then
		return nil
	end

	local path = {}
	for part in inner:gmatch("[^.]+") do
		local trimmed = (part:match("^%s*(.-)%s*$") :: string)
		local unquoted = trimmed:match('^"(.*)"$') or trimmed:match("^'(.*)'$")
		table.insert(path, unquoted or trimmed)
	end
	return path
end

local function pathsEqual(a: {string}, b: {string}): boolean
	if #a ~= #b then
		return false
	end
	for i, v in a do
		if b[i] ~= v then
			return false
		end
	end
	return true
end

function tomlpatch.set(source: string, path: {string}, value: TomlValue): string
	if #path < 1 then
		error("tomlpatch.set: path must have at least one segment")
	end

	local sectionPath = {}
	for i = 1, #path - 1 do
		sectionPath[i] = path[i]
	end
	local keyName = path[#path]

	local hasCRLF = source:find("\r\n", 1, true) ~= nil
	local lines = splitLines(source)
	local currentSection: {string} = {}
	local found = false

	for i, rawLine in lines do
		local line = if hasCRLF then (rawLine:gsub("\r$", "")) else rawLine

		local headerPath = parseSectionHeader(line)
		if headerPath then
			currentSection = headerPath
			continue
		end

		if pathsEqual(currentSection, sectionPath) then
			local key, prefix, rest = matchKeyLine(line)
			if key == keyName then
				local _, trailing = splitValueAndTrailing(rest :: string)
				local newLine = (prefix :: string) .. serializeValue(value) .. trailing
				lines[i] = if hasCRLF then newLine .. "\r" else newLine
				found = true
				break
			end
		end
	end

	if not found then
		error(`tomlpatch.set: key "{table.concat(path, ".")}" not found — this only edits existing keys`)
	end

	return table.concat(lines, "\n")
end

function tomlpatch.setToFile(filePath: string, keyPath: {string}, value: TomlValue)
	local source = fs.readFileSync(filePath)
	local patched = tomlpatch.set(source, keyPath, value)
	fs.writeFileSync(filePath, patched)
end

return tomlpatch
