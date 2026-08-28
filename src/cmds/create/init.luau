local select = require("@utils/select")
local style = require("@utils/style")
local createEnum = require("@self/create.enum")
local createProject = require("@self/create-project")

local serde = zune.serde
local process = zune.process
local fs = zune.fs

local toml = serde.toml

local RUNTIMES = createEnum.Runtimes
local PROJECTS = createEnum.Projects

local configTemplate: { [string]: any }?

local function createConfig(projectPath: string)
    if not configTemplate then
        process.exit(1)
        return
    end

    local endocedConfigFile = toml.encode(configTemplate)
    fs.makeDir(projectPath, true)
    fs.writeFileSync(projectPath .. "/mayari.toml", endocedConfigFile)
end

local function exec(args: { string })
    local project = if #args == 0 or args[1] == "." or args[1] == "./" then "" else `{args[1]}/`
    local projectPath = `{process.cwd()}/{project}`
    local configFile = fs.stat(projectPath .. "/mayari.toml")
    
    if configFile.kind == "file" then
        style.warn('a "mayari.toml" file already exist')
        return
    end

    local projectType = select.select("Which project type will you use?", {
        { label = "Standard", value = PROJECTS.STANDARD, hint = "Full-featured scaffold for backend logic and static serving." },
        { label = "Bare", value = PROJECTS.BARE, hint = "Minimal scaffold with core configs and common libraries." },
    }) :: createEnum.Projects

    if projectType == PROJECTS.BARE then
        configTemplate = {
            runtime = RUNTIMES.LUAU:lower()
        }
    else
        local runtime = select.select("Which runtime do you prefer?", {
            { label = "Lute", value = RUNTIMES.LUTE, hint = "The official Luau runtime" },
            { label = "Lune", value = RUNTIMES.LUNE, hint = "Built by the community" },
            { label = "Zune", value = RUNTIMES.ZUNE, hint = "Built by the community" },
        }) :: createEnum.Projects
        
        configTemplate = {
            runtime = runtime:lower()
        }
    end

    createProject(projectPath, projectType, configTemplate.runtime)
    createConfig(projectPath)
end

return {
    exec = exec,  
    desc = "Scaffold a new Mayari project in the current directory"
}
