extends Control

var stop_all=false

onready var elems=self.get_node("elems")
onready var vport=Array()

func _ready():
	for a in get_node("../shadow_map").get_child_count():
		if(get_node("../shadow_map").get_child(a) is Viewport):
			vport.append(get_node("../shadow_map").get_child(a))

func _process(delta):
	var tdelta=max(0.001,delta) #against WASM build
	get_node("fps").text="FPS: "+str(int(1/tdelta))

func _on_debug_pressed():
	elems.visible=!elems.visible


func _on_CheckBox3_toggled(button_pressed):
	if(!button_pressed):
		stop_all=true
		for a in vport:
			a.render_target_update_mode=Viewport.UPDATE_DISABLED
	else:
		stop_all=false
		for a in vport:
			a.render_target_update_mode=Viewport.UPDATE_ALWAYS


func _on_CheckBox6_toggled(button_pressed):
	get_node("../Camera/vlights").visible=!button_pressed
	if(button_pressed):
		get_node("elems/CheckBox3").disabled=true
		stop_all=true
		for a in vport:
			a.render_target_update_mode=Viewport.UPDATE_DISABLED
	else:
		get_node("elems/CheckBox3").disabled=false
		if(get_node("elems/CheckBox3").pressed):
			stop_all=false
			for a in vport:
				a.render_target_update_mode=Viewport.UPDATE_ALWAYS


func _on_CheckBox2_toggled(button_pressed):
	if(button_pressed):
		get_node("elems/CheckBox").pressed=false
		get_node("elems/CheckBox7").pressed=false
		for a in vport:
			a.size.x=256
			a.size.y=256


func _on_CheckBox_toggled(button_pressed):
	if(button_pressed):
		get_node("elems/CheckBox2").pressed=false
		get_node("elems/CheckBox7").pressed=false
		for a in vport:
			a.size.x=512
			a.size.y=512


func _on_CheckBox7_toggled(button_pressed):
	if(button_pressed):
		get_node("elems/CheckBox").pressed=false
		get_node("elems/CheckBox2").pressed=false
		for a in vport:
			a.size.x=128
			a.size.y=128


func _on_CheckBox4_toggled(button_pressed):
	if(button_pressed):
		get_node("elems/CheckBox5").pressed=false
		get_node("../Camera/vlights").material_override.shader=load("res://shaders/vulume_lights_16.shader") as Shader


func _on_CheckBox5_toggled(button_pressed):
	if(button_pressed):
		get_node("elems/CheckBox4").pressed=false
		get_node("../Camera/vlights").material_override.shader=load("res://shaders/vulume_lights.shader") as Shader


func _on_CheckBox8_toggled(button_pressed):
	get_node("../floor").visible=button_pressed


func _on_CheckBox9_toggled(button_pressed):
	get_node("../objects").visible=button_pressed


func _on_CheckBox10_toggled(button_pressed):
	get_node("../objects2").visible=button_pressed


func _on_CheckBox11_toggled(button_pressed):
	get_node("../floor").set_layer_mask_bit(1,button_pressed)


func _on_ColorPickerButton_color_changed(color):
	get_node("../shadow_map").update_color(color)


func _on_ColorPickerButton_picker_created():
	get_node("../Camera").set_ui_input(true)


func _on_ColorPickerButton_popup_closed():
	get_node("../Camera").set_ui_input(false)


func _on_ColorPickerButton_pressed():
	get_node("../Camera").set_ui_input(true)
