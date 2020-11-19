
package.path = "../?.lua;" .. package.path

require("tests/test_utils")
require("ltc_formula")

insulate("Formula", function()

	testutils.activate_mock_random()


	insulate("Generate formula", function()
		it("random operation", function()

			testutils.reinit_random({1, 2, 3, 4})
			assert.equals('plus', learntocount.formula_generator.random_operation())
			assert.equals('minus', learntocount.formula_generator.random_operation())
			assert.equals('multiply', learntocount.formula_generator.random_operation())
			assert.equals('divide', learntocount.formula_generator.random_operation())
				
		end)

		it("check random operation", function()
					  
			values = {}
			for i = 1,100 do
				local op = learntocount.formula_generator.random_operation()
				values[op]=true				
			end

			assert.is_true(values["plus"])
			assert.is_true(values["minus"])
			assert.is_true(values["multiply"])
			assert.is_true(values["divide"])

			assert.equals(
				testutils.table_length(learntocount.formula_generator.operations), 
				testutils.table_length(values))

		end)

		it("should generate one entry per digit", function()
			
			testutils.reinit_random({1, 15, 72 ,9})
			local formula = learntocount.formula_generator.generate()
			
			assert.equals("1",      formula[1])
			assert.equals("5",      formula[2])
			
			assert.equals("7",      formula[4])
			assert.equals("2",      formula[5])
			assert.equals("equals", formula[6])
			
		end)

		it("should generate simple division", function()
			_G.learntocount = testutils.extends(learntocount, {
				formula_generator = testutils.extends(learntocount.formula_generator,
				{
					random_operation = function() 
						return 'divide'
					end
				})
			})

			testutils.reinit_random({5, 7 ,9})
			local formula = learntocount.formula_generator.generate()
			
			assert.equals("3",      formula[1])
			assert.equals("5",      formula[2])
			assert.equals("divide", formula[3])
			assert.equals("7",      formula[4])
			assert.equals("equals", formula[5])
			
		end)
	end)

	insulate("check operation is valid()", function()
	
		it("valid function but not an operation", function()
			assert.is_false(learntocount.formula_generator.is_valid_operation("2+2"))
		end)
		it("invalid function", function()
			assert.is_false(learntocount.formula_generator.is_valid_operation("2+2="))
		end)
	
		it("valid add operation", function()
			assert.is_true(learntocount.formula_generator.is_valid_operation("2+2==4"))
		end)

		it("valid multipliy operation", function()
			assert.is_true(learntocount.formula_generator.is_valid_operation("1*8==8"))
		end)
	
		it("only operation characters", function()
			assert.is_false(learntocount.formula_generator.is_valid_operation("(math.pow(2, 2)+2==4)"))
		end)
	
	end)
end)


