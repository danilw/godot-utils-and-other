extends RigidBody

var start_pos=Vector3()
var stop_time=0.0
var iTime=0.0

func _ready():
	start_pos=self.translation
	
func _process(delta):
	iTime+=delta
	anti_fall()
	sphere_pos()

func anti_fall():
	if(self.translation.length()>100)&&(self.mode==RigidBody.MODE_RIGID):
			self.mode=RigidBody.MODE_KINEMATIC
			self.set_visible(false)
			stop_time=iTime
	if(iTime-stop_time>1.0)&&(self.mode==RigidBody.MODE_KINEMATIC):
			self.translation=start_pos+Vector3(0,2,0)
			self.mode=RigidBody.MODE_RIGID
			self.set_visible(true)

func sphere_pos():
	get_node("../../p1/p1/spheres/"+self.name).translation=self.translation
	get_node("../../p1/p1/spheres/"+self.name).rotation=self.rotation
	get_node("../../p2/p2/spheres/"+self.name).translation=self.translation
	get_node("../../p2/p2/spheres/"+self.name).rotation=self.rotation
	get_node("../../p3/p3/spheres/"+self.name).translation=self.translation
	get_node("../../p3/p3/spheres/"+self.name).rotation=self.rotation
	get_node("../../p4/p4/spheres/"+self.name).translation=self.translation
	get_node("../../p4/p4/spheres/"+self.name).rotation=self.rotation
	get_node("../../p5/p5/spheres/"+self.name).translation=self.translation
	get_node("../../p5/p5/spheres/"+self.name).rotation=self.rotation
	
