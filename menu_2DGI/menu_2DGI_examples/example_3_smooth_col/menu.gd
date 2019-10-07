extends Control

var texture_orig=load("res://menu_textures/orig_1.png") as Texture
var texture_glow1=load("res://menu_textures/glow_1.png") as Texture
var texture_glow2=load("res://menu_textures/glow_2.png") as Texture
var texture_glow3=load("res://menu_textures/glow_3.png") as Texture
var texture_glow4=load("res://menu_textures/glow_4.png") as Texture

var glow1=0.0
var glow2=0.0
var glow3=0.0
var glow4=0.0
var glowg=1.0

var glow1b=false
var glow2b=false
var glow3b=false
var glow4b=false

func _ready():
	pass

func _process(delta):
	var any_of=false
	if(glow1b):
		glow1+=delta
		any_of=any_of||(glow1>=1)
	else:
		glow1+=-delta
	if(glow2b):
		glow2+=delta
		any_of=any_of||(glow2>=1)
	else:
		glow2+=-delta
	if(glow3b):
		glow3+=delta
		any_of=any_of||(glow3>=1)
	else:
		glow3+=-delta
	if(glow4b):
		glow4+=delta
		any_of=any_of||(glow4>=1)
	else:
		glow4+=-delta
	if(any_of):
		glowg+=-delta
	else:
		glowg=1.0
	glow1=clamp(glow1,0,1)
	glow2=clamp(glow2,0,1)
	glow3=clamp(glow3,0,1)
	glow4=clamp(glow4,0,1)
	glowg=clamp(glowg,0,1)
	get_node("menu_texture").material.set("shader_param/glow1",glow1)
	get_node("menu_texture").material.set("shader_param/glow2",glow2)
	get_node("menu_texture").material.set("shader_param/glow3",glow3)
	get_node("menu_texture").material.set("shader_param/glow4",glow4)
	get_node("menu_texture").material.set("shader_param/glowg",glowg)

func _on_b1_pressed():
	get_node("popup").popup_centered(Vector2(320,240))

func _on_b1_button_down():
	glow1=1.0
	glow1b=true

func _on_b1_button_up():
	glow1b=false


func _on_b1_mouse_entered():
	glow1b=true


func _on_b1_mouse_exited():
	glow1b=false


func _on_b2_pressed():
	get_node("popup").popup_centered(Vector2(320,240))


func _on_b2_button_down():
	glow2=1.0
	glow2b=true


func _on_b2_button_up():
	glow2b=false


func _on_b2_mouse_entered():
	glow2b=true


func _on_b2_mouse_exited():
	glow2b=false


func _on_b3_pressed():
	get_node("popup").popup_centered(Vector2(320,240))


func _on_b3_button_down():
	glow3=1.0
	glow3b=true


func _on_b3_button_up():
	glow3b=false


func _on_b3_mouse_entered():
	glow3b=true


func _on_b3_mouse_exited():
	glow3b=false


func _on_b4_pressed():
	get_node("popup").popup_centered(Vector2(320,240))


func _on_b4_button_down():
	glow4=1.0
	glow4b=true


func _on_b4_button_up():
	glow4b=false


func _on_b4_mouse_entered():
	glow4b=true


func _on_b4_mouse_exited():
	glow4b=false
