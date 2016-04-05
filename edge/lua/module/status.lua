-- -*- coding: utf-8 -*-
-- -- @Date    : 2015-01-27 05:56
-- -- @Author  : Alexa (AlexaZhou@163.com)
-- -- @Link    : 
-- -- @Disc    : record nginx infomation 

local json = require "cjson"

local _M = {}

local KEY_STATUS_INIT = "I_"

local KEY_START_TIME = "G_"

local KEY_TOTAL_COUNT = "F_"
local KEY_TOTAL_COUNT_SUCCESS = "H_"

local KEY_TRAFFIC_READ = "J_"
local KEY_TRAFFIC_WRITE = "K_"

local KEY_TIME_TOTAL = "L_"


-- maybe optimized, read from redis
function _M.init()

    local shared_status = ngx.shared.status

    local ok, err = shared_status:add( KEY_STATUS_INIT, true )

    if ok then
		shared_status:set( KEY_TOTAL_COUNT, 0 )
		shared_status:set( KEY_TOTAL_COUNT_SUCCESS, 0 )
		
        shared_status:set( KEY_TRAFFIC_READ, 0 )
		shared_status:set( KEY_TRAFFIC_WRITE, 0 )
		
        shared_status:set( KEY_TIME_TOTAL, 0 )
    end

end

--add global count info
function _M.log()
    local shared_status = ngx.shared.status

    shared_status:incr( KEY_TOTAL_COUNT, 1 )

    if tonumber(ngx.var.status) < 400 then
        shared_status:incr( KEY_TOTAL_COUNT_SUCCESS, 1 )
    end

    shared_status:incr( KEY_TRAFFIC_READ, ngx.var.request_length)
    shared_status:incr( KEY_TRAFFIC_WRITE, ngx.var.bytes_sent )
    shared_status:incr( KEY_TIME_TOTAL, ngx.var.request_time )
    ngx.log(ngx.ERR, "are you coming to the tree")
end

function _M.report()
    local shared_status = ngx.shared.status
    local var = ngx.var

    local report = {}
    report['total_cnt'] = shared_status:get( KEY_TOTAL_COUNT )
    report['suc_cnt'] = shared_status:get( KEY_TOTAL_COUNT_SUCCESS )
    report['time'] = ngx.now()
    report['resp_time'] = shared_status:get( KEY_TIME_TOTAL )
    
    report['t_read'] = shared_status:get( KEY_TRAFFIC_READ )
    report['t_write'] = shared_status:get( KEY_TRAFFIC_WRITE )
    return report

end

return _M
