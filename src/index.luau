local process = zune.process
local style = require("@utils/style")
local version = require("@cmds/version")

local cmds: {
    [string]: {
        exec: (...any) -> (),
        desc: string
    }
} = {
    create = require("@cmds/create"),
    help = require("@cmds/help"),
    setup = require("@cmds/setup"),
    start = require("@cmds/start")
}

local subcmd: string?
local args: { string } = {}
local flags: { string } = {}
local stopParsingFlags = false

local function main()
    for index, token in process.args do
		if index == 1 then
			continue
		end

		if index == 2 then
			if token == "--version" or token == "-v" then
				version.exec()
				return
            end
            
            if token == "--help" or token == "-h" then
                cmds.help.exec(cmds, args)
                return
			end

			subcmd = token
			continue
		end

		if stopParsingFlags then
			table.insert(args, token)
			continue
		end

		if token == "--" then
			stopParsingFlags = true
			continue
		end

		if string.sub(token, 1, 2) == "--" then
			local flagName = string.sub(token, 3)
			table.insert(flags, flagName)
			continue
		end

		if string.sub(token, 1, 1) == "-" then
			local flagName = string.sub(token, 2)
			table.insert(flags, flagName)
			continue
		end

		table.insert(args, token)
	end

	if not subcmd then
		cmds.help.exec(cmds)
		return
	end

	local cmd = cmds[subcmd] or nil

	if not cmd then
        style.err(`Command "{subcmd}" does not exist`)
        return
    elseif subcmd == "help" then
		cmds.help.exec(cmds, args)
		return
	end

	cmd.exec(args, flags)
end

main()
