AddCSLuaFile()
math.average = function( ... )
	local args = { ... }
	local result = 0

	for k, v in pairs( args ) do
		result = result + v
	end

	return result / #args
end
