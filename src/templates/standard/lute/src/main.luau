local Mayari = require('mayari')
local process = require('@lute/process')

local PORT = process.env.PORT or 8080
local app = Mayari.new(PORT :: number)

app:listen(function()
    print(`Mayari is running on Port {PORT}`)
end)
