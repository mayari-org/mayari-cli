local style = require("@utils/style")

local function exec(cmds: { [string]: string })
    print(style.bold("Usage: mayari <command> [...args]\n"))
    print(style.bold("Commands:"))

    local max_length = 0
    local modules: { [string]: any } = {}

    -- First pass: find the longest command name and cache modules
    for name, cmd in cmds do
        modules[name] = require(cmd) :: { [string]: any }
        if #name > max_length then
            max_length = #name
        end
    end

    local extra_padding = 4

    -- Second pass: print with consistent alignment
    for name, module in modules do
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
