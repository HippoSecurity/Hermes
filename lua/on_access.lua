local matcher = require "lua.module.matcher"
local sregex  = require "lua.module.sregex"
local fetcher = require "lua.module.fetcher"
local router  = require "lua.module.router"

-- get rules from some cache according to remote ip
local rules = fetcher.get_rules(ngx.var.remote_addr, ngx.var.request_uri) 

matcher:new(sregex.generate(rules)):run()

router:run()