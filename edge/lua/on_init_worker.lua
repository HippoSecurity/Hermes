local config = require "lua.module.config"
local http = require "resty.http"
local json = require "cjson"
local summary = require "lua.module.summary"
local status = require "lua.module.status"

local function upload_status( premature )
    -- body
    if premature then return end

    local httpc = http.new()

    local data = {status=status.report()} -- may get from status

    local res, err = httpc:request_uri("http://" .. config.sys_fetch_addr() or "127.0.0.1:80" .. "/api/upload_status", {
            method = "POST",
            body = json.encode({mid=config.sys_fetch_mid(), time=ngx.time(), name=config.sys_fetch_name(), data=data})
        })

    if res.status ~= 200 then
        ngx.log(ngx.WARNING, "get unexpected status code: ", res.status, "err: ", err)
    end

    ngx.timer.at(5, upload_status)
end

if 0 == ngx.worker.id() then   -- first worker
    ngx.timer.at(0, upload_status)
end
