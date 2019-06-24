extends Viewport

var osize=Vector2(0,0)

func _ready():
	osize=OS.get_window_size()
	set_size(osize)
	pass

var passff=false
func _process(delta):
	self.msaa
	if (osize!=OS.get_window_size())&&(passff):
		osize=OS.get_window_size()
		set_size(osize)
		#self.set_size_override(true,osize)
		#self.set_size_override_stretch(true)
	passff=true
