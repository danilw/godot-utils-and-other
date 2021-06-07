extends Node2D

var iTime=0.0
var iFrame=0
var iMouse=Vector2() 
var iResolution=Vector2(1280,720)

var inp_used=false
var inp_used_id=0
var gid=0
var gidx=-1

var live_box_elem=0
var live_circle_elem=0
var live_line_elem=0
var live_text_elem=0
var live_tri_elem=0

const max_elems=5 #same in shaders

func _ready():
	pass

func upd_imouse():
	var m_pos=get_viewport().get_mouse_position()/iResolution
	m_pos.x=clamp(m_pos.x,0,1)
	m_pos.y=clamp(m_pos.y,0,1)
	iMouse=Vector2(m_pos.x*iResolution.x,iResolution.y*m_pos.y)

func _process(delta):
	iTime+=delta
	iFrame+=1
	upd_imouse()
