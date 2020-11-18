
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


learntocode.formula_generator = {
    generate = function()
        insert_number_as_characters = function(result, number)
            for character in string.gmatch(dump(number),".") do
                table.insert(result, character)
            end
        end

        local operation = calculus.random_operation()
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
} 

 function equation_start_and_direction(pos)
    local direction = equation_direction(pos)
    if (direction == nil) then
        if learntocount.is_position_a_digit(pos) then
            direction = minetest.registered_nodes[minetest.get_node(pos).name].value
        end
    end
    
    if direction == nil then
        return nil, nil
    end

    local start = find_first_equation_position(pos, direction)
    return start, direction
end

function clean_equation(pos)
    
    local start, direction = equation_start_and_direction(pos)
    if start == nil or direction == nil then
        return ""
    end

    local current_pos = start 
    local current_node = minetest.get_node(current_pos)
    while startsWith(current_node.name, "learntocount:") do    
        minetest.set_node(current_pos, {name="air"})
       
        current_pos = vector.add(current_pos, direction)
        current_node = minetest.get_node(current_pos)
    end
end

function generate_equation(pos, direction)
    
    local formula = learntocode.formula_generator.generate()
    local current_pos = pos
    local param2=0
    if direction.x == 0 then
        param2=1
    end
    for index, value in pairs(formula) do
        minetest.set_node(current_pos, {
             name='learntocount:symbol_fix_' .. value,
             param2=param2
            })
        current_pos=vector.add(current_pos, direction)  
    end

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

    local start, direction = equation_start_and_direction(pos)
    if start == nil or direction == nil then
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
