servercleaner={
	players=365,
	revoke_moderator=90,
	guest=7,
	unknown_filtertime=150,
	actions={},
	nodes={},
	node_actions={},
	updating={},
	node_filter={},
	entity_filter={},
	default_privs=minetest.settings:get("default_privs") or "",
	server_owner={[minetest.settings:get("name")]=true,singleplayer=true},
	delme={},
	advm_user={},
	storage={
		save=function(data,key,newdata)
			data.storage:set_string(key,minetest.serialize(newdata))
		end,
		load=function(data,key,keys)
			return minetest.deserialize(data.storage:get_string(key)) or {}
		end,
		storage=minetest.get_mod_storage(),
	}
}

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

minetest.register_on_mods_loaded(function()
	servercleaner.unknownentities_handler()
	servercleaner.unknownnodes_handler()
end)

minetest.after(0.1,function()
	for name, value in minetest.get_auth_handler().iterate() do
		servercleaner.outdated_player(name)
	end
end)

if minetest.get_modpath("unified_inventory") then

unified_inventory.register_button("advm",{
	type="image",
	image="servercleaner_advm.png",
	tooltip="Advanced members handler",
	action=function(user)
		servercleaner.advm(user:get_player_name())
	end,
	condition=function(player)
		return minetest.check_player_privs(player:get_player_name(), {kick=true})
	end,
})

unified_inventory.register_button("clonf",{
	type="image",
	image="servercleaner_filter.png",
	tooltip="Nodes/objects filter",
	action=function(user)
		servercleaner.clonf(user:get_player_name())
	end,
	condition=function(player)
		return minetest.check_player_privs(player:get_player_name(), {scadmin=true})
	end,
})
end