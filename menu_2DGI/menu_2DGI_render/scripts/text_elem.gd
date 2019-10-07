extends HBoxContainer

onready var top_node=get_node("../")
onready var global_v=get_tree().get_root().get_node("scene")

var self_id=0

var self_size=0
const self_type=0
var self_render=true
var self_color=Color.black
var self_rot=0
var self_text=""

func get_self_type():
	return self_type

func _ready():
	self_id=global_v.gid
	global_v.gid+=1
	global_v.live_text_elem+=1
	self_color=get_node("ColorPickerButton").color
	self_text=get_node("LineEdit").text

func hit():
	if(global_v.inp_used)&&(global_v.gidx!=self_id):
		return false
	if(global_v.inp_used)&&(global_v.gidx==self_id):
		return true
	var a=global_v.iMouse
	var rect=21*top_node.rect_scale.x
	var b=top_node.rect_position
	if(abs(a.x-b.x-rect/2)<rect/2)&&(abs(a.y-b.y-rect/2)<rect/2):
		return true

func unhit():
	if(global_v.inp_used)&&(global_v.gidx==self_id)&&(!Input.is_mouse_button_pressed(BUTTON_LEFT)):
		global_v.inp_used=false

func _process(delta):
	unhit()
	if(hit()):
		if(Input.is_mouse_button_pressed(BUTTON_LEFT)):
			global_v.gidx=self_id
			global_v.inp_used=true
			var a=global_v.iMouse
			var rect=21*top_node.rect_scale.x
			top_node.rect_position=a-Vector2(rect/2-11.25,rect/2)
			top_node.rect_position=Vector2(int(top_node.rect_position.x/22.5)*22.5,11.25+int(top_node.rect_position.y/22.5)*22.5)
			top_node.rect_position.y=min(top_node.rect_position.y,720-11.25)
			
	Input.is_mouse_button_pressed(BUTTON_LEFT)

func _on_Button_pressed():
	global_v.live_text_elem+=-1
	top_node.queue_free()


func _on_LineEdit2_text_changed(new_text):
	var rot=get_node("LineEdit2").text.to_int()
	var rect=21
	top_node.rect_pivot_offset=Vector2(rect/2,rect/2)
	top_node.rect_rotation=rot
	get_node("TextureRect").rect_rotation=-rot
	self_rot=rot

func _on_OptionButton_item_selected(ID):
	#top_node.rect_scale=Vector2(1+ID,1+ID)
	self_size=ID

func _on_ColorPickerButton_color_changed(color):
	self_color=get_node("ColorPickerButton").color

func _on_LineEdit_text_changed(new_text):
	self_text=new_text

func _on_CheckBox_pressed():
	self_render=!self_render
