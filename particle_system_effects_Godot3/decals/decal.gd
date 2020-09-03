extends MeshInstance

onready var global_v=get_tree().get_root().get_node("scene")

# decals based on https://github.com/Mr-Slurpy/Screen-Space-Decals

const ttlive=30

var material_id=-1
var iTime=0
var iFrame=0

func _ready():
	set_local()

func set_local():
	mesh.set_local_to_scene(true)
	material_override.set_local_to_scene(true)
	material_override.shader.set_local_to_scene(true)

func set_material_id(mid):
	material_id=mid
	material_override.set_shader_param("material_id", mid)

func set_viewport(vpt):
	material_override.set_shader_param("material_id_viewport", vpt)


var once_p=true
func _process(delta):
	material_override.set_shader_param("ttlive", ttlive)
	material_override.set_shader_param("iTime", max(iTime-0.25,0))
	material_override.set_shader_param("iFrame", max(iFrame-int(0.25*60),0))
	material_override.set_shader_param("depth_step", global_v.depth_step)
	get_node("expl/expl").material_override.set_shader_param("iTime", iTime)
	if(once_p&&(iTime>0.25)):
		once_p=false
		get_node("expl/Particles").emitting=true
		get_node("expl/Particles2").emitting=true
	if(iTime>0.5):
		get_node("expl/expl").visible=false
		
	if(material_id>=0):
		iTime+=delta
		iFrame+=1
		if(iTime>ttlive):
			get_parent().call_deferred("remove_child",self)
			set_process(false)
