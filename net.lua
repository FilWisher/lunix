-- TODO: clean up cffi for creating sockaddr_{in,un}

local ffi = require "ffi"
local bit = require "bit"
local file = require "file"
local err = require "error"
local util = require "util"

local cffi = ffi.C

ffi.cdef[[
typedef size_t socklen_t;
struct addrinfo {
	int ai_flags;
	int ai_family;
	int ai_socktype;
	int ai_protocol;
	socklen_t ai_addrlen;
	struct sockaddr *ai_addr;
	char *ai_canonname;
	struct addrinfo *ai_next;
};
struct in_addr {
	  unsigned long s_addr;
};
struct sockaddr_in {
	short sin_family;
	unsigned short sin_port;
	struct in_addr sin_addr;
	char sin_zero[8];
};
struct sockaddr_un {
	unsigned short sun_family;
	char sun_path[108];
};
int socket(int domain, int type, int protocol);
int setsockopt(int s, int level, int optname, const void *optval, socklen_t optlen);
int connect(int s, const struct sockaddr *name, socklen_t namelen);
int bind(int s, const struct sockaddr *name, socklen_t namelen);
int listen(int s, int backlog);
int accept(int s, struct sockaddr *addr, socklen_t *addrlen);
int shutdown(int s, int how);
int getaddrinfo(const char *hostname, const char *servname,
	const struct addrinfo *hints, struct addrinfo **res);
void freeaddrinfo(struct addrinfo *ai);
int inet_pton(int af, const char *src, void *dst);
int unlink(const char *);
]]

local PF_UNSPEC = 0
local PF_LOCAL = 1
local PF_INET = 2
local PF_INET6 = 24

local SOCK_STREAM = 1
local SOCK_DGRAM = 2
local SOCK_RAW = 3

local SOL_SOCKET = 0xffff

local SO_REUSEADDR = 0x0004
local SO_REUSEPORT = 0x0200

local AI_PASSIVE = 1
local AI_CANONNAME = 2
local AI_NUMERICHOST = 4
local AI_NUMERICSERV = 16
local AI_FQDN = 32
local AI_ADDRCONFIG = 64

local function unlink(str)
   return cffi.unlink(str)
end

local function socket(domain, typ, protocol)
	return cffi.socket(domain, typ, protocol)
end

local function bind(fd, addr, addrlen)
	return cffi.bind(fd, ffi.cast("struct sockaddr *", addr), addrlen)
end

local function listen(fd, num)
	return cffi.listen(fd, num)
end

local function _accept(fd, sockaddr_str)
   local sockaddr = ffi.new(sockaddr_str)
   local addrlen = ffi.new("socklen_t[1]")
   addrlen[0] = ffi.sizeof(sockaddr_str)
   local cfd = cffi.accept(fd, ffi.cast("struct sockaddr *", sockaddr), addrlen)
   if cfd <= 0 then
      return cfd, nil
   end
   return cfd, {sockaddr=sockaddr, addrlen=addrlen}
end

local function accept_in(fd)
   return _accept(fd, "struct sockaddr_in")
end

local function accept_un(fd)
   return _accept(fd, "struct sockaddr_un")
end

local function ntohl(x) return x end
local function ntohs(x) return x end
if ffi.abi("le") then
	local shr = bit.rshift
	function ntohl(x) return bit.bswap(x) end
	function ntohs(x) return shr(ntohl(x), 16) end
end

local function sockaddr_in(ip, port)
	local addr = ffi.new("struct sockaddr_in", {})
	local addrlen = ffi.sizeof("struct sockaddr_in")
	addr.sin_family = PF_INET
	addr.sin_port = ntohs(port)
	cffi.inet_pton(PF_INET, ip, addr.sin_addr)
	return addr, addrlen
end

local function sockaddr_un(path)
   local addr = ffi.new("struct sockaddr_un", {})
   local str, addrlen = util.cstring(path)
   ffi.copy(addr.sun_path, str, #path)
   addr.sun_family = PF_LOCAL
   addrlen = addrlen + ffi.sizeof("unsigned short")
   return addr, addrlen
end

local function close(fd)
   return cffi.close(fd)
end

return {
	socket = socket,
	bind = bind,
	listen = listen,
	accept_in = accept_in,
	accept_un = accept_un,
	sockaddr_in = sockaddr_in,
	sockaddr_un = sockaddr_un,
}
