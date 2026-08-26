local style = require("@utils/style")

local function exec(cmds: { [string]: { exec: (...any) -> (), desc: string } },  _args: { string? })

    print(style.bold("Mayari CLI", "black") .. " - CLI tool for Mayari projects\n")
    print(style.bold("Usage: mayari <command> [...args]\n"))
    print(style.bold("Commands:"))

    local max_length = 0
    for name, _  in cmds do
        if #name > max_length then
            max_length = #name
        end
    end

    local extra_padding = 4 

    for i, v in cmds do
        local padding_needed = max_length - #i + extra_padding
        local spaces = string.rep(" ", padding_needed)
        print("  " .. style.bold(i, "green") .. spaces .. v.desc)
    end

    return
end

return {
    exec = exec,
    desc = "Prints this."
}
