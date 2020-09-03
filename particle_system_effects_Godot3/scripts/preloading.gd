extends Spatial

onready var global_v=get_tree().get_root().get_node("scene")
var o_rot=Vector3(0,0,0)

func expreload(val):
	get_node("../bg_particles/cubes").visible=val
	get_node("../bg_particles/basic_p").visible=val
	get_node("../bg_particles/door_lines").visible=val
	get_node("../bg_particles/door_lines2").visible=val
#	get_node("../bg_particles/door_lines2").emitting=val
#	get_node("../bg_particles/door_lines").emitting=val
	get_node("../particle_effects/portal/Particles2").emitting=val
	get_node("../decals_spawn/decal").visible=val

func load_scr(val):
	get_node("loading").visible=val

func _ready():
	expreload(true)
	#load_scr(true)
	o_rot=get_node("../Camera").get_rotation()
	get_node("../Camera").set_rotation(Vector3(0,0,0))
	

var iTime=0
var sdelta=1.0/60.0
func _process(delta):
	get_node("../Camera").rotate(Vector3.UP,sdelta*PI*2)
	iTime+=sdelta
	global_v.preload_time+=delta
	if((iTime>1)&&(!global_v.pleload_done)):
		expreload(false)
		load_scr(false)
		get_node("../Camera").set_rotation(o_rot)
		global_v.pleload_once=true
		set_process(false)



