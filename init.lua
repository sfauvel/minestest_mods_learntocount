local modpath = minetest.get_modpath("learntocount")
_G.learntocode = {}
learntocode.formula_generator = dofile(modpath .. "/ltc_formula.lua")

dofile(modpath .. "/ltc_node.lua")
dofile(modpath .. "/ltc_calculus.lua")
dofile(modpath .. "/ltc_mapgen.lua")


local function startsWith(String, Start)
	return string.sub(String,1,string.len(Start))==Start
end
 

minetest.register_on_player_receive_fields(function(sender, formname, fields)

	minetest.log('learntocount: register_on_player_receive_fields')
	if formname:find('learntocount:lab_checker_') == 1 then
		local x, y, z = formname:match('learntocount:lab_checker_(.-)_(.-)_(.*)')
		local pos = {x=tonumber(x), y=tonumber(y), z=tonumber(z)}
		--print("Checker at " .. minetest.pos_to_string(pos) .. " got " .. dump(fields))
		local meta = minetest.get_meta(pos)
		if fields.b_saytext ~= nil then -- If we get a checkbox value we need to save that immediately because they are not sent on clicking 'Save' (due to a bug in minetest)
			meta:set_string('b_saytext', fields.b_saytext)
		end
		if fields.b_dispense ~= nil then -- ditto
			meta:set_string('b_dispense', fields.b_dispense)
		end
		if fields.b_lock ~= nil then -- ditto
			meta:set_string('b_lock', fields.b_lock)
		end
		if fields.save ~= nil then
			meta:set_string('solution', fields.solution)
			if meta:get_string('b_saytext') == 'true' then
				meta:set_string('s_saytext', fields.s_saytext)
			end
		end
	end
end)

local function win_something(pos)
	local count = 0
	minetest.log("registered_nodes: " .. dump(table.getn(minetest.registered_nodes)))
	for i,line in pairs(minetest.registered_nodes) do
		count = count + 1
	end
	minetest.log("Registerd nodes: "..dump(count))
	local index_win = math.random(count)
	count = 0
	for i,line in pairs(minetest.registered_nodes) do
		count = count + 1
		if (count == index_win) then
			local node_win = i
			minetest.log("Win "..node_win)
			--minetest.set_node({x=pos.x, y=pos.y+1, z=pos.z}, minetest.registered_nodes[node_win])
			minetest.add_item({x=pos.x, y=pos.y+1, z=pos.z}, node_win.." 5")
			

			local start, direction = equation_start_and_direction(pos)
			clean_equation(pos)
			if math.random(1,100) < 80 then
				generate_equation(start, direction)
			end
		end
	end

end

minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)

	local nodeXA = minetest.get_node({x=pos.x-1, y=pos.y, z=pos.z})
	local nodeXB = minetest.get_node({x=pos.x+1, y=pos.y, z=pos.z})
	local nodeZA = minetest.get_node({x=pos.x,   y=pos.y, z=pos.z-1})
	local nodeZB = minetest.get_node({x=pos.x,   y=pos.y, z=pos.z+1})

	local isDigitXA = startsWith(nodeXA.name, "learntocount:")
	local isDigitXB = startsWith(nodeXB.name, "learntocount:")
	local isDigitZA = startsWith(nodeZA.name, "learntocount:")
	local isDigitZB = startsWith(nodeZB.name, "learntocount:")


	if ((isDigitXA or isDigitXB) and (isDigitZA or isDigitZB)) then 
		minetest.log("Digit not possible here because intersection between X and Z")
		newnode.name = "air"
		minetest.set_node(pos, newnode)
	end

	if (isDigitXA and isDigitXB) and (nodeXA.param2 ~= nodeXB.param2) then
		minetest.log("Digit not possible here because not same face direction on X.")
		newnode.name = "air"
		minetest.set_node(pos, newnode)
	end
	
	if (isDigitZA and isDigitZB) and (nodeZA.param2 ~= nodeZB.param2) then
		minetest.log("Digit not possible here because not same face direction on Z.")
		newnode.name = "air"
		minetest.set_node(pos, newnode)
	end

	local direction = newnode.param2 % 2
	if isDigitXA then direction = 0 end
	if isDigitZA then direction = 1 end
	if isDigitXB then direction = 0 end
	if isDigitZB then direction = 1 end

 	if direction ~= newnode.param2 then
 		minetest.log("Rotate...")
 		newnode.param2 = direction
 		minetest.set_node(pos, newnode)
 	end
 

    local equation = read_equation(pos)

	minetest.log("Equation: " .. equation)

	minetest.log("learntocode.formula_generator "..dump(learntocode.formula_generator))
	if learntocode.formula_generator.is_valid_operation(equation) then 
	 	minetest.log("Equation '"..equation.."' is valid.")
	 
		win_something(pos)
	

   else
      minetest.log("Equation '"..equation.."' is INVALID.")
	end
  
end)
