-- -*- coding: utf-8 -*-
-- -- @Date    : 2016-03-28 15:40
-- -- @Author  : Aifei (aifei@openresty.org)
-- -- @Link    : 
-- -- @Disc    : record nginx infomation 

local json = require "cjson"

local _M = {}

local KEY_EDGE_INFO  = "M_"

local function process_edge_info()
    -- body
    ngx.req.read_body()

    local body = ngx.var.request_body

    local body_json = json.decode(body)

    local edge = { mid = body_json.mid, name = body_json.name, ip = ngx.var.remote_addr }

    return edge, body_json.data
end

--add global count info
function _M.document()
    local edge, data = process_edge_info()
    local shared_edges  = ngx.shared.c_edges
    local shared_status = ngx.shared.c_status

    local status = {
        t_cnt     = data.total_cnt or 0,
        s_cnt     = data.suc_cnt or 0,
        req_len   = data.avg_request_length or 0,
        bytes_sent= data.avg_bytes_sent or 0,
    }

    shared_status:set(edge.mid , json.encode(status))

    shared_edges:set( edge.mid, json.encode(edge), 30)

end

function _M.edges()
    -- body
    local shared_edges = ngx.shared.c_edges

    local edges = shared_edges:get_keys(0)

    local data = {}

    for _, mid in pairs(edges) do 
        data[mid] = json.decode(shared_edges:get(mid))
    end

    ngx.say(json.encode({ ret = 'success', data = data }))
end


function _M.report()
    local mid = ngx.var.arg_mid

    if not mid then
        return ngx.exit(400)
    end

    local shared_status = ngx.shared.c_status

    local report = shared_status:get(mid)
    -- report['request_all_count'] = shared_status:get( KEY_TOTAL_CNT .. mid )
    -- report['request_success_count'] = shared_status:get( KEY_SUCCESS_CNT .. mid)
    -- report['response_time_total'] = shared_status:get( KEY_TIME_TOTAL .. mid)
    
    -- report['traffic_read'] = shared_status:get( KEY_TRAFFIC_READ .. mid)
    -- report['traffic_write'] = shared_status:get( KEY_TRAFFIC_WRITE .. mid)


    ngx.say(report)
end

return _M
