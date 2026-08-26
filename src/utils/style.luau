local process = zune.process

local Style = {}

local RESET = "\27[0m"

local BOLD_COLORS = {
    gray = "\27[1;38;5;246m",
    lightgray = "\27[1;38;5;251m",
    darkred = "\27[1;38;5;124m",
    red = "\27[1;38;5;9m",
    yellow = "\27[1;38;5;11m",
    green = "\27[1;38;5;10m",
    blue = "\27[1;38;5;12m",
    purple = "\27[1;38;5;13m",
    cyan = "\27[1;38;5;14m",
}

local NORMAL_COLORS = {
    gray = "\27[38;5;246m",
    lightgray = "\27[38;5;251m",
    darkred = "\27[38;5;124m",
    red = "\27[38;5;9m",
    yellow = "\27[38;5;11m",
    green = "\27[38;5;10m",
    blue = "\27[38;5;12m",
    purple = "\27[38;5;13m",
    cyan = "\27[38;5;14m",
}

export type COLORS = keyof<typeof(NORMAL_COLORS)>

function Style.normal<T>(msg: T, color: COLORS?)
    return `{NORMAL_COLORS[color] or ""}{msg}{RESET}`
end

function Style.bold<T>(msg: T, color: COLORS?)
    return `{BOLD_COLORS[color] or "\27[1m"}{msg}{RESET}`
end

function Style.normal256<T>(msg: T, colorCode: number)
    return `\27[38;5;{colorCode}m{msg}{RESET}`
end

function Style.bold256<T>(msg: T, colorCode: number)
    return `\27[1;38;5;{colorCode}m{msg}{RESET}`
end

function Style.printB<T>(msg: T, color: COLORS?)
    print(Style.bold(msg, color))
end

function Style.print<T>(msg: T, color: COLORS?)
   print(Style.normal(msg, color))
end

function Style.warn<T>(msg: T)
    print(`mayari {Style.normal("[warn]", "yellow")} {msg}`)
end

function Style.err<T>(msg: T, exitCode: number?)
    print(`mayari {Style.normal("[error]", "red")} {msg}`)
    return process.exit(exitCode or 1)
end

return Style
