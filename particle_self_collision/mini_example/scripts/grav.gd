extends ColorRect

onready var global_v=get_tree().get_root().get_node("scene")

var click=0

func _ready():
	pass

func angle2d(c, e):
	var theta = atan2(e.y-c.y, e.x-c.x)
	return theta

func _process(delta):
	self.material.set("shader_param/iTime",global_v.iTime)
	self.material.set("shader_param/iFrame",global_v.iFrame)
	var tm=global_v.iMouse
	tm.x=(tm.x-self.rect_position.x)
	tm.y=(tm.y-self.rect_position.y)
	if(click==1):
		self.material.set("shader_param/iMouse",tm)
		var tv=min(Vector2(tm.x-75,tm.y-75).length(),75)/75
		var md=Transform2D()
		md = md.rotated(-(-PI/2+angle2d(Vector2(tm.x-75,tm.y-75),Vector2(0,0))))
		md = md.translated( Vector2(0,tv) )
		global_v.gravity=md.get_origin()*global_v.gravity_max
		global_v.gravity.y=-global_v.gravity.y
