local common = require("common")
local response = common.response

local Home = {}

function Home.Get()
    return response.json({ msg = 'Hello, Mayari' })
end

return Home
