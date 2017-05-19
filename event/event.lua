local ffi = require "ffi"
local util = require "util"
local cffi = ffi.C

ffi.cdef[[
typedef long time_t;
typedef long suseconds_t;
struct timeval {
	time_t tv_sec;
	suseconds_t tv_usec;
};
struct event_base;
typedef int evutil_socket_t;
struct event_base;
struct event;
struct event_base *event_init(void);
typedef void (*event_callback_fn)(evutil_socket_t, short, void *);
int event_set(struct event *ev, int fd, short event, void (*fn)(int, short, void *), void *arg);
struct event *event_new(struct event_base *, evutil_socket_t, short, event_callback_fn, void *);
int event_add(struct event *ev, const struct timeval *tv);
int event_del(struct event *ev);
int event_dispatch(void);
]]

local EV_TIMEOUT = bit.lshift(1, 0)
local EV_READ    = bit.lshift(1, 1)
local EV_WRITE   = bit.lshift(1, 2)
local EV_SIGNAL	 = bit.lshift(1, 3)
local EV_PERSIST = bit.lshift(1, 4)

local libevent = ffi.load("libevent.so")

local function init()
	return libevent.event_init()
end

local function set(ev, fd, evs, cb)
	local what
	if type(evs) == 'table' then
		what = util.bor_reduce(evs)
	else
		what = evs
	end
	-- XXX: can't pass arg yet (possibly use ffi.copy?)
	return libevent.event_set(ev, fd, what, ffi.cast("event_callback_fn", cb), nil)
end

local function add(ev, seconds, useconds)
	local tv = nil
	if type(seconds) == 'number' or type(useconds) == 'number' then
		tv = ffi.new("struct timeval", {seconds, useconds})
	end
	return libevent.event_add(ev, tv)
end

local function del(ev)
	return libevent.event_del(ev)
end

local function dispatch()
	return libevent.event_dispatch()
end

local function event_new(base, fd, evs, cb)
	local what
	if type(evs) == 'table' then
		what = util.bor_reduce(evs)
	else
		what = evs or 0
	end
	return libevent.event_new(base, fd or -1, what, ffi.cast("event_callback_fn", cb), nil)
end

return {
	 init = init,
	 set = set,
	 add = add,
	 del = del,
	 dispatch = dispatch,
	 event_new = event_new,
	 EV_TIMEOUT = EV_TIMEOUT,
	 EV_READ = EV_READ,
	 EV_WRITE = EV_WRITE,
	 EV_SIGNAL = EV_SIGNAL,
	 EV_PERSIST = EV_PERSIST,
}
