-- TCP transport for libexec/lib/amqp.lua over LuaSocket (pinned in flake.nix): connect(host, port, timeout) returns
-- {send, recv, settimeout, close} with recv(n) delivering exactly n bytes or nil, err ("closed", "timeout", ...).
local socket = require("socket")
local M = {}

function M.connect(host, port, timeout)
	local s = socket.tcp()
	s:settimeout(timeout)
	local ok, err = s:connect(host, port)
	if not ok then s:close(); return nil, string.format("%s:%s: %s", host, port, err) end
	s:setoption("tcp-nodelay", true)
	return {
		send = function(_, bytes)
			local i, e = s:send(bytes)
			if not i then return nil, e end
			return true
		end,
		recv = function(_, n)
			local data, e = s:receive(n)
			if not data then return nil, e end
			return data
		end,
		settimeout = function(_, t) s:settimeout(t) end,
		close = function() s:close() end,
	}
end

return M
