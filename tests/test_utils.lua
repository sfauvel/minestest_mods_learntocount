
-- https://olivinelabs.com/busted/
	
_G.core = {}
local builtin_path="../../builtin"
dofile(builtin_path.."/common/misc_helpers.lua")

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
	mock_random = function(first, last)
		testutils.random_index = (testutils.random_index % table.getn(testutils.random_values)) + 1
		return testutils.random_values[testutils.random_index];
	end,
	activate_mock_random = function()
		_G.math={
			random = testutils.mock_random
		}
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