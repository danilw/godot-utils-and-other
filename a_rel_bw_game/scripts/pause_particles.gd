extends FutariParticles

var speed_scale_local=1

func _ready():
	speed_scale_local=self.get_speed_scale()

func on_pause():
	if(get_tree().paused):
		#get_tree().connect("idle_frame", self, "_internal_process")
		speed_scale_local=self.get_speed_scale()
		self.set_speed_scale(0)
	else:
		#get_tree().disconnect("idle_frame", self, "_internal_process")
		self.set_speed_scale(speed_scale_local)
	pass
