--gets the players current level formula can be modified to change the level gap
function getLevel(xp)
	xp = tonumber(xp)
	return math.floor(xp/100)
end

--creates an xp file for any new player, and sets their xp to 0.
minetest.register_on_newplayer(function(player)
	file = io.open(minetest.get_worldpath().."/"..player:get_player_name().."_xp", "w")
	file:write("0")
	file:close()
end)

--this wipes out a players xp when they die
minetest.register_on_dieplayer(function(player)
	file = io.open(minetest.get_worldpath().."/"..player:get_player_name().."_xp", "w")
	file:write("0")
	file:close()
	minetest.chat_send_player(player:get_player_name(), "Your experience as been resets")
end)

--when a player digs a node
minetest.register_on_dignode(function(pos, oldnode, digger)
	node_name = oldnode.name
	digger_name = digger:get_player_name()
	give_xp = false
	amount_of_xp = 0
	--check to see if the node dug is a node that we want to give xp, then assign the xp drop
	if node_name == "default:stone_with_coal" then
		give_xp = true
		amount_of_xp = 3
	elseif node_name == "default:stone_with_copper" then
		give_xp = true
		amount_of_xp = 5
	elseif node_name == "default:stone_with_diamond" then
		give_xp = true
		amount_of_xp = 20
	elseif node_name == "default:stone_with_gold" then
		give_xp = true
		amount_of_xp = 15
	elseif node_name == "default:stone_with_iron" then
		give_xp = true
		amount_of_xp = 10
	elseif node_name == "default:stone_with_mese" then
		give_xp = true
		amount_of_xp = 30
	end
	
	--add the appropriate amount of xp to the players file
	if give_xp then
		read_xp = io.open(minetest.get_worldpath().."/"..digger_name.."_xp", "r")
		current_xp = read_xp:read("*l")
		read_xp:close()
		current_lvl = getLevel(current_xp)		
		if current_xp ~= nil then
			increased_xp = current_xp + amount_of_xp
			write_xp = io.open(minetest.get_worldpath().."/"..digger_name.."_xp", "w")
			write_xp:write(increased_xp)
			write_xp:close()
			--check to see if the player leveled up and if so reward them
			if (getLevel(increased_xp) ~= current_lvl) then
				minetest.chat_send_player(digger_name, "Congratulations, you've advanced to level " .. current_lvl + 1 .. "! Enjoy your Mese!")
				reward = "default:mese " .. getLevel(increased_xp)
				minetest.env:add_item(pos, reward)
			end
		end
	end
end)

--a chat command /myxp that lets the player check their current experience and level
minetest.register_chatcommand("myxp", {
	func = function(name, param)
		read_xp = io.open(minetest.get_worldpath().."/"..name.."_xp", "r")
		current_xp = read_xp:read("*l")
		read_xp:close()
		return true, "You currently have " .. current_xp .. " experience. (Lvl " .. getLevel(current_xp) .. ")"
	end
})
