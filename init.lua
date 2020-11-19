local modpath = minetest.get_modpath("learntocount")
_G.learntocount = {}
learntocount.formula_generator = dofile(modpath .. "/ltc_formula.lua")

dofile(modpath .. "/ltc_node.lua")
dofile(modpath .. "/ltc_core.lua")
dofile(modpath .. "/ltc_mapgen.lua")


local function win_something(pos)

	function insert_table(final_table, table_to_add)
		local count = 0
		for key,obj in pairs(table_to_add) do
			count = count + 1
			table.insert(final_table, key)
		end
		return count
	end


	all_registered_objects={}
	local count = insert_table(all_registered_objects, minetest.registered_items)
		+ insert_table(all_registered_objects, minetest.registered_nodes)
		+ insert_table(all_registered_objects, minetest.registered_craftitems)
		+ insert_table(all_registered_objects, minetest.registered_tools)

	minetest.sound_play("learntocount_winning")


	local index_win = math.random(count)

	local node_win = all_registered_objects[index_win]
	minetest.log("Win "..node_win)
	minetest.add_item({x=pos.x, y=pos.y+1, z=pos.z}, node_win.." "..math.random(1, 10))
	
	-- Must be calculated before cleaning nodes
	local start, direction = learntocount.core.equation_start_and_direction(pos)
	learntocount.core.clean_equation(pos)
	if math.random(1,100) < 80 then
		learntocount.core.generate_equation(start, direction)
	end
end

local function normalize_digit_orientation(pos, newnode)
	local nodeXA = minetest.get_node({x=pos.x-1, y=pos.y, z=pos.z})
	local nodeXB = minetest.get_node({x=pos.x+1, y=pos.y, z=pos.z})
	local nodeZA = minetest.get_node({x=pos.x,   y=pos.y, z=pos.z-1})
	local nodeZB = minetest.get_node({x=pos.x,   y=pos.y, z=pos.z+1})

	local isDigitXA = learntocount.is_node_a_digit(nodeXA)
	local isDigitXB = learntocount.is_node_a_digit(nodeXB)
	local isDigitZA = learntocount.is_node_a_digit(nodeZA)
	local isDigitZB = learntocount.is_node_a_digit(nodeZB)

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
	if isDigitXB then direction = 0 end
	if isDigitZA then direction = 1 end
	if isDigitZB then direction = 1 end

 	if direction ~= newnode.param2 then
 		minetest.log("Rotate...")
 		newnode.param2 = direction
 		minetest.set_node(pos, newnode)
 	end
 
end

minetest.register_on_placenode(function(pos, newnode, placer, oldnode, itemstack, pointed_thing)

	if not learntocount.is_node_a_digit(newnode) then
		return
	end

	normalize_digit_orientation(pos, newnode)

    local equation = learntocount.core.read_equation(pos)

	--minetest.log("Equation: " .. equation)

	--minetest.log("learntocount.formula_generator "..dump(learntocount.formula_generator))
	if learntocount.formula_generator.is_valid_operation(equation) then 
	 	minetest.log("Equation '"..equation.."' is valid.")
	 
		win_something(pos)
    else
      	minetest.log("Equation '"..equation.."' is INVALID.")
	end
  
end)
