extends Sprite


export var radius=0 # 512 256 64 32
export var mass=0

export var is_static=false # static does not move by gravity
export var can_collide=true # collision enable

# bounce include gravity vector and reflect it, false to disable
export var reflect_gravity_on_hit=false
export var bval=1.0 # 1.0 is bounce value, set <1 

# enable/disable self gravity
export var self_gravity=true

# enable/disable self gravity
export var react_gravity=true

export var coll_level_3_active=false
export var start_heading=Vector2()

var is_active=true # if false this object ignored
var heading=Vector2() #velocity

onready var root_node=get_node("../")
var node_list=Array()

# colors
# black static object with gravity
# red movable object with gravity, and do not react on other gravity
# blue moving object without gravity
# green moving object without gravity and collision

#texture used to have mipmaps

func _ready():
	if(radius==512):
		self.texture=load("res://round.png") as Texture
	elif(radius==256):
		self.texture=load("res://round2.png") as Texture
	elif(radius==64):
		self.texture=load("res://round3.png") as Texture
	elif(radius==32):
		self.texture=load("res://round4.png") as Texture
	else:
		radius=0
	if(radius==0)||(mass==0):
		is_active=false
		self.visible=false
	
	for a in range(get_node("../").get_child_count()):
		var el=get_node("../").get_child(a)
		node_list.append(el)
	
	var self_color=Color()
	self.material=self.material.duplicate()
	if(is_static):
		self_color=Color.black
	elif(can_collide)&&(self_gravity)&&(!react_gravity):
		self_color=Color.red
	elif(can_collide)&&(!self_gravity)&&(react_gravity):
		self_color=Color.blue
	elif(!can_collide)&&(!self_gravity)&&(react_gravity):
		self_color=Color.green
	
	self.material.set("shader_param/color",self_color)
	heading=start_heading

func _process(delta):
	if(!is_active):
		return #can be free() node instead
	sumVector()
	slow_it(delta)
	lim_heading()
	self.position+=heading
	
	update_text()
	process_input()

func update_text():
	self.material.set("shader_param/len",str(mass).length())
	self.material.set("shader_param/value",int(mass))
	self.material.set("shader_param/zoom_val",root_node.scale.x)

# mass change by mouse
func process_input():
	if !(self_gravity&&is_active):
		return
	var iResolution=Vector2(1280,720)
	var iMouse=get_viewport().get_mouse_position()/iResolution
	iMouse=(iMouse-Vector2(0.5,0.5))*iResolution
	if((self.position*root_node.scale-iMouse).length()<(radius/2)*root_node.scale.x):
		root_node.mouse_block=true
		if(Input.is_action_pressed("l_click")):
			mass+=int(250+20000*smoothstep(5000,500000,mass))
		if(Input.is_action_pressed("r_click")):
			mass+=-int(250+20000*smoothstep(5000,500000,mass))
		mass=clamp(mass,10,9999999)
	

# max speed limit, slowdown
const max_speed=10
func lim_heading():
	if(heading.length()>max_speed):
		heading=heading.normalized()*max_speed

func angle2d(c,e):
	var theta = atan2(e.y-c.y,e.x-c.x)
	return theta

# move back to center when position too far
const max_length=10000
func slow_it(delta):
	if(self.position.length()>max_length):
		var angl=-PI/2+angle2d(Vector2(),self.position)
		var tva=max_speed*Vector2(sin(-angl),cos(-angl))
		heading+=-tva*delta

# void
func distance_length(a,b):
	return (a-b).length()

# float
func calculateGravity(body):
	if(body==self):
		return 0
	var mass1=mass
	var mass2=body.mass
	var distanceBetween=distance_length(self.position,body.position)
	distanceBetween=max(distanceBetween,0.0001)
	return ((mass1 * mass2) / pow(distanceBetween, 2))

# vec2
func findVector(body):
	var forceBetween = calculateGravity(body);
	var hvDist=body.position-self.position
	var totalDistance = abs(hvDist.x) + abs(hvDist.y);
	totalDistance=max(totalDistance,0.0001)
	return (forceBetween / totalDistance) * hvDist;

# bool
func collides(body):
	var temp=self.position+heading
	var distance = distance_length(temp,body.position);
	if (distance < radius/2+body.radius/2):
		return true
	else:
		return false

# vec2
func bounce(body,fi,dyn):
	var tangentVector=Vector2()
	tangentVector.y = -(body.position.x - self.position.x)
	tangentVector.x = body.position.y - self.position.y
	tangentVector = tangentVector.normalized()
	var tfi=Vector2()
	if(reflect_gravity_on_hit):
		tfi=fi
	var relativeVelocity = self.heading - body.heading + tfi
	var leng = relativeVelocity.dot(tangentVector)
	var velComponentOnTangent = leng*tangentVector
	var velComponentPerpendicularToTangent=relativeVelocity - velComponentOnTangent
	var ret=velComponentPerpendicularToTangent
	if(dyn):
		var tret=2*ret/(mass+body.mass)
		body.heading+=tret*mass
		return -tret*body.mass
	else:
		return -2*ret

# vec2
func unstuck(body):
	var angl=-PI/2+angle2d(self.position,body.position)
	var temp=self.position+heading
	var distance = distance_length(temp,body.position);
	var distanceToMove = radius/2 + body.radius/2 - distance
	var tva=distanceToMove*Vector2(sin(-angl),cos(-angl))
	self.position+=-tva

# void
func sumVector():
	if(is_static):
		return
	var final=heading
	for a in range(node_list.size()):
		var el=node_list[a]
		if(el==self)||(!el.is_active):
			continue
		if(!is_static)&&(react_gravity)&&(el.self_gravity):
			var tv=findVector(el) # gravity
			final+=tv
		if(!is_static)&&(can_collide)&&(el.can_collide):
			if(collides(el)): # collision
				if(el.is_static):
					final=heading+bounce(el,final,false)*bval # bounce static
				else:
					final=heading+bounce(el,final,true)*bval # bounce dyn
				unstuck(el)
				#break
	heading=final
	

















