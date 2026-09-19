local process = zune.process
local style = require("@utils/style")

local cmds: {
    [string]: string
} = {
    create = "@cmds/create",
    help = "@cmds/help",
    build = "@cmds/build"
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
				require("@cmds/version").exec()
				return
            end
            
            if token == "--help" or token == "-h" then
                require("@cmds/help").exec(cmds)
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
		require("@cmds/help").exec(cmds)
		return
	end

    if not cmds[subcmd] then
        style.err(`Command "{subcmd}" does not exist`)
        return
    end

	local cmd = require(cmds[subcmd]) :: { desc: string, exec: (...any) -> () }

    if subcmd == "help" then
		require("@cmds/help").exec(cmds)
		return
	end

	cmd.exec(args, flags)
end

main()
