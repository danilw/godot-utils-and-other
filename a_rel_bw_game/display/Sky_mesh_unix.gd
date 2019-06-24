extends MeshInstance

export (float) var iTime=0.0;
export (int) var iFrame=0;

func _ready():
	pass

func _process(delta):
	self.get_surface_material(0).set("shader_param/iTime",iTime)
	self.get_surface_material(0).set("shader_param/iFrame",iFrame)
	iTime+=delta
	iFrame+=1