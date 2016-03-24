local http = require "resty.http"
local httpc = http.new()

local url = 'http://www.xueqiu.com/'--ngx.var.scheme .. "://" .. "xueqiu.com" .. ngx.var.request_uri
local res, err = httpc:request_uri(url,{
    headers = {
        ["Accept"] = "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
        ["Accept-Language"] = "zh-CN,zh;q=0.8,en;q=0.6",
        ["Host"] = "xueqiu.com",
        ["User-Agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.109 Safari/537.36",
    }
})

if not err and res and res.status == ngx.HTTP_OK then
    local response = res.body
    local from, n, err = ngx.re.find(res.body, [[input type="text"]])
    if from then
        local newstr, n, err = ngx.re.gsub(res.body, '"password"', '"#ksajDSmL"')
        if newstr then
            response = newstr
        end
    end
    ngx.say(response)
else
    ngx.exit(res.status)
end
