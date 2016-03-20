
local loader = require "resty.loader"

local ip  = loader.load("lua.ip_rule")
local url = loader.load("lua.url_rule")

ip.run()

url.run()

