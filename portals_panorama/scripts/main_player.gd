extends KinematicBody

var mouse_c=false
var is_ui=false
var _mouse_position = Vector2(0.0, 0.0)
var _yaw = 0.0
var _pitch = 0.0
var _total_yaw = 0.0
var _total_pitch = 0.0

const sensitivity = 0.25
const smoothness = 0.25

const yaw_limit = 360
const pitch_limit = 360

const GRAVITY = -0.35
const JUMP_SPEED = 10.0
var jump_timer=0.0
var hfloor_timer=0.0
var hit_floor=false

var _direction = Vector3(0.0, 0.0, 0.0)
var vel=Vector3(0,0,0)
var _speed = Vector3(0.0, 0.0, 0.0)
const max_speed = Vector3(5.0, 5.0, 5.0)
const acceleration = 1.0
const deceleration = 0.1
const MAX_SLOPE_ANGLE = 80

var forward_action = "ui_up"
var backward_action = "ui_down"
var left_action = "ui_left"
var right_action = "ui_right"
var up_action = "ui_page_up"
var down_action = "ui_page_down"

var iTime=0.0
var start_pos=Vector3()

func _ready():
	start_pos=self.translation

func _process(delta):
	anti_fall()
	_update_mouselook()
	update_all_cam()
	iTime+=delta

func _physics_process(delta):
	process_movement(delta)
	process_collision(delta)
	
func _input(event):
	if event is InputEventMouseButton:
		mouse_c=!mouse_c
	if mouse_c and !is_ui:
		if event is InputEventMouseMotion:
			_mouse_position = event.relative
	
	if event.is_action_pressed(forward_action):
		_direction.z = -1
	elif event.is_action_pressed(backward_action):
		_direction.z = 1
	elif not Input.is_action_pressed(forward_action) and not Input.is_action_pressed(backward_action):
		_direction.z = 0

	if event.is_action_pressed(left_action):
		_direction.x = -1
	elif event.is_action_pressed(right_action):
		_direction.x = 1
	elif not Input.is_action_pressed(left_action) and not Input.is_action_pressed(right_action):
		_direction.x = 0
	
	if is_on_floor()||(hit_floor):
		hfloor_timer=iTime
	if is_on_floor()||hit_floor||iTime-hfloor_timer>1:
		hit_floor=true
		if Input.is_action_just_pressed("ui_select"):
			hit_floor=false
			vel.y = JUMP_SPEED
			jump_timer=iTime
	

func anti_fall():
	if(self.translation.length()>100):
		self.translation=start_pos+Vector3(0,5,0)

func process_movement(delta):
	var offset = max_speed * acceleration * _direction
	
	_speed.x = clamp(_speed.x + offset.x, -max_speed.x, max_speed.x)
	_speed.y = clamp(_speed.y + offset.y, -max_speed.y, max_speed.y)
	_speed.z = clamp(_speed.z + offset.z, -max_speed.z, max_speed.z)
	
	# Apply deceleration if no input
	if _direction.x == 0:
		_speed.x *= (1.0 - deceleration)
	if _direction.y == 0:
		_speed.y *= (1.0 - deceleration)
	if _direction.z == 0:
		_speed.z *= (1.0 - deceleration)
	vel.x = _speed.x
	vel.z = _speed.z
	var tvely=0.99*vel.y
	vel.y=0
	var md=get_node("Camera").transform
	md=md.translated(vel)
	vel=md.origin
	vel.y = tvely+GRAVITY
	vel = move_and_slide(vel,Vector3(0,1,0), true, 4, deg2rad(MAX_SLOPE_ANGLE),false)

func process_collision(delta):
	for a in get_slide_count():
		var collision = get_slide_collision(a)
		if(collision.collider.is_in_group("spheres")):
			if(collision.collider is RigidBody):
				if(collision.collider.mode==RigidBody.MODE_RIGID):
					collision.collider.apply_central_impulse(-collision.normal * vel.length() * 1.0)

func update_all_cam():
	var cam_node=Array()
	cam_node.append(get_node("../p1/p1/Camera"))
	cam_node.append(get_node("../p2/p2/Camera"))
	cam_node.append(get_node("../p3/p3/Camera"))
	cam_node.append(get_node("../p4/p4/Camera"))
	cam_node.append(get_node("../p5/p5/Camera"))
	cam_node.append(get_node("../p0/Camera"))
	for a in cam_node:
		a.rotation=get_node("Camera").rotation
		a.translation=self.translation
		a.translation.y+=1

func _update_mouselook():
	_mouse_position *= sensitivity
	_yaw = _yaw * smoothness + _mouse_position.x * (1.0 - smoothness)
	_pitch = _pitch * smoothness + _mouse_position.y * (1.0 - smoothness)
	_mouse_position = Vector2(0, 0)

	if yaw_limit < 360:
		_yaw = clamp(_yaw, -yaw_limit - _total_yaw, yaw_limit - _total_yaw)
	if pitch_limit < 360:
		_pitch = clamp(_pitch, -pitch_limit - _total_pitch, pitch_limit - _total_pitch)

	_total_yaw += _yaw
	_total_pitch += _pitch
	
	get_node("Camera").rotate_y(deg2rad(-_yaw))
	get_node("Camera").rotate_object_local(Vector3(1,0,0), deg2rad(-_pitch))
