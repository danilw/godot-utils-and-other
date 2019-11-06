extends Node2D

onready var iChannel=get_node("../iChannel0")
onready var iChannel_buf=get_node("../iChannel_buf0")

onready var data_fbo=get_node("../data_FBO")
onready var data_buf=get_node("../data_buf")

func _ready():
	var tc=iChannel_buf.get_viewport().get_texture()
	#tc.flags=Texture.FLAG_FILTER
	tc.flags=0
	iChannel.get_child(0).material.set("shader_param/iChannel0",tc)
	
	var tc2=data_buf.get_viewport().get_texture()
	tc2.flags=0
	data_fbo.get_child(0).material.set("shader_param/iChannel0",tc2)
