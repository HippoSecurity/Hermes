-- -*- coding: utf-8 -*-
-- -- @Date    : 2016-03-28 15:40
-- -- @Author  : Aifei (aifei@openresty.org)
-- -- @Link    : 
-- -- @Disc    : record nginx infomation 

local dkjson = require "lua.module.dkjson"
local json = require "cjson"

local _M = {}

local KEY_ALL = "A_"

local KEY_UNION = "U_"

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

    local data = dkjson.encode(tmp, {indent=true})

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

    -- get rules
    local path = ngx.config.prefix() .. "conf/config"

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

    -- get union
    path = ngx.config.prefix() .. "conf/config"
    data = nil

    fd, err = io.open(path, 'r')

    if fd then
        data = fd:read("*all")
        fd:close()
    else
        return ngx.log(ngx.ERR, "open config file err: ", err)
    end

    if string.len(data) ~= 0 then
        rules_cache:set(KEY_UNION, data)
    end

end


-- 提供给终端获取策略的接口
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
    local rules_accord_default = rules_cache:get(KEY_ALL .. "all")

    if rules_accord_default then
        merge_table(result, json.decode(rules_accord_default))
    end

    ngx.say(json.encode(result))

end

-- 向某个mid 或者 all 添加一条策略
function _M.set()
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

    return ngx.exit(200)
end


-- 为了简单 直接重写
function _M.rewrite()
    -- body  
    local mid = ngx.var.arg_mid

    if not mid then return ngx.exit(400) end

    local rules_cache = ngx.shared.c_rules

    ngx.req.read_body()

    rules_cache:set(mid, ngx.var.request_body)

    save()

    return ngx.exit(200)
end


local function union_save( data )
    -- body
    local path = ngx.config.prefix() .. "conf/union"

    local fd, err = io.open(path, 'w+')

    if fd then
        fd:write(data)
        fd:close()
    else
        return ngx.log(ngx.ERR, "write config file err: ", err)
    end

end


function _M.union_add()
    -- body
    local rules_cache = ngx.shared.c_rules

    ngx.req.read_body()

    local cur_rules, flag = rules_cache:get(KEY_UNION)

    ngx.log(ngx.ERR, cur_rules)

    local tmp = json.decode(cur_rules or "{}")

    table.insert(tmp, json.decode(ngx.var.request_body))

    local union_rules = dkjson.encode(tmp, {indent=true})

    ngx.log(ngx.ERR, union_rules)

    rules_cache:set(KEY_UNION, union_rules)

    union_save(union_rules)

    return ngx.exit(200)
end


function _M.union_rewrite()
    -- body
    local rules_cache = ngx.shared.c_rules

    ngx.req.read_body()

    local tmp = ngx.var.request_body

    rules_cache:set(KEY_UNION, tmp)

    union_save(tmp)

    return ngx.exit(200)
end


function _M.union_fetch()
    -- body
    local rules_cache = ngx.shared.c_rules

    local union_rules, _ = rules_cache:get(KEY_UNION)

    ngx.say(union_rules or '[]') 

end


return _M


