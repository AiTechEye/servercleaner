servercleaner.advm=function(username,msg)
	msg=msg or ""
	local p=minetest.get_player_privs(username)
	local gui="size[20,10]"

	.. "label[0,1.5;" .. minetest.colorize("#8833FF","scadmin") .. "]"
	.. "label[1.3,1.5;" .. minetest.colorize("#FF8888","scmoderator") .. "]"
	.. "label[3,1.5;" .. minetest.colorize("#777777","not defined") .. "]"
	.. "label[4.5,1.5;" .. minetest.colorize("#00FF00",msg) .. "]"
	.. (p.scadmin and "button[0,0;3,1;del;Delete]" or "")
	.. (p.scadmin and "button[0,0.7;3,1;delmod;Downgrad to player]" or "")
	.. (p.privs and "button[3,0;3,1;gmod;Grant scmoderator]" or "")
	.. (p.privs and "button[3,0.7;3,1;rmod;Revoke scmoderator]" or "")
	.. (p.privs and "button[6,0;3,1;gad;Grant scadmin]" or "")
	.. (p.privs and "button[6,0.7;3,1;rad;Revoke scadmin]" or "")
	.. (p.privs and "button[9,0;3,1;gd;Grant dont_delete #]" or "")
	.. (p.privs and "button[9,0.7;3,1;rd;Revoke dont_delete #]" or "")
	.. (p.privs and "button[12,0;2,1;grant;Grant:]" or "")
	.. (p.privs and "button[12,0.7;2,1;revoke;Revoke:]" or "")

	local dprivs=minetest.string_to_privs(servercleaner.default_privs)
	local all={}
	local list=""
	local is=0
	local privslist=""

	for name, value in minetest.get_auth_handler().iterate() do
		local privs=minetest.get_player_privs(name)
		for priv, tr in pairs(privs) do
			if not dprivs[priv] and priv~="scguest" then
				is=is+1
				local p2s=name
				if privs.dont_delete then
					p2s=p2s .."  #  "
				else
					p2s=p2s .."     "
				end

				p2s=p2s .. minetest.privs_to_string(privs):gsub(","," ") ..","

				if privs.scadmin then
					list=list .. "#8833FF" .. p2s
				elseif privs.scmoderator then
					list=list  .."#FF8888" .. p2s
				else
					list=list .."#777777" .. p2s
				end
				all[is]=name
				break
			end
		end
	end

	for name, value in pairs(minetest.registered_privileges) do
		privslist=privslist .. name .. ","
	end

	list=list:sub(0,list:len()-1)
	privslist=privslist:sub(0,privslist:len()-1)

	gui=gui .. "textlist[0,2;20,8;members;" .. list .."]"
	.. (p.privs and "dropdown[14,0;3,1;privs;" .. privslist ..";1]" or "")

	servercleaner.advm_user[username]=servercleaner.advm_user[username] or {index=1}
	servercleaner.advm_user[username].list=all
	minetest.after(0.1, function(gui,username)
			return minetest.show_formspec(username, "servercleaner.advm",gui)
	end, gui,username)
end

servercleaner.runcmd=function(cmd,name,param)
	local c=minetest.registered_chatcommands[cmd]
	local p1,p2=minetest.check_player_privs(name, minetest.get_player_privs(name))
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
		if pressed.quit or not servercleaner.advm_user[name] then
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
			servercleaner.advm(name,gp)
			return
		end
		local mname=servercleaner.advm_user[name].list[servercleaner.advm_user[name].index]
		local msg=""

		if pressed.grant then
			msg=servercleaner.runcmd("grant",name,mname .." " .. pressed.privs)
		elseif pressed.revoke then
			msg=servercleaner.runcmd("revoke",name,mname .." " .. pressed.privs)
		elseif pressed.del then
			msg=servercleaner.runcmd("delplayer",name,mname)
			minetest.after(1.1, function(name,msg)
				if servercleaner.advm_user[name] then
					servercleaner.advm(name,msg)
				end
			end, name,msg)
			return
		elseif pressed.delmod then
			msg=servercleaner.runcmd("delmod",name,mname)
		elseif pressed.gmod then
			msg=servercleaner.runcmd("grant",name,mname .." scmoderator")
		elseif pressed.gad then
			msg=servercleaner.runcmd("grant",name,mname .." scadmin")
		elseif pressed.rmod then
			msg=servercleaner.runcmd("revoke",name,mname .." scmoderator")
		elseif pressed.rad then
			msg=servercleaner.runcmd("revoke",name,mname .." scadmin")
		elseif pressed.gd then
			msg=servercleaner.runcmd("grant",name,mname .." dont_delete")
		elseif pressed.rd then
			msg=servercleaner.runcmd("revoke",name,mname .." dont_delete")
		else
			return
		end
		servercleaner.advm(name,msg)
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
		local privs=minetest.string_to_privs(servercleaner.default_privs)
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