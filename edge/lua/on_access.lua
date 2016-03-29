-- -*- coding: utf-8 -*-
-- -- @Date    : 2016-03-28 15:40
-- -- @Author  : Aifei (aifei@openresty.org)
-- -- @Link    : 
-- -- @Disc    : record nginx infomation 

local matcher = require "lua.module.matcher"
local sregex  = require "lua.module.sregex"
local fetcher = require "lua.module.fetcher"

-- get rules from some cache according to remote ip
local rules = fetcher.get_rules(ngx.var.remote_addr, ngx.var.request_uri) 

matcher:new(sregex.generate(rules)):run()
