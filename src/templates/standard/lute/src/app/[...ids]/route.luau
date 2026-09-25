local common = require("common")

local response = common.response

local Home = {}

type Params = { 
    ids: { string } 
}

function Home.Get(req: IRequest<Params>)
    local userIds = req.params.ids
    return response.json({ userIds = userIds, msg = 'Found user IDs' })
end

return Home
