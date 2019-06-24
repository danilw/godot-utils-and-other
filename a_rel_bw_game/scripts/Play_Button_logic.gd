extends KinematicBody

onready var p_oob_a2=get_node("../../../../scene/particles_oob/Attractor2_2")
onready var p_oob_v=get_node("../../../../scene/particles_oob/Vortex1_2")
onready var global_v=get_node("../../../../scene")
onready var outlinep=get_node("../../../../scene/play_group/outline")
onready var outlinec=get_node("../../../../scene/conf_group/outline")
onready var cb=get_node("../../../../scene/play_group/play_back")
onready var post_p=get_tree().get_root().get_node("scene/main_screen")
onready var gui_cc=get_tree().get_root().get_node("scene/gui_c/vp/gui")

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
	if(v_enabled):
		outlinep.set_emitting(true)
		eval=smoothstep(in_time,in_time+2.35,global_v.iTime)
		eval=max(eval,oeval11)
		eval=min(eval,0.35)
		oeval=eval
		if(!global_v.conf_clicked):
			teval=smoothstep(in_time,in_time+1.35,global_v.iTime)
			teval=max(teval,oteval)
			cb.get_surface_material(0).set("shader_param/color",Color("ff0000")*teval)
		eval2=smoothstep(in_time,in_time+1.75,global_v.iTime)
		oeval2=eval2
		eval2=min(eval2,0.35)
		eval2=max(eval2,oeval12)
	else:
		outlinep.set_emitting(false)
		eval=smoothstep(out_time+2.75,out_time,global_v.iTime)
		eval=min(eval,oeval)
		eval=min(eval,0.35)
		oeval11=eval
		oteval=smoothstep(out_time+1.25,out_time,global_v.iTime)
		teval*=oteval
		oteval=min(teval,oteval)
		cb.get_surface_material(0).set("shader_param/color",Color("ff0000")*oteval)
		eval2=smoothstep(out_time+3.35,out_time,global_v.iTime)
		eval2=min(eval2,oeval2)
		eval2=min(eval2,0.35)
		oeval12=eval2
	p_oob_a2.set_strength(0.15*(0.01+0.99*eval))
	p_oob_v.set_strength(0.5*(0.01+0.99*eval2))

onready var cbb=get_node("../../../../scene/conf_group/conf/StaticBody/CollisionShape")
onready var pbb=get_node("../../../../scene/play_group/play/StaticBody/CollisionShape")
onready var pb=get_node("../../../../scene/play_group/play_back")
onready var ptmr=get_node("../../../../scene/play_group/pause_tmr")
onready var ptmr2=get_node("../../../../scene/play_group/pause_tmr2")
onready var floorx=get_node("../../../../scene/floor_anix/floor")
onready var pbp=get_node("../../../../scene/play_group/play_p")
onready var cbr=get_node("../../../../scene/conf_group/conf_back")
onready var cbrp=get_node("../../../../scene/conf_group/conf_p")
onready var score_c=get_tree().get_root().get_node("scene/score")
onready var floor_l=get_node("../../../../scene/floor_anix/left_f")
onready var floor_r=get_node("../../../../scene/floor_anix/right_f")
var rid=0;

func hide_on_play():
	score_c.set_visible(true)
	pbb.set_disabled(true)
	cbb.set_disabled(true)
	floorx.process_material.set("shader_param/vval",global_v.iTime)
	floorx.process_material.set("shader_param/rid",rid)
	floorx.set_visible(true)
	floor_l.set_visible(true)
	floor_r.set_visible(true)
	rid=(rid+1)%3;
	cbr.set_visible(false)
	pb.set_visible(false)
	ptmr.set_visible(false)
	ptmr2.set_visible(false)
	pbp.set_emitting(false)
	cbrp.set_emitting(false)
	outlinep.set_emitting(false)
	outlinec.set_emitting(false)
	get_tree().paused=false
	gui_cc.disable_refl(post_p.disable_refl)
	mouse_out_event()
	post_p.ispause=false
	


func mouse_entered_event(mouse_press):
	if(global_v.iTime<2.0):
		return
	if(!v_enabled):
		in_time=global_v.iTime
	if(!global_v.conf_clicked)&&(!global_v.play_clicked)&&(mouse_press):
		global_v.play_clicked=true
		global_v.is_played_once=true
		post_p.play_click=global_v.iTime
		post_p.material.set("shader_param/minif2",global_v.play_clicked)
		hide_on_play()
	v_enabled=true

func mouse_out_event():
	if(v_enabled):
		out_time=global_v.iTime
	v_enabled=false
