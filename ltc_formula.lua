

learntocount.formula_generator = {}
 
learntocount.formula_generator.operations = {"plus", "minus", "multiply", "divide"}
    
function learntocount.formula_generator.random_operation()
    local random_value=math.random(1, table.getn(learntocount.formula_generator.operations))
    for index, value in ipairs(learntocount.formula_generator.operations) do
        if index == random_value then
            return value
        end
    end
        
    print("ERROR")
    return nil
end

function learntocount.formula_generator.generate()
    insert_number_as_characters = function(result, number)
        for character in string.gmatch(dump(number),".") do
            table.insert(result, character)
        end
    end

    local operation = learntocount.formula_generator.random_operation()
    
    local result = {}

    if operation == "divide" then
        local first = math.random(0, 9)
        local second = math.random(1, 9)
        insert_number_as_characters(result, first*second)
        table.insert(result, operation)
        insert_number_as_characters(result, second)
        table.insert(result, 'equals')
        
    else
        local first = math.random(0, 9)
        local second = math.random(0, 9)    
        insert_number_as_characters(result, first)
        table.insert(result, operation)
        insert_number_as_characters(result, second)
        table.insert(result, 'equals')
        
    end
    return result
end


function learntocount.formula_generator.is_valid_operation(operation)

    if not string.match(operation, "^[0-9%*%+%=%-%/]*$") then
        --print(operation.." is not a valide operation")
        return false
    end
	
	local evaluate_operation = loadstring("return " .. operation)
	

	if type(evaluate_operation) ~= "function" then
		--print(operation.." is not a function")
		return false
	end

	local result = evaluate_operation()
	if type(result) ~= "boolean" then
		--minetest.log(operation.." is not an equation")
		return false
	end 
	
	return result
end

return learntocount.formula_generator