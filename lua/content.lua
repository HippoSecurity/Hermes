local redis = require "resty.redis"

local mid = ngx.var.arg_mid

local red = redis:new()

local ok, err = red:connect("127.0.0.1", 1234)

if not ok then
    ngx.log(ngx.ERR, "faile connect! err = ", err)
    return
end

red:set_timeout(100)

local data, err = reg:get(mid)

if data then
    ngx.say("hit")
end
