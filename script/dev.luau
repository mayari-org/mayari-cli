local process = zune.process
local fs = zune.fs
local io = zune.io

local platform = zune.platform

local FILE_NAME = "mayari"

local success, _e = pcall(function()
    return fs.readFileSync(`./{FILE_NAME}`)
end)

if success then
    fs.deleteFile(`./{FILE_NAME}`)
end

local binaryName = ""

if platform.os == "windows" then
    binaryName = `{FILE_NAME}.exe`
else
    binaryName = FILE_NAME
end

local result = process.run("zune", { 
    "bundle",
    "src/index.luau", 
    "src/cmds/**/*.luau",
    "src/utils/**/*.luau",
    "packages/**/*.luau",
    "-f",
    ".luaurc",
    "ember.toml",
    "src/templates/**/*",
    `--out=dist/{binaryName}`,
}, {
    stderr = "inherit",
    stdin = "inherit",
    stdout = "inherit"
})

if not result.ok then
    io.stderr:write(result.stderr and result.stderr or "")
end
