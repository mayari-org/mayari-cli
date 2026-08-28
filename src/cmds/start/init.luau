local style = require("@utils/style")
local collectLuauFiles = require("@utils/RequireResolver/collectLuauFiles")
local resolveFile = require("@utils/RequireResolver/resolveFile")

local process = zune.process
local fs = zune.fs
local toml = zune.serde.toml

local entryDirPath = "./src"
local outDir = "./dist"

local function exec()
    local tomlContent = fs.readFileSync(`{process.cwd()}/mayari.toml`)
    local mayari = toml.decode(tomlContent)

    if not (fs.stat(`{entryDirPath}/main.luau`).kind == "file") then
        style.warn(`Entry file named as "main.luau" is not found at {process.cwd()}/src`)
        return
    end

    for _, filePath in collectLuauFiles(entryDirPath) do
        resolveFile(filePath, outDir)
    end

    local result = process.run(mayari.runtime, { "run", `{outDir}/src/main` }, {
        stderr = "inherit",
        stdin = "inherit",
        stdout = "inherit"
    })

    if not result.ok then
        style.err(result.stderr, result.code)
        return
    else
        print(result.stdout)
    end
end

return {
    exec = exec,
    desc = "Start the mayari backend."
}
