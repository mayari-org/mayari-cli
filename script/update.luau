local tomlPatch = require("@utils/tomlpatch")

local process = zune.process

local templatePath = "./src/templates"
local standardPath = `{templatePath}/standard`

local lpms = {
    zuneLpm = `{standardPath}/zune/ember.toml`,
    luneLpm = `{standardPath}/lune/ember.toml`,
    luteLpm = `{standardPath}/lute/ember.toml`,
    bareLpm = `{templatePath}/bare/ember.toml`
} :: { [string]: string }

local mainLpm = `./ember.toml`

local function updateAll(newVer: string)
    for _, lpmPath in lpms do
        tomlPatch.setToFile(lpmPath, { "tools", "mayari" }, `mayari-org/mayari-cli@{newVer}`)
    end

    tomlPatch.setToFile(mainLpm, { "package", "version" }, newVer)
end

updateAll(process.args[2])
