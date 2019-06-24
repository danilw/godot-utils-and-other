extends Camera

onready var global_v=get_node("../../scene")
onready var gui_cc=get_tree().get_root().get_node("scene/gui_c/vp/gui")
onready var cam2=get_tree().get_root().get_node("scene/Sky_p/scene/Camera")

onready var cbb=get_node("../../scene/conf_group/conf/StaticBody/CollisionShape")
onready var pbb=get_node("../../scene/play_group/play/StaticBody/CollisionShape")
onready var pb=get_node("../../scene/play_group/play_back")
onready var pbp=get_node("../../scene/play_group/play_p")
onready var cbr=get_node("../../scene/conf_group/conf_back")
onready var cbrp=get_node("../../scene/conf_group/conf_p")
onready var outlinep=get_node("../../scene/play_group/outline")
onready var outlinec=get_node("../../scene/conf_group/outline")
onready var post_p=get_tree().get_root().get_node("scene/main_screen")
onready var ptmr=get_node("../../scene/play_group/pause_tmr")
onready var rtfx=get_node("../../scene/play_group/pause_tmr/rtxxx")
onready var ptmr2=get_node("../../scene/play_group/pause_tmr2")
onready var floorx=get_node("../../scene/floor_anix/floor")
onready var floor_l=get_node("../../scene/floor_anix/left_f")
onready var floor_r=get_node("../../scene/floor_anix/right_f")
onready var floor_lfa=get_node("../../scene/floor_anix/floor_lp_r")
onready var floor_rfa=get_node("../../scene/floor_anix/floor_lp_l")

var _mouse_position = Vector2(0.0, 0.0)
var _yaw = 0.0
var _pitch = 0.0
var _total_yaw = 0.0
var _total_pitch = 0.0

var click_time=0.0
var unclick_time=0.0
var lpt=0.0
var isclick=false
var isinm=false
var pause_clicks=0

func _ready():
	self.environment.background_sky.set_panorama(global_v.iChannel_panorama)

func _input(event):
	if event is InputEventKey:
		if ((event.scancode == KEY_ESCAPE)or(event.scancode == KEY_1))and(!global_v.conf_clicked)and(!get_tree().paused):
			display_on_esc()
			return

func _physics_process(delta):
	if (Input.is_mouse_button_pressed(BUTTON_LEFT)):
		get_object_under_mouse(true)
	else:
		get_object_under_mouse(false)

onready var p_ex=get_node("../../scene/refl_body/sup_p")
onready var p_ex_a=get_node("../../scene/refl_body/sup_p/Attractor")
onready var p_ex_v=get_node("../../scene/refl_body/sup_p/Vortex")
onready var player_bgl=get_node("../../scene/refl_body/glow")
var rc_once=false
var rc_d=false
var rc_time=0
var dex=false
var dex_timer=0
var pxtime=0

func e_ex_action(delta):
	if(get_tree().paused):
		if(dex):
			pxtime+=delta
		return
	if(rc_d):
		dex=true
	dex_timer=global_v.iTime-pxtime-rc_time
	if(global_v.iTime-pxtime-rc_time>11.0):
		pxtime=0
		dex=false
	if(dex):
		player_bgl.get_surface_material(0).set("shader_param/glow_c",Color(0.08,0.3,1.0,1.0)*smoothstep(rc_time+11.0,rc_time+7.0,global_v.iTime-pxtime)*smoothstep(rc_time+1.5,rc_time+3.0,global_v.iTime-pxtime))
		if(global_v.iTime-pxtime-rc_time<02.60):
			p_ex.set_emitting(true)
		else:
			p_ex.set_emitting(false)
		if(global_v.iTime-pxtime-rc_time<3.0):
			p_ex_a.strength=1.80*smoothstep(rc_time+0.5,rc_time+2.50,global_v.iTime-pxtime)
		else:
			p_ex_a.strength=-15.0*smoothstep(rc_time+1.0,rc_time+5.0,global_v.iTime-pxtime)
			p_ex_a.strength*=smoothstep(rc_time+7.0,rc_time+2.90,global_v.iTime-pxtime)
		p_ex_v.strength=2.0*smoothstep(rc_time+0.85,rc_time+2.50,global_v.iTime-pxtime)
		p_ex_v.strength*=smoothstep(rc_time+5.0,rc_time+2.90,global_v.iTime-pxtime)
	else:
		player_bgl.get_surface_material(0).set("shader_param/glow_c",Color(0.0,0.0,0.0,1.0))
		p_ex.set_emitting(false)
		p_ex_a.strength=0.0001
		p_ex_v.strength=0.0001
		
		
		

func right_click():
	if ((Input.is_mouse_button_pressed(BUTTON_RIGHT))&&(AP>=0.9999)&&(!post_p.ispause)&&(!rc_once)&&(!rc_d)):
		rc_once=true
		rc_time=global_v.iTime
	if((!Input.is_mouse_button_pressed(BUTTON_RIGHT))&&(rc_once)):
		rc_once=false

func _process(delta):
	e_process(delta)
	right_click()
	e_ex_action(delta)
	var _yval=0.0
	var _pval=0.0
	if(post_p.ispause):
		_yval=50.0
		_pval=45.0
	else:
		_yval=15.0
		_pval=30.0
	if(global_v.conf_clicked):
		cam2.set_fov(gui_cc.fov_val)
		self.set_fov(gui_cc.fov_val)
	if (Input.is_mouse_button_pressed(BUTTON_LEFT))&&(!isinm)&&((global_v.play_clicked)||(!global_v.conf_clicked)&&(!global_v.play_clicked)):
		_mouse_position = get_viewport().get_mouse_position()/OS.get_window_size()-Vector2(0.5,0.5)
		_mouse_position.x=clamp(_mouse_position.x,-0.5,0.5)
		_mouse_position.y=clamp(_mouse_position.y,-0.5,0.5)
		if !isclick:
			click_time=global_v.iTime
		isclick=true
		var eval=0.1+0.9*smoothstep(click_time,click_time+0.5,global_v.iTime)
		lpt=eval*0.75*global_v.get_pause_anim_timer()
		_yaw = _mouse_position.x*lpt
		_pitch = _mouse_position.y*lpt
	else:
		if isclick:
			unclick_time=global_v.iTime
		var eval=smoothstep(unclick_time+1.5,unclick_time+4.0,global_v.iTime)
		isclick=false
		if(global_v.iTime-unclick_time<1.5):
			eval=smoothstep(unclick_time+1.5,unclick_time,global_v.iTime)
			_yaw = eval*_mouse_position.x*lpt
			_pitch = eval*_mouse_position.y*lpt
		else:
			_yaw=-0.35*eval*_total_yaw/_yval
			_pitch=-0.35*eval*_total_pitch/_pval
	if sign(_total_yaw)==sign(_yaw):
		_yaw = _yaw *(_yval-abs(_total_yaw))/_yval
	if sign(_total_pitch)==sign(_pitch):
		_pitch = _pitch*(_pval-abs(_total_pitch))/_pval
		
	if abs(_total_yaw+_yaw)<50:
		_total_yaw += _yaw
		rotate_y(deg2rad(-_yaw))
	
	if abs(_total_pitch+_pitch)<45:
		_total_pitch += _pitch
		rotate_object_local(Vector3(1,0,0), deg2rad(-_pitch))

func get_object_under_mouse(mouse_press):
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_from = self.project_ray_origin(mouse_pos)
	var RAY_LENGTH=10
	var ray_to = ray_from + self.project_ray_normal(mouse_pos) * RAY_LENGTH
	var space_state = get_world().direct_space_state
	var selection = space_state.intersect_ray(ray_from, ray_to)
	if(selection.size()!=0):
		if(selection.get("collider")!=null):
			if(selection.get("collider").has_method("mouse_entered_event")):
				isinm=false
				if !isclick:
					isinm=true
					selection.get("collider").mouse_entered_event(mouse_press)
				else:
					selection.get("collider").mouse_entered_event(false)
			else:
				global_v.get_node("play_group/play/StaticBody").mouse_out_event()
				global_v.get_node("conf_group/conf/StaticBody").mouse_out_event()
				isinm=false
	else:
		global_v.get_node("play_group/play/StaticBody").mouse_out_event()
		global_v.get_node("conf_group/conf/StaticBody").mouse_out_event()
		isinm=false
	#return selection

func display_on_esc():
	if(!get_tree().paused):
		get_tree().paused=true
		gui_cc.disable_refl(true)
		pbb.set_disabled(false)
		cbb.set_disabled(false)
		cbr.set_visible(true)
		pb.set_visible(true)
		pbp.set_emitting(true)
		cbrp.set_emitting(true)
		cbrp.set_visible(true)
		pbp.set_visible(true)
		outlinep.set_visible(true)
		outlinec.set_visible(true)
		floorx.set_visible(false)
		floorxa.set_visible(false)
		floorxb.set_visible(false)
		floorx.process_material.set("shader_param/vval",100000.0)
		pause_clicks+=1
		if(global_v.is_played_once):
			if(pause_clicks%2==1):
				ptmr.set_visible(true)
				rtfx.ctime=global_v.iTime
				ptmr.material_override.set("shader_param/ctime",global_v.iTime)
			else:
				ptmr2.set_visible(true)
				ptmr2.material_override.set("shader_param/ctime",global_v.iTime)
		
		global_v.conf_clicked=false
		global_v.play_clicked=false
		post_p.material.set("shader_param/minif",global_v.conf_clicked)
		post_p.material.set("shader_param/minif2",global_v.play_clicked)
		post_p.ispause=true
	#global_v.is_played_once=false
	

#it here, bad I know
var SPEED=0.0 #0-1
var AP=0.0 #0-1
var GO_flag=false

var minus_speed_val=0

var speed_pf=(1.0/60.0)*(1.0/60.0)
var ap_pf=(1.0/20.0)*(1.0/60.0)

onready var parts_oob=get_node("../../scene/particles_oob")
onready var parts_oob_v4=get_node("../../scene/particles_oob/Vortex4")
onready var player_b=get_node("../../scene/refl_body")
onready var cubevp=get_node("../../scene/cube_vp")
onready var floorxa=get_node("../../scene/floor_anix/floor_a")
onready var floorxb=get_node("../../scene/floor_anix/floor_b")
onready var floor_lw2=get_node("../../scene/floor_anix/left_f/wind2")
onready var floor_rw2=get_node("../../scene/floor_anix/right_f/wind2")
onready var pgg=get_node("../../scene/play_group/")
onready var cgg=get_node("../../scene/conf_group/")

func move_player(pos):
	#-19.5,17.5
	if(pos<0.0):
		var vvl=smoothstep(-19.5,-17.0,self.translation.x)
		pos*=vvl
	else:
		var vvl=smoothstep(17.5,15.0,self.translation.x)
		pos*=vvl
	self.translation.x+=pos
	parts_oob.translation.x+=pos
	#print("oob: "+str(parts_oob.translation.x)) #they not equal(sometime)...maybe bug
	player_b.translation.x+=pos
	#print("player: "+str(player_b.translation.x))
	pgg.translation.x+=pos
	cgg.translation.x+=pos
	for a in range(6):
		cubevp.get_child(a).get_child(0).translation.x+=pos
	if((player_b.translation.x)<-14.50):
		floor_lfa.set_emitting(true)
		floorxa.set_visible(true)
		floorxa.get_surface_material(0).set("shader_param/ppos",smoothstep(15.50,19.0,abs(player_b.translation.x)))
	else:
		floor_lfa.set_emitting(false)
		floorxa.set_visible(false)
	if((player_b.translation.x)>13.50):
		floor_rfa.set_emitting(true)
		floorxb.set_visible(true)
		floorxa.get_surface_material(0).set("shader_param/ppos",smoothstep(13.50,17.0,abs(player_b.translation.x)))
	else:
		floor_rfa.set_emitting(false)
		floorxb.set_visible(false)
	var vmdl=smoothstep(unclick_time+05.5,unclick_time+1.0,global_v.iTime)
	if(isclick):
		vmdl=1.0
	if(_mouse_position.x>=0.0):
		parts_oob_v4.strength=max(max((lpt)*10.5*_mouse_position.x*vmdl,parts_oob_v4.strength*vmdl),0.15)
	else:
		parts_oob_v4.strength=min(min((lpt)*10.5*_mouse_position.x*vmdl,parts_oob_v4.strength*vmdl),-0.15)
	

func update_uniforms():
	post_p.material.set("shader_param/sval",smoothstep(0,1,SPEED))
	post_p.material.set("shader_param/ssval",smoothstep(0,1,AP))
	post_p.material.set("shader_param/msval",min(minus_speed_val,1.0))
	post_p.material.set("shader_param/psval",rc_d)

func player_speed(delta):
	#if(GO_flag):
	#	return
	SPEED+=-minus_speed_val*delta*2.0
	minus_speed_val+=-minus_speed_val*delta*2.0
	minus_speed_val=max(minus_speed_val,0.0)
	if(SPEED<0.0):
		GO_flag=true
		#return
	if(minus_speed_val<=0.01):
		SPEED+=1.0*speed_pf
	if(rc_once&&(AP>=0.9999)):
		rc_d=true
	if(rc_d):
		AP=smoothstep(rc_time+4.0,rc_time,global_v.iTime)-smoothstep(rc_time,rc_time+2.0,global_v.iTime)
		if(AP<=0.0001):
			rc_d=false
	else:
		if(!dex):
			AP+=ap_pf
	
	SPEED=clamp(SPEED,0,1)
	AP=clamp(AP,0,1)

onready var sky_bS=get_tree().get_root().get_node("scene/Sky/Sprite")
var pause_rt=Vector3(-0.65244*2.0, 1.29969, -2.26926)
func tunp(delta):
	var vtr=0.0
	if(global_v.play_clicked):
		vtr=smoothstep(0.0,pause_rt.x,self.translation.x-player_b.translation.x)
	else:
		vtr=1.0-smoothstep(0.0,pause_rt.x,(self.translation.x-player_b.translation.x))
		vtr*=-1
	if(!post_p.ispause):
		sky_bS.sun_pos+=(1.0-abs(vtr))*delta
	else:
		sky_bS.sun_pos+=abs(vtr)*delta
	self.translation.x+=vtr*delta*0.5


func e_process(delta):
	tunp(delta)
	if(global_v.play_clicked):
		player_speed(delta)
	update_uniforms()
	if(!post_p.ispause):
		var mv=_mouse_position.x
		mv=sign(mv)*mv*mv*lpt+mv*lpt
		var vmd=smoothstep(unclick_time+0.45,unclick_time,global_v.iTime)
		if(isclick):
			vmd=1.0
		move_player(-6.5*mv*delta*vmd)
	if(global_v.play_clicked)&&(post_p.play_click+10.0<post_p.iTime):
		cbrp.set_visible(false)
		pbp.set_visible(false)
		outlinep.set_visible(false)
		outlinec.set_visible(false)
	if(post_p.ispause)&&(floor_l.get_speed_scale()>0.001):
		var vsp=floor_l.get_speed_scale()-01.3850*floor_l.get_speed_scale()*delta
		vsp=max(vsp,0.001)
		floor_l.set_speed_scale(vsp)
		floor_r.set_speed_scale(vsp)
		p_ex.set_speed_scale(vsp)
		floor_lw2.set_strength(vsp*1.0)
		floor_rw2.set_strength(vsp*1.0)
	if(!post_p.ispause)&&(floor_l.get_speed_scale()<1.0):
		var vsp=floor_l.get_speed_scale()+01.3850*delta
		vsp=min(vsp,1.0)
		floor_l.set_speed_scale(vsp)
		floor_r.set_speed_scale(vsp)
		p_ex.set_speed_scale(vsp)
		floor_lw2.set_strength(vsp*1.0)
		floor_rw2.set_strength(vsp*1.0)
		

func minus_speed():
	minus_speed_val+=0.12















