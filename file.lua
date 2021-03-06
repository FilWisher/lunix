local ffi = require "ffi"
local bit = require "bit"
local util = require "util"
local cffi = ffi.C

ffi.cdef[[
int read(int, char *, size_t);
int write(int, char *, size_t);
int open(char *file, int mode);
int close(int);
int fcntl(int, int, ...);
]]

local O_RDONLY = 0
local O_WRONLY = bit.lshift(1, 0)
local O_RDWR   = bit.lshift(1, 1)
local O_CREAT  = bit.lshift(1, 2)
local O_EXCL   = bit.lshift(1, 3)
local O_NOCTTY = bit.lshift(1, 4)
local O_TRUNC  = bit.lshift(1, 5)
local O_APPEND = bit.lshift(1, 6)

local O_NONBLOCK = bit.lshift(1, 11)

local F_GETFL = 3
local F_SETFL = 4

local function setnonblock(fd)
	local n = cffi.fcntl(fd, F_GETFL, 0)
	n = bit.bor(n, O_NONBLOCK)
	return cffi.fcntl(fd, F_SETFL, n)
end

-- open :: string -> { int } -> fd
local function open(file, modes)
	local mode = modes
	if type(modes) == 'table' then
		mode = util.bor_reduce(modes)
	end
	local file_str = util.cstring(file)
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
	local buf, len = util.cstring(str)
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
	setnonblock = setnonblock,
	
	O_RDONLY = O_RDONLY,
	O_WRONLY = O_WRONLY,
	O_RDWR = O_RDWR,
	O_CREAT = O_CREAT,
	O_EXCL = O_EXCL,
	O_NOCTTY = O_NOCTTY,
	O_TRUNC = O_TRUNC,
	O_APPEND = O_APPEND,
	
	O_NONBLOCK = O_NONBLOCK,
}
