local common = require('common')
local response = common.response


local Home = {}

function Home.Get(req: common.RequestWith<{ id: string }>)
    local userId = req.params.id
    return response.json({ userId = userId, msg = 'Found a user ID' })
end

return Home
