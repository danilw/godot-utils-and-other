extends Control

func _ready():
	pass
	
onready var global_v=get_tree().get_root().get_node("scene")
onready var oMouse=Vector2(global_v.iMouse.x,global_v.iMouse.y)

func _process(delta):
	press_once=true
	global_v.clean_scr=false
	global_v.clean_scr5=false
	global_v.clean_scr10=false
	global_v.update_once=false
	global_v.rem_once=false
	get_node("set_IDx2").text=str(global_v.part_total)
	global_v.spawn1=get_node("mouse_ctrl/rnd1").pressed
	global_v.spawn2=get_node("mouse_ctrl/rnd2").pressed
	
	if(Input.is_mouse_button_pressed(BUTTON_RIGHT)):
		var imtr = ((oMouse-Vector2(global_v.iMouse.x,global_v.iMouse.y))/global_v.iResolution)*global_v.zoom_v
		get_node("scrolls/vx").value+=imtr.x*100/4
		get_node("scrolls/vy").value+=imtr.y*100/4
	oMouse=Vector2(global_v.iMouse.x,global_v.iMouse.y)

func _on_clean_pressed():
	global_v.last_created_index=0
	global_v.part_total=0
	global_v.clean_scr=true


func _on_info_pressed():
	get_node("info_dlg").popup_centered(Vector2(600,350))

func _on_zoom_value_changed(value):
	global_v.zoom_v=value/100.0

var press_once=true
func _on_force_toggled(button_pressed):
	if(!press_once):
		return
	press_once=false
	if(!get_node("mouse_ctrl/force").pressed):
		get_node("mouse_ctrl/force").pressed=true
	else:
		get_node("mouse_ctrl/rnd1").pressed=false
		get_node("mouse_ctrl/rnd2").pressed=false


func _on_rnd1_toggled(button_pressed):
	if(!press_once):
		return
	press_once=false
	if(!get_node("mouse_ctrl/rnd1").pressed):
		get_node("mouse_ctrl/rnd1").pressed=true
	else:
		get_node("mouse_ctrl/force").pressed=false
		get_node("mouse_ctrl/rnd2").pressed=false


func _on_rnd2_toggled(button_pressed):
	if(!press_once):
		return
	press_once=false
	if(!get_node("mouse_ctrl/rnd2").pressed):
		get_node("mouse_ctrl/rnd2").pressed=true
	else:
		get_node("mouse_ctrl/rnd1").pressed=false
		get_node("mouse_ctrl/force").pressed=false


func _on_grav_gui_input(event):
	if(event is InputEventMouseButton):
		if(event.button_index==1):
			get_node("grav").click=event.button_mask
		else:
			get_node("grav").click=0


var is_paused=false

func upd_pause():
	if is_paused:
		#get_node("mouse_ctrl2/set_del").disabled=false
		#get_node("mouse_ctrl2/set_ed").disabled=false
		get_node("../iChannel0").render_target_update_mode=Viewport.UPDATE_DISABLED
		get_node("../iChannel1").render_target_update_mode=Viewport.UPDATE_DISABLED
		get_node("../iChannel_buf0").render_target_update_mode=Viewport.UPDATE_DISABLED
	else:
		#get_node("mouse_ctrl2/set_del").disabled=true
		#get_node("mouse_ctrl2/set_ed").disabled=true
		get_node("../iChannel0").render_target_update_mode=Viewport.UPDATE_ALWAYS
		get_node("../iChannel1").render_target_update_mode=Viewport.UPDATE_ALWAYS
		get_node("../iChannel_buf0").render_target_update_mode=Viewport.UPDATE_ALWAYS
	

func _on_pause_pressed():
	is_paused=!is_paused
	upd_pause()

func update_once():
	get_node("../iChannel0").render_target_update_mode=Viewport.UPDATE_ONCE
	get_node("../iChannel1").render_target_update_mode=Viewport.UPDATE_ONCE
	get_node("../iChannel_buf0").render_target_update_mode=Viewport.UPDATE_ONCE

func _on_set_ed_pressed():
	var tv=get_node("mouse_ctrl2/set_IDx").text.to_int()
	if(tv<global_v.part_total):
		global_v.update_id=tv
		global_v.update_type=1+get_node("mouse_ctrl2/set_type").get_selected_id()
		global_v.update_once=true
		if is_paused:
			update_once()

func _on_set_del_pressed():
	var tv=get_node("mouse_ctrl2/set_IDx").text.to_int()
	if(tv<global_v.part_total):
		global_v.update_id=tv
		global_v.rem_once=true
		if is_paused:
			update_once()

func _on_hide__pressed():
	self.visible=!self.visible

func _on_vx_value_changed(value):
	global_v.scr_posx=value/100.0

func _on_vy_value_changed(value):
	global_v.scr_posy=value/100.0


func _on_clean2_pressed():
	global_v.last_created_index=50000-1
	global_v.part_total=50000
	global_v.clean_scr5=true

func _on_clean3_pressed():
	global_v.last_created_index=100000-1
	global_v.part_total=100000
	global_v.clean_scr10=true

func _on_speed_value_changed(value):
	global_v.speed=value/100.0
