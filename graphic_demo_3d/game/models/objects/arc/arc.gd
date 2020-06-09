extends Spatial

var state_o=[true,false,false,false] # [white,blue,green,red]
var state_n=Color(1,0,0,0)

const fspeed=1
const gspeed=1.5

onready var nodef=[]
onready var nodel=[]
onready var vps
var ppos=[0,0]
var ppos2=[0,0]

var iTime=0

func _ready():
	nodef.append(get_node("f1"))
	nodef.append(get_node("f2"))
	nodef.append(get_node("f3"))
	nodef.append(get_node("f4"))
	nodef.append(get_node("f5"))
	nodel.append(get_node("l1"))
	nodel.append(get_node("l4"))
	nodel.append(get_node("l2"))
	nodel.append(get_node("l3"))
	vps=get_node("viewport/Sprite")

func _process(delta):
	iTime+=delta
	nodel[1].material_override.set("shader_param/iTime",iTime)
	vps.material.set("shader_param/delta",delta)
	vps.material.set("shader_param/ppos",PoolIntArray(ppos))
	vps.material.set("shader_param/ppos2",PoolIntArray(ppos2))
	
	for a in range(4):
		if(state_o[a]):
			state_n[a]+=delta*gspeed
		else:
			state_n[a]-=delta*fspeed
		state_n[a]=clamp(state_n[a],0,1)
	for a in range(4):
		nodef[a].material_override.set("shader_param/blendx",state_n)
		if(state_n[a]>0):
			nodel[a].get_child(0).visible=true
			nodel[a].get_child(0).light_energy=state_n[a]
			if(a==1):
				nodel[a].material_override.set("shader_param/blendx",state_n)
			else:
				nodel[a].material_override.emission_energy=state_n[a]*10
		else:
			nodel[a].get_child(0).visible=false
			if(a==1):
				nodel[a].material_override.set("shader_param/blendx",state_n)
			else:
				nodel[a].material_override.emission_energy=state_n[a]*10
	nodef[4].material_override.set("shader_param/blendx",state_n)
	

func update_ppos(pposx):
	ppos[0]=pposx.x
	ppos[1]=pposx.y

func update_ppos2(pposx):
	ppos2[0]=pposx.x
	ppos2[1]=pposx.y

func _on_Areao_body_entered(body):
	if(body.is_a_parent_of(self)):
		return
	if(body.is_in_group("player")):
		state_o[0]=true
		state_o[1]=false
		state_o[2]=false
		state_o[3]=false


func _on_Areao_body_exited(body):
	pass


func _on_Areagreen_body_entered(body):
	if(body.is_a_parent_of(self)):
		return
	if(body.is_in_group("player")):
		state_o[2]=true
		state_o[0]=false
		state_o[1]=false
#		state_o[3]=false


func _on_Areagreen_body_exited(body):
	pass


func _on_Areared_body_entered(body):
	if(body.is_a_parent_of(self)):
		return
	if(body.is_in_group("player")):
		state_o[3]=true
		state_o[0]=false
		state_o[1]=false
#		state_o[2]=false


func _on_Areared_body_exited(body):
	pass


func _on_Areablue_body_entered(body):
	if(body.is_a_parent_of(self)):
		return
	if(body.is_in_group("player")):
		state_o[0]=false
		state_o[1]=true
		state_o[2]=false
		state_o[3]=false


func _on_Areablue_body_exited(body):
	pass
