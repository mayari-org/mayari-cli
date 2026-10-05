local collectLuauSpecFiles = require("@utils/collectLuauSpecFiles")
local resolveFile = require("@utils/RequireResolver/resolveFile")

local process = zune.process
local fs = zune.fs
local toml = zune.serde.toml

local entryDirPath = "."
local outDir = "./.mayari/tests"


local excludeDirs = {
    "./node_modules",
    "./.mayari",
    "./src/templates",
    "./.git",
    "./.vscode",
    "./dist",
    "./out",
}

local function exec()
    for _, filePath in collectLuauSpecFiles(entryDirPath, excludeDirs) do
        resolveFile(filePath, outDir)
    end

    local mayariTomlSrc = fs.readFile("./mayari.toml")
    local mayariConfig: { runtime: string } = toml.decode(mayariTomlSrc)

    fs.makeDir(outDir, true)

    local entryPath = `{outDir}/run.luau`
    fs.createFile(entryPath, { truncate = false })
    fs.writeFileSync(entryPath, 'require("../../packages/luau/eval").runTest(".mayari/tests")\n')

    process.run(mayariConfig.runtime, { "run", entryPath }, { 
        stdout = "inherit",
        stdio = "inherit",
        stderr = "inherit",
    })
end

return {
    exec = exec,
    desc = "Executes test files."
}
