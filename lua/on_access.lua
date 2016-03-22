local matcher = require "lua.module.matcher"
local sregex  = require "lua.module.sregex"

-- local rules = get_from_redis(ngx.var.remote_addr) -- get rules from some cache according to remote ip

-- assume rules 
local rules = [=[
    [
        {"act":"url","operate":"!≈", "value":"test","code":"403"},
        {"act":"url","operate":"≈", "value":"test1","code":"403"}
    ]
]=]

matcher:new(sregex.generate(rules)):run()

