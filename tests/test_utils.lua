
-- https://olivinelabs.com/busted/
	
function startsWith(String, Start)
	return string.sub(String,1,string.len(Start))==Start
end

testutils = {
	nodes={},
	get_node = function(pos)
		--print('minetest.get_node '..pos.x.."/"..pos.y.."/"..pos.z)
		return testutils.nodes[pos.x.."/"..pos.y.."/"..pos.z]
	end,

	random_index=0,
	random_values={0},
	reinit_random = function(values)
		testutils.random_index=0
		testutils.random_values=values
	end,

	has_value = function(tab, searchValue)
		for key, value in pairs(tab) do
			if value == searchValue then
				return true
			end
		end
	
		return false
	end
}