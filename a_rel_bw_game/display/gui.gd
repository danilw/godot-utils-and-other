extends Control

var fov_val=70
var ppoff=false

func dummy_init():
	fov_val=70
	ppoff=false

func _ready():
	disable_refl(true)

func _on_FOV_value_changed(value):
	fov_val=value


onready var gui_c=get_tree().get_root().get_node("scene/gui_c")
onready var global_v=get_tree().get_root().get_node("scene/main_screen/main_vp/scene")
onready var post_p=get_tree().get_root().get_node("scene/main_screen")
onready var main_vp=get_tree().get_root().get_node("scene/main_screen/main_vp")

func _on_Ok_pressed():
	gui_c.set_visible(false)
	gui_c.get_node("vp").set_disable_input(true)
	gui_c.get_node("vp").set_update_mode(Viewport.UPDATE_DISABLED)
	global_v.conf_clicked=false
	post_p.material.set("shader_param/minif",global_v.conf_clicked)
	global_v.get_node("conf_group/conf/StaticBody").mouse_out_event()


func _on_PP_toggled(button_pressed):
	ppoff=button_pressed
	post_p.ppoff=ppoff

onready var cube_cameras=get_tree().get_root().get_node("scene/main_screen/main_vp/scene/cube_vp")
onready var sky_b=get_tree().get_root().get_node("scene/Sky/Sprite")

func _on_panorama_toggled(button_pressed):
	sky_b.material.set("shader_param/disable_panorama",button_pressed)
	post_p.disable_panorama=button_pressed
	for a in range(6):
		cube_cameras.get_child(a).set_transparent_background(button_pressed)


func _on_reflection_toggled(button_pressed):
	post_p.disable_refl=button_pressed

func disable_refl(state):
	if(state):
		for a in range(6):
			cube_cameras.get_child(a).set_update_mode(Viewport.UPDATE_DISABLED)
	else:
		for a in range(6):
			cube_cameras.get_child(a).set_update_mode(Viewport.UPDATE_ALWAYS)

func _on_refl_res_value_changed(value):
	for a in range(6):
		cube_cameras.get_child(a).set_size(Vector2(value,value))


func _on_MSAA_value_changed(value):
	main_vp.set_msaa(value)


func _on_less_parts_toggled(button_pressed):
	global_v.set_particles(button_pressed)
