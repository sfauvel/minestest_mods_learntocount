
local function log_position(message, position)
    minetest.log(message..position.x.."/"..position.y.."/"..position.z)
end

local function is_in_air(data, area, position, length)
    local c_air = minetest.get_content_id("air")	
    for index=0,length do
        local vi = area:index(position.x+index, position.y, position.z)
        if data[vi] == c_air then
            return true
        end 
    end
    --log_position("Not in air:", position)
    return false
end


local function add_some_simple_symbols(minp, maxp, data, area) 
    local c_air = minetest.get_content_id("air")	

    local function node_under(x, y, z)
        return minetest.get_node(vector.new(x,y-1,z))
    end

    local function startsWith(String, Start)
        return string.sub(String,1,string.len(Start))==Start
    end

    local function is_node_to_crush(node_name)
        return minetest.get_item_group(node_name, "flower") == 0 
                or node_name == "default:snow"
                or startsWith(node_name, "flowers:")
    end

    local function add_symbol_on_surface(positions_to_add, area, x, z, startY, endY) 
        for y=startY,endY,1 do
            local node_index = area:index(x, y, z)
            local node_under_index = area:index(x, y-1, z)

            if data[node_index] == c_air  and data[node_under_index] ~= c_air then
                local name = node_under(x,y,z).name
                if is_node_to_crush(name) then
                    node_index = area:index(x, y-1, z)                  
                end
                
                table.insert(positions_to_add, node_index)
            end 
        end
    end


    local positions_to_add={}
    local FREQUENCY=100
    local next = math.random(1,FREQUENCY)
    local current = 0
    for x=minp.x,maxp.x,1 do
        for z=minp.z,maxp.z,1 do
            current = current + 1
            if current >= next then
                current = 0
                next = math.random(1,FREQUENCY)

                add_symbol_on_surface(positions_to_add, area, x, z, minp.y,maxp.y)
            end
        end
    end

    for i,p in ipairs(positions_to_add) do
        local symbol = minetest.get_content_id("learntocount:symbol_" .. math.random(0,9))	 
        data[p] = symbol
    end
end

local function add_equations(minp, maxp, data, area) 
    local direction = vector.new(1,0,0)
    
    local x = minp.x
    while x < maxp.x do
        local z = minp.z
        while z < maxp.z do
            local y = minp.y
            while y < maxp.y do
                local formula = learntocount.formula_generator.generate()		
                if not (is_in_air(data, area, vector.new(x, y, z), table.getn(formula))) then
                    --log_position("Build in:", vector.new(x, y, z))
					for index, value in pairs(formula) do
						local vi = area:index(x+index, y, z)
						local symbol = minetest.get_content_id("learntocount:symbol_fix_" .. value)
						data[vi] = symbol
					end
				
                end
                y = y + math.random(1, 5)
            end
            z = z + math.random(1, 20)
        end
        x = x + math.random(1, 20)
    end
end


minetest.register_on_generated(function(minp, maxp, seed)
	local debug = "minp="..(minetest.pos_to_string(minp))..", maxp="..(minetest.pos_to_string(maxp))..", seed="..seed
    --minetest.log(debug)
    --print(debug)
	--minetest.chat_send_all(debug)

	local manip = minetest.get_voxel_manip()
	local e1, e2 = manip:read_from_map(minp, maxp)
	local area = VoxelArea:new{MinEdge=e1, MaxEdge=e2}
	local data = manip:get_data()

    add_some_simple_symbols(minp, maxp, data, area)
    add_equations(minp, maxp, data, area)

	manip:set_data(data)
	manip:write_to_map()
	manip:update_map() 

end)
