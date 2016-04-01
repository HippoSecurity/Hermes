-- -*- coding: utf-8 -*-
-- -- @Date    : 2016-03-28 15:40
-- -- @Author  : Aifei (aifei@openresty.org)
-- -- @Link    : 
-- -- @Disc    : record nginx infomation 

local json = require "cjson"

local _M = {}


local function merge_table( to, from )
    -- body
    if not from and not to then return {} end

    for index, value in pairs(from) do
        table.insert(to, value)
    end

    return to
end


local function split_no_pat(s, delim, max_lines)
    if type(delim) ~= "string" or string.len(delim) <= 0 then
        return {}
    end

    if nil == max_lines or max_lines < 1 then
        max_lines = 0
    end

    local count = 0
    local start = 1
    local t = {}
    while true do
        local pos = s:find(delim, start, true) -- plain find
        if not pos then
          break
        end

        table.insert (t, s:sub(start, pos - 1))
        start = pos + string.len (delim)
        count = count + 1
        print(count, max_lines)
        if max_lines > 0 and count >= max_lines then
            break
        end
    end

    if max_lines > 0 and count >= max_lines then
    else
        table.insert (t, s:sub(start))
    end

    return t
end


local function save()
    -- body
    local path = ngx.config.prefix() .. "conf/rules"
    
    local rules_cache = ngx.shared.c_rules

    local keys = rules_cache:get_keys()

    local tmp = {}

    for _, key in pairs(keys) do
        local rules = rules_cache:get(key)

        if rules then
            tmp[key] = json.decode(rules_cache:get(key))
        end
    end

    local data = json.encode(tmp)

    local fd, err = io.open(path, 'w+')

    if fd then
        fd:write(data)
        fd:close()
    else
        return ngx.log(ngx.ERR, "write config file err: ", err)
    end
end


-- 这部分可能有序列化和反序列化灾难 记录在这里 后面用lrucache优化
function _M.init()
    -- fetch from storage first, like local file
    local rules_cache = ngx.shared.c_rules

    local path = ngx.config.prefix() .. "conf/rules"

    local fd, err = io.open(path, 'r')
    local data = nil

    if fd then
        data = fd:read("*all")
        fd:close()
    else
        return ngx.log(ngx.ERR, "open config file err: ", err)
    end

    local rules = json.decode(data)

    for key, value in pairs(rules) do 
        rules_cache:set(key, json.encode(value))
    end

end


function _M.fetch()
    --body
    local mid = ngx.var.arg_mid

    if not mid then return ngx.exit(400) end

    local result = {}
    local rules_cache = ngx.shared.c_rules

    -- policy on specified edge-server
    local rules_accord_mid = rules_cache:get(mid)

    if rules_accord_mid then   
        merge_table(result, json.decode(rules_accord_mid))
    end

    -- policy on all edge-servers
    local rules_accord_default = rules_cache:get("all")

    if rules_accord_default then
        merge_table(result, json.decode(rules_accord_default))
    end

    ngx.say(json.encode(result))

end


function _M.add()
    -- body  
    local mid = ngx.var.arg_mid

    if not mid then return ngx.exit(400) end

    local rules_cache = ngx.shared.c_rules

    ngx.req.read_body()

    local cur_rules, flag = rules_cache:get(mid)

    local tmp = {}

    if cur_rules then
        tmp = json.decode(cur_rules)
    end

    table.insert(tmp, json.decode(ngx.var.request_body))

    rules_cache:set(mid, json.encode(tmp))

    save()

end

return _M


