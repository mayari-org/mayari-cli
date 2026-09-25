local common = require("common")

local response = common.response

local Home = {}

type ReqParam = { 
    params: { id: string }
}

function Home.Get(req: IRequest<ReqParam>)
    local userId = req.params.id
    return response.json({ userId = userId, msg = 'Found a user ID' })
end

return Home
