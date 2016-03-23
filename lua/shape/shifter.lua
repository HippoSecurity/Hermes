local http = require "resty.http"
local httpc = http.new()

local url = 'http://www.xueqiu.com'--ngx.var.scheme .. "://" .. "xueqiu.com" .. ngx.var.request_uri
local res, err = httpc:request_uri(url)

if res.status == ngx.HTTP_OK then
    local response = res.body
    local from, n, err = ngx.re.find(res.body, [[input type="text"]])
    if from then
        ngx.log(ngx.ERR, url)
        local newstr, n, err = ngx.re.gsub(res.body, '"password"', '"#ksajDSmL"')
        if newstr then
            response = newstr
        end
    end
    ngx.say(response)
else
    ngx.exit(res.status)
end
