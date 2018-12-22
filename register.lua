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