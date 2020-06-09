extends MeshInstance

var iTime=0

func _ready():
	pass

func _process(delta):
	iTime+=delta
	self.material_override.set("shader_param/iTime",iTime)
