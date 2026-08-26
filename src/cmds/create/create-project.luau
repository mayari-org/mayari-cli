local createEnum = require("./create.enum")
local style = require("@utils/style")

local fs = zune.fs

local function generateProject(filePaths: { string }, projectPath: string, subNum: number)
    local dirname: { string } = {}

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
        fs.writeFile(`{projectPath}{filePath:sub(subNum)}`, fileBufferContent)
    end
end

local function createStandard(projectPath: string, runtime: string)
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
end

local function createBare(projectPath: string)
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
end

local function createProject(projectPath: string, projectType: string, runtime: string)
    if projectType == createEnum.Projects.STANDARD then
        createStandard(projectPath, runtime)
    else
        createBare(projectPath)
    end
end

return createProject
