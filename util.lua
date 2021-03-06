local ffi = require "ffi"
local bit = require "bit"

-- bor_reduce :: { int } -> int
local function bor_reduce(bits)
	local agg = 0
	for _, b in ipairs(bits) do
		agg = bit.bor(agg, b)
	end
	return agg
end

-- cstring :: string -> (char[], int)
local function cstring(str)
	 local len = #str
	 local c_str = ffi.new("char[?]", len)
	 ffi.copy(c_str, str)
	 return c_str, len
end


return {
	bor_reduce = bor_reduce,
	cstring = cstring,
}
