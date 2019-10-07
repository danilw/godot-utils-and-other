extends Control

var textuer_orig=load("res://menu_textures/orig_1.png") as Texture
var textuer_glow1=load("res://menu_textures/glow_1.png") as Texture
var textuer_glow2=load("res://menu_textures/glow_2.png") as Texture

func _ready():
	pass


func _on_b1_pressed():
	get_node("popup").popup_centered(Vector2(320,240))


func _on_b1_mouse_entered():
	get_node("menu_it").texture=textuer_glow1


func _on_b1_mouse_exited():
	get_node("menu_it").texture=textuer_orig


func _on_b2_pressed():
	get_node("popup").popup_centered(Vector2(320,240))


func _on_b2_mouse_entered():
	get_node("menu_it").texture=textuer_glow2


func _on_b2_mouse_exited():
	get_node("menu_it").texture=textuer_orig
