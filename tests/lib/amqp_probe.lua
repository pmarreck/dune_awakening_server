-- AMQP probe for integration tests, through libexec/lib/amqp.lua over TCP.
-- luajit tests/lib/amqp_probe.lua PORT USER PASSWORD_FILE declare QUEUE
--   prints "ok" or the broker's refusal
-- luajit tests/lib/amqp_probe.lua PORT USER PASSWORD_FILE bind QUEUE EXCHANGE KEY
-- luajit tests/lib/amqp_probe.lua PORT USER PASSWORD_FILE consume EXCHANGE KEY N READYFILE
--   binds a fresh gm.bridge.probe queue, touches READYFILE, then prints N deliveries as "routing_key|user_id|body"
package.path = "libexec/lib/?.lua;" .. package.path
local amqp, tcp = require("amqp"), require("amqp_tcp")
local port, user, pwfile, action = tonumber(arg[1]), arg[2], arg[3], arg[4]
local f = assert(io.open(pwfile)); local password = f:read("*l"); f:close()
local t, err = tcp.connect("127.0.0.1", port, 10)
if not t then print("connect: " .. err); os.exit(1) end
local conn; conn, err = amqp.handshake(t, { user = user, password = password, product = "amqp-probe" })
if not conn then print(err); os.exit(1) end
local function check(ok, e) if not ok then print(e); os.exit(1) end end
if action == "declare" then
	check(conn:declare_queue(arg[5], { exclusive = true, auto_delete = true }))
	print("ok")
elseif action == "bind" then
	check(conn:declare_queue(arg[5], { exclusive = true, auto_delete = true }))
	check(conn:bind_queue(arg[5], arg[6], arg[7]))
	print("ok")
elseif action == "consume" then
	local q = "gm.bridge.probe"
	check(conn:declare_queue(q, { exclusive = true, auto_delete = true }))
	check(conn:bind_queue(q, arg[5], arg[6]))
	check(conn:consume(q, "probe", { no_ack = true, exclusive = true }))
	local rf = assert(io.open(arg[8], "w")); rf:close()
	t:settimeout(30)
	for _ = 1, tonumber(arg[7]) do
		local d; d, err = conn:next_delivery()
		if not d then print(err); os.exit(1) end
		print(d.routing_key .. "|" .. tostring(d.properties.user_id) .. "|" .. d.body)
		io.stdout:flush()
	end
end
conn:close()
t:close()
