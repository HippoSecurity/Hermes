-- -*- coding: utf-8 -*-
-- -- @Date    : 2016-03-28 15:40
-- -- @Author  : Aifei (aifei@openresty.org)
-- -- @Link    : 
-- -- @Disc    : record nginx infomation 

local summary   = require "lua.module.summary"
local status    = require "lua.module.status"
local accounts  = require "lua.module.accounts"
local dashboard = require "lua.module.dashboard"
local rpm       = require "lua.module.rpm"
local json = require "cjson"

local dd = require "lua.module.dd"

local _M = {}

_M.url_route = {}
_M.mime_type = {}
_M.mime_type['.js'] = "application/x-javascript"
_M.mime_type['.css'] = "text/css"
_M.mime_type['.html'] = "text/html"

function _M.run()
    -- body
    local action = string.lower(ngx.req.get_method().." "..ngx.var.uri)

    local handle = _M.url_route[action]

    if nil ~= handle then
        return handle()
    elseif ngx.re.find(action, "get /dashboard") then
        ngx.log(ngx.ERR, "flag")
        ngx.header.content_type = "application/json"
        ngx.header.charset = "utf-8"

        dashboard:run(action)
    else
        return ngx.exit(404)
    end

end

_M.url_route["post /dashboard/login"] = accounts.login

_M.url_route["get /dashboard/edges"] = status.edges

_M.url_route["get /dashboard/report"] = status.report

_M.url_route["get /dashboard/debug"] = dd.show

_M.url_route["get /dashboard/test"] = accounts.test

-- set rules including add or upgrade
_M.url_route["post /dashboard/add_rules"] = rpm.add

-- support to edge server
_M.url_route["post /dashboard/upload_status"] = status.document

_M.url_route["get /dashboard/fetch_rules"] = rpm.fetch

return _M
