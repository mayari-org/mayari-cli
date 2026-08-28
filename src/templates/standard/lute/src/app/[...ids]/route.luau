local common = require("common")
local response = common.response

local Home = {}

function Home.Get(req: common.RequestWith<{ ids: { string } }>)
    local userIds = req.params.ids
    return response.json({ userIds = userIds, msg = 'Found user IDs' })
end

return Home
