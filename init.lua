servercleaner={
	players=365,
	actions={},
	nodes={},
	node_actions={},
	revoke_moderator=90,
	guest=7,
	}

--local servercleaner_storage=minetest.get_mod_storage()
--servercleaner_storage:set_string("players",string.gsub(servercleaner_storage:get_string("players")," " .. name .." ",""))

minetest.register_on_newplayer(function(player)
	minetest.after(0.1,function(player)
		local name=player:get_player_name()
		local privs=minetest.get_player_privs(name)
		privs.guest=true
		minetest.set_player_privs(name,privs)
	end,player)
end)

minetest.register_on_joinplayer(function(player)
	local name=player:get_player_name()
	local privs=minetest.get_player_privs(name)
	if privs.guest then
		privs.guest=nil
		minetest.set_player_privs(name,privs)
	end
end)

minetest.register_privilege("guest", {
	description = "Guest",
	give_to_singleplayer= false,
})

minetest.register_privilege("dont_delete", {
	description = "Will not be deleted",
	give_to_singleplayer= false,
})

minetest.register_privilege("moderator", {
	description = "Moderator",
	give_to_singleplayer= false,
})

minetest.register_privilege("admin", {
	description = "Admin",
	give_to_singleplayer= false,
})

servercleaner.register_owner_node=function(node,action)
	if type(node)=="table" then
		for i, n in pairs(node) do
			if minetest.get_modpath(n:sub(0,n:find(":")-1)) then
				table.insert(servercleaner.nodes,n)
				servercleaner.node_actions[n]=action or servercleaner.reset_owner
			end
		end
	else
		if minetest.get_modpath(node:sub(0,node:find(":")-1)) then
			table.insert(servercleaner.nodes,node)
			servercleaner.node_actions[node]=action or servercleaner.reset_owner
		end
	end
end

servercleaner.register_on_delete=function(mod_depends,action)
	if minetest.get_modpath(mod_depends) then
		servercleaner.actions[mod_depends]=action
	end
end

servercleaner.reset_owner=function(pos,node)
	local meta=minetest.get_meta(pos)
	local owner=meta:get_string("owner")
	if owner~="" and not minetest.player_exists(owner) then
		meta:set_string("owner","")
		local def=minetest.registered_nodes[node.name]
		if def and def.description then
			meta:set_string("infotext", def.description .. " (Abandoned)")
		else
			meta:set_string("infotext", "Abandoned")
		end
	end
end

servercleaner.remove_owned_node=function(pos,node)
	local meta=minetest.get_meta(pos)
	local owner=meta:get_string("owner")
	if owner~="" and not minetest.player_exists(owner) then
		minetest.remove_node(pos)
	end
end

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

minetest.register_chatcommand("delmod", {
	params = "<playername>",
	description = "Downgrad moderator to player (has the moderator privilege)",
	privs = {admin = true},
	func = function(name, param)
		if param=="" then
			return false
		elseif not minetest.player_exists(param) then
			return false, "player doesnt exist"
		elseif minetest.check_player_privs(param, {dont_delete=true}) then
			return false,"player " .. param .. " has the dont_delete privilege"
		elseif not minetest.check_player_privs(param, {moderator=true}) then
			return false, "player " .. param .. " dont have the moderator privilege"
		elseif minetest.check_player_privs(param, {moderator=true}) then
			local s=minetest.settings:get("default_privs") or ""
			local privs={}
			for i, p in pairs(s.split(s,", ")) do
				privs[p]=true
			end
			minetest.set_player_privs(param,privs)
			minetest.log("Moderator " .. param .."downgraded to player (by " .. name .. ")")
			return true,"Moderator " .. param .."downgraded to player"
		end
		return false
	end,
})

minetest.register_chatcommand("delme", {
	description = "Delete your account",
	func = function(name, param)
		servercleaner.delete_player(name,name)
	end,
})

servercleaner.outdated_player=function(name)
	local a=minetest.get_auth_handler().get_auth(name)
	if not a then
		return
	end
	local diff=os.difftime(os.time(), a.last_login) / (24 * 60 * 60)

	if diff>=servercleaner.players then
		servercleaner.delete_player(name)
	elseif diff>=servercleaner.guest and minetest.check_player_privs(name, {guest=true}) and not minetest.check_player_privs(name, {admin=true}) then
		servercleaner.delete_player(name)
	elseif diff>servercleaner.revoke_moderator and minetest.check_player_privs(name, {moderator=true}) and not minetest.check_player_privs(name, {dont_delete=true}) then
		local s=minetest.settings:get("default_privs") or ""
		local privs={}
		for i, p in pairs(s.split(s,", ")) do
			privs[p]=true
		end
		minetest.set_player_privs(name,privs)
		minetest.log("Moderator " .. name .."downgraded to player (" .. servercleaner.revoke_moderator .. " days expired)")
	end
end

servercleaner.delete_player=function(name,by)
	if minetest.check_player_privs(name, {dont_delete=true}) then
		if by then
			minetest.chat_send_player(by,"player " .. name .. " has the dont_delete privilege, and will not be deleted")
		end
		return
	end
	minetest.log("Delete player " .. name .. " (" .. ((by and "by " .. by ..")") or servercleaner.players .. " days expired)"))
	for i, action in pairs(servercleaner.actions) do
		action(name)
	end
	if minetest.get_player_by_name(name) then
		minetest.kick_player(name, "Account Deleted")
	end
	minetest.after(1,function(name,by)
		minetest.remove_player_auth(name)
		local del=minetest.remove_player(name)
		if by and del then
			minetest.chat_send_player(by,"player " .. name .. " deleted")
		end
	end,name,by)
end

minetest.after(0,function()
	for name, value in minetest.get_auth_handler().iterate() do
		servercleaner.outdated_player(name)
	end
end)


minetest.register_lbm({
	name="servercleaner:abandoned_owners",
	nodenames=servercleaner.nodes,
	run_at_every_load=true,
	action=function(pos,node)
		servercleaner.node_actions[node.name](pos,node)
	end
})

servercleaner.register_on_delete("areas",function(name)
	for id, area in pairs(areas.areas) do
		if areas:isAreaOwner(id, name) then
			areas:remove(id)
		end
	end
	areas:save()
end)

servercleaner.register_on_delete("beds",function(name)
	beds.spawn[name]=nil
	beds.save_spawns()
end)

servercleaner.register_on_delete("unified_inventory",function(name)
	unified_inventory.home_pos[name]=nil
	unified_inventory.set_home({get_player_name=function() return "?" end},{x=0,y=0,z=0})
end)

servercleaner.register_owner_node({
	"default:chest_locked",
	"bones:bones",
	"doors:trapdoor_steel",
	"doors:trapdoor_steel_open",
	"doors:door_steel_a",
	"doors:door_steel_b",
})

servercleaner.register_owner_node({
	"protector:protect",
	"protector:protect2",
},servercleaner.remove_owned_node)