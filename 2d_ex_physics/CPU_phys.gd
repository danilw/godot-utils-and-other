extends Node2D

var elem

var iTime=0.0

var static_obj=Array()
var static_orb_radius=Array()

# GDScript can not calculate too much loops look like
# same logic on C can display 500+ body very easy on my CPU(60fps)
# when GDScript can not more then 100
var static_size=6
var dyn_grav_size=10*1
var dyn_size=10*6
var dyn_nograv_size=10*2

var mouse_block=false

func _ready():
	# preload
	elem=preload("res://CPU_object.tscn")
	var iResolution=Vector2(1280,720)
	self.position=iResolution/2
	
	# static gravity objects
	spawn_1()
	spawn_2()
	spawn_3()
	spawn_4()
	
	get_node("../Control/Label").text+=str(static_size+dyn_grav_size+dyn_size+dyn_nograv_size)+" body"
	
	

func _process(delta):
	iTime+=delta
	process_input(delta)
	process_static_move(delta)
	mouse_block=false

func spawn_1():
	for a in range(static_size):
		var s=elem.instance()
		s.radius=512
		s.mass=10000
		s.is_static=true
		s.can_collide=true
		var an=PI/8*a
		static_orb_radius.append(600*a+25*a*a)
		s.position=(static_orb_radius[static_orb_radius.size()-1]*Vector2(sin(an),cos(an)))
		static_obj.append(s)
		self.call_deferred("add_child",s)

func spawn_2():
	for a in range(dyn_grav_size):
		var s=elem.instance()
		s.radius=256
		s.mass=10000
		s.is_static=false
		s.can_collide=true
		s.react_gravity=false
		s.self_gravity=true
		s.bval=1
		var an=a*((PI*2)/dyn_grav_size)
		s.position=(800+200*a)*Vector2(sin(an),cos(an))
		self.call_deferred("add_child",s)

func spawn_3():
	for a in range(dyn_size):
		var s=elem.instance()
		s.radius=64
		s.mass=1
		s.is_static=false
		s.can_collide=true
		s.self_gravity=false
		s.bval=0.98
		var an=a*((PI*2)/dyn_size)
		s.position=(650+10*a)*Vector2(sin(an),cos(an))
		self.call_deferred("add_child",s)

func spawn_4():
	for a in range(dyn_nograv_size):
		var s=elem.instance()
		s.radius=32
		s.mass=1
		s.is_static=false
		s.can_collide=false
		s.self_gravity=false
		s.bval=0.98
		var an=a*((PI*2)/dyn_nograv_size)
		s.position=(750+10*a)*Vector2(sin(an),cos(an))
		self.call_deferred("add_child",s)

func process_input(delta):
	if(Input.is_action_pressed("zoom_out")||(Input.is_action_pressed("l_click")&&(!mouse_block))):
		self.scale=self.scale+Vector2(delta*2.0,delta*2.0)*self.scale
		self.scale=Vector2(min(self.scale.x,1),min(self.scale.y,1))
	if(Input.is_action_pressed("zoom_in")||(Input.is_action_pressed("r_click")&&(!mouse_block))):
		self.scale=self.scale-Vector2(delta*2.0,delta*2.0)*self.scale
		self.scale=Vector2(max(self.scale.x,0.01),max(self.scale.y,0.01))
	

func angle2d(c,e):
	var theta = atan2(e.y-c.y,e.x-c.x)
	return theta

# move on circle
func process_static_move(delta):
	for a in range(static_size):
		var angl=-PI/2+angle2d(Vector2(),static_obj[a].position)
		angl+=(0.81-0.7*smoothstep(0,static_size,a))*delta
		var tva=static_orb_radius[a]*Vector2(sin(-angl),cos(-angl))
		static_obj[a].heading=-static_obj[a].position+tva









