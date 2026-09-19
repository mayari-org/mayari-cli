local style = require("@utils/style")
local collectLuauFiles = require("@utils/RequireResolver/collectLuauFiles")
local resolveFile = require("@utils/RequireResolver/resolveFile")

local process = zune.process
local fs = zune.fs

local entryDirPath = "./src"
local outDir = "./.mayari"

local function exec()
    if not (fs.stat(`{entryDirPath}/main.luau`).kind == "file") then
        style.warn(`Entry file named as "main.luau" is not found at {process.cwd()}/src`)
        return
    end

    for _, filePath in collectLuauFiles(entryDirPath) do
        resolveFile(filePath, outDir)
    end

    print("Mayari build complete...\n")
end

return {
    exec = exec,
    desc = "Build the mayari project."
}
