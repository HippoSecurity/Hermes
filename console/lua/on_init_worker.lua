local config = reuiqre "lua.module.config"
local http = require "resty.http"


local function upload( premature, addr )
    -- body
    if premature then
        return
    end

    local uri = "http://" .. addr
    local httpc = http.new()

    local res, err = httpc:request_uri(uri .. "/api/upload_info.json", {
            method = "POST",
            body = common.json_encode({mid=mid, name=name, data={}})
        })

    if res.status ~= 200 then
        ngx.log(ngx.WARNING, "get unexpected status code: ", res.status, "err: ", err)
    end

    ngx.timer.at(60, upload, addr)
end

if 0 == ngx.worker.id() then   -- first worker
    local addr = 
    ngx.timer.at(0, upload, addr)
end
