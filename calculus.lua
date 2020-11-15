local function startsWith(String, Start)
	return string.sub(String,1,string.len(Start))==Start
end

learntocount = {
    is_position_a_digit = function(position)
        return position~=nil and learntocount.is_node_a_digit(minetest.get_node(position))
    end,
    is_node_a_digit = function(node)
        return node~=nil and startsWith(node.name, "learntocount:")
    end
}

function is_valid_operation(operation)
	--string.match(operation, "[0-9\+\=]")
	
	local evaluate_operation = loadstring("return " .. operation)
	

	if type(evaluate_operation) ~= "function" then
		print ("Not a function")
		return false
	end

	local result = evaluate_operation()
	if type(result) ~= "boolean" then
		print ("Not an equation")
		return false
	end 
	
	return result
end

function find_first_equation_position(pos, move)
    --local current_pos = vector.add(pos, move)
   -- print("find_first_equation_position: "..dump(pos))
    local current_pos = pos
    local current_node = minetest.get_node(current_pos)
   
    local result = nil
    while learntocount.is_node_a_digit(current_node) do
        result = current_pos       
        current_pos = vector.subtract(current_pos, move)
        current_node = minetest.get_node(current_pos)
    end
    return result
end



calculus = {
    operations = {"plus", "minus", "multiply", "divide"},
    
    random_operation= function()
        local random_value=math.random(1, table.getn(calculus.operations))
        for index, value in ipairs(calculus.operations) do
            if index == random_value then
                return value
            end
        end
            
        print("ERROR")
        return nil
    end
}


FormulaGenerator = {
    generate = function()
        return {
            dump(math.random(0, 9)),
            calculus.random_operation(),
            dump(math.random(0, 9)),
            'equals'
        }
    end
} 

function generate_equation(pos, direction)
    
    local formula = FormulaGenerator.generate()
    local current_pos = pos
    local param2=0
    if direction.x == 0 then
        param2=1
    end
    for index, value in pairs(formula) do
        minetest.set_node(current_pos, {
             name='learntocount:symbol_' .. value,
             param2=param2
            })
        current_pos=vector.add(current_pos, direction)  
    end
    minetest.set_node(current_pos, {name='air'})
    current_pos=vector.add(current_pos, direction)  
    minetest.set_node(current_pos, {name='air'})
    

end

function equation_direction(pos)
    
    if (learntocount.is_position_a_digit({x=pos.x-1, y=pos.y, z=pos.z})
        or learntocount.is_position_a_digit({x=pos.x+1, y=pos.y, z=pos.z})) then
        return vector.new(1, 0 , 0)
    end
    if (learntocount.is_position_a_digit({x=pos.x, y=pos.y, z=pos.z-1})
        or learntocount.is_position_a_digit({x=pos.x, y=pos.y, z=pos.z+1})) then
        return vector.new(0, 0 , -1)
    end
    return nil
   
end

function read_equation(pos)
    --print("read_equation "..dump(pos))
    local direction = equation_direction(pos)
    if (direction == nil) then
        if learntocount.is_position_a_digit(pos) then
            return minetest.registered_nodes[minetest.get_node(pos).name].value
        else
            return ""
        end
    end
    
    local start = find_first_equation_position(pos, direction)
    if (start == nil)  then
      return ""
    end
    
    local current_pos = start 
    local current_node = minetest.get_node(current_pos)

    local equation = ""
    while startsWith(current_node.name, "learntocount:") do
        local node = minetest.registered_nodes[current_node.name]
        equation = equation .. node.value
       
        current_pos = vector.add(current_pos, direction)
        current_node = minetest.get_node(current_pos)
    end
    return equation
end


local function register_symbol_node(name, digit, equation_value, humanname)
	minetest.register_node('learntocount:symbol_' .. name, {
		drawtype = 'normal',
		tiles = {'learntocount.png', 'learntocount.png', 'learntocount.png', 
			'learntocount.png', 'learntocount.png', 'learntocount_' .. name .. '.png'},
		paramtype2 = 'facedir',
		description = humanname,
		groups = {learntocount_util=1, snappy=3},
        value = equation_value
    })
end

local s = '0123456789'
for i in s:gmatch('.') do
	register_symbol_node(i, i, i, i)
end

register_symbol_node('decimalpoint', '.', '.',  '. (Decimal point)')
register_symbol_node('divide', {':', '/'}, '/', ': (Divide)')
register_symbol_node('equals', '=', '==', '= (Equals)')
register_symbol_node('less', '<', '<', '< (Less than)')
register_symbol_node('minus', '-', '-', '- (Minus)')
register_symbol_node('more', '>', '>', '> (More than)')
register_symbol_node('multiply', {'*', 'x'}, '*', '* (Multiply)')
register_symbol_node('plus', '+', '+', '+ (Plus)')
