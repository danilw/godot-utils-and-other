extends MeshInstance

func _ready():
	pass

func _process(delta):
	self.rotate_z(-0.006)
	self.rotate_y(0.005)

