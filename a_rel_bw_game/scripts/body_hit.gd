extends KinematicBody

onready var cam_p=get_node("../../../../../scene/pause_camera")

func _ready():
	pass

func hit():
	cam_p.minus_speed()