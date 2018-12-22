minetest.register_on_newplayer(function(player)
	minetest.after(0.1,function(player)
		local name=player:get_player_name()
		local privs=minetest.get_player_privs(name)
		privs.scguest=true
		minetest.set_player_privs(name,privs)
	end,player)
end)

minetest.register_on_joinplayer(function(player)
	local name=player:get_player_name()
	local privs=minetest.get_player_privs(name)
	if privs.scguest then
		privs.scguest=nil
		minetest.set_player_privs(name,privs)
	end
end)

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

servercleaner.outdated_player=function(name)
	local a=minetest.get_auth_handler().get_auth(name)
	if not a then
		return
	end
	local diff=os.difftime(os.time(), a.last_login) / (24 * 60 * 60)
	if diff>=servercleaner.players then
		servercleaner.delete_player(name)
	elseif diff>=servercleaner.guest and minetest.check_player_privs(name, {scguest=true}) and not minetest.check_player_privs(name, {scadmin=true}) then
		servercleaner.delete_player(name)
	elseif diff>servercleaner.revoke_moderator and minetest.check_player_privs(name, {scmoderator=true}) and not minetest.check_player_privs(name, {dont_delete=true}) then
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

