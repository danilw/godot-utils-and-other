extends Control

onready var global_v=get_tree().get_root().get_node("scene")
onready var btns=get_node("btns")

func _ready():
	pass

func _process(delta):
	var uv=global_v.iMouse/global_v.iResolution
	uv.y=1-uv.y
	if((uv).length()<0.25):
		btns.visible=true
	else:
		btns.visible=false

func _on_debug_mid_pressed():
	get_node("../Camera/mid_debug").visible=!get_node("../Camera/mid_debug").visible


func _on_debug_mid2_pressed():
	get_node("scr").visible=!get_node("scr").visible


func _on_debug_mid3_pressed():
	get_node("audio").visible=!get_node("audio").visible
	if(get_node("audio").visible):
		get_node("../audio/AudioStreamPlayer3D").play(0)
	else:
		get_node("../audio/AudioStreamPlayer3D").stop()


func _on_debug_mid4_pressed():
	get_node("../Camera/depth_debug").visible=!get_node("../Camera/depth_debug").visible


func _on_glow_b_toggled(button_pressed):
	get_node("../Camera/").environment.glow_enabled=button_pressed
