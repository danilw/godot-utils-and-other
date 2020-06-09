extends Spatial

var o_rot=Vector3(0,0,0)

func _ready():
	get_node("../spheres/Cone/shield").visible=true
	get_node("../spheres/Cone/shield2").visible=true
	o_rot=get_node("../Camera").get_rotation()
	

var iTime=0
var sdelta=1.0/60.0
func _process(delta):
	get_node("../Camera").rotate(Vector3.UP,sdelta*PI*2)
	iTime+=sdelta
	if(iTime>1):
		get_node("../spheres/Cone/shield").visible=false
		get_node("../spheres/Cone/shield2").visible=false
		set_process(false)
		get_node("../Control").loaded=true
		get_node("../Camera").set_rotation(o_rot)
		get_node("../Camera").loaded=true
