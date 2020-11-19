
package.path = "../?.lua;" .. package.path


require("tests/test_utils")

local builtin_path="../../builtin"
dofile(builtin_path.."/common/misc_helpers.lua")
dofile(builtin_path.."/common/vector.lua")

_G.minetest = {
	registered_nodes={},

	get_node = function(pos)
		--print('minetest.get_node '..pos.x.."/"..pos.y.."/"..pos.z)
		local node = testutils.nodes[pos.x.."/"..pos.y.."/"..pos.z]
		
		if node~=nil then 
			return node
		else
			return { name='air' }
		end
	end,

	set_node = function(pos, node)
	--	print("minetest.set_node(pos, node)")
		testutils.nodes[pos.x.."/"..pos.y.."/"..pos.z]=node
	end,


	register_node = function(name, definition)
		--print("register ".. name)
		minetest.registered_nodes[name]=definition
	end
}


require("ltc_node")
require("ltc_formula")
require("ltc_core")

describe("math_game", function()
	
	local set_node_by_name=function(position, name)
		minetest.set_node(position, {name=name})
	end
	
	before_each(function() 
		testutils.nodes = {}
	end)

	describe("read equation()", function()
			
		it("when nothing around", function()
			assert.equals("", read_equation(vector.new(0, 0, 0)))
		end)

		it("when stone around", function()
			set_node_by_name(vector.new(4,0,7), "default:stone")
			assert.equals("", read_equation(vector.new(5, 0, 7)))
		end)
		it("when learntocount node around in x axe", function()
			set_node_by_name(vector.new(20,0,20), "learntocount:symbol_3")
			assert.equals("3", read_equation(vector.new(20, 0, 20)))
		end)
		
		it("when several learntocount nodes around", function()
			set_node_by_name(vector.new(30,0,20), "learntocount:symbol_3")
			set_node_by_name(vector.new(31,0,20), "learntocount:symbol_plus")
			set_node_by_name(vector.new(32,0,20), "learntocount:symbol_5")
			assert.equals("3+5", read_equation(vector.new(32, 0, 20)))
		end)

		it("when several learntocount nodes around in both side", function()
			set_node_by_name(vector.new(30,0,20), "learntocount:symbol_3")
			set_node_by_name(vector.new(31,0,20), "learntocount:symbol_plus")
			set_node_by_name(vector.new(32,0,20), "learntocount:symbol_5")
			assert.equals("3+5", read_equation(vector.new(31, 0, 20)))
		end)

		it("when learntocount node around in z axe", function()
			set_node_by_name(vector.new(20,0,20), "learntocount:symbol_3")
			assert.equals("3", read_equation(vector.new(20, 0, 20)))
		end)

		it("when several learntocount nodes around in both side in z axes", function()
			set_node_by_name(vector.new(40,0,22), "learntocount:symbol_3")
			set_node_by_name(vector.new(40,0,21), "learntocount:symbol_plus")
			set_node_by_name(vector.new(40,0,20), "learntocount:symbol_5")
			assert.equals("3+5", read_equation(vector.new(40, 0, 21)))
		end)

		it("with fix symbols", function()
			set_node_by_name(vector.new(50,0,20), "learntocount:symbol_fix_4" )
			set_node_by_name(vector.new(51,0,20), "learntocount:symbol_fix_minus" )
			set_node_by_name(vector.new(52,0,20), "learntocount:symbol_fix_7" )
			assert.equals("4-7", read_equation(vector.new(50, 0, 20)))
		end)

	end)
	describe("Find first position", function()

		it("Find first position on axe x", function()
			set_node_by_name(vector.new(30,0,20), "learntocount:symbol_3" )
			set_node_by_name(vector.new(31,0,20), "learntocount:symbol_plus" )
			set_node_by_name(vector.new(32,0,20), "learntocount:symbol_5" )

			local first = find_first_equation_position(vector.new(32,0,20), vector.new(1,0,0))
			assert.equals(true, vector.equals(vector.new(30,0,20), first))
		end)

		it("Find first position on axe z", function()
			set_node_by_name(vector.new(30,5,20), "learntocount:symbol_2" )
			set_node_by_name(vector.new(30,5,19), "learntocount:symbol_minus" )
			set_node_by_name(vector.new(30,5,18), "learntocount:symbol_8" )

			local first = find_first_equation_position(vector.new(30,5,18), vector.new(0,0,-1))
			assert.equals(true, vector.equals(vector.new(30,5,20), first))
		end)
	end)

	describe("Clean equation", function()

		it("Find first position on axe x", function()
			set_node_by_name(vector.new(30,0,20), "learntocount:symbol_3" )
			set_node_by_name(vector.new(31,0,20), "learntocount:symbol_plus" )
			set_node_by_name(vector.new(32,0,20), "learntocount:symbol_5" )
			set_node_by_name(vector.new(33,0,20), "default:stone" )

			assert.is_true(startsWith(testutils.get_node(vector.new(30,0,20)).name, "learntocount:symbol_"))
			assert.is_true(startsWith(testutils.get_node(vector.new(31,0,20)).name, "learntocount:symbol_"))
			assert.is_true(startsWith(testutils.get_node(vector.new(32,0,20)).name, "learntocount:symbol_"))
			
			clean_equation(vector.new(31,0,20))
			
			assert.equals(testutils.get_node(vector.new(30,0,20)).name, "air")
			assert.equals(testutils.get_node(vector.new(31,0,20)).name, "air")
			assert.equals(testutils.get_node(vector.new(32,0,20)).name, "air")
			assert.equals(testutils.get_node(vector.new(33,0,20)).name, "default:stone")
			
		end)

	end)

	insulate("generate equation()", function()

		it("generate equation on axe x", function()
			
			_G.learntocount = testutils.extends(learntocount, {
				formula_generator = testutils.extends(learntocount.formula_generator, {
					generate = function() 
						return {"5", "plus", "7", "equals"}
					end
				})
			})
	
			generate_equation(vector.new(5, 3, 20), vector.new(1, 0, 0))

			assert.equals("learntocount:symbol_fix_5", testutils.get_node(vector.new(5,3,20)).name)
			assert.equals("learntocount:symbol_fix_plus", testutils.get_node(vector.new(6,3,20)).name)
			assert.equals("learntocount:symbol_fix_7", testutils.get_node(vector.new(7,3,20)).name)
			assert.equals("learntocount:symbol_fix_equals", testutils.get_node(vector.new(8,3,20)).name)
			
			assert.equals(0, testutils.get_node(vector.new(5,3,20)).param2)
			assert.equals(0, testutils.get_node(vector.new(6,3,20)).param2)
			assert.equals(0, testutils.get_node(vector.new(7,3,20)).param2)
			assert.equals(0, testutils.get_node(vector.new(8,3,20)).param2)
			
		end)

		it("generate equation on axe z", function()

			_G.learntocount = testutils.extends(learntocount, {
				formula_generator = testutils.extends(learntocount.formula_generator, {
					generate = function() 
						return {"5", "plus", "7", "equals"}
					end
				})
			})
		
			generate_equation(vector.new(5, 3, 20), vector.new(0, 0, -1))

			assert.equals("learntocount:symbol_fix_5", testutils.get_node(vector.new(5,3,20)).name)
			assert.equals("learntocount:symbol_fix_plus", testutils.get_node(vector.new(5,3,19)).name)
			assert.equals("learntocount:symbol_fix_7", testutils.get_node(vector.new(5,3,18)).name)
			assert.equals("learntocount:symbol_fix_equals", testutils.get_node(vector.new(5,3,17)).name)
	
			assert.equals(1, testutils.get_node(vector.new(5,3,20)).param2)
			assert.equals(1, testutils.get_node(vector.new(5,3,19)).param2)
			assert.equals(1, testutils.get_node(vector.new(5,3,18)).param2)
			assert.equals(1, testutils.get_node(vector.new(5,3,17)).param2)
		end)


		it("operation come from formula generator operation ", function()
			_G.learntocount = testutils.extends(learntocount, {
				formula_generator = testutils.extends(learntocount.formula_generator, {
					generate = function() 
						return {"5", "minus", "7", "equals"}
					end
				})
			})

			generate_equation(vector.new(5, 3, 20), vector.new(1, 0, 0))
			assert.equals("learntocount:symbol_fix_minus", testutils.get_node(vector.new(6,3,20)).name)
			
		end)

		it("generate equation with more than 1 digit", function()
			_G.calculus = {
				random_operation = function() 
					return 'plus'
				end
			}

			_G.learntocount = testutils.extends(learntocount, {
				formula_generator = testutils.extends(learntocount.formula_generator, {
					generate = function() 
						return {"5", "2", "plus", "7", "1", "equals"}
					end
				})
			})
			testutils.reinit_random({52, 71 ,9})	
			generate_equation(vector.new(5, 3, 20), vector.new(1, 0, 0))

			assert.equals("learntocount:symbol_fix_5", testutils.get_node(vector.new(5,3,20)).name)
			assert.equals("learntocount:symbol_fix_2", testutils.get_node(vector.new(6,3,20)).name)
			assert.equals("learntocount:symbol_fix_plus", testutils.get_node(vector.new(7,3,20)).name)
			assert.equals("learntocount:symbol_fix_7", testutils.get_node(vector.new(8,3,20)).name)
			assert.equals("learntocount:symbol_fix_1", testutils.get_node(vector.new(9,3,20)).name)
			assert.equals("learntocount:symbol_fix_equals", testutils.get_node(vector.new(10,3,20)).name)
			
		end)

	end)


end)
