
minetest.register_on_generated(function(minp, maxp, seed)
	local debug = "minp="..(minetest.pos_to_string(minp))..", maxp="..(minetest.pos_to_string(maxp))..", seed="..seed
    minetest.log(debug)
    --print(debug)
	--minetest.chat_send_all(debug)

	local manip = minetest.get_voxel_manip()
	local e1, e2 = manip:read_from_map(minp, maxp)
	local area = VoxelArea:new{MinEdge=e1, MaxEdge=e2}

	local data = manip:get_data()

    local function log_position(message, position)
        minetest.log(message..position.x.."/"..position.y.."/"..position.z)
    end

	local function is_in_air(area, position, length)
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

    local c_air = minetest.get_content_id("air")	
    local midx = minp.x+math.floor((maxp.x-minp.x)/2)
    local midy = minp.y+math.floor((maxp.y-minp.y)/2)
    local midz = minp.z+math.floor((maxp.z-minp.z)/2)
    minetest.log("Mid x:"..midx.." y:"..midy.." z:"..midz )


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
                for y=minp.y,maxp.y,1 do
                    local vi = area:index(x, y, z)
                    local under = area:index(x, y-1, z)

                   -- local name = minetest.get_node(vector.new(x,y-1,z)).name
                   -- if minetest.get_item_group(name, "sand") ~= 0
                   --     or minetest.get_item_group(name, "wood") ~= 0
                   --     or minetest.get_item_group(name, "stone") ~= 0 then
                   --         table.insert(positions_to_add, vi)
                   -- end

                    if data[vi] == c_air  and data[under] ~= c_air then
                        local name = minetest.get_node(vector.new(x,y-1,z)).name
                        if minetest.get_item_group(name, "flower") == 0 
                            or name == "default:snow"
                            or string.sub(name,1,string.len("flowers:"))=="flowers" then
                                vi = area:index(x, y-1, z)
                        end
                        table.insert(positions_to_add, vi)
                    end 
                end
            end
        end
    end

    for i,p in ipairs(positions_to_add) do
        local symbol = minetest.get_content_id("learntocount:symbol_" .. math.random(0,9))	 
        data[p] = symbol
    end

    local direction = vector.new(1,0,0)
    
   -- for x=minp.x,maxp.x,10 do
	--	for z=minp.z,maxp.z,10 do
	--		for y=minp.y,maxp.y,3 do
	--			local formula = FormulaGenerator.generate()		
   --             if not (is_in_air(area, vector.new(x, y, z), table.getn(formula))) then
   --               --  log_position("Build in:", vector.new(x, y, z))
	--				for index, value in pairs(formula) do
	--					local vi = area:index(x+index, y, z)
	--					local symbol = minetest.get_content_id("learntocount:symbol_fix_" .. value)
	--					data[vi] = symbol
	--				end
	--			
	--			end
	--			
	--		end
	--	end
   -- end
   -- 

    local x = minp.x
    while x < maxp.x do
        local z = minp.z
        while z < maxp.z do
            local y = minp.y
            while y < maxp.y do
                local formula = FormulaGenerator.generate()		
                if not (is_in_air(area, vector.new(x, y, z), table.getn(formula))) then
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


	manip:set_data(data)
	manip:write_to_map()
	manip:update_map() 

end)
