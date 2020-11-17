
package.path = "../?.lua;" .. package.path


require("tests/test_utils")
_G.core = {}

local builtin_path="../../builtin"
dofile(builtin_path.."/common/misc_helpers.lua")
dofile(builtin_path.."/common/vector.lua")

_G.minetest = {
	registered_nodes={}
}


function minetest.get_node(pos)
	--print('minetest.get_node '..pos.x.."/"..pos.y.."/"..pos.z)
	local node = testutils.nodes[pos.x.."/"..pos.y.."/"..pos.z]
	
	if node~=nil then 
		return node
	else
		return { name='air' }
	end
end

function minetest.set_node(pos, node)
--	print("minetest.set_node(pos, node)")
--	print(dump(pos.x).."/"..dump(pos.y).."/"..dump(pos.z)..":"..dump(node))

	testutils.nodes[pos.x.."/"..pos.y.."/"..pos.z]=node
end


function minetest.register_node(name, definition)
	--print("register ".. name)
    minetest.registered_nodes[name]=definition
end


require("ltc_node")
require("ltc_calculus")


MockNode={    
}
function MockNode:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

describe("math_game", function()
	
	set_node_by_name=function(position, name)
		minetest.set_node(position, {name=name})
	end

	describe("xx()", function()
		it("evaluate operation", function()		
			assert.equal(loadstring("return " .. "2+2")(), 4)
		end)

		it("evaluate operation", function()			
			assert.is_true(loadstring("return " .. "2+2==4")())
		end)
	end)

	describe("check operation is valid()", function()

		it("valid function but not an operation", function()
			assert.is_false(is_valid_operation("2+2"))
		end)
		it("invalid function", function()
			assert.is_false(is_valid_operation("2+2="))
		end)

		it("valid operation", function()
			assert.is_true(is_valid_operation("2+2==4"))
		end)


		it("only operation characters", function()
			assert.is_false(is_valid_operation("(math.pow(2, 2)+2==4)"))
		end)

	end)
	describe("read equation()", function()
			

		set_node_by_name(vector.new(10,0,20), "default:stone")
		set_node_by_name(vector.new(20,0,20), "learntocount:symbol_3")
		
		set_node_by_name(vector.new(30,0,20), "learntocount:symbol_3")
		set_node_by_name(vector.new(31,0,20), "learntocount:symbol_plus")
		set_node_by_name(vector.new(32,0,20), "learntocount:symbol_5")

		set_node_by_name(vector.new(40,0,22), "learntocount:symbol_3")
		set_node_by_name(vector.new(40,0,21), "learntocount:symbol_plus")
		set_node_by_name(vector.new(40,0,20), "learntocount:symbol_5")
	
		set_node_by_name(vector.new(50,0,20), "learntocount:symbol_fix_4" )
		set_node_by_name(vector.new(51,0,20), "learntocount:symbol_fix_minus" )
		set_node_by_name(vector.new(52,0,20), "learntocount:symbol_fix_7" )
		
		it("when nothing around", function()
			assert.equals("", read_equation(vector.new(0, 0, 0)))
		end)

		it("when stone around", function()
			assert.equals("", read_equation(vector.new(5, 0, 7)))
		end)
		it("when learntocount node around in x axe", function()
			assert.equals("3", read_equation(vector.new(20, 0, 20)))
		end)
		it("when learntocount node around in x axe", function()
			assert.equals("", read_equation(vector.new(21, 0, 20)))
		end)
		it("when several learntocount nodes around", function()
			assert.equals("3+5", read_equation(vector.new(32, 0, 20)))
		end)

		it("when several learntocount nodes around in both side", function()
			assert.equals("3+5", read_equation(vector.new(40, 0, 21)))
		end)

		it("when learntocount node around in z axe", function()
			assert.equals("3", read_equation(vector.new(20, 0, 20)))
		end)

		it("when several learntocount nodes around in both side in z axes", function()
			assert.equals("3+5", read_equation(vector.new(40, 0, 20)))
		end)

		it("with fix symbols", function()
			assert.equals("4-7", read_equation(vector.new(50, 0, 20)))
		end)

	end)
	describe("Find first position", function()
		set_node_by_name(vector.new(30,0,20), "learntocount:symbol_3" )
		set_node_by_name(vector.new(31,0,20), "learntocount:symbol_plus" )
		set_node_by_name(vector.new(32,0,20), "learntocount:symbol_5" )


		set_node_by_name(vector.new(30,5,20), "learntocount:symbol_2" )
		set_node_by_name(vector.new(30,5,19), "learntocount:symbol_minus" )
		set_node_by_name(vector.new(30,5,18), "learntocount:symbol_8" )

		it("Find first position on axe x", function()
			local first = find_first_equation_position(vector.new(32,0,20), vector.new(1,0,0))
			assert.equals(true, vector.equals(vector.new(30,0,20), first))
		end)

		it("Find first position on axe z", function()
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
			print(4)
			
			clean_equation(vector.new(31,0,20))
			
			assert.equals(testutils.get_node(vector.new(30,0,20)).name, "air")
			assert.equals(testutils.get_node(vector.new(31,0,20)).name, "air")
			assert.equals(testutils.get_node(vector.new(32,0,20)).name, "air")
			assert.equals(testutils.get_node(vector.new(33,0,20)).name, "default:stone")
			
		end)

	end)

	insulate("generate equation()", function()

		_G.math={
			random = function(first, last)
				testutils.random_index = (testutils.random_index % table.getn(testutils.random_values)) + 1
				return testutils.random_values[testutils.random_index];
			end
		}
		it("random operation #only", function()

			testutils.reinit_random({1, 2, 3, 4})
			assert.equals('plus', calculus.random_operation())
			assert.equals('minus', calculus.random_operation())
			assert.equals('multiply', calculus.random_operation())
			assert.equals('divide', calculus.random_operation())
				
		end)

		it("generate equation on axe x", function()
			_G.calculus = {
				random_operation = function() 
					return 'plus'
				end
			}

			testutils.reinit_random({5, 7 ,9})	
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
			_G.calculus= {
				random_operation = function() 
					return 'plus'
				end
			}
			function calculus.random_operation()
				return 'plus'
			end

			testutils.reinit_random({5, 7 ,9})	
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


		it("operation come from random_operation ", function()
			_G.calculus= {
				random_operation = function() 
					return 'minus'
				end
			}

			function calculus.random_operation()
				return 'minus'
			end

			testutils.reinit_random({5, 7 ,9})

			generate_equation(vector.new(5, 3, 20), vector.new(1, 0, 0))
			assert.equals("learntocount:symbol_fix_minus", testutils.get_node(vector.new(6,3,20)).name)
			
		end)

		it("generate equation with more than 1 digit", function()
			_G.calculus = {
				random_operation = function() 
					return 'plus'
				end
			}

			testutils.reinit_random({52, 71 ,9})	
			generate_equation(vector.new(5, 3, 20), vector.new(1, 0, 0))

			assert.equals("learntocount:symbol_fix_5", testutils.get_node(vector.new(5,3,20)).name)
			assert.equals("learntocount:symbol_fix_2", testutils.get_node(vector.new(6,3,20)).name)
			assert.equals("learntocount:symbol_fix_plus", testutils.get_node(vector.new(7,3,20)).name)
			assert.equals("learntocount:symbol_fix_7", testutils.get_node(vector.new(8,3,20)).name)
			assert.equals("learntocount:symbol_fix_1", testutils.get_node(vector.new(9,3,20)).name)
			assert.equals("learntocount:symbol_fix_equals", testutils.get_node(vector.new(10,3,20)).name)
			
		end)

		it("should generate simple division", function()
			_G.calculus= {
				random_operation = function() 
					return 'divide'
				end
			}

			testutils.reinit_random({5, 7 ,9})
			local formula = FormulaGenerator.generate()
			
			assert.equals("3",      formula[1])
			assert.equals("5",      formula[2])
			assert.equals("divide", formula[3])
			assert.equals("7",      formula[4])
			assert.equals("equals", formula[5])
			
		end)

	end)

	describe("Check random", function() 
		it("check random operation", function()
	
			values = {}
			for i = 1,100 do
				local op = calculus.random_operation()
			--	print(op)
				values[op]=true
			end
			assert.is_true(values["plus"])
			assert.is_true(values["minus"])
			assert.is_true(values["multiply"])
			assert.is_true(values["divide"])
		end)

	end)

end)
