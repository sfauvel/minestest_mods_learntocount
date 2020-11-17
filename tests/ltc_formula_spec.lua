
package.path = "../?.lua;" .. package.path

require("tests/test_utils")
require("ltc_formula")

insulate("Formula", function()

	testutils.activate_mock_random()

	it("should generate one entry per digit", function()
		
		testutils.reinit_random({1, 15, 72 ,9})
		local formula = formula_generator.generate()
		
		assert.equals("1",      formula[1])
		assert.equals("5",      formula[2])
		
		assert.equals("7",      formula[4])
		assert.equals("2",      formula[5])
		assert.equals("equals", formula[6])
		
	end)

	it("should generate simple division", function()
		_G.formula_generator= {
			generate=formula_generator.generate,
			operations=formula_generator.operations,
			random_operation = function() 
				return 'divide'
			end
		}

		testutils.reinit_random({5, 7 ,9})
		local formula = formula_generator.generate()
		
		assert.equals("3",      formula[1])
		assert.equals("5",      formula[2])
		assert.equals("divide", formula[3])
		assert.equals("7",      formula[4])
		assert.equals("equals", formula[5])
		
	end)
	
end)
