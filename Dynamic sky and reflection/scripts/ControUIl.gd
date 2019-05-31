extends Control

onready var global_v=get_tree().get_root().get_node("scene")

func cb_press1():
	if !global_v.get_node("Control/CheckBox2").pressed:
		global_v.get_node("Control/CheckBox2").pressed=true
		return
	global_v.get_node("Control/CheckBox3").pressed=false
	global_v.get_node("Control/CheckBox4").pressed=false

func cb_press2():
	if !global_v.get_node("Control/CheckBox3").pressed:
		global_v.get_node("Control/CheckBox3").pressed=true
		return
	global_v.get_node("Control/CheckBox2").pressed=false
	global_v.get_node("Control/CheckBox4").pressed=false

func cb_press3():
	if !global_v.get_node("Control/CheckBox4").pressed:
		global_v.get_node("Control/CheckBox4").pressed=true
		return
	global_v.get_node("Control/CheckBox2").pressed=false
	global_v.get_node("Control/CheckBox3").pressed=false

func _ready():
	pass
