minetest.register_privilege("scguest", {
	description = "Guest",
	give_to_singleplayer= false,
})

minetest.register_privilege("dont_delete", {
	description = "Will not be deleted",
	give_to_singleplayer= false,
})

minetest.register_privilege("scmoderator", {
	description = "Moderator",
	give_to_singleplayer= false,
})

minetest.register_privilege("scadmin", {
	description = "Admin",
	give_to_singleplayer= false,
})

minetest.register_chatcommand("advm", {
	description = "Show Advanced members",
	privs = {kick = true},
	func = function(name, param)
		servercleaner.advm(name)
		return true
	end,
})

minetest.register_chatcommand("delplayer", {
	params = "<playername>",
	description = "Delete player",
	privs = {ban = true},
	func = function(name, param)
		if param=="" then
			return false,"/delplayer <playername>"
		elseif name==param then
			return false,"delete a player, not yourself, use '/delme' instead"
		elseif minetest.check_player_privs(param, {scmoderator=true}) and not minetest.check_player_privs(name, {scadmin=true}) then
			return false,"Moderators can't delete moderators"
		elseif not minetest.check_player_privs(name, {privs=true}) and (minetest.check_player_privs(param, {scadmin=true}) or minetest.check_player_privs(param, {privs=true})) then
			return false,"can't delete admin"
			
		else
			servercleaner.delete_player(param,name)
		end
	end,
})

minetest.register_chatcommand("delmod", {
	params = "<playername>",
	description = "Downgrad to player",
	privs = {ban = true},
	func = function(name, param)
		local user=minetest.get_player_privs(name)
		if not (user.privs or user.scmoderator or user.scadmin) then
			return false,"Requires privs or scadmin or scmoderator privilege"
		elseif param=="" then
			return false
		elseif not minetest.player_exists(param) then
			return false, "player doesnt exist"
		elseif minetest.check_player_privs(param, {dont_delete=true}) then
			return false,"player " .. param .. " has the dont_delete privilege"
		end

		local player=minetest.get_player_privs(param)


		if servercleaner.server_owner[param] then
			return false,"can't downgraded server owner"
		elseif user.privs then
		elseif user.scadmin and (player.scadmin or player.privs) then
			return false,"You can't downgrade admins"
		elseif user.scmoderator and (player.scmoderator or player.scadmin or player.privs) then
			return false,"You can't downgrade moderators or admins"
		end

		local privs=minetest.string_to_privs(servercleaner.default_privs)
		minetest.set_player_privs(param,privs)
		minetest.log(param .." downgraded to player (by " .. name .. ")")
		return true,param .." downgraded to player"
	end,
})

minetest.register_chatcommand("delme", {
	description = "Delete your account",
	func = function(name, param)
		if not servercleaner.delme[name] then
			servercleaner.delme[name]=true
			minetest.after(20,function(name)
				servercleaner.delme[name]=nil
				if minetest.get_player_by_name(name) then
					minetest.chat_send_player(name,"The time (20) has expired")
				end
			end,name)
			return false,"Are you sure you want to delete your account?\nAll your privileges, protected/areas/data will be deleted, locked stuff will be able for other people.\nTo confirm type: /delme delete me"
		elseif servercleaner.delme[name] and param=="delete me" then
			servercleaner.delete_player(name,name)
		end
		return true
	end,
})

minetest.register_chatcommand("clobjects", {
	description = "Check and clear unknown objects",
	func = function(name, param)
		local player=minetest.get_player_by_name(name)
		if not player then
			return
		end
		servercleaner.uobjects(player:get_pos(),name)
	end,
})

minetest.register_chatcommand("clonf", {
	description = "Object & nodes filter",
	privs={scadmin=true},
	func = function(name, param)
		local player=minetest.get_player_by_name(name)
		if not player then
			return
		end
		servercleaner.clonf(name)
	end,
})

minetest.register_tool("servercleaner:add2clonf", {
	description = "Add to input",
	inventory_image = "servercleaner_add.png",
	groups = {not_in_creative_inventory=1},
	on_drop = function(itemstack, user, pointed_thing)
		itemstack:take_item()
		return itemstack
	end,
	on_use = function(itemstack, user, pointed_thing)
		local name=user:get_player_name()
		local admin=minetest.check_player_privs(name, {scadmin=true})
		if not admin then
			minetest.chat_send_player(name,"You aren't allowed to use this")
		elseif pointed_thing.type=="object" and not pointed_thing.ref:is_player() then
			if pointed_thing.ref:get_luaentity() then
				servercleaner.clonf(name,pointed_thing.ref:get_luaentity().name)
			else
				servercleaner.uobjects(user:get_pos(),name)
				servercleaner.clonf(name)
			end
		elseif pointed_thing.type=="node" then
			local na=minetest.get_node(pointed_thing.under).name
			if minetest.registered_nodes[na] then
				servercleaner.clonf(name,na)
			else
				minetest.chat_send_player(name,"Punch it")
			end
		end
		itemstack:take_item()
		return itemstack
	end,
})