extends Control

onready var wf
onready var ch1
onready var ch2
onready var player

var out_st=false
var out_en=false

func _ready():
	wf=get_node("../woolf")
	ch1=get_node("TextureRect")
	ch2=get_node("TextureRect2")
	ch1.material.set("shader_param/alpha",0)
	player=get_node("../Camera")

var smv=0
const speed=0.25

var iTime=0
var loaded=false
var oload=false

func _process(delta):
	
	if(!oload):
		if(iTime<1):
			ch2.material.set("shader_param/iTime",iTime)
			if(loaded):
				iTime+=delta
		else:
			ch2.visible=false
			oload=true
	
	if(!out_st):
		return
	
	var oleng=(player.translation-wf.translation).length()
	var leng=0.35+0.65*clamp(oleng/5,0,1)
	leng*=1-clamp((oleng-10.5)/3,0,1)
	if(out_en):
		smv+=-delta*0.5
	else:
		smv+=delta*speed
	smv=clamp(smv,0,1)
	ch1.material.set("shader_param/alpha",smv*0.5*leng)
	


func _on_st_body_exited(body):
	out_st=true


func _on_area_in_body_exited(body):
	out_en=true


func _on_area_in_body_entered(body):
	out_en=false
