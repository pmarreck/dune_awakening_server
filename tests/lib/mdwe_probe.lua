-- Exercises what our LuaJIT tools need from the runtime (compiled traces, cjson, LuaSocket, plain ffi.C calls) plus an
-- FFI callback, then reports key=value lines: whether W^X is enforced on this process (MemoryDenyWriteExecute), the
-- JIT's mcode security mode, and how many executable memfd code mappings exist. Run by tests/integration/luajit-mdwe.
local ffi = require("ffi")
local cjson = require("cjson")
local socket = require("socket")

ffi.cdef [[
int getpid(void);
void *mmap(void *addr, size_t len, int prot, int flags, int fd, long off);
int mprotect(void *addr, size_t len, int prot);
int munmap(void *addr, size_t len);
void qsort(void *base, size_t n, size_t size, int (*cmp)(const void *, const void *));
]]
local PROT_READ, PROT_WRITE, PROT_EXEC = 1, 2, 4
local MAP_PRIVATE, MAP_ANONYMOUS = 0x02, 0x20
local PAGE = 4096

-- W^X probe: adding execute to a fresh writable page is exactly what MemoryDenyWriteExecute refuses.
local function wx_denied()
	local p = ffi.C.mmap(nil, PAGE, PROT_READ + PROT_WRITE, MAP_PRIVATE + MAP_ANONYMOUS, -1, 0)
	assert(ffi.cast("intptr_t", p) ~= -1, "mmap failed")
	local rc = ffi.C.mprotect(p, PAGE, PROT_READ + PROT_EXEC)
	ffi.C.munmap(p, PAGE)
	return rc ~= 0
end

local sum = 0
for i = 1, 3e6 do sum = sum + i % 7 end
assert(sum == 8999997, "hot loop sum " .. sum)

local doc
for i = 1, 2e4 do doc = cjson.decode(cjson.encode({ n = i, s = "x" })) end
assert(doc.n == 2e4 and doc.s == "x", "cjson round trip")

local tcp = assert(socket.tcp())
tcp:close()
assert(socket.gettime() > 0, "socket.gettime")

local pid = 0
for _ = 1, 1e5 do pid = ffi.C.getpid() end
assert(pid > 0, "getpid")

local arr = ffi.new("int[5]", { 5, 3, 1, 4, 2 })
local cmp = ffi.cast("int (*)(const void *, const void *)", function(a, b)
	local x, y = ffi.cast("const int *", a)[0], ffi.cast("const int *", b)[0]
	return x < y and -1 or (x > y and 1 or 0)
end)
ffi.C.qsort(arr, 5, ffi.sizeof("int"), cmp)
cmp:free()
assert(arr[0] == 1 and arr[4] == 5, "qsort through an FFI callback")

local mcode_rx = 0
for line in io.lines("/proc/self/maps") do
	if line:match("^%x+%-%x+ r%-xp .*/memfd:luajit%-mcode") then mcode_rx = mcode_rx + 1 end
end
print("wx_denied=" .. tostring(wx_denied()))
print("jit=" .. tostring((jit.status())))
print("mcode_security=" .. tostring(jit.security and jit.security("mcode")))
print("mcode_rx=" .. mcode_rx)
print("done=true")
