servercleaner={
	players=365,
	revoke_moderator=90,
	guest=7,
	actions={},
	nodes={},
	node_actions={},
	default_privs=minetest.settings:get("default_privs") or "",
	delme={},
	}

--local servercleaner_storage=minetest.get_mod_storage()
--servercleaner_storage:set_string("players",string.gsub(servercleaner_storage:get_string("players")," " .. name .." ",""))

dofile(minetest.get_modpath("servercleaner") .. "/functions.lua")
dofile(minetest.get_modpath("servercleaner") .. "/privs_commands.lua")
dofile(minetest.get_modpath("servercleaner") .. "/register.lua")

minetest.register_lbm({
	name="servercleaner:abandoned_owners",
	nodenames=servercleaner.nodes,
	run_at_every_load=true,
	action=function(pos,node)
		servercleaner.node_actions[node.name](pos,node)
	end
})

minetest.after(0,function()
	for name, value in minetest.get_auth_handler().iterate() do
		servercleaner.outdated_player(name)
	end
end)