
local matcher = require "lua.module.matcher"
local sregex  = require "lua.module.sregex"

local rules = get_from_redis(ngx.var.remote_addr) -- get rules from some cache according to remote ip

local my_matcher = matcher:new(sregex.generate(rules))

my_matcher.run()

