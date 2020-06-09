extends Spatial

var blends=0
var blendx=false

onready var light_node

func _ready():
	light_node=get_node("SpotLight")

func _process(delta):
	if(blendx):
		blends+=delta
	else:
		blends+=-delta
	if(blends<=0):
		blends=0
		#light_node.visible=false
		#light_node.light_energy=blends
	else:
		blends=min(blends,1)
		#light_node.light_energy=blends


func _on_Area_body_entered(body):
	if(body.is_a_parent_of(self)):
		return
	if(body.is_in_group("player")):
		blendx=true
		#light_node.visible=true


func _on_Area_body_exited(body):
	if(body.is_a_parent_of(self)):
		return
	if(body.is_in_group("player")):
		blendx=false
