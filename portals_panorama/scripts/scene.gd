extends Spatial

# this is VERY BAD way to make portals, each portal render its scene in own viewport
# rendering many portals at same time is big overhead
# this can be optimized by creating simple "button" to enable portal
# when player move close to door, this way will be rendered max 3 viewports at same time
# I use it because it enought for this demo

# why viewports per portal
# because https://github.com/godotengine/godot/issues/19438
# Godot do not implement Cull Mask for lights
# if you do not need own unique light per portal scene
# then all portals can exist in single viewport, single scene
# (sorting by render priority outside/inside portal)

# Panorama-shaders licence:
# License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
# (credit) original shader author linked in *.shader files
# same to static panorama images

# this project will work in GLES3 render

var mnodes=5
var area_in_state=[false,false,false,false,false]
var opt_portals=false #menu checkbox

func _ready():
	pass

func _process(delta):
	optimize_portals()
	portals_a_timers(delta)
	resolution_control()

const STRETCH_MODE_NONE = 0
const STRETCH_MODE_2D = 1 
const STRETCH_MODE_VIEWPORT = 2 
const STRETCH_ASPECT_IGNORE = 0
const STRETCH_ASPECT_KEEP = 1
var old_res=Vector2(1280,720)

func resolution_control():
	var new_res=get_viewport().size
	if((int(old_res.x)!=int(new_res.x))||(int(old_res.y)!=int(new_res.y))):
		old_res=new_res
		for a in mnodes+1:
			get_node("p"+str(a)).size=new_res
	#get_tree().set_screen_stretch(STRETCH_MODE_NONE,STRETCH_ASPECT_IGNORE,Vector2(1280,720))


func _on_Area_body_entered(body,id):
	if(body.is_in_group("spheres")):
		get_node("p"+str(id+1)+"/p"+str(id+1)+"/spheres/"+body.name).visible=true
	if(body.is_in_group("player")):
		get_node("sun_pos/b0/glow").material_override.render_priority=4
		get_node("sun_pos/b1/glow").material_override.render_priority=4
		get_node("sun_pos/b2/glow").material_override.render_priority=4
		var st=id
		for a in mnodes-1:
			st+=1
			if(st>=mnodes):st=0
			get_node("portals").get_child(st).get_node("wall/wall_out").material_override.render_priority=3
			get_node("portals").get_child(st).get_node("wall/wall_in").material_override.render_priority=1
			get_node("portals").get_child(st).get_node("wall/door_out").material_override.render_priority=4

func _on_Area_body_exited(body,id):
	if(body.is_in_group("spheres")):
		get_node("p"+str(id+1)+"/p"+str(id+1)+"/spheres/"+body.name).visible=false
	if(body.is_in_group("player")):
		get_node("sun_pos/b0/glow").material_override.render_priority=11
		get_node("sun_pos/b1/glow").material_override.render_priority=11
		get_node("sun_pos/b2/glow").material_override.render_priority=11
		var st=id
		for a in mnodes-1:
			st+=1
			if(st>=mnodes):st=0
			get_node("portals").get_child(st).get_node("wall/wall_out").material_override.render_priority=10
			get_node("portals").get_child(st).get_node("wall/wall_in").material_override.render_priority=5
			get_node("portals").get_child(st).get_node("wall/door_out").material_override.render_priority=15


func _on_Area2_body_entered(body):
	if(body.is_in_group("spheres")):
		body.visible=false


func _on_Area2_body_exited(body):
	if(body.is_in_group("spheres")):
		body.visible=true


var timers=[0,0,0,0,0]
var iTime=0
func portals_a_timers(delta):
	for a in mnodes:
		if(area_in_state[a]):
			timers[a]+=delta*0.5
		else:
			timers[a]=0
		get_node("portals").get_child(a).get_node("wall/door_out").material_override.set("shader_param/timer",timers[a])
		get_node("portals").get_child(a).get_node("wall/door_out").material_override.set("shader_param/is_opt",opt_portals)
	iTime+=delta
	


func optimize_portals():
	if(!opt_portals):return
	if(area_in_state[0]):get_node("p1").set("render_target_update_mode",Viewport.UPDATE_WHEN_VISIBLE)
	else:get_node("p1").set("render_target_update_mode",Viewport.UPDATE_DISABLED)
	if(area_in_state[1]):get_node("p2").set("render_target_update_mode",Viewport.UPDATE_WHEN_VISIBLE)
	else:get_node("p2").set("render_target_update_mode",Viewport.UPDATE_DISABLED)
	if(area_in_state[2]):get_node("p3").set("render_target_update_mode",Viewport.UPDATE_WHEN_VISIBLE)
	else:get_node("p3").set("render_target_update_mode",Viewport.UPDATE_DISABLED)
	if(area_in_state[3]):get_node("p4").set("render_target_update_mode",Viewport.UPDATE_WHEN_VISIBLE)
	else:get_node("p4").set("render_target_update_mode",Viewport.UPDATE_DISABLED)
	if(area_in_state[4]):get_node("p5").set("render_target_update_mode",Viewport.UPDATE_WHEN_VISIBLE)
	else:get_node("p5").set("render_target_update_mode",Viewport.UPDATE_DISABLED)

func _on_Area3_body_entered(body, id):
	if(body.is_in_group("player")):area_in_state[id]=true

func _on_Area3_body_exited(body, id):
	if(body.is_in_group("player")):area_in_state[id]=false
