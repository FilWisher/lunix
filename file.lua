local ffi = require "ffi"
local bit = require "bit"
local cffi = ffi.C

ffi.cdef[[
int read(int, char *, size_t);
int write(int, char *, size_t);
int open(char *file, int mode);
int close(int);
int perror(const char *);
]]

local O_RDONLY = 0
local O_WRONLY = bit.lshift(1, 0)
local O_RDWR = bit.lshift(1, 1)
local O_CREAT = bit.lshift(1, 2)
local O_EXCL = bit.lshift(1, 3)
local O_NOCTTY = bit.lshift(1, 4)
local O_TRUNC = bit.lshift(1, 5)
local O_APPEND = bit.lshift(1, 6)

-- bor_reduce :: { int } -> int
local function bor_reduce(bits)
	local bit = 0
	for _, b in ipairs(bits) do
		bit = bit.bor(bit, b)
	end
	return bit
end

-- to_cstring :: string -> (char[], int)
local function to_cstring(str)
	 local len = #str
	 local c_str = ffi.new("char[?]", len)
	 ffi.copy(c_str, str)
	 return c_str, len
end

-- open :: string -> { int } -> fd
local function open(file, modes)
	local mode = modes
	if type(modes) == 'table' then
		mode = bor_reduce(modes)
	end
	local file_str = to_cstring(file)
	return cffi.open(file_str, mode)
end

-- read :: fd -> int -> (string, int)
local function read(fd, size)
	local buf = ffi.new("char[?]", size)
	local n = cffi.read(fd, buf, size)
	if n <= 0 then
		return "", n
	end
	return ffi.string(buf, n), n
end

-- write :: fd -> string -> int
local function write(fd, str)
	local buf, len = to_cstring(str)
	return cffi.write(fd, buf, len)
end

-- close :: fd -> int
local function close(fd)
	return cffi.close(fd)
end

return {
	open = open,
	read = read,
	write = write,
	close = close,
	O_RDONLY = O_RDONLY,
	O_WRONLY = O_WRONLY,
	O_RDWR = O_RDWR,
	O_CREAT = O_CREAT,
	O_EXCL = O_EXCL,
	O_NOCTTY = O_NOCTTY,
	O_TRUNC = O_TRUNC,
	O_APPEND = O_APPEND,
}
