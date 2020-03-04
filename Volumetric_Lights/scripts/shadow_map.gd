extends Spatial

# configure:
# set all visible objects for volume lights, its VisualInstance Layer to 2

export var color=Color("5b5aff")

# this is not best solution, but it works
# better solution can use single camera(instead of cubemap)
# and make everything in DEPTH buffer

# shader logic is "sampling depth arround light" in main camera view
# minimal example of that logic https://www.shadertoy.com/view/XsKGRz

# self https://github.com/danilw/godot-utils-and-other
# Licence: no licence, use it as you wish.

# twitter.com/AruGL

# GLES2 build does not work in Web because this bug https://github.com/godotengine/godot/issues/36786
# for Web-export used GLES3(WebGl2)

# camera far
const far=10
onready var start_pos=self.get_node("../light_pos/light1").translation

var iTime=0.0
onready var cameras=Array()
onready var control=self.get_node("../Control")
func _ready():
	self.visible=true
	for a in self.get_child_count():
		if(self.get_child(a).get_child_count()>0):
			if(self.get_child(a).get_child(0) is Camera):
				cameras.append(self.get_child(a).get_child(0))
	
	for a in cameras:
		a.far=far
		a.translation=start_pos
	self.translation=start_pos
	
	update_color(color)
	self.get_node("../Control/elems/ColorPickerButton").color=color
	

func update_color(colorx):
	self.get_node("OmniLight").light_color=colorx
	self.get_node("MeshInstance").material_override.set("shader_param/colorx",colorx)
	self.get_node("../Camera/vlights").material_override.set("shader_param/colorx",colorx)


func _process(delta):
	if(!control.stop_all):
		iTime+=delta
		self.translation.x=start_pos.x+sin(iTime*0.5)
		self.translation.z=start_pos.z+2*cos(iTime*0.5)
	for a in cameras:
		a.translation.x=self.translation.x
		a.translation.z=self.translation.z

