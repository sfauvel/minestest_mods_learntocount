

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

    local MAX_NUMBER_VALUE = 9

    local insert_number_as_characters = function(result, number)
        for character in string.gmatch(dump(number),".") do
            table.insert(result, character)
        end
    end
    local binary_operation=function(left, operator, right)
        local result = {}
        insert_number_as_characters(result, left)
        table.insert(result, operator)
        insert_number_as_characters(result, right)
        table.insert(result, 'equals')
        return result
    end

    local operations_builder = {}
    
    operations_builder["divide"]=function()
        local result = {}
        local first = math.random(0, MAX_NUMBER_VALUE)
        local second = math.random(1, MAX_NUMBER_VALUE) -- Start at 1 to avoid division by 0
        return binary_operation(first*second, "divide", second)
    end
    
    operations_builder["minus"]=function()
        local result = {}
        local first = math.random(0, MAX_NUMBER_VALUE)
        local second = math.random(0, MAX_NUMBER_VALUE)
        if first > second then
            return binary_operation(first, "minus", second)
        else
            return binary_operation(second, "minus", first)
        end
    end
    
    local default_operation_builder=function(operator)
        local result = {}
        local first = math.random(0, MAX_NUMBER_VALUE)
        local second = math.random(0, MAX_NUMBER_VALUE)    
        return binary_operation(first, operator, second)
    end

    local operation = learntocount.formula_generator.random_operation()
    
    local builder = operations_builder[operation]
    if (builder ~= nil) then
        return builder()
    else
        return default_operation_builder(operation)
    end
    
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