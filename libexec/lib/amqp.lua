-- Minimal AMQP 0-9-1 client for the GM bridge: a pure frame codec (encoders for the handful of methods a consumer
-- needs, decoders for frames, methods, content headers and field tables, and an assembler that turns
-- Deliver + header + body frames into messages) plus a handshake/consume driver over an injected transport
-- ({send = fn(self, bytes), recv = fn(self, n) -> exactly n bytes or nil, err}). No I/O happens in this module.
-- Spec: AMQP 0-9-1 (amqp0-9-1.pdf / amqp0-9-1.xml), RabbitMQ's field-table type letters.
local bit = require("bit")
local band, bor, rshift, lshift = bit.band, bit.bor, bit.rshift, bit.lshift
local char, byte = string.char, string.byte

local M = {}
M.PROTOCOL_HEADER = "AMQP\0\0\9\1"
local FRAME_METHOD, FRAME_HEADER, FRAME_BODY, FRAME_HEARTBEAT = 1, 2, 3, 8
local FRAME_END = 0xCE
M.FRAME_METHOD, M.FRAME_HEADER, M.FRAME_BODY, M.FRAME_HEARTBEAT = FRAME_METHOD, FRAME_HEADER, FRAME_BODY, FRAME_HEARTBEAT

-- Encoding ------------------------------------------------------------------------------------------------------

local function u8(n) return char(band(n, 0xff)) end
local function u16(n) return char(band(rshift(n, 8), 0xff), band(n, 0xff)) end
local function u32(n) return char(band(rshift(n, 24), 0xff), band(rshift(n, 16), 0xff), band(rshift(n, 8), 0xff), band(n, 0xff)) end
local function shortstr(s)
	assert(#s <= 255, "shortstr longer than 255 bytes")
	return u8(#s) .. s
end
local function longstr(s) return u32(#s) .. s end

-- Field table with string ('S'), boolean ('t') and nested table ('F') values, keys in sorted order so the bytes are
-- deterministic.
local encode_table
encode_table = function(t)
	local keys = {}
	for k in pairs(t or {}) do keys[#keys + 1] = k end
	table.sort(keys)
	local parts = {}
	for _, k in ipairs(keys) do
		local v = t[k]
		if type(v) == "boolean" then parts[#parts + 1] = shortstr(k) .. "t" .. u8(v and 1 or 0)
		elseif type(v) == "table" then parts[#parts + 1] = shortstr(k) .. "F" .. encode_table(v)
		else parts[#parts + 1] = shortstr(k) .. "S" .. longstr(tostring(v)) end
	end
	local body = table.concat(parts)
	return u32(#body) .. body
end
M.encode_table = encode_table

local function frame(ftype, channel, payload) return u8(ftype) .. u16(channel) .. u32(#payload) .. payload .. char(FRAME_END) end
local function method(channel, class, meth, args) return frame(FRAME_METHOD, channel, u16(class) .. u16(meth) .. (args or "")) end

function M.start_ok(client_properties, user, password)
	return method(0, 10, 11, encode_table(client_properties) .. shortstr("PLAIN") .. longstr("\0" .. user .. "\0" .. password) .. shortstr("en_US"))
end
function M.tune_ok(channel_max, frame_max, heartbeat) return method(0, 10, 31, u16(channel_max) .. u32(frame_max) .. u16(heartbeat)) end
function M.connection_open(vhost) return method(0, 10, 40, shortstr(vhost) .. shortstr("") .. u8(0)) end
function M.connection_close(code, text) return method(0, 10, 50, u16(code) .. shortstr(text) .. u16(0) .. u16(0)) end
function M.connection_close_ok() return method(0, 10, 51) end
function M.channel_open(channel) return method(channel, 20, 10, shortstr("")) end
function M.channel_close_ok(channel) return method(channel, 20, 41) end
function M.queue_declare(channel, queue, o)
	o = o or {}
	local bits = bor(o.passive and 1 or 0, o.durable and 2 or 0, o.exclusive and 4 or 0, o.auto_delete and 8 or 0)
	return method(channel, 50, 10, u16(0) .. shortstr(queue) .. u8(bits) .. encode_table(o.arguments))
end
function M.queue_bind(channel, queue, exchange, routing_key)
	return method(channel, 50, 20, u16(0) .. shortstr(queue) .. shortstr(exchange) .. shortstr(routing_key) .. u8(0) .. encode_table(nil))
end
function M.basic_consume(channel, queue, tag, o)
	o = o or {}
	local bits = bor(o.no_local and 1 or 0, o.no_ack and 2 or 0, o.exclusive and 4 or 0)
	return method(channel, 60, 20, u16(0) .. shortstr(queue) .. shortstr(tag) .. u8(bits) .. encode_table(nil))
end

-- Decoding ------------------------------------------------------------------------------------------------------

-- A cursor over a byte string; each reader returns the value and advances.
local function reader(s, pos)
	local r = { s = s, p = pos or 1 }
	local function need(n) if r.p + n - 1 > #s then error("amqp: truncated field", 0) end end
	function r.u8() need(1); local v = byte(s, r.p); r.p = r.p + 1; return v end
	function r.u16() need(2); local a, b = byte(s, r.p, r.p + 1); r.p = r.p + 2; return a * 256 + b end
	function r.u32() need(4); local a, b, c, d = byte(s, r.p, r.p + 3); r.p = r.p + 4; return ((a * 256 + b) * 256 + c) * 256 + d end
	function r.u64() local hi = r.u32(); return hi * 4294967296 + r.u32() end
	function r.i8() local v = r.u8(); return v >= 128 and v - 256 or v end
	function r.i16() local v = r.u16(); return v >= 32768 and v - 65536 or v end
	function r.i32() local v = r.u32(); return v >= 2147483648 and v - 4294967296 or v end
	function r.i64() local hi = r.i32(); return hi * 4294967296 + r.u32() end
	function r.bytes(n) need(n); local v = s:sub(r.p, r.p + n - 1); r.p = r.p + n; return v end
	function r.shortstr() return r.bytes(r.u8()) end
	function r.longstr() return r.bytes(r.u32()) end
	return r
end

local read_table
-- One field value by its RabbitMQ type letter.
local function read_value(r)
	local t = char(r.u8())
	if t == "t" then return r.u8() ~= 0
	elseif t == "b" then return r.i8() elseif t == "B" then return r.u8()
	elseif t == "s" then return r.i16() elseif t == "u" then return r.u16()
	elseif t == "I" then return r.i32() elseif t == "i" then return r.u32()
	elseif t == "l" then return r.i64() elseif t == "L" then return r.u64()
	elseif t == "f" then r.bytes(4); return 0 elseif t == "d" then r.bytes(8); return 0
	elseif t == "D" then local scale = r.u8(); return r.i32() / 10 ^ scale
	elseif t == "S" or t == "x" then return r.longstr()
	elseif t == "T" then return r.u64()
	elseif t == "F" then return read_table(r)
	elseif t == "A" then
		local stop = r.u32(); stop = r.p + stop
		local a = {}
		while r.p < stop do a[#a + 1] = read_value(r) end
		return a
	elseif t == "V" then return nil
	else error("amqp: unknown field type " .. string.format("%q", t), 0) end
end
read_table = function(r)
	local len = r.u32()
	local stop = r.p + len
	local t = {}
	while r.p < stop do
		local k = r.shortstr()
		t[k] = read_value(r)
	end
	if r.p ~= stop then error("amqp: field table overran its length", 0) end
	return t
end
function M.decode_table(s, pos) return read_table(reader(s, pos)) end

-- parse_frame(buf, pos) -> {type, channel, payload}, next_pos; or nil when buf holds no complete frame yet.
-- Errors on a frame whose end octet is not 0xCE (the stream is then unrecoverable).
function M.parse_frame(buf, pos)
	pos = pos or 1
	if #buf - pos + 1 < 8 then return nil end
	local r = reader(buf, pos)
	local ftype, channel, size = r.u8(), r.u16(), r.u32()
	if #buf - r.p + 1 < size + 1 then return nil end
	local payload = r.bytes(size)
	if r.u8() ~= FRAME_END then error("amqp: bad frame end octet", 0) end
	return { type = ftype, channel = channel, payload = payload }, r.p
end

local METHODS = {
	["10.10"] = { "connection.start", function(r, m)
		m.version_major, m.version_minor = r.u8(), r.u8()
		m.server_properties = read_table(r); m.mechanisms = r.longstr(); m.locales = r.longstr()
	end },
	["10.30"] = { "connection.tune", function(r, m) m.channel_max, m.frame_max, m.heartbeat = r.u16(), r.u32(), r.u16() end },
	["10.41"] = { "connection.open-ok" },
	["10.50"] = { "connection.close", function(r, m) m.reply_code, m.reply_text, m.class_id, m.method_id = r.u16(), r.shortstr(), r.u16(), r.u16() end },
	["10.51"] = { "connection.close-ok" },
	["20.11"] = { "channel.open-ok" },
	["20.40"] = { "channel.close", function(r, m) m.reply_code, m.reply_text, m.class_id, m.method_id = r.u16(), r.shortstr(), r.u16(), r.u16() end },
	["20.41"] = { "channel.close-ok" },
	["50.11"] = { "queue.declare-ok", function(r, m) m.queue, m.message_count, m.consumer_count = r.shortstr(), r.u32(), r.u32() end },
	["50.21"] = { "queue.bind-ok" },
	["60.21"] = { "basic.consume-ok", function(r, m) m.consumer_tag = r.shortstr() end },
	["60.60"] = { "basic.deliver", function(r, m)
		m.consumer_tag, m.delivery_tag, m.redelivered = r.shortstr(), r.u64(), r.u8() ~= 0
		m.exchange, m.routing_key = r.shortstr(), r.shortstr()
	end },
}

-- decode_method(payload) -> {name, class_id, method_id, ...arguments}; unknown methods get name "class.method".
function M.decode_method(payload)
	local r = reader(payload)
	local class, meth = r.u16(), r.u16()
	local key = class .. "." .. meth
	local spec = METHODS[key]
	local m = { name = spec and spec[1] or key, class_id = class, method_id = meth }
	if spec and spec[2] then spec[2](r, m) end
	return m
end

-- Basic content properties, from property-flag bit 15 downwards.
local PROPERTIES = {
	{ "content_type", "shortstr" }, { "content_encoding", "shortstr" }, { "headers", "table" }, { "delivery_mode", "u8" },
	{ "priority", "u8" }, { "correlation_id", "shortstr" }, { "reply_to", "shortstr" }, { "expiration", "shortstr" },
	{ "message_id", "shortstr" }, { "timestamp", "u64" }, { "type", "shortstr" }, { "user_id", "shortstr" },
	{ "app_id", "shortstr" }, { "cluster_id", "shortstr" },
}

-- decode_header(payload) -> {class_id, body_size, properties}
function M.decode_header(payload)
	local r = reader(payload)
	local h = { class_id = r.u16() }
	r.u16() -- weight
	h.body_size = r.u64()
	local flags = r.u16()
	if band(flags, 1) ~= 0 then error("amqp: continued property flags are not supported", 0) end
	h.properties = {}
	for i, p in ipairs(PROPERTIES) do
		if band(flags, lshift(1, 16 - i)) ~= 0 then
			h.properties[p[1]] = p[2] == "table" and read_table(r) or r[p[2]]()
		end
	end
	return h
end

-- assembler(): push(frame) returns a complete delivery {consumer_tag, delivery_tag, redelivered, exchange,
-- routing_key, properties, body} once its Deliver, header and all body frames have arrived; nil otherwise.
-- Other method frames are returned as {method = decoded} so the caller can react (e.g. Connection.Close).
function M.assembler()
	local a = {}
	local pending, parts, have
	function a:push(f)
		if f.type == FRAME_HEARTBEAT then return nil end
		if f.type == FRAME_METHOD then
			local m = M.decode_method(f.payload)
			if m.name ~= "basic.deliver" then return { method = m } end
			pending, parts, have = m, {}, 0
			return nil
		end
		if not pending then error("amqp: content frame without a preceding Basic.Deliver", 0) end
		if f.type == FRAME_HEADER then
			local h = M.decode_header(f.payload)
			pending.properties, pending.body_size = h.properties, h.body_size
		elseif f.type == FRAME_BODY then
			if not pending.properties then error("amqp: body frame before content header", 0) end
			parts[#parts + 1] = f.payload; have = have + #f.payload
		end
		if pending.properties and have >= pending.body_size then
			local d = pending
			d.body = table.concat(parts)
			pending = nil
			return d
		end
		return nil
	end
	return a
end

-- Driver over a transport ---------------------------------------------------------------------------------------

local function read_frame(t)
	local head, err = t:recv(7)
	if not head then return nil, err end
	local size = ((byte(head, 4) * 256 + byte(head, 5)) * 256 + byte(head, 6)) * 256 + byte(head, 7)
	local rest; rest, err = t:recv(size + 1)
	if not rest then return nil, err end
	local ok, f = pcall(M.parse_frame, head .. rest, 1)
	if not ok then return nil, f end
	return f
end

local Conn = {}
Conn.__index = Conn

-- Next method frame on any channel, skipping heartbeats; a server Connection.Close is answered and returned as error.
function Conn:next_method()
	while true do
		local f, err = read_frame(self.t)
		if not f then return nil, "connection lost: " .. tostring(err) end
		if f.type == FRAME_METHOD then
			local m = M.decode_method(f.payload)
			if m.name == "connection.close" then
				self.t:send(M.connection_close_ok())
				return nil, string.format("server closed the connection: %d %s", m.reply_code, m.reply_text)
			end
			if m.name == "channel.close" then
				self.t:send(M.channel_close_ok(f.channel))
				return nil, string.format("server closed the channel: %d %s", m.reply_code, m.reply_text)
			end
			return m
		elseif f.type ~= FRAME_HEARTBEAT then
			return nil, "unexpected content frame"
		end
	end
end

function Conn:rpc(bytes, want)
	local ok, err = self.t:send(bytes)
	if not ok then return nil, "send failed: " .. tostring(err) end
	local m; m, err = self:next_method()
	if not m then return nil, err end
	if m.name ~= want then return nil, "expected " .. want .. ", got " .. m.name end
	return m
end

function Conn:declare_queue(queue, opts)
	local m, err = self:rpc(M.queue_declare(self.channel, queue, opts), "queue.declare-ok")
	return m and m.queue, err
end
function Conn:bind_queue(queue, exchange, key) return self:rpc(M.queue_bind(self.channel, queue, exchange, key), "queue.bind-ok") end
function Conn:consume(queue, tag, opts)
	self.assembler = M.assembler()
	return self:rpc(M.basic_consume(self.channel, queue, tag, opts), "basic.consume-ok")
end

-- Block until the next complete delivery; nil, err when the connection ends.
function Conn:next_delivery()
	while true do
		local f, err = read_frame(self.t)
		if not f then return nil, "connection lost: " .. tostring(err) end
		local ok, d = pcall(self.assembler.push, self.assembler, f)
		if not ok then return nil, d end
		if d and d.method then
			if d.method.name == "connection.close" then
				self.t:send(M.connection_close_ok())
				return nil, string.format("server closed the connection: %d %s", d.method.reply_code, d.method.reply_text)
			elseif d.method.name == "channel.close" then
				return nil, string.format("server closed the channel: %d %s", d.method.reply_code, d.method.reply_text)
			end
		elseif d then
			return d
		end
	end
end

function Conn:close()
	self.t:send(M.connection_close(200, "bye"))
	pcall(self.next_method, self)
end

-- handshake(transport, {user, password, vhost, product}) -> connection with channel 1 open, or nil, err.
-- Heartbeats are declined (0): the bridge runs on the broker's own host and reconnects when the socket closes.
function M.handshake(t, o)
	local conn = setmetatable({ t = t, channel = 1 }, Conn)
	local ok, err = t:send(M.PROTOCOL_HEADER)
	if not ok then return nil, "send failed: " .. tostring(err) end
	local m; m, err = conn:next_method()
	if not m then return nil, err end
	if m.name ~= "connection.start" then return nil, "expected connection.start, got " .. m.name end
	if not m.mechanisms:find("PLAIN", 1, true) then return nil, "server does not offer PLAIN authentication" end
	local props = { product = o.product or "amqp.lua", capabilities = { authentication_failure_close = true } }
	m, err = conn:rpc(M.start_ok(props, o.user, o.password), "connection.tune")
	if not m then return nil, err end
	conn.frame_max = m.frame_max
	ok, err = t:send(M.tune_ok(m.channel_max, m.frame_max, 0))
	if not ok then return nil, "send failed: " .. tostring(err) end
	m, err = conn:rpc(M.connection_open(o.vhost or "/"), "connection.open-ok")
	if not m then return nil, err end
	m, err = conn:rpc(M.channel_open(conn.channel), "channel.open-ok")
	if not m then return nil, err end
	return conn
end

return M
