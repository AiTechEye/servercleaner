servercleaner={
	players=365,
	areas=minetest.get_modpath("areas")~=nil,
	}


--revoke_moderator=90,
 --guests=7,
--local servercleaner_storage=minetest.get_mod_storage()
--servercleaner_storage:set_string("players",string.gsub(servercleaner_storage:get_string("players")," " .. name .." ",""))

minetest.register_on_joinplayer(function(player)
end)

minetest.register_chatcommand("delplayer", {
	params = "<playername>",
	description = "Delete player",
	privs = {ban = true},
	func = function(name, param)
		if param=="" then
			return
		end
		servercleaner.delete_player(param,name)
	end,
})

minetest.register_chatcommand("delme", {
	description = "Delete your account",
	func = function(name, param)
		servercleaner.delete_player(name)
	end,
})

servercleaner.outdated_player=function(name)
	local a=minetest.get_auth_handler().get_auth(name)
	if not a then
		return
	end
	if os.difftime(os.time(), a.last_login) / (24 * 60 * 60)>=servercleaner.players then
		servercleaner.delete_player(name)
	end
end

servercleaner.delete_player=function(name,by)
	if minetest.get_player_by_name(name) then
		minetest.kick_player(name, "Account Deleted")
	end
	minetest.after(1,function(name,by)
		local del=minetest.remove_player(name)
		if minetest.remove_player_auth then
			minetest.remove_player_auth(name)
		end
		if del==0 then
			if servercleaner.areas then
				for id, area in pairs(areas.areas) do
					if areas:isAreaOwner(id, name) then
						areas:remove(id)
					end
				end
				areas:save()
			end

			if by then
				minetest.chat_send_player(by,"player " .. name .. " deleted")
			end
		end
	end,name,by)
end

minetest.after(0,function()
	for name, value in minetest.get_auth_handler().iterate() do
		servercleaner.outdated_player(name)
	end
end)

minetest.register_lbm({
	name="servercleaner:abandoned_storages",
	nodenames={"default:chest_locked","bones:bones","doors:trapdoor_steel","doors:trapdoor_steel_open","doors:door_steel_a","doors:door_steel_b"},
	run_at_every_load=true,
	action=function(pos,node)
		local meta=minetest.get_meta(pos)
		local owner=meta:get_string("owner")
		if not minetest.player_exists(owner) then
			meta:set_string("owner","")
			local def=minetest.registered_nodes[node.name]
			if def and def.description then
				meta:set_string("infotext", def.description .. " (Abandoned)")
			else
				meta:set_string("infotext", "Abandoned")
			end
		end
	end
})