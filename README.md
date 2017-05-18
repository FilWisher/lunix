# lunix
lua bindings to common posix functions using cffi

## error.lua

 * ```perror(str)```
 * ```err(fmt, ...)```

## file.lua
 * ```open(str, modes)```
 * ```read(fd, size)```
 * ```write(fd, str)```
 * ```close(fd)```

## net.lua
 * ```socket(domain, typ, protocol)```
 * ```bind(fd, addr, addrlen)```
 * ```listen(fd, num)```
 * ```accept(fd)```
 * ```sockaddr_in(ip, port)```