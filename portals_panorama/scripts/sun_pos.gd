extends Spatial

const mbtns=3
const mgbtns=5
var iTime=0.0
var ocol=Array()
var ogcol=[Array(),Array(),Array(),Array(),Array()]

var angles=Vector3(-160,-80,-10)
var agngles=[Vector3(-5,-70,-178),Vector3(-160,-80,-10),Vector3(-160,-80,-10),
			Vector3(-160,-80,-10),Vector3(-160,-80,-10)]
var switcher=[false,false,false]
var sgwitcher=[[false,false,false],[false,false,false],[false,false,false],[false,false,false],[false,false,false]]
var smooth_vel=0.0
const max_vel=5.0

func _ready():
	for a in mbtns:
		ocol.append(get_node("b"+str(a)+"/glow").material_override.get("shader_param/colorx"))
		if(a!=0):get_node("b"+str(a)+"/glow").material_override.set("shader_param/colorx",Color.darkgray)
	for a in mgbtns:
		for b in mbtns:
			ogcol[a].append(get_node("../p"+str(a+1)+"/p"+str(a+1)+"/portals/a/sun_pos/"+"b"+str(b)+"/glow").material_override.get("shader_param/colorx"))
			if(b!=0):get_node("../p"+str(a+1)+"/p"+str(a+1)+"/portals/a/sun_pos/"+"b"+str(b)+"/glow").material_override.set("shader_param/colorx",Color.darkgray)
	

func smooth_sun(delta):
	var c=angles[0]
	if(switcher[1]):c=angles[1]
	if(switcher[2]):c=angles[2]
	var cg=get_node("../DirectionalLight").rotation_degrees.x
	var val=lerp(cg,c,delta/7.5)
	get_node("../DirectionalLight").rotation_degrees.x=val
	
	var da=get_node("../DirectionalLight").rotation
	da = -Vector3(sin(da.z),-(sin(da.x) * cos(da.z)), cos(da.x) * cos(da.y))
	get_node("../main_player/Camera/sphere").material_override.set("shader_param/dir_angle",da)
	

func smooth_g_sun(delta):
	for a in mgbtns:
		var c=agngles[a][0]
		if(sgwitcher[a][1]):c=agngles[a][1]
		if(sgwitcher[a][2]):c=agngles[a][2]
		var cg=get_node("../p"+str(a+1)+"/p"+str(a+1)+"/"+"DirectionalLight").rotation_degrees.x
		var val=lerp(cg,c,delta/7.5)
		get_node("../p"+str(a+1)+"/p"+str(a+1)+"/"+"DirectionalLight").rotation_degrees.x=val
		
		var da=get_node("../p"+str(a+1)+"/p"+str(a+1)+"/"+"DirectionalLight").rotation
		var oda=da
		da = -Vector3(sin(da.z),-(sin(da.x) * cos(da.z)), cos(da.x) * cos(da.y))
		get_node("../p"+str(a+1)+"/p"+str(a+1)+"/"+"Camera/sphere").material_override.set("shader_param/angle",oda)
		get_node("../p"+str(a+1)+"/p"+str(a+1)+"/"+"Camera/sphere").material_override.set("shader_param/dir_angle",da)
		get_node("../p"+str(a+1)+"/p"+str(a+1)+"/"+"Camera/sphere").material_override.set("shader_param/iTime",iTime)


func _process(delta):
	smooth_sun(delta)
	smooth_g_sun(delta)
	iTime+=delta

func _on_Area_btn_body_entered(body, idx, px):
	if(!body.is_in_group("player")):
		return
	if(px==0):
		get_node("b"+str(idx)+"/button").translation.y=-0.15
		get_node("b"+str(idx)+"/glow").material_override.set("shader_param/colorx",ocol[idx])
		switcher[idx]=true
		idx+=1
		for a in mbtns-1:
			if(idx>=mbtns):
				idx=0
			get_node("b"+str(idx)+"/button").translation.y=0
			get_node("b"+str(idx)+"/glow").material_override.set("shader_param/colorx",Color.darkgray)
			switcher[idx]=false
			idx+=1
		return
	
	#else
	get_node("../p"+str(px)+"/p"+str(px)+"/portals/a/sun_pos/"+"b"+str(idx)+"/button").translation.y=-0.15
	get_node("../p"+str(px)+"/p"+str(px)+"/portals/a/sun_pos/"+"b"+str(idx)+"/glow").material_override.set("shader_param/colorx",ogcol[px-1][idx])
	sgwitcher[px-1][idx]=true
	idx+=1
	for a in mbtns-1:
		if(idx>=mbtns):
			idx=0
		get_node("../p"+str(px)+"/p"+str(px)+"/portals/a/sun_pos/"+"b"+str(idx)+"/button").translation.y=0
		get_node("../p"+str(px)+"/p"+str(px)+"/portals/a/sun_pos/"+"b"+str(idx)+"/glow").material_override.set("shader_param/colorx",Color.darkgray)
		sgwitcher[px-1][idx]=false
		idx+=1
	return






