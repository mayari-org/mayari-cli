local alias = require("@utils/alias")

local fs = zune.fs
local process = zune.process

local mayariPath = `{process.cwd()}/packages/luau/mayari`
local originalPath = `{process.cwd()}/packages/luau`

local data = fs.stat(mayariPath)

local mayariPkgList = {
    "core",
    "common",
    "adpt",
    "static"
}

local function moveToMayariDir(mayariFile: string)
    fs.move(`{originalPath}/{mayariFile}`, `{mayariPath}/{mayariFile}`)

    local fileContent = fs.readFileSync(`{mayariPath}/{mayariFile}`)

    fileContent = fileContent:gsub('require%("%./', 'require("../', 1)
    fs.writeFileSync(`{mayariPath}/{mayariFile}`, fileContent)
end


local function exec()
    if not (data.kind == "directory") then
        fs.makeDir(mayariPath)
    end

    for _, pkg in mayariPkgList do
        if fs.stat(`{originalPath}/{pkg}.luau`).kind == "file" then
            moveToMayariDir(`{pkg}.luau`)
        end
    end

    alias.set("mayari", "./packages/luau/mayari")
end

return {
    exec = exec,
    desc = "Sets up the Mayari packages."
}
