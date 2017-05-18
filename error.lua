local ffi = require "ffi"
local cffi = ffi.C

ffi.cdef[[
int perror(const char *);
]]

local function perror(str)
	return cffi.perror(str)
end

local function err(fmt, ...)
	return perror(string.format(fmt, ...))
end

return {
	perror = perror,
	err = err
}
