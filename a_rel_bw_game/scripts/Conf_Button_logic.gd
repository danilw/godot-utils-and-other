extends KinematicBody

onready var p_oob_a2=get_node("../../../../scene/particles_oob/Attractor2")
onready var p_oob_v=get_node("../../../../scene/particles_oob/Vortex")
onready var global_v=get_node("../../../../scene")
onready var outline=get_node("../../../../scene/conf_group/outline")
onready var cb=get_node("../../../../scene/conf_group/conf_back")
onready var post_p=get_tree().get_root().get_node("scene/main_screen")
onready var gui_c=get_tree().get_root().get_node("scene/gui_c")

var v_enabled=false
var in_time=0.0
var out_time=-10.0
var oeval=0.05
var oeval2=0.05
var oeval11=0.0
var oeval12=0.0
var oteval=0.0
var teval=0.0

func _ready():
	pass

func _process(delta):
	var eval=0.0
	var eval2=0.0
	if(v_enabled)||(global_v.conf_clicked):
		outline.set_emitting(true)
		eval=smoothstep(in_time,in_time+2.35,global_v.iTime)
		eval=max(eval,oeval11)
		eval=min(eval,0.35)
		oeval=eval
		teval=smoothstep(in_time,in_time+1.35,global_v.iTime)
		teval=max(teval,oteval)
		cb.get_surface_material(0).set("shader_param/color",Color("9de7ff")*teval)
		eval2=smoothstep(in_time,in_time+1.75,global_v.iTime)
		oeval2=eval2
		eval2=min(eval2,0.35)
		eval2=max(eval2,oeval12)
	else:
		outline.set_emitting(false)
		eval=smoothstep(out_time+2.75,out_time,global_v.iTime)
		eval=min(eval,oeval)
		eval=min(eval,0.35)
		oeval11=eval
		oteval=smoothstep(out_time+1.25,out_time,global_v.iTime)
		teval*=oteval
		oteval=min(teval,oteval)
		cb.get_surface_material(0).set("shader_param/color",Color("9de7ff")*oteval)
		eval2=smoothstep(out_time+3.35,out_time,global_v.iTime)
		eval2=min(eval2,oeval2)
		eval2=min(eval2,0.35)
		oeval12=eval2
	p_oob_a2.set_strength(0.15*(0.05+0.95*eval))
	p_oob_v.set_strength(0.5*(0.05+0.95*eval2))

func mouse_entered_event(mouse_press):
	if(global_v.iTime<2.0):
		return
	if(!v_enabled)&&(!global_v.conf_clicked):
		in_time=global_v.iTime
		post_p.conf_click=in_time
	if(!global_v.conf_clicked)&&(mouse_press):
		global_v.conf_clicked=true
		post_p.material.set("shader_param/minif",global_v.conf_clicked)
		gui_c.set_visible(true)
		gui_c.get_node("vp").set_disable_input(false)
		gui_c.get_node("vp").set_update_mode(Viewport.UPDATE_ALWAYS)
	v_enabled=true

func mouse_out_event():
	if(v_enabled):
		out_time=global_v.iTime
	v_enabled=false
