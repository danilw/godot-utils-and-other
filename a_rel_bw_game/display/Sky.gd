extends Sprite

#udate uniforms

export (float) var iTime=0.0
export (int) var iFrame=0
export (float) var sun_pos=0.0

func _ready():
	pass

func _process(delta):
	self.material.set("shader_param/iTime",iTime)
	self.material.set("shader_param/sun_pos",sun_pos)
	self.material.set("shader_param/iFrame",iFrame)
	iTime+=delta
	iFrame+=1
