local tomlPatch = require("@utils/tomlpatch")

local process = zune.process

local templatePath = "./src/templates"
local standardPath = `{templatePath}/standard`

local lpms = {
    zuneLpm = `{standardPath}/zune/lpm.toml`,
    luneLpm = `{standardPath}/lune/lpm.toml`,
    luteLpm = `{standardPath}/lute/lpm.toml`,
    bareLpm = `{templatePath}/bare/lpm.toml`
} :: { [string]: string }

local mainLpm = `./lpm.toml`

local function updateAll(newVer: string)
    for _, lpmPath in lpms do
        tomlPatch(lpmPath, { "tools", "mayari" }, `mayari-org/mayari-cli@{newVer}`)
    end

    tomlPatch(mainLpm, { "package", "version" }, newVer)
end

updateAll(process.args[2])
