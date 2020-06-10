extends Spatial




# Created by Danil (2020+) https://github.com/danilw

# some shaders use external source code that can be under CC non commercial License
# all used external resource linked on each shader, if used

# used two models with animations, origianl link (model License CC, check its sketchfab bage)
# https://sketchfab.com/3d-models/wolf-with-animations-f3769a474a714ebbbaca0d97f9b0a5a0
# https://sketchfab.com/3d-models/lil-guy-8fd55a0dcd8042168e7ffa57d7f279a5



onready var env
onready var player

func _ready():
	env=get_node("Camera").environment
	player=get_node("Camera")
	

var dir=false
var timerx=1

const min_speed=0.08
var speed=0.05

const lcenter=Vector3(6.5005,0,-4.438)
var ldelta=1.0/60.0

func calc_center():
	var sz=2.0625*2
	var center_l=Vector2(6.5*sz,-6*sz)
	var base_pos=Vector2(-7.937,12.062) # posiiton of one of particle-zone
	base_pos+=Vector2(-sz*3,sz*2)
	base_pos+=center_l
	print(base_pos) #lcenter

const dr=6 # min depth range on fade

func _process(delta):
	ldelta=max(delta,0.001)
	timer_lp()
	update_vp_res()
#	dir=false #uncomment to disable fog
	if(dir):
		if(timerx>0):
			var ttr=player.translation-lcenter
			var ttr2=Vector2(ttr.x,ttr.z).length()
			speed=min_speed+0.3*(clamp((ttr2-19)/2,0,1))
			speed=clamp(speed,0.1,1)
			timerx+=-delta*speed
			timerx=clamp(timerx,0,1)
			env.fog_depth_begin=2.5+60*timerx
			env.fog_depth_end=dr+60*timerx
	else:
		if(timerx<1):
			speed=min_speed
			timerx+=delta*speed
			timerx=clamp(timerx,0,1)
			env.fog_depth_begin=2.5+60*timerx
			env.fog_depth_end=dr+60*timerx
	

var osize=Vector2(1280,720)/2
func update_vp_res():
	var ts=OS.get_window_size()/2
	if((ts.x!=osize.x)||(ts.y!=osize.y)):
		osize=ts
		get_node("edge").set_size(osize)

func _on_area_in_body_entered(body):
	dir=false


func _on_area_in_body_exited(body):
	dir=true

var oncelp=false
var cframes=0

func timer_lp():
	if(oncelp):
		cframes+=1
		if(cframes>3):
			cframes=0
			oncelp=false

func _on_fa1_body_entered(body,val):
	if(body.is_a_parent_of(self)):
		return
	if(body.is_in_group("player")):
		var tp=Vector3(0,0,0)
		var sz=2.0625*2

# this Vector3(numbers) calculated by center(lcenter) position and shift on some number of tiles base on it, tile size 2.0625*2
# player.tp_frame for debug
		match(val):
			0:
				if(!oncelp):
					oncelp=true
					tp=Vector3(-14.1245,0,0)
					tp.z=player.translation.z
					#player.tp_frame=true
			1:
				if(!oncelp):
					oncelp=true
					tp=Vector3(27.12449,0,0)
					tp.z=player.translation.z
					#player.tp_frame=true
			2:
				if(!oncelp):
					oncelp=true
					tp=Vector3(0,0,-22.9995)
					tp.x=player.translation.x
					#player.tp_frame=true
			3:
				if(!oncelp):
					oncelp=true
					tp=lcenter+Vector3(0,0,4.5*sz)
					tp.x=player.translation.x
					#player.tp_frame=true
		tp.z+=-player.local_sp.z*10*(floor(1/ldelta)/60.0)
		tp.x+=-player.local_sp.x*10*(floor(1/ldelta)/60.0)
		player.translation.x=tp.x
		player.translation.z=tp.z
	
	
















