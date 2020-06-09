extends MeshInstance

onready var lp=[]
onready var l2n

func _ready():
	lp.append(get_node("../p1").transform)
	lp.append(get_node("../p2").transform)
	lp.append(get_node("../p3").transform)
	lp.append(get_node("../p4").transform)
	l2n=get_node("../l2")

var mov=false
var iTime=0
var iTime2=0
var ctr=1

func _process(delta):
	if(mov):
		if(iTime2>PI/2):
			mov=false
			iTime2=0
			ctr=(ctr+1)%4
			return
		iTime=fmod(iTime,PI*2)
		iTime+=delta*0.25
		iTime2+=delta*0.25
		var v2=-sin(iTime)
		var v1=-cos(iTime)
		self.translation=Vector3(smoothstep(0,1,abs(v1))*2.8*sign(v1),0.62,smoothstep(0,1,abs(v2))*2.8*sign(v2))
		self.transform.basis=self.transform.interpolate_with(lp[ctr],delta*(0.25/(PI/2))).basis
func _on_Area_body_entered(body):
	if(body.is_a_parent_of(self)):
		return
	if(body.is_in_group("player")):
		mov=true
