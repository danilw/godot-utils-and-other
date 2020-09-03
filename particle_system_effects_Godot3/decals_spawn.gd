extends Spatial

# decals based on https://github.com/Mr-Slurpy/Screen-Space-Decals

onready var cnode=get_node("decal")
onready var cnode_mat=get_node("decal").material_override
onready var cspawn=get_node("spawn")
onready var vptx=get_node("../material_id")
var rp_counter=0

func _ready():
	pass

func new_decal_at(pos,abasis,mid):
	rp_counter+=1
	rp_counter=rp_counter%40
	var ccopy=cnode.duplicate(DUPLICATE_SCRIPTS)
	ccopy.material_override=cnode_mat.duplicate(false)
	ccopy.material_override.render_priority=rp_counter
	ccopy.set_local()
	ccopy.set_viewport(vptx.get_viewport().get_texture())
	ccopy.set_material_id(mid)
	ccopy.visible=true
	ccopy.translation=pos
	var bscale=ccopy.scale
	ccopy.transform.basis=abasis
	ccopy.scale=bscale
	cspawn.add_child(ccopy)
	
	bscale=ccopy.get_node("expl").scale
	ccopy.get_node("expl").transform.basis=abasis.inverse()
	ccopy.get_node("expl").scale=bscale

func _process(delta):
	pass
