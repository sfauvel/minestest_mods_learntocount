local function register_symbol_node(name, digit, equation_value, humanname)
	minetest.register_node('learntocount:symbol_' .. name, {
		drawtype = 'normal',
		tiles = {'learntocount.png', 'learntocount.png', 'learntocount.png', 
			'learntocount.png', 'learntocount.png', 'learntocount_' .. name .. '.png'},
		paramtype2 = 'facedir',
		description = humanname,
		groups = {snappy=3},
        value = equation_value
    })
    minetest.register_node('learntocount:symbol_fix_' .. name, {
		drawtype = 'normal',
		tiles = {'learntocount_fix.png', 'learntocount_fix.png', 'learntocount_fix.png', 
			'learntocount_fix.png', 'learntocount_fix.png', 'learntocount_' .. name .. '.png'},
		paramtype2 = 'facedir',
		description = humanname,
		groups = {snappy=3},
        value = equation_value,
        can_dig = function(pos, player)
            return false
        end
    })
end

local function startsWith(String, Start)
	return string.sub(String,1,string.len(Start))==Start
end
 
learntocount.is_node_a_digit = function(node)
	return node~=nil and startsWith(node.name, "learntocount:")
end

learntocount.is_position_a_digit = function(position)
    return position~=nil and learntocount.is_node_a_digit(minetest.get_node(position))
end

local digits = '0123456789'
for i in digits:gmatch('.') do
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
