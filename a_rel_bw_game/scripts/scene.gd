extends Spatial

var iTime=0.0
var iFrame=0
var conf_clicked=false
var play_clicked=false
var is_played_once=false
var iChannel_panorama=null

func _ready():
	pass

func get_pause_anim_timer():
	return smoothstep(4.0,7.0,iTime)

func _process(delta):
	iTime+=delta
	iFrame+=1

onready var p_ex=get_node("refl_body/sup_p")
onready var right_f=get_node("floor_anix/right_f")
onready var left_f=get_node("floor_anix/left_f")
onready var spawn_group=get_node("spawn_group")

func set_particles(val):
	if(val):
		p_ex.amount=8192
		right_f.amount=18000/2
		left_f.amount=18000/2
		for a in range(spawn_group.get_child_count()):
			spawn_group.get_child(a).get_node("FutariParticles").amount=8192/2
	else:
		p_ex.amount=8192*2
		right_f.amount=18000
		left_f.amount=18000
		for a in range(spawn_group.get_child_count()):
			spawn_group.get_child(a).get_node("FutariParticles").amount=8192