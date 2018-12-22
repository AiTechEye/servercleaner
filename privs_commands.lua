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
		elseif minetest.check_player_privs(param, {scadmin=true}) then
			return false,"can't delete admin"
			
		else
			servercleaner.delete_player(param,name)
		end
	end,
})

minetest.register_chatcommand("delmod", {
	params = "<playername>",
	description = "Downgrad moderator to player (has the scmoderator privilege)",
	privs = {scadmin = true},
	func = function(name, param)
		if param=="" then
			return false
		elseif not minetest.player_exists(param) then
			return false, "player doesnt exist"
		elseif minetest.check_player_privs(param, {dont_delete=true}) then
			return false,"player " .. param .. " has the dont_delete privilege"
		elseif not minetest.check_player_privs(param, {scmoderator=true}) then
			return false, "player " .. param .. " dont have the scmoderator privilege"
		else
			local privs=minetest.string_to_privs(servercleaner.default_privs)
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