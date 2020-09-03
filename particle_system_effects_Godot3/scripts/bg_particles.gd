extends Spatial

onready var cnode=get_node("cubes")
onready var cnode2=get_node("cubes_o")
onready var bnode=get_node("basic_p")
onready var crnode=get_node("cube_repeat")
onready var crnode2=get_node("cube_repeat/cube")
onready var crnode22=get_node("cube_repeat/cube2")
onready var dnode=get_node("door_lines")
onready var dnode2=get_node("door_lines2")

onready var camnode=get_node("../Camera")

onready var demnode=get_node("demo_p/cube")
onready var demnode2=get_node("demo_p/line_glow")

onready var demofount=get_node("demo_p/sparks_fountain")

func _ready():
	pass

var iTime=0
var iFrame=0
var iTime_bg=0

var show_bg=false

func _process(delta):
		
	iTime+=delta
	iFrame+=1
	if(show_bg):
		iTime_bg+=delta
	cnode.material_override.set("shader_param/iTime",iTime_bg)
	cnode.process_material.set("shader_param/iTime",iTime_bg)
	cnode.material_override.set("shader_param/cam_pos",camnode.translation)
	cnode2.material_override.set("shader_param/cam_pos",camnode.translation)
	
	demnode.material_override.set("shader_param/cam_pos",camnode.translation)
	demnode2.material_override.set("shader_param/cam_pos",camnode.translation)
	
	dnode.material_override.set("shader_param/cam_pos",camnode.translation)
	dnode2.material_override.set("shader_param/cam_pos",camnode.translation)
	
	demofount.material_override.set("shader_param/cam_pos",camnode.translation)
	demofount.material_override.set("shader_param/iTime",iTime)
	
	bnode.material_override.set("shader_param/iTime",max(iTime_bg-30,0)+27.1*2)
	bnode.process_material.set("shader_param/iTime",max(iTime_bg-30,0)+27.1*2)
	
	crnode.material_override.set("shader_param/iTime",iTime)
	crnode.process_material.set("shader_param/iTime",iTime)
	crnode2.material_override.set("shader_param/iTime",iTime)
	crnode22.material_override.set("shader_param/iTime",iTime)

	
