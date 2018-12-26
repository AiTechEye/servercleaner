servercleaner.clonf=function(username,text)
	servercleaner.advm_user[username]=servercleaner.advm_user[username] or {list={},index=1,filter=1}

	local filter=servercleaner.advm_user[username].filter
	text=text or ""
	local gui="size[20,10]"

	.. "textlist[0,-0.3;2.5,2.3;filter;All,#FF8888Unknown Nodes,#8833FFUnknown Objects,#ff7700Exists nodes,#FFFF00Exists entities;1]"
	.. "button[3,-0.2;1.3,1;del;Delete]"
	.. "button[4,-0.2;1.3,1;sca;Scan]"
	.. "field[5.3,0;3,1;addinput;;" .. text .. "]"
	.. "item_image_button[7.8,-0.2;1.3,1;servercleaner:add2clonf;addbyit;]"

	local list=""
	local n=0
	local all={}

	if filter==1 or filter==4 then
		for name, value in pairs(servercleaner.node_filter) do
			n=n+1
			list=list .. "#ff7700" .. name .. ","
			table.insert(all,{name=name,change="node_filter",globallist="node_filter"})
		end
	end
	if filter==1 or filter==5 then
		for name, value in pairs(servercleaner.entity_filter) do
			n=n+1
			list=list .. "#FFFF00" .. name .. ","
			table.insert(all,{name=name,change="entity_filter",globallist="entity_filter"})
		end
	end
	if filter==1 or filter==2 then
		for name, value in pairs(servercleaner.storage:load("nonexists_nodes")) do
			n=n+1
			list=list .. "#FF8888" .. name .."            " .. os.date("!%Y-%m-%d %H:%M.%S",value) .. ","
			table.insert(all,{name=name,change="nonexists_nodes"})
		end
	end
	if filter==1 or filter==3 then
		for name, value in pairs(servercleaner.storage:load("nonexists_entities")) do
			n=n+1
			list=list .. "#8833FF" .. name .."            " .. os.date("!%Y-%m-%d %H:%M.%S",value) .. ","
			table.insert(all,{name=name,change="nonexists_entities"})
		end
	end
	list=list:sub(0,list:len()-1)

	gui=gui .. "textlist[0,2;20,8;list;" .. list .."]"
	.. "label[3,1.5;" .. minetest.colorize("#00FF00",n) .. "]"
	.."tooltip[addinput;Filter: Type an existing node or entity and press Enter]"

	servercleaner.advm_user[username].list=all

	minetest.after(0.1, function(gui,username)
		if servercleaner.advm_user[username] then
			return minetest.show_formspec(username, "servercleaner.clonf",gui)
		end
	end, gui,username)
end



servercleaner.advm=function(username,msg,text)
	msg=msg or ""
	text=text or ""
	local p=minetest.get_player_privs(username)
	servercleaner.advm_user[username]=servercleaner.advm_user[username] or {index=1,pfilter=1,id=0}

	local gui="size[20,10]"

	.. "label[0,1.5;" .. minetest.colorize("#ff7700","Owner") .. "]"
	.. "label[0.8,1.5;" .. minetest.colorize("#8833FF","scadmin") .. "]"
	.. "label[1.8,1.5;" .. minetest.colorize("#FF8888","scmoderator") .. "]"
	.. "label[3.2,1.5;" .. minetest.colorize("#777777","not defined") .. "]"
	.. "label[4.5,1.5;" .. minetest.colorize("#7777FF","new") .. "]"
	.. "label[5,1.5;" .. minetest.colorize("#00FF00",msg) .. "]"

	 .. "textlist[0,-0.3;2.5,1.7;pfilter;Advanced members,Active players;" .. servercleaner.advm_user[username].pfilter .. "]"
	.. (p.ban and "textlist[2.5,-0.3;2.5,1.7;del;Delete," .. (p.scadmin and "Downgrad to player" or "") .."]" or "")
	.. (p.privs and "textlist[5,-0.3;2.5,1.7;addadv;#FF8888+ scmoderator,#FF8888- scmoderator,#8833FF+ scadmin,#8833FF- scadmin,+ dont_delete #,- dont_delete #]" or "")
	.. (p.privs and "button[7.5,0.4;1,1;grant;Grant]" or "")
	.. (p.privs and "button[8.2,0.4;1.3,1;revoke;Revoke]" or "")

	.. "button[13,-0.3;2,1;clearob;ClObjects]"

	.. "field[10.5,0.7;3,1;cmdtext;;" .. text .. "]"


	local dprivs=minetest.string_to_privs(servercleaner.default_privs)
	local all={}
	local list=""
	local is=0
	local cmds=","
	local privslist=""


	if servercleaner.advm_user[username].pfilter==1 then
		for name, value in minetest.get_auth_handler().iterate() do
			local privs=minetest.get_player_privs(name)
			for priv, tr in pairs(privs) do
				if not dprivs[priv] and priv~="scguest" then
					is=is+1
					local p2s=name .. (privs.dont_delete and "  #  " or "     ")  .. minetest.privs_to_string(privs):gsub(","," ") ..","

					list=list .. ((servercleaner.server_owner[name] and "#ff7700") or (privs.scadmin and "#8833FF") or (privs.scmoderator and "#FF8888") or "#777777") .. p2s

					all[is]=name
					break
				end
			end
		end

	else

		for _, player in pairs(minetest.get_connected_players()) do
			local name=player:get_player_name()
			local privs=minetest.get_player_privs(name)
			is=is+1
			local pset
			local p2s=name .. (privs.dont_delete and "  #  " or "     ") .. minetest.privs_to_string(privs):gsub(","," ") ..","

			if servercleaner.server_owner[name] then
				list=list .. "#ff7700" .. p2s
				pset=true
			elseif privs.scadmin then
				list=list .. "#8833FF" .. p2s
				pset=true
			elseif privs.scmoderator then
				list=list  .."#FF8888" .. p2s
				pset=true
			else
				for priv, tr in pairs(privs) do
					if not dprivs[priv] and priv~="scguest" then
						list=list .."#777777" .. p2s
						pset=true
						break
					end
				end
			end
			if privs.scguest and not pset then
				list=list .."#7777FF" .. p2s
			elseif not pset then
				list=list .. p2s
			end
			all[is]=name
		end

	end


	for name, value in pairs(minetest.registered_privileges) do
		privslist=privslist .. name .. ","
	end
	for name, v in pairs(minetest.registered_chatcommands) do
		if minetest.check_player_privs(username, v.privs) then
			cmds=cmds .. name .. ","
		end
	end

	cmds=cmds:sub(0,cmds:len()-1)
	list=list:sub(0,list:len()-1)
	privslist=privslist:sub(0,privslist:len()-1)

	gui=gui .. "textlist[0,2;20,8;members;" .. list .."]"
	.. (p.privs and "dropdown[7.5,-0.2;3,1;privs;" .. privslist ..";1]" or "")
	.. "dropdown[10.3,-0.2;3,1;cmdname;" .. cmds ..";1]"

	servercleaner.advm_user[username].list=all

	minetest.after(0.1, function(gui,username)
		if servercleaner.advm_user[username] then
			return minetest.show_formspec(username, "servercleaner.advm",gui)
		end
	end, gui,username)

	if servercleaner.advm_user[username].pfilter==2 then
		local id=servercleaner.advm_user[username].id
		minetest.after(1, function(username,msg,id)
			if servercleaner.advm_user[username]
			and servercleaner.advm_user[username].id==id
			and servercleaner.advm_user[username].pfilter==2 then
				servercleaner.advm(username,msg)
			end
		end, username,msg,id)
	end
end

servercleaner.runcmd=function(cmd,name,param)
	local c=minetest.registered_chatcommands[cmd]
	if not c then
		minetest.chat_send_all("<"..name.."> " .. cmd .." " .. param)
		return "<"..name.."> " .. cmd .." " .. param
	end
	local p1=minetest.check_player_privs(name, c.privs)
	local msg=""
	local a
	if not p1 then
		msg="You aren't' allowed to do that"
	elseif c then
		a,msg=c.func(name,param)
		msg=msg or ""
		minetest.chat_send_player(name,msg)

	end
	return msg
end

minetest.register_on_player_receive_fields(function(user, form, pressed)

	if form=="servercleaner.advm" then
		local name=user:get_player_name()
		if (pressed.quit and not pressed.key_enter) or not servercleaner.advm_user[name] then
			servercleaner.advm_user[name]=nil
			return
		elseif pressed.members and pressed.members~="IMV" then
			local n=pressed.members:gsub("CHG:","")
			servercleaner.advm_user[name].index=tonumber(n)
			local mname=servercleaner.advm_user[name].list[tonumber(n)]
			if not mname then
				return
			end
			local p=minetest.privs_to_string(minetest.get_player_privs(mname))
			local gp=p:gsub(",",", ")
			minetest.chat_send_player(name,"Privileges of " .. minetest.colorize("#00ff00",mname) .. "\n" .. gp)
			servercleaner.advm_user[name].id=servercleaner.advm_user[name].id+1
			servercleaner.advm(name,gp)
			return
		elseif pressed.pfilter and pressed.pfilter~="IMV" then
			local n=pressed.pfilter:gsub("CHG:","")
			servercleaner.advm_user[name].pfilter=tonumber(n)
			servercleaner.advm_user[name].id=servercleaner.advm_user[name].id+1
			servercleaner.advm(name)
			return
		end


		local mname=servercleaner.advm_user[name].list[servercleaner.advm_user[name].index]
		local msg=""
		local text=""
		if not mname then
			return
		end

		if not pressed.key_enter and pressed.cmdname and pressed.cmdname~="" then
			local c=minetest.registered_chatcommands[pressed.cmdname]
			if c then
				msg=c.params
				text=pressed.cmdname
			end
		elseif pressed.cmdtext and pressed.key_enter and pressed.cmdtext:len()>0 then
			local a=pressed.cmdtext
			msg=servercleaner.runcmd(a:find(" ") and a:sub(1,a:find(" ")-1) or a,name,a:find(" ") and a:sub(a:find(" ")+1,a:len()) or "")
		elseif pressed.clearob then
			msg=servercleaner.runcmd("clobjects",name,"")
		elseif pressed.grant then
			msg=servercleaner.runcmd("grant",name,mname .." " .. pressed.privs)
		elseif pressed.revoke then
			msg=servercleaner.runcmd("revoke",name,mname .." " .. pressed.privs)
		elseif pressed.del=="CHG:1" then
			msg=servercleaner.runcmd("delplayer",name,mname)
			minetest.after(1.1, function(name,msg)
				if servercleaner.advm_user[name] then
					servercleaner.advm_user[name].id=servercleaner.advm_user[name].id+1
					servercleaner.advm(name,msg)
				end
			end, name,msg)
			return
		elseif pressed.del=="CHG:2" then
			msg=servercleaner.runcmd("delmod",name,mname)
		elseif pressed.addadv=="CHG:1" then
			msg=servercleaner.runcmd("grant",name,mname .." scmoderator")
		elseif pressed.addadv=="CHG:2" then
			msg=servercleaner.runcmd("revoke",name,mname .." scmoderator")
		elseif pressed.addadv=="CHG:3" then
			msg=servercleaner.runcmd("grant",name,mname .." scadmin")
		elseif pressed.addadv=="CHG:4" then
			msg=servercleaner.runcmd("revoke",name,mname .." scadmin")
		elseif pressed.addadv=="CHG:5" then
			msg=servercleaner.runcmd("grant",name,mname .." dont_delete")
		elseif pressed.addadv=="CHG:6" then
			msg=servercleaner.runcmd("revoke",name,mname .." dont_delete")
		else
			return
		end

		if (pressed.del or pressed.addadv) then
			minetest.close_formspec(name,"servercleaner.advm")
		end

		msg=msg:gsub("%[","|")
		msg=msg:gsub("%]","|")

		servercleaner.advm_user[name].id=servercleaner.advm_user[name].id+1
		servercleaner.advm(name,msg,text)
	elseif form=="servercleaner.clonf" then
		local name=user:get_player_name()
		if (pressed.quit and not pressed.key_enter) or not servercleaner.advm_user[name] then
			servercleaner.advm_user[name]=nil
			return
		elseif pressed.del then
			local ob=servercleaner.advm_user[name].list[servercleaner.advm_user[name].index]
			local storage=servercleaner.storage:load(ob.change)
			storage[ob.name]=nil
			servercleaner.storage:save(ob.change,storage)
			if ob.globallist then
				servercleaner[ob.globallist][ob.name]=nil
			end
			servercleaner.clonf(name)
		elseif pressed.addinput and pressed.addinput~="" and pressed.addinput~="__builtin:item" and pressed.key_enter then
			local no=minetest.registered_nodes[pressed.addinput]
			local en=minetest.registered_entities[pressed.addinput]
			local it
			if not (en or no) then
				servercleaner.clonf(name,"Doesn't exists")
				return
			elseif en then
				local storage=servercleaner.storage:load("entity_filter")
				storage[pressed.addinput]=1
				servercleaner.storage:save("entity_filter",storage)
				servercleaner["entity_filter"][pressed.addinput]=1
				servercleaner.clonf(name)
				minetest.registered_entities[pressed.addinput].on_activate=function(self)
					self.object:remove()
				end
				minetest.registered_entities[pressed.addinput].on_step=function(self)
					self.object:remove()
				end
			end
			if no then
				local storage=servercleaner.storage:load("node_filter")
				storage[pressed.addinput]=1
				servercleaner.storage:save("node_filter",storage)
				servercleaner["node_filter"][pressed.addinput]=1
				servercleaner.clonf(name)
			end
			servercleaner.clonf(name)
		elseif pressed.list and pressed.list.members~="IMV" then
			local n=pressed.list:gsub("CHG:","")
			servercleaner.advm_user[name].index=tonumber(n)
		elseif pressed.sca then
			servercleaner.runcmd("clobjects",name,"")
			servercleaner.clonf(name)
		elseif pressed.filter then
			local n=pressed.filter:gsub("CHG:","")
			servercleaner.advm_user[name].filter=tonumber(n)
			servercleaner.clonf(name)
		elseif pressed.addbyit then
			user:get_inventory():add_item("main", ItemStack("servercleaner:add2clonf"))
			minetest.close_formspec(name,"servercleaner.clonf")
		end
	end
end)

minetest.register_on_newplayer(function(player)
	minetest.after(0.1,function(player)
		local name=player:get_player_name()
		local privs=minetest.get_player_privs(name)
		privs.scguest=true
		minetest.set_player_privs(name,privs)
	end,player)
end)


minetest.register_on_punchnode(function(pos,node,player,pointed_thing)
	if not minetest.registered_nodes[node.name] then
		local exist_nodes=servercleaner.storage:load("exist_nodes")
		local nonexists_nodes=servercleaner.storage:load("nonexists_nodes")
		local n=0
		for y=-50,50,1 do
		for x=-50,50,1 do
		for z=-50,50,1 do
			local p={x=pos.x+x,y=pos.y+y,z=pos.z+z}
			local cc=vector.length(vector.new({x=x,y=y,z=z}))/50
			local name=minetest.get_node(p).name
			if not minetest.registered_nodes[name] then
				if not nonexists_nodes[name] then
					n=n+1
				end
				nonexists_nodes[name]=os.time()
				exist_nodes[name]=nil
				minetest.remove_node(p)
			end
		end
		end
		end
		servercleaner.storage:save("exist_nodes",exist_nodes)
		servercleaner.storage:save("nonexists_nodes",nonexists_nodes)
		minetest.chat_send_player(player:get_player_name(),n .. " unknown nodes added to the filter and will be automatically removed to next start")
		servercleaner.uobjects(pos,player:get_player_name())
	end
end)

servercleaner.uobjects=function(pos,name)
	local exist_entities=servercleaner.storage:load("exist_entities")
	local nonexists_entities=servercleaner.storage:load("nonexists_entities")
	local n=0
	for _, ob in ipairs(minetest.get_objects_inside_radius(pos, 100)) do
		if not (ob:is_player() or minetest.registered_entities[ob:get_entity_name()]) then
			local en=ob:get_entity_name()
			if not nonexists_entities[en] then
				n=n+1
			end
			nonexists_entities[en]=os.time()
			exist_entities[en]=nil
			ob:remove()
		end
	end
	if n>0 then
		servercleaner.storage:save("exist_entities",exist_entities)
		servercleaner.storage:save("nonexists_entities",nonexists_entities)
		minetest.chat_send_player(name,n .. " unknown objects added to the filter and will be automatically removed to next start")
	end
end

minetest.register_on_joinplayer(function(player)
	local name=player:get_player_name()
	local privs=minetest.get_player_privs(name)
	if privs.scguest then
		privs.scguest=nil
		minetest.set_player_privs(name,privs)
	end
end)

minetest.register_on_leaveplayer(function(player)
	local name=player:get_player_name()
	if servercleaner.advm_user[name] then
		servercleaner.advm_user[name]=nil
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
	if not a or servercleaner.server_owner[name] then
		return
	end
	local diff=os.difftime(os.time(), a.last_login) / (24 * 60 * 60)
	if diff>=servercleaner.players then
		servercleaner.delete_player(name)
	elseif diff>=servercleaner.guest and minetest.check_player_privs(name, {scguest=true}) and not minetest.check_player_privs(name, {scadmin=true}) then
		servercleaner.delete_player(name)
	elseif diff>servercleaner.revoke_moderator and minetest.check_player_privs(name, {scmoderator=true}) and not minetest.check_player_privs(name, {dont_delete=true}) then
		local privs=minetest.string_to_privs(servercleaner.default_privs)
		minetest.set_player_privs(name,privs)
		minetest.log("Moderator " .. name .."downgraded to player (" .. servercleaner.revoke_moderator .. " days expired)")
	end
end

servercleaner.delete_player=function(name,by)
	if minetest.check_player_privs(name, {dont_delete=true}) or servercleaner.server_owner[name] then
		if by then
			minetest.chat_send_player(by,"player " .. name .. ((servercleaner.server_owner[name] and " is serverowner") or " has the dont_delete privilege") .. ", and will not be deleted")
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

servercleaner.unknownnodes_handler=function()
	local remove_nodes={}
	local exist_nodes=servercleaner.storage:load("exist_nodes")
	local nonexists_nodes=servercleaner.storage:load("nonexists_nodes")
	for name, value in pairs(minetest.registered_nodes) do
		exist_nodes[name]=1
		nonexists_nodes[name]=nil
	end
	for name, value in pairs(exist_nodes) do
		if not minetest.registered_nodes[name] then
			nonexists_nodes[name]=os.time()
			exist_nodes[name]=nil
		end
	end

	for name, value in pairs(nonexists_nodes) do
		if value==1 then
			nonexists_nodes[name]=os.time()
		elseif (os.difftime(os.time(), value) / (24 * 60 * 60))>servercleaner.unknown_filtertime then
			nonexists_nodes[name]=nil
		end
		table.insert(remove_nodes,name)
	end

	servercleaner.storage:save("exist_nodes",exist_nodes)
	servercleaner.storage:save("nonexists_nodes",nonexists_nodes)

	for name, value in pairs(servercleaner.storage:load("node_filter")) do
		servercleaner.node_filter[name]=value
		table.insert(remove_nodes,name)
	end

	minetest.register_lbm({
		name=":servercleaner:nonexists_nodes",
		nodenames=remove_nodes,
		run_at_every_load=true,
		action=function(pos,node)
			minetest.remove_node(pos)
			if servercleaner.node_filter[node.name] then
			elseif not servercleaner.updating.nodes then
				servercleaner.updating.nodes={[node.name]=os.time()}
				minetest.after(5,function()
					local nonexists_nodes=servercleaner.storage:load("nonexists_nodes")
					for name, value in pairs(servercleaner.updating.nodes) do
						nonexists_nodes[name]=value
					end
					servercleaner.storage:save("nonexists_nodes",nonexists_nodes)
					servercleaner.updating.nodes=nil
				end)
			else
				servercleaner.updating.nodes[node.name]=os.time()
			end
		end
	})
end

servercleaner.unknownentities_handler=function()
	local exist_entities=servercleaner.storage:load("exist_entities")
	local nonexists_entities=servercleaner.storage:load("nonexists_entities")

	for name, value in pairs(minetest.registered_entities) do
		exist_entities[name]=1
		nonexists_entities[name]=nil
	end

	for name, value in pairs(exist_entities) do
		if not minetest.registered_entities[name] then
			nonexists_entities[name]=os.time()
			exist_entities[name]=nil
		end
	end

	for name, value in pairs(nonexists_entities) do
		if value==1 then
			nonexists_entities[name]=os.time()
		elseif (os.difftime(os.time(), value) / (24 * 60 * 60))>servercleaner.unknown_filtertime then
			nonexists_entities[name]=nil
		end

		minetest.register_entity(":" .. name,{
			on_activate=function(self)
				if not servercleaner.updating.entities then
					servercleaner.updating.entities={[self.name]=os.time()}
					minetest.after(5,function()
						local nonexists_entities=servercleaner.storage:load("nonexists_entities")
						for name, value in pairs(servercleaner.updating.entities) do
							nonexists_entities[name]=value
						end
						servercleaner.storage:save("nonexists_entities",nonexists_entities)
						servercleaner.updating.entities=nil
					end)
				else
					servercleaner.updating.entities[self.name]=os.time()
				end
				self.object:remove()
			end
		})
	end
	servercleaner.storage:save("exist_entities",exist_entities)
	servercleaner.storage:save("nonexists_entities",nonexists_entities)
	for name, value in pairs(servercleaner.storage:load("entity_filter")) do
		servercleaner.entity_filter[name]=value
		minetest.register_entity(":" .. name,{
			on_activate=function(self)
				self.object:remove()
			end
		})
	end
end