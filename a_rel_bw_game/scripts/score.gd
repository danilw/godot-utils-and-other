extends Label

onready var pause_camera=get_tree().get_root().get_node("scene/main_screen/main_vp/scene/pause_camera")

var score=0.0
export (int) var lastsc=0

func _ready():
	self.set_text("00000")
	pass

func _process(delta):
	if(!get_tree().paused):
		if(pause_camera.SPEED<=0.05):
			score=0
		score+=delta
		if(lastsc!=floor(score)):
			lastsc=floor(score)
			var texxt=str(lastsc)
			var ext=""
			for a in range(max(5-texxt.length(),0)):
				ext+="0"
			self.set_text(ext+texxt)
