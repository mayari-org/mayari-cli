local fs = zune.fs
local toml = zune.serde.toml

local function exec()
    local contentBuffer = fs.embedFile("../../../lpm.toml")
    local lpmContent = toml.decode(contentBuffer)

    print(`v{lpmContent.package.version}`)
end

return {
    exec = exec,
    desc = "Prints the current version of Mayari CLI."
}
