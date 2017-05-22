local ffi = require "ffi"
local cffi = ffi.C

ffi.cdef[[
typedef int pid_t;
pid_t fork(void);
pid_t getpid(void);
pid_t waitpid(pid_t, int *, int);
]]

local function fork()
	return cffi.fork()
end

local function getpid()
	return cffi.getpid()
end

local function wait(pid)
	return cffi.waitpid(pid, nil, 0)
end

return {
	fork = fork,
	getpid = getpid,
	wait = wait,
}
