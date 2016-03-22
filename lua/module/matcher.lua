
local ok, new_tab = pcall(require, "table.new")
if not ok then
    new_tab = function (narr, nrec) return {} end
end

local _M = new_tab(0, 4)
_M._VERSION = '0.10'

local mt = { __index = _M }

function _M.new( self, rules )
    -- body
    -- may get an rules list from params
    return setmetatable({ rules = rules }, mt)
end

_M.matcher = {}

--test_var is a basic test method, used by other test method 
local function test_var( condition, var )

   local operator = condition['operate']
   local value =  condition['value']
   
   if operator == "=" then
        if var == value then
            return true
        end
    elseif operator == "!=" then
        if var ~= value then
            return true
        end
    elseif operator == '≈' then
        if var ~= nil and ngx.re.find( var, value, 'isjo' ) ~= nil then
            return true
        end
    elseif operator == '!≈' then
        if var == nil or ngx.re.find( var, value, 'isjo' ) == nil then
            return true
        end
    elseif operator == '!' then
        if var == nil then
            return true
        end
    end

    return false
end


_M.matcher['url'] = function ( condition )
    local uri = ngx.var.uri;
    return test_var( condition, uri )
end

_M.matcher["ip"] = function ( condition )
    local remote_addr = ngx.var.remote_addr
    return test_var( condition, remote_addr )
end

_M.matcher["ua"] = function ( condition )
    local http_user_agent = ngx.var.http_user_agent;
    return test_var( condition, http_user_agent )
end

_M.matcher["refer"] = function ( condition )
    local http_referer = ngx.var.http_referer;
    return test_var( condition, http_referer )
end

--uncompleted
-- function _M.test_args( condition )
    
--     local target_arg_re = condition['name']
--     local find = ngx.find
--     local test_var = _M.test_var
    

--     --handle args behind uri
--     for k,v in pairs( ngx.req.get_uri_args()) do
--         if type(v) == "table" then
--             for arg_idx,arg_value in ipairs(v) do
--                 if target_arg_re == nil or find( k, target_arg_re ) ~= nil then
--                     if test_var( condition, arg_value ) == true then
--                         return true
--                     end
--                 end
--             end
--         elseif type(v) == "string" then
--             if target_arg_re == nil or find( k, target_arg_re ) ~= nil then
--                 if test_var( condition, v ) == true then
--                     return true
--                 end
--             end
--         end
--     end
    
    
--     ngx.req.read_body()
--     --ensure body has not be cached into temp file
--     if ngx.req.get_body_file() ~= nil then
--         return false
--     end
    
--     local body_args,err = ngx.req.get_post_args()
--     if body_args == nil then
--         ngx.say("failed to get post args: ", err)
--         return false
--     end
    
--     --check args in body
--     for k,v in pairs( body_args ) do
--         if type(v) == "table" then
--             for arg_idx,arg_value in ipairs(v) do
--                 if target_arg_re == nil or find( k, target_arg_re ) ~= nil then
--                     if test_var( condition, arg_value ) == true then
--                         return true
--                     end
--                 end
--             end
--         elseif type(v) == "string" then
--             if target_arg_re == nil or find( k, target_arg_re ) ~= nil then
--                 if test_var( condition, v ) == true then
--                     return true
--                 end
--             end
--         end
--     end

--     return false
-- end

_M.matcher["host"] = function ( condition )
    local hostname = ngx.var.host
    return test_var( condition, hostname )
end

-- rules = {
--     url   = {
--         {operate="≈", values = {}, action = "block", code = "403"},
--         {operate="=", values = {}, action = "accept"}
--     }
--     agent = {operate="≈", value={}, action = "block", code = "403"}
-- }

function _M.run( self )
    -- body
    -- do match job according to rules list which comes from params
    local rules = self.rules

    local matcher = _M.matcher

    return rules

end

function _M.version( self )
    -- body
    return self._VERSION
end

return _M