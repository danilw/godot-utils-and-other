extends Spatial

onready var floorx

onready var guyx
onready var guyx_sk
onready var lght_l
onready var lght_r
onready var ln1
onready var ln2
onready var ln3
onready var ll1
onready var ll2
onready var ll1x
onready var ll2x
onready var ll1l
onready var ll2l
onready var atr


var tube_len=0
var tube_len2=0
var tube_len3=0

var iTime=0
var bid_l=0
var bid_r=0


func _ready():
	floorx=get_node("floor")
	guyx=get_node("guy")
	guyx_sk=get_node("guy/root/RootNode/lilGuy_Reference/Node 2/Skeleton")
	bid_l=guyx_sk.find_bone("lil_guy_left_hand_11")
	bid_r=guyx_sk.find_bone("lil_guy_right_hand_17")
	lght_l=get_node("guy/root/RootNode/lilGuy_Reference/left_l")
	lght_r=get_node("guy/root/RootNode/lilGuy_Reference/left_r")
	ln1=get_node("l1")
	ln2=get_node("l2")
	ln3=get_node("l3")
	ll1=get_node("guy/root/RootNode/lilGuy_Reference/left_l/MeshInstance")
	ll2=get_node("guy/root/RootNode/lilGuy_Reference/left_r/MeshInstance")
	ll1x=get_node("guy/root/RootNode/lilGuy_Reference/Node 2/Skeleton/Mesh 32")
	ll2x=get_node("guy/root/RootNode/lilGuy_Reference/Node 2/Skeleton/Mesh 50")
	ll1l=get_node("guy/root/RootNode/lilGuy_Reference/left_l")
	ll2l=get_node("guy/root/RootNode/lilGuy_Reference/left_r")
	atr=get_node("guy/AnimationTree")
	
	#floorx.material_override.set("shader_param/sphereRad",get_node("round_l").mesh.radius/2.0)
	#floorx.material_override.set("shader_param/tubeRad1",get_node("tube").mesh.radius/2.0)
	tube_len=(get_node("l1").mesh.mid_height+get_node("l1").mesh.radius*2.0)/2.0
	tube_len2=(get_node("l2").mesh.mid_height+get_node("l2").mesh.radius*2.0)/2.0
	tube_len3=(get_node("l3").mesh.mid_height+get_node("l3").mesh.radius*2.0)/2.0
	save_ocol()

func _process(delta):
	process_anim(delta)
	process_lights(delta)
	iTime+=delta
	floorx.material_override.set("shader_param/spherePos1",guyx_sk.get_bone_global_pose(bid_l).origin/100.0)
	floorx.material_override.set("shader_param/spherePos2",guyx_sk.get_bone_global_pose(bid_r).origin/100.0)
	var rotx=ln1.rotation
	rotx = Vector3(sin(rotx.y)*cos(rotx.x),-(sin(rotx.x)),cos(rotx.x) * cos(rotx.y))*tube_len
	
	var tpos=ln1.translation
	floorx.material_override.set("shader_param/tubeStart1",tpos+rotx)
	floorx.material_override.set("shader_param/tubeEnd1",tpos-rotx)
	
	rotx=ln2.rotation
	rotx = Vector3(sin(rotx.y)*cos(rotx.x),-(sin(rotx.x)),cos(rotx.x) * cos(rotx.y))*tube_len2
	
	tpos=ln2.translation
	floorx.material_override.set("shader_param/tubeStart2",tpos+rotx)
	floorx.material_override.set("shader_param/tubeEnd2",tpos-rotx)
	
	rotx=ln3.rotation
	rotx = Vector3(sin(rotx.y)*cos(rotx.x),-(sin(rotx.x)),cos(rotx.x) * cos(rotx.y))*tube_len3
	
	tpos=ln3.translation
	floorx.material_override.set("shader_param/tubeStart3",tpos+rotx)
	floorx.material_override.set("shader_param/tubeEnd3",tpos-rotx)
	
	
func process_anim(delta):
	var pose=guyx_sk.get_bone_global_pose(bid_l)
	lght_l.transform=pose
	pose=guyx_sk.get_bone_global_pose(bid_r)
	lght_r.transform=pose

var animtimer=false
var ocol=[]
var ll1c
var ll2c

func save_ocol():
	ocol.append(floorx.material_override.get("shader_param/spherecol1"))
	ocol.append(floorx.material_override.get("shader_param/spherecol2"))
	ocol.append(floorx.material_override.get("shader_param/tubecol1"))
	ocol.append(floorx.material_override.get("shader_param/tubecol2"))
	ocol.append(floorx.material_override.get("shader_param/tubecol3"))
	floorx.material_override.set("shader_param/spherecol1",ocol[0]*0)
	floorx.material_override.set("shader_param/spherecol2",ocol[1]*0)
	floorx.material_override.set("shader_param/tubecol1",ocol[2]*0)
	floorx.material_override.set("shader_param/tubecol2",ocol[3]*0)
	floorx.material_override.set("shader_param/tubecol3",ocol[4]*0)
	ln1.material_override.emission_energy=0
	ln2.material_override.emission_energy=0
	ln3.material_override.emission_energy=0
	ll1c=ll1.material_override.get("shader_param/colorx")
	ll2c=ll2.material_override.get("shader_param/colorx")
	ll1x.material_override.emission_energy=0
	ll2x.material_override.emission_energy=0
	ll1l.light_energy=0
	ll2l.light_energy=0

var timer_x=0

func process_lights(delta):
	if(animtimer):
		timer_x=min(timer_x+delta,4)
	else:
		timer_x=max(timer_x-delta,0)
	var timerx=0
	var tx=0.0
	timerx=smoothstep(0+tx,1+tx,timer_x)
	floorx.material_override.set("shader_param/tubecol2",ocol[3]*timerx)
	floorx.material_override.set("shader_param/tubecol3",ocol[4]*timerx)
	ln2.material_override.emission_energy=timerx*3
	ln3.material_override.emission_energy=timerx*3
	tx=0.8
	timerx=smoothstep(0+tx,1+tx,timer_x)
	floorx.material_override.set("shader_param/tubecol1",ocol[2]*timerx)
	ln1.material_override.emission_energy=timerx*3
	tx=1.6
	timerx=smoothstep(0+tx,1+tx,timer_x)
	floorx.material_override.set("shader_param/spherecol1",ocol[0]*timerx)
	floorx.material_override.set("shader_param/spherecol2",ocol[1]*timerx)
	ll1.material_override.set("shader_param/colorx",ll1c*timerx)
	ll2.material_override.set("shader_param/colorx",ll2c*timerx)
	ll1x.material_override.emission_energy=timerx*3
	ll2x.material_override.emission_energy=timerx*3
	ll1l.light_energy=timerx*1.5
	ll2l.light_energy=timerx*1.5
	tx=2.4
	timerx=smoothstep(0+tx,1+tx,timer_x)
	atr.set("parameters/TimeScale/scale",timerx*0.65)
	

func _on_Area_body_entered(body):
	if(body.is_a_parent_of(self)):
		return
	if(body.is_in_group("player")):
		animtimer=true

func _on_Area_body_exited(body):
	if(body.is_a_parent_of(self)):
		return
	if(body.is_in_group("player")):
		animtimer=false
