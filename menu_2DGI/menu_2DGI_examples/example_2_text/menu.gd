extends Control

var texture_orig=load("res://menu_textures/orig_1.png") as Texture
var texture_glow1=load("res://menu_textures/glow_1.png") as Texture
var texture_glow2=load("res://menu_textures/glow_2.png") as Texture
var texture_glow3=load("res://menu_textures/glow_3.png") as Texture
var texture_glow4=load("res://menu_textures/glow_4.png") as Texture

func _ready():
	pass

#switch textures on state, thats logic

func _on_b1_pressed():
	get_node("popup").popup_centered(Vector2(320,240))

func _on_b1_button_down():
	get_node("menu_texture").texture=texture_glow4

func _on_b1_button_up():
	get_node("menu_texture").texture=texture_orig


func _on_b1_mouse_entered():
	get_node("menu_texture").texture=texture_glow1


func _on_b1_mouse_exited():
	get_node("menu_texture").texture=texture_orig


func _on_b2_pressed():
	get_node("popup").popup_centered(Vector2(320,240))


func _on_b2_button_down():
	get_node("menu_texture").texture=texture_glow2


func _on_b2_button_up():
	get_node("menu_texture").texture=texture_orig


func _on_b2_mouse_entered():
	get_node("menu_texture").texture=texture_glow2


func _on_b2_mouse_exited():
	get_node("menu_texture").texture=texture_orig


func _on_b3_pressed():
	get_node("popup").popup_centered(Vector2(320,240))


func _on_b3_button_down():
	get_node("menu_texture").texture=texture_glow3


func _on_b3_button_up():
	get_node("menu_texture").texture=texture_orig


func _on_b3_mouse_entered():
	get_node("menu_texture").texture=texture_glow3


func _on_b3_mouse_exited():
	get_node("menu_texture").texture=texture_orig
