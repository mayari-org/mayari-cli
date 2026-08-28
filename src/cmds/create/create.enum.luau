local CreateEnum = {}

export type Projects = keyof<typeof(CreateEnum.Projects)>
export type Runtimes = keyof<typeof(CreateEnum.Runtimes)>

CreateEnum.Projects = {
    STANDARD = "STANDARD",
    BARE = "BARE",
}

CreateEnum.Runtimes = {
    LUNE = "LUNE",
    ZUNE = "ZUNE", 
    LUTE = "LUTE",
    LUAU = "LUAU",
}

return CreateEnum
