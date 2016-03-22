local matcher = require "lua.module.matcher"
local sregex  = require "lua.module.sregex"

-- local rules = get_from_redis(ngx.var.remote_addr) -- get rules from some cache according to remote ip

-- assume rules 
local rules = '[{"act":"url","operate":"≈", "value":"hello","code":"403"}]'

local my_matcher = matcher:new(sregex.generate(rules))
my_matcher:run()


