local createEnum = require("./create.enum")
local style = require("@utils/style")
local finishPrompt = require("@utils/finish-prompt")
local prompt = require("@utils/prompt")
local tomlPatch = require("@utils/tomlpatch")

local fs = zune.fs
local process = zune.process

local SETUP_COMMANDS: { [string]: { { string | { string } } } } = {
    [createEnum.Runtimes.LUTE] = {
        { "lute", { "setup", "--with-luaurc" } },
    },
    [createEnum.Runtimes.LUNE] = {
        { "lune", { "setup" } },
    },
    [createEnum.Runtimes.LUAU] = {
        { "lute", { "setup", "--with-luaurc" } },
        { "lune", { "setup" } },
    },
}

local function generateProject(filePaths: { string }, projectPath: string, subNum: number)
    local projectName = ""
    local dirname: { string } = {}
    local extraLines = 0

    if subNum == 24 then
        extraLines = 1
    elseif subNum == 16 then
        local ispatternRight = false
        repeat
            extraLines += 2
            projectName = prompt("Enter project name: ", style.normal('[Scoped as "scope/name"; letters and numbers only]', "gray"))

            if not projectName:match("^[a-z0-9_-]+/[a-z0-9_-]+$") then
                extraLines += 2
                style.print(`"{projectName}" does not match the pattern "scope/name"\n`, "red")
            else
                ispatternRight = true
            end
        until ispatternRight
    end

    for _, filePath in filePaths do
        local fileDir = fs.path.dirname(filePath)

        if not fileDir then
            return
        end

        table.insert(dirname, fileDir:sub(subNum))
    end

    for _, dirPath in dirname do
        fs.makeDir(`{projectPath}{dirPath}`, true)
    end

    for _, filePath in filePaths do
        local fileBufferContent = fs.embedFile(`../../{filePath}`)
        
        if subNum == 16 and filePath == "templates/bare/ember.toml" then
            local source = buffer.tostring(fileBufferContent)
            local updatedSource = tomlPatch.set(source, { "package", "name" }, projectName)
            fileBufferContent = buffer.fromstring(updatedSource)
        end
        fs.writeFile(`{projectPath}{filePath:sub(subNum)}`, fileBufferContent)
    end

    finishPrompt.success("Generated a new Mayari project!\n", nil, extraLines)

    local processResult = process.run("embr", { "i" }, { 
        stdin = "inherit",
        stdout = "inherit",
        stderr = "inherit"
    })

    if not processResult.ok then
        print(processResult.stderr)
        process.exit(processResult.code)
    end
end

local function runSetup(program: string, args: { string })
    local processResult = process.run(program, args, { stderr = "inherit" })

    if not processResult.ok then
        print(processResult.stderr)
        process.exit(processResult.code)
    end
end

local function generateTypeDefRc(runtime: createEnum.Runtimes)
    local commands = SETUP_COMMANDS[runtime:upper()]
    if not commands then
        return
    end

    for _, command in commands do
        runSetup(command[1] :: string, command[2] :: { string })
    end
end

local function createStandard(projectPath: string, runtime: createEnum.Runtimes)
    local standardFiles: { string } = {}
    local standardTemplate = `src/templates/standard/{runtime}`
    local standardMainTemplate = `src/templates/standard/main`

    for _, filePath in fs.embeddedFiles() do
        if filePath:sub(1, #standardTemplate) == standardTemplate 
        or filePath:sub(1, #standardMainTemplate) == standardMainTemplate then
            table.insert(standardFiles, filePath:sub(5))
        end
    end

    if #standardFiles == 0 then
        style.err("standardFiles table do not have any values")
        return
    end

    generateProject(standardFiles, projectPath, 24)

    generateTypeDefRc(runtime)

    style.printB("\nRun:", "green")
    style.print("embr start\n")
    style.printB("Or for development mode:", "green")
    style.print("embr run dev\n")
end

local function createBare(projectPath: string, runtime: createEnum.Runtimes)
    local bareFiles: { string } = {}
    local bareTemplate = "src/templates/bare"

    for _, filePath in fs.embeddedFiles() do
        if filePath:sub(1, #bareTemplate) == bareTemplate then
            table.insert(bareFiles, filePath:sub(5))
        end
    end

    if #bareFiles == 0 then
        style.err("bareFiles table do not have any values")
        return
    end

    generateProject(bareFiles, projectPath, 16)

    generateTypeDefRc(runtime)

    style.printB("\nRun:", "green")
    style.print("embr start\n")
end

local function createProject(projectPath: string, projectType: createEnum.Projects, runtime: createEnum.Runtimes)
    if projectType == createEnum.Projects.STANDARD then
        createStandard(projectPath, runtime)
    else
        createBare(projectPath, runtime)
    end
end

return createProject
