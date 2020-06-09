extends Navigation

# from https://github.com/godotengine/godot-demo-projects/tree/master/3d/navmesh

var SPEED = 0.0
var timer = 0.0

const min_time=1.5
const run_time=2
const walk_time=2

const walk_speed=0.35
const run_speed=1.5

var begin = Vector3()
var end = Vector3()

var path = []

onready var player
onready var wf
onready var sp
onready var wf_oscale
onready var max_l
onready var wfanim

func _ready():
	player=get_node("../Camera")
	wf=get_node("../woolf")
	sp=get_node("../spheres")
	wf_oscale=wf.get_transform().basis.get_scale()
	max_l=(player.get_node("wfp").translation).length()+0.1
	wfanim=wf.get_node("AnimationTree")

var tlook=Vector3(0,0,0)

func _process(delta):
	if path.size() > 1:
		timer+=delta
		var to_walk = delta * SPEED
		SPEED=smoothstep(0,walk_time,timer)*walk_speed
		SPEED+=smoothstep(walk_time,walk_time+run_time,timer)*run_speed
		var pa=Vector2(tlook.x,tlook.z)
		var pb=Vector2(wf.translation.x,wf.translation.z)
		SPEED=0.1*SPEED+0.9*SPEED*(clamp((pa-pb).length()-max_l-0.05,0,1))
		if((to_walk < 0.001)&&(timer>-min_time+0.5)):
			var otx=wf.get_transform()
			var otx2=wf.get_transform()
			otx2.origin=Vector3(0,0,0)
			otx2 = otx2.looking_at(otx.origin-tlook, Vector3.UP)
			var tba=Basis(wf.get_transform().basis.get_rotation_quat().slerp(otx2.basis.get_rotation_quat(),delta))
			wf.transform.basis=tba
			wf.scale=wf_oscale
		if(to_walk > 0.001):
			var to_watch = Vector3.UP
			while to_walk > 0 and path.size() >= 2:
				var pfrom = path[path.size() - 1]
				var pto = path[path.size() - 2]
				to_watch = (pto - pfrom).normalized()
				var d = pfrom.distance_to(pto)
				if d <= to_walk:
					path.remove(path.size() - 1)
					to_walk -= d
				else:
					path[path.size() - 1] = pfrom.linear_interpolate(pto, to_walk / d)
					to_walk = 0
			var atpos = path[path.size() - 1]
			var atdir = to_watch
			atdir.y = 0
			
			var t = Transform()
			var ot=wf.get_transform()
			t.origin = atpos
			t = t.looking_at(atpos - atdir, Vector3.UP)
			t.basis=Basis(ot.basis.get_rotation_quat().slerp(t.basis.get_rotation_quat(),delta*3))
			
			wf.set_transform(t)
			wf.scale=wf_oscale
			wf.translation.y=0
			var b=Vector2(sp.translation.x,sp.translation.z)
			var a=Vector2(wf.translation.x,wf.translation.z)
			wf.translation.y=clamp(9-(a-b).length(),0,1)*0.19
		
		if ((path.size() < 2)||(clamp((pa-pb).length(),0,1)<max_l)):
			path = []
	else:
		timer+=-delta
		SPEED+=-delta
		SPEED=max(SPEED,0)
		if(timer<-min_time):
			set_process(false)
		
	timer=clamp(timer,-min_time,run_time+walk_time)
	wfanim.set("parameters/anim_blend/blend_position",-0.5*(1-smoothstep(-min_time,-min_time+0.5,timer))+SPEED/(walk_speed+run_speed))
	


func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_RIGHT and event.pressed:
		begin = get_closest_point(wf.get_translation())
		end=get_closest_point(player.get_node("wfp").global_transform.origin)
		_update_path()
		

func _update_path():
	var p = get_simple_path(begin, end, true)
	path = Array(p) # Vector3 array too complex to use, convert to regular array.
	path.invert()
	set_process(true)
	tlook=Vector3(player.translation.x,0,player.translation.z)
