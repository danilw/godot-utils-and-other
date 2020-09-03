# Licensed under the MIT License.
# Copyright (c) 2018-2020 Jaccomo Lorenz (Maujoe)

# base on https://github.com/Maujoe/godot-camera-control

extends Spatial

# User settings:
# General settings
export var enabled = true setget set_enabled

# See https://docs.godotengine.org/en/latest/classes/class_input.html?highlight=Input#enumerations
export(int, "Visible", "Hidden", "Captured, Confined") var mouse_mode = Input.MOUSE_MODE_VISIBLE

enum Freelook_Modes {MOUSE, INPUT_ACTION, MOUSE_AND_INPUT_ACTION}

# Freelook settings
export var freelook = true
export (Freelook_Modes) var freelook_mode = 2
export (float, 0.0, 1.0) var sensitivity = 0.5
export (float, 0.0, 0.999, 0.001) var smoothness = 0.5 setget set_smoothness
export (int, 0, 360) var yaw_limit = 360
export (int, 0, 360) var pitch_limit = 360

# Movement settings
export var movement = true
export (float, 0.0, 1.0) var acceleration = 1.0
export (float, 0.0, 0.0, 1.0) var deceleration = 0.1
export var max_speed = Vector3(1.0, 1.0, 1.0)
export var local = true

# Input Actions
export var rotate_left_action = ""
export var rotate_right_action = ""
export var rotate_up_action = ""
export var rotate_down_action = ""
export var forward_action = "ui_up"
export var backward_action = "ui_down"
export var left_action = "ui_left"
export var right_action = "ui_right"
export var forward_action2 = "wasd_w"
export var backward_action2 = "wasd_s"
export var left_action2 = "wasd_a"
export var right_action2 = "wasd_d"
export var up_action = "ui_page_up"
export var down_action = "ui_page_down"
export var trigger_action = ""

# Intern variables.
var _mouse_offset = Vector2()
var _rotation_offset = Vector2()
var _yaw = 0.0
var _pitch = 0.0
var _total_yaw = 0.0
var _total_pitch = 0.0

var _direction = Vector3(0.0, 0.0, 0.0)
var _speed = Vector3(0.0, 0.0, 0.0)

var _triggered=false

const ROTATION_MULTIPLIER = 500

var mouse_c=false
var is_ui=false
var loaded=true

func _ready():
	set_enabled(enabled)

func get_action_x(val1,val2):
	var a=Input.get_action_strength(val1)
	var b=Input.get_action_strength(val1)
	if(a==0):
		return b
	return a

func _input(event):
	if(!loaded):
		return
	if event is InputEventMouseButton:
		if(event.button_index==1):
			mouse_c=event.pressed
		else:
			mouse_c=false
	if len(trigger_action)!=0:
		if event.is_action_pressed(trigger_action):
			_triggered=true
		elif event.is_action_released(trigger_action):
			_triggered=false
	else:
		_triggered=true
	if freelook and _triggered and mouse_c and !is_ui:
		if event is InputEventMouseMotion:
			_mouse_offset = event.relative
			
		_rotation_offset.x = Input.get_action_strength(rotate_right_action) - Input.get_action_strength(rotate_left_action)
		_rotation_offset.y = Input.get_action_strength(rotate_down_action) - Input.get_action_strength(rotate_up_action)

	if movement and _triggered and !is_ui:
		_direction.x = get_action_x(right_action,right_action2) - get_action_x(left_action,left_action2)
		_direction.y = Input.get_action_strength(up_action) - Input.get_action_strength(down_action)
		_direction.z = get_action_x(backward_action,backward_action2) - get_action_x(forward_action,forward_action2)

onready var c1=get_node("../material_id/floor_scene/Camera")
func copy_mov():
	c1.transform=self.transform

func _process(delta):
	if(!loaded):
		return
	if _triggered:
		if freelook:
			_update_rotation(delta)
		if movement:
			_update_movement(delta)
	copy_mov()
	
	

func _physics_process(delta):
	test_mouse()

func _update_movement(delta):
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

	if local:
		translate(_speed * delta)
	else:
		global_translate(_speed * delta)

func _update_rotation(delta):
	var offset = Vector2();
	
	if not freelook_mode == Freelook_Modes.INPUT_ACTION:
		offset += _mouse_offset * sensitivity
	if not freelook_mode == Freelook_Modes.MOUSE: 
		offset += _rotation_offset * sensitivity * ROTATION_MULTIPLIER * delta
	
	_mouse_offset = Vector2()

	_yaw = _yaw * smoothness + offset.x * (1.0 - smoothness)
	_pitch = _pitch * smoothness + offset.y * (1.0 - smoothness)

	if yaw_limit < 360:
		_yaw = clamp(_yaw, -yaw_limit - _total_yaw, yaw_limit - _total_yaw)
	if pitch_limit < 360:
		_pitch = clamp(_pitch, -pitch_limit - _total_pitch, pitch_limit - _total_pitch)

	_total_yaw += _yaw
	_total_pitch += _pitch


	rotate_y(deg2rad(-_yaw))
	rotate_object_local(Vector3(1,0,0), deg2rad(-_pitch))

func set_enabled(value):
	enabled = value
	if enabled:
		Input.set_mouse_mode(mouse_mode)
		set_process_input(true)
	else:
		set_process(false)
		set_process_input(false)
		set_physics_process(false)

func set_smoothness(value):
	smoothness = clamp(value, 0.001, 0.999)

onready var global_v=get_tree().get_root().get_node("scene")
const ray_length = 100
const collision_mask=1
func test_mouse():
	if (Input.is_mouse_button_pressed(BUTTON_RIGHT)):
		var mouse_local=Vector2()
		mouse_local.x=global_v.iMouse.x
		mouse_local.y=global_v.iResolution.y-global_v.iMouse.y
		var camera = self
		var ray_from = camera.project_ray_origin(mouse_local)
		var ray_to = ray_from + camera.project_ray_normal(mouse_local) * ray_length
		var space_state = get_world().direct_space_state
		var selection = space_state.intersect_ray(ray_from, ray_to, [self,get_node("KinematicBody")], collision_mask)
		if(selection):
			global_v.iMouse_3d=selection.position
			global_v.iMouse_3d_normal=selection.normal
			var tobj_groups=selection.collider.get_groups()
			var a=[1,2.3]
			if(tobj_groups.size()>0):
				match(tobj_groups[0]):
					"mat_id_0":
						global_v.iMouse_mid=0
					"mat_id_1":
						global_v.iMouse_mid=1
					"mat_id_2":
						global_v.iMouse_mid=2
					"mat_id_3":
						global_v.iMouse_mid=3
					"mat_id_4":
						global_v.iMouse_mid=4
	else:
		global_v.iMouse_mid=-1
