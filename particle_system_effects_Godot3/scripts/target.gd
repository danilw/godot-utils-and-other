extends Spatial

onready var global_v=get_tree().get_root().get_node("scene")

onready var targetn=self
onready var targetn2=get_node("target")
onready var camn=get_node("../Camera")
onready var target_mat=get_node("target/MeshInstance").material_override
onready var decal_spawn=get_node("../decals_spawn")

var base_col=Color()
var targetn_transform=Transform()

func _ready():
	targetn_transform=targetn2.transform
	base_col=target_mat.albedo_color

func look_at_with_y(trans,new_y,v_up):
	trans.basis.y=new_y.normalized()
	trans.basis.z=v_up*-1
	trans.basis.x = trans.basis.z.cross(trans.basis.y).normalized();
	trans.basis.z = trans.basis.y.cross(trans.basis.x).normalized();
	trans.basis.x = trans.basis.x * -1
	trans.basis = trans.basis.orthonormalized() 
	return trans

var local_timer=0

func spawn_decal(pos,angles,mid):
	if(local_timer>1):
		local_timer=0
		decal_spawn.new_decal_at(pos,angles,mid)

func update_target(delta):
	if(Input.is_mouse_button_pressed(BUTTON_RIGHT)&&(global_v.iMouse_mid>=0)):
		local_timer+=delta*1.0
		targetn.visible=true
		targetn.translation=global_v.iMouse_3d
		var new_t=look_at_with_y(targetn_transform,global_v.iMouse_3d_normal,camn.global_transform.basis.y)
		targetn2.transform=targetn2.transform.interpolate_with(new_t,delta*5)
		spawn_decal(global_v.iMouse_3d,new_t.basis,global_v.iMouse_mid)
		target_mat.albedo_color=Color(max(base_col.g*local_timer,base_col.r),max(base_col.g*(1-local_timer),base_col.r),base_col.b,base_col.a)
	else:
		targetn.visible=false
		target_mat.albedo_color=base_col
		local_timer=0
		

func _process(delta):
	update_target(delta)
