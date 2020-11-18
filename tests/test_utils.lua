
-- https://olivinelabs.com/busted/
	
_G.core = {}
_G.learntocode = {}

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
	end,


	-- To extends an object, you can redefine it with 'extends' methods and pass functions to add or redefined.
	-- You must redifined first level after _G otherwise it will not be restored at the end of the test.
	-- First option redefining first level:
	--	_G.learntocode = {				
	--	
	--		formula_generator = expand(learntocode.formula_generator,
	--		{
	--			random_operation = function() 
	--				return 'divide'
	--			end
	--		})
	--	}

	-- Second option extending first level:
	--_G.learntocode = testutils.extends(learntocode, {
	--	formula_generator = testutils.extends(learntocode.formula_generator,
	--	{
	--		random_operation = function() 
	--			return 'divide'
	--		end
	--	})
	--})
	set_from = function(obj, from_obj)
		for k, v in pairs(from_obj) do
			obj[k] = v	
		end
		return obj
	end,

	clone = function(obj) 
		return testutils.set_from({}, obj)
	end,

	extends = function(obj, extension) 
		return testutils.set_from(testutils.clone(obj), extension)
	end
}