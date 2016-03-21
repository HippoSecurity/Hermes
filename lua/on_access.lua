
-- local matcher = require "lua.module.matcher"
-- local sregex  = require "lua.module.sregex"

-- local rules = get_from_redis(ngx.var.remote_addr) -- get rules from some cache according to remote ip

-- assume rules 
-- local rules = {}

-- local my_matcher = matcher:new(sregex.generate(rules))

-- my_matcher.run()


local rules = [[{
    "url":[
        {"operate":"≈", "values":{}, "action":"block", "code":"403"},
        {"operate":"=", "values" :{}, "action":"accept"}
    ],
    "agent" : [
        {"operate":"≈", "value":{}, "action" : "block", "code" : "403"}
    ]    
}]]

local json = require "cjson"

ngx.say(json.decode(rules))

