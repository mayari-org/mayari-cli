local style = require("@utils/style")

local function exec(cmds: { [string]: string })

    print(style.bold("Mayari CLI", "gray") .. " - CLI tool for Mayari projects\n")
    print(style.bold("Usage: mayari <command> [...args]\n"))
    print(style.bold("Commands:"))

    for name, cmd in cmds do
        local max_length = 0
        local module = require(cmd) :: { [string]: any }

        if #name > max_length then
            max_length = #name
        end

        local extra_padding = 4 

        local padding_needed = max_length - #name + extra_padding
        local spaces = string.rep(" ", padding_needed)
        print("  " .. style.bold(name, "green") .. spaces .. module.desc)
    end

    

    return
end

return {
    exec = exec,
    desc = "Prints this."
}
