-- Unit tests for libexec/lib/amqp.lua (run by tests/unit/amqp). Expected bytes are computed by hand from the
-- AMQP 0-9-1 specification (frame = type, channel, size, payload, 0xCE; method payload = class, method, arguments).
package.path = "libexec/lib/?.lua;" .. package.path
local amqp = require("amqp")
local failures = 0
local function fail(msg) io.stderr:write("FAIL ", msg, "\n"); failures = failures + 1 end

-- "01 00 0a" -> bytes; whitespace ignored, 'text' in quotes inserted literally.
local function hex(s)
	local out = {}
	local i = 1
	while i <= #s do
		local c = s:sub(i, i)
		if c == "'" then
			local j = s:find("'", i + 1, true)
			out[#out + 1] = s:sub(i + 1, j - 1); i = j + 1
		elseif c:match("%x") then
			out[#out + 1] = string.char(tonumber(s:sub(i, i + 1), 16)); i = i + 2
		else i = i + 1 end
	end
	return table.concat(out)
end
local function tohex(b) return (b:gsub(".", function(c) return string.format("%02x ", c:byte()) end)) end
local function eq_bytes(name, got, want)
	if got ~= want then fail(name .. ":\n  got  " .. tohex(got or "") .. "\n  want " .. tohex(want)) end
end
local function eq(name, got, want)
	if got ~= want then fail(string.format("%s: got %s, want %s", name, tostring(got), tostring(want))) end
end

-- Encoders -----------------------------------------------------------------------------------------------------
eq_bytes("protocol header", amqp.PROTOCOL_HEADER, hex("'AMQP' 00 00 09 01"))
eq_bytes("tune-ok", amqp.tune_ok(0, 131072, 0), hex("01 0000 0000000c 000a 001f 0000 00020000 0000 ce"))
eq_bytes("connection.open /", amqp.connection_open("/"), hex("01 0000 00000008 000a 0028 01 '/' 00 00 ce"))
eq_bytes("channel.open 1", amqp.channel_open(1), hex("01 0001 00000005 0014 000a 00 ce"))
eq_bytes("queue.declare exclusive auto-delete", amqp.queue_declare(1, "gm.bridge.x", { exclusive = true, auto_delete = true }),
	hex("01 0001 00000017 0032 000a 0000 0b 'gm.bridge.x' 0c 00000000 ce"))
eq_bytes("queue.bind", amqp.queue_bind(1, "q", "chat.intercept", "#"),
	hex("01 0001 0000001e 0032 0014 0000 01 'q' 0e 'chat.intercept' 01 '#' 00 00000000 ce"))
eq_bytes("basic.consume no-ack", amqp.basic_consume(1, "q", "t", { no_ack = true }),
	hex("01 0001 0000000f 003c 0014 0000 01 'q' 01 't' 02 00000000 ce"))
eq_bytes("connection.close-ok", amqp.connection_close_ok(), hex("01 0000 00000004 000a 0033 ce"))
eq_bytes("connection.close", amqp.connection_close(200, "bye"),
	hex("01 0000 0000000e 000a 0032 00c8 03 'bye' 0000 0000 ce"))
-- StartOk: client properties {product = "b"} (table: key shortstr, 'S', longstr), PLAIN response \0user\0pass.
eq_bytes("start-ok PLAIN", amqp.start_ok({ product = "b" }, "u", "p"),
	hex("01 0000 0000002a 000a 000b 0000000e 07 'product' 'S' 00000001 'b' 05 'PLAIN' 00000004 00 'u' 00 'p' 05 'en_US' ce"))

-- Nested tables: RabbitMQ answers a failed login with Connection.Close only when the client advertises the
-- authentication_failure_close capability; otherwise it just drops the socket.
eq_bytes("nested table", amqp.encode_table({ capabilities = { a = true } }),
	hex("00000016 0c 'capabilities' 'F' 00000004 01 'a' 't' 01"))

-- Frame parsing ------------------------------------------------------------------------------------------------
do
	local buf = hex("01 0000 0000000c 000a 001e 07ff 00020000 003c ce 08 00")
	local f, nextpos = amqp.parse_frame(buf, 1)
	eq("frame type", f and f.type, 1); eq("frame channel", f and f.channel, 0); eq("next pos", nextpos, 21)
	local m = amqp.decode_method(f.payload)
	eq("tune name", m.name, "connection.tune"); eq("tune channel_max", m.channel_max, 2047)
	eq("tune frame_max", m.frame_max, 131072); eq("tune heartbeat", m.heartbeat, 60)
	eq("incomplete frame", (amqp.parse_frame(buf, nextpos)), nil)
	local ok, err = pcall(amqp.parse_frame, hex("01 0000 00000000 00"), 1)
	eq("bad frame end rejected", ok, false)
	if ok then fail("bad frame end accepted") elseif not tostring(err):find("frame end") then fail("bad frame end error: " .. tostring(err)) end
end

-- Delivery: Basic.Deliver + content header (content_type, headers table, user_id) + body split over two frames.
local deliver = hex("01 0001 00000024 003c 003c 03 'ctg' 0000000000000007 00 0e 'chat.intercept' 03 'A#1' ce")
local header = hex("02 0001 00000030 003c 0000 000000000000000a a010 04 'json' 00000008 01 'k' 'S' 00000001 'v' 10 'ABCDEF0123456789' ce")
local body1 = hex("03 0001 00000006 'hello ' ce")
local body2 = hex("03 0001 00000004 'wrld' ce")
do
	local m = amqp.decode_method(assert(amqp.parse_frame(deliver, 1)).payload)
	eq("deliver name", m.name, "basic.deliver"); eq("consumer tag", m.consumer_tag, "ctg"); eq("delivery tag", m.delivery_tag, 7)
	eq("exchange", m.exchange, "chat.intercept"); eq("routing key", m.routing_key, "A#1"); eq("redelivered", m.redelivered, false)
	local h = amqp.decode_header(assert(amqp.parse_frame(header, 1)).payload)
	eq("body size", h.body_size, 10); eq("content type", h.properties.content_type, "json")
	eq("header table", h.properties.headers and h.properties.headers.k, "v"); eq("user_id", h.properties.user_id, "ABCDEF0123456789")
	eq("absent property", h.properties.app_id, nil)
end
do
	local a = amqp.assembler()
	local out = {}
	for _, fr in ipairs({ deliver, header, body1, body2 }) do
		local d = a:push(assert(amqp.parse_frame(fr, 1)))
		if d then out[#out + 1] = d end
	end
	eq("one delivery assembled", #out, 1)
	if out[1] then
		eq("assembled body", out[1].body, "hello wrld"); eq("assembled user_id", out[1].properties.user_id, "ABCDEF0123456789")
		eq("assembled routing key", out[1].routing_key, "A#1")
	end
	-- Empty body: complete on the header.
	local empty = hex("02 0001 0000000e 003c 0000 0000000000000000 0000 ce")
	a:push(assert(amqp.parse_frame(deliver, 1)))
	local d = a:push(assert(amqp.parse_frame(empty, 1)))
	eq("empty body delivery", d and d.body, "")
	eq("no user_id when absent", d and d.properties.user_id, nil)
end

-- Tables: every field type RabbitMQ sends in Connection.Start server properties.
do
	local t = amqp.decode_table(hex("0000002a 01 'a' 't' 01 01 'b' 'b' ff 01 'c' 's' fffe 01 'd' 'I' 00000005 01 'e' 'l' 0000000000000009 01 'f' 'F' 00000000 01 'g' 't' 00"), 1)
	eq("bool", t.a, true); eq("signed byte", t.b, -1); eq("signed short", t.c, -2); eq("int", t.d, 5); eq("long", t.e, 9)
	eq("nested table", type(t.f), "table"); eq("false", t.g, false)
end

-- Client handshake over a scripted transport: what the client sends, in order, for what the server says.
do
	local start = hex("01 0000 0000001c 000a 000a 00 09 00000000 00000005 'PLAIN' 00000005 'en_US' ce")
	local tune = hex("01 0000 0000000c 000a 001e 07ff 00020000 003c ce")
	local open_ok = hex("01 0000 00000005 000a 0029 00 ce")
	local ch_ok = hex("01 0001 00000008 0014 000b 00000000 ce")
	local inbound = start .. tune .. open_ok .. ch_ok
	local pos, sent = 1, {}
	local transport = {
		send = function(_, b) sent[#sent + 1] = b; return true end,
		recv = function(_, n)
			if pos > #inbound then return nil, "closed" end
			local s = inbound:sub(pos, pos + n - 1); pos = pos + n; return s
		end,
	}
	local conn, err = amqp.handshake(transport, { user = "u", password = "p", vhost = "/", product = "b" })
	if not conn then fail("handshake: " .. tostring(err)) else
		local got = table.concat(sent)
		local props = { product = "b", capabilities = { authentication_failure_close = true } }
		local want = amqp.PROTOCOL_HEADER .. amqp.start_ok(props, "u", "p") .. amqp.tune_ok(2047, 131072, 0)
			.. amqp.connection_open("/") .. amqp.channel_open(1)
		eq_bytes("handshake bytes", got, want)
	end
	-- A server that refuses (Connection.Close 403 in place of Tune) is reported, with its reply text.
	inbound = start .. hex("01 0000 00000019 000a 0032 0193 0e 'ACCESS_REFUSED' 0000 0000 ce")
	pos, sent = 1, {}
	conn, err = amqp.handshake(transport, { user = "u", password = "bad", vhost = "/" })
	eq("refused handshake", conn, nil)
	if not tostring(err):find("ACCESS_REFUSED", 1, true) then fail("refusal not reported: " .. tostring(err)) end
end

os.exit(failures == 0 and 0 or 1)
