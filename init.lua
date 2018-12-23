servercleaner={
	players=365,
	revoke_moderator=90,
	guest=7,
	actions={},
	nodes={},
	node_actions={},
	default_privs=minetest.settings:get("default_privs") or "",
	delme={},
	advm_user={},
	nonexists_nodes={},
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

minetest.after(0.1,function()
	for name, value in minetest.get_auth_handler().iterate() do
		servercleaner.outdated_player(name)
	end
	servercleaner.unknownentities_handler()
	servercleaner.unknownnodes_handler()
	--for i, a in pairs(minetest.registered_lbms) do
	--	if a.name=="servercleaner:nonexists_items" then
	--		print(a.name)
	--		a.nodenames=servercleaner.nonexists_nodes
	--		break
	--	end
	--end
end)



servercleaner.nonexists_nodes2del={}

for name, value in pairs(servercleaner.storage:load("nonexists_nodes")) do
	servercleaner.nonexists_nodes2del[name]=1
	table.insert(servercleaner.nonexists_nodes,name)
end

minetest.register_lbm({
	name="servercleaner:nonexists_items",
	nodenames=servercleaner.nonexists_nodes,
	run_at_every_load=true,
	action=function(pos,node)
		if not minetest.registered_nodes[node.name] then
			minetest.remove_node(pos)
		elseif servercleaner.nonexists_nodes2del[node.name] then
			servercleaner.nonexists_nodes2del[node.name]=nil

			local exist_nodes=servercleaner.storage:load("exist_nodes")
			local nonexists_nodes=servercleaner.storage:load("nonexists_nodes")
			exist_nodes[node.name]=1
			nonexists_nodes[node.name]=nil
			servercleaner.storage:save("exist_nodes",exist_nodes)
			servercleaner.storage:save("nonexists_nodes",nonexists_nodes)
			servercleaner.nonexists_nodes[node.name]=nil
		end
	end
})