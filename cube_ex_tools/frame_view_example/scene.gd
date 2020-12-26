extends Spatial

# Created by Danil (2020+) https://github.com/danilw
# The MIT License

# script just to control time and animation

var iTime:float=0.0

const sec_to_record=8

onready var capture1=get_node("capture1")
onready var capture2=get_node("capture2")
onready var ball=get_node("dynamic/RigidBody")

var ball_start=Vector3()

func _ready():
  ball_start=ball.translation

func _process(delta):
  var timer=fmod(iTime,sec_to_record*2+2)
  
  if(timer-2<sec_to_record)&&(timer-2>0):
    if(ball.mode==RigidBody.MODE_KINEMATIC):
      ball.mode=RigidBody.MODE_RIGID
  else:
    if(ball.mode==RigidBody.MODE_RIGID):
      ball.mode=RigidBody.MODE_KINEMATIC
      ball.translation=ball_start
  
  var local_timer=clamp(timer-2,0,sec_to_record)-clamp(timer-2-sec_to_record,0,sec_to_record)
  capture1.material_override.set("shader_param/iTime",local_timer)
  capture2.material_override.set("shader_param/iTime",local_timer)
  
  iTime+=delta
