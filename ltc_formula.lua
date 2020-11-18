

formula_generator = {}
 
formula_generator.operations = {"plus", "minus", "multiply", "divide"}
    
function formula_generator.random_operation()
    local random_value=math.random(1, table.getn(formula_generator.operations))
    for index, value in ipairs(formula_generator.operations) do
        if index == random_value then
            return value
        end
    end
        
    print("ERROR")
    return nil
end

function formula_generator.generate()
    insert_number_as_characters = function(result, number)
        for character in string.gmatch(dump(number),".") do
            table.insert(result, character)
        end
    end

    local operation = formula_generator.random_operation()
    local first = math.random(0, 9)
    local second = math.random(0, 9)
    
    local result = {}

    if operation == "divide" then
        insert_number_as_characters(result, first*second)
        table.insert(result, operation)
        insert_number_as_characters(result, second)
        table.insert(result, 'equals')
        
    else
        insert_number_as_characters(result, first)
        table.insert(result, operation)
        insert_number_as_characters(result, second)
        table.insert(result, 'equals')
        
    end
    return result
end


function formula_generator.is_valid_operation(operation)

    if not string.match(operation, "^[0-9%+%=%-%/]*$") then
        --minetest.log(operation.." is not a valide operation")
        return false
    end
	
	local evaluate_operation = loadstring("return " .. operation)
	

	if type(evaluate_operation) ~= "function" then
		--minetest.log(operation.." is not a function")
		return false
	end

	local result = evaluate_operation()
	if type(result) ~= "boolean" then
		--minetest.log(operation.." is not an equation")
		return false
	end 
	
	return result
end

return formula_generator