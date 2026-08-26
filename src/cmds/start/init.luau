local style = require("@utils/style")
local collectLuauFiles = require("@utils/RequireResolver/collectLuauFiles")
local resolveFile = require("@utils/RequireResolver/resolveFile")

local process = zune.process
local fs = zune.fs
local toml = zune.serde.toml

local entryDirPath = "./src"
local outDir = "./dist"
local tomlContent = fs.readFileSync(`{process.cwd()}/mayari.toml`)
local mayari = toml.decode(tomlContent)

local function exec()
    -- if mayari.runtime ~= "lute" 
    -- or mayari.runtime ~= "lune"
    -- or mayari.runtime ~= "zune" then
    --     print(mayari.runtime)
    --     style.err('The listed runtime on your "mayari.toml" is not supported')
    --     return
    -- end

    if not (fs.stat(`{entryDirPath}/main.luau`).kind == "file") then
        style.warn(`Entry file named as "main.luau" is not found at {process.cwd()}/src`)
        return
    end

    style.print("Resolving Luau Files!", "yellow")
    for _, filePath in collectLuauFiles(entryDirPath) do
        local resolved = resolveFile(filePath, outDir)
        print(filePath .. " -> " .. style.normal(resolved, "green"))
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
