extends Spatial

func _ready():
	pass


func sw_vis(st):
	#get_node("../bg_particles/cubes_o").visible=st
	get_node("../bg_particles/cubes_o").emitting=st
	
	get_node("../bg_particles/demo_p").visible=st
	get_node("../bg_particles/cube_repeat").visible=st
	get_node("../floor_scene").visible=st
	get_node("../particle_effects/clouds/Particles").emitting=st
	get_node("../particle_effects/clouds/Particles2").emitting=st
	get_node("../particle_effects/sparks").emitting=st
	get_node("../particle_effects/sparks_fountain").emitting=st
	get_node("../bg_particles/demo_p/sparks_fountain").emitting=st
	get_node("../particle_effects/portal").visible=st
	get_node("../particle_effects/running/Particles").emitting=st
	get_node("../particle_effects/running/character").visible=st


func _on_show_map_body_entered(body):
	if(body.is_a_parent_of(self)):
		return
	if(body.is_in_group("player")):
		sw_vis(true)
		get_node("../bg_particles/door_lines2").visible=true
		get_node("../bg_particles/door_lines").visible=true
		get_node("../bg_particles/door_lines2").emitting=true
		get_node("../bg_particles/door_lines").emitting=true


func _on_show_bg_body_entered(body):
	if(body.is_a_parent_of(self)):
		return
	if(body.is_in_group("player")):
		sw_vis(false)
		get_node("../bg_particles").show_bg=true
		get_node("../bg_particles/door_lines2").visible=true
		get_node("../bg_particles/door_lines").visible=true
		get_node("../bg_particles/door_lines2").emitting=true
		get_node("../bg_particles/door_lines").emitting=true
		get_node("../bg_particles/basic_p").visible=true
		get_node("../bg_particles/cubes").visible=true
		if(!get_node("../audio/AudioStreamPlayer3D").playing):
			get_node("../audio/AudioStreamPlayer3D").play(0)


func _on_portal_area_body_entered(body):
	if(body.is_a_parent_of(self)):
		return
	if(body.is_in_group("player")):
		get_node("../particle_effects/portal/Particles2").emitting=true


func _on_portal_area_body_exited(body):
	if(body.is_a_parent_of(self)):
		return
	if(body.is_in_group("player")):
		get_node("../particle_effects/portal/Particles2").emitting=false
