extends Control

func _ready():
	pass

func _process(delta):
	fade_btns(delta)

var iTime=0.0
var last_mtime=0.0
var mouse_in=false

func fade_btns(delta):
	iTime+=delta
	if(mouse_in):last_mtime=iTime
	var alph=smoothstep(4,0,iTime-last_mtime)
	if(get_node("Control").visible):alph=1
	get_node("options").get("custom_styles/hover").bg_color.a=alph
	get_node("options").get("custom_styles/pressed").bg_color.a=alph
	get_node("options").get("custom_styles/focus").bg_color.a=alph
	get_node("options").get("custom_styles/disabled").bg_color.a=alph
	get_node("options").get("custom_styles/normal").bg_color.a=alph
	
	get_node("options").set("custom_colors/font_color_disabled",Color(1,1,1,alph))
	get_node("options").set("custom_colors/font_color",Color(1,1,1,alph))
	get_node("options").set("custom_colors/font_color_hover",Color(1,1,1,alph))
	get_node("options").set("custom_colors/font_color_pressed",Color(1,1,1,alph))
	
	
	

func _on_options_pressed():
	get_node("Control").visible=!get_node("Control").visible


func _on_Control_mouse_entered():
	mouse_in=true


func _on_Control_mouse_exited():
	mouse_in=false


func _on_CheckBox_pressed():
	get_node("../").opt_portals=!get_node("../").opt_portals
	if(!get_node("../").opt_portals):
		get_node("../p1").set("render_target_update_mode",Viewport.UPDATE_WHEN_VISIBLE)
		get_node("../p2").set("render_target_update_mode",Viewport.UPDATE_WHEN_VISIBLE)
		get_node("../p3").set("render_target_update_mode",Viewport.UPDATE_WHEN_VISIBLE)
		get_node("../p4").set("render_target_update_mode",Viewport.UPDATE_WHEN_VISIBLE)
		get_node("../p5").set("render_target_update_mode",Viewport.UPDATE_WHEN_VISIBLE)
