extends Spatial

var iTime_l=0
var blenda=0
var blendb=0
var blenda_s=false

onready var cnode
onready var snode
onready var s2node

func _ready():
	cnode=get_node("Cone")
	snode=get_node("Cone/shield")
	s2node=get_node("Cone/shield2")

func _process(delta):
	if(blenda_s):
		blenda+=delta*0.5
		blenda=min(blenda,1)
		iTime_l+=delta
	if(iTime_l>25):
		iTime_l+=delta
		blendb+=delta*0.5
		blendb=min(blendb,1)
		if(iTime_l>30):
			iTime_l=0
			blenda_s=false
			snode.visible=false
			s2node.visible=false
			blenda=0
			blendb=0
		
	cnode.material_override.set("shader_param/blenda",blenda)
	cnode.material_override.set("shader_param/blendb",blendb)
	cnode.material_override.set("shader_param/iTime",iTime_l)
	snode.material_override.set("shader_param/iTime",iTime_l)
	s2node.material_override.set("shader_param/iTime",iTime_l)

func _on_Area_body_entered(body):
	pass 


func _on_Area_body_exited(body):
	if(body.is_a_parent_of(self)):
		return
	if(body.is_in_group("player")):
		if(!blenda_s):
			snode.visible=true
			s2node.visible=true
			blenda_s=true
			iTime_l=0
