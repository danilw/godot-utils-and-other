extends Spatial

# shadertoy texture logic https://gist.github.com/soulthreads/2efe50da4be1fb5f7ab60ff14ca434b8
var img_width = 512
var img_heigh = 2

const VU_COUNT = 512
const FREQ_MAX = 11025.0
const MIN_DB = 78
const dB_min = -100 
const dB_max = -30

onready var spectrum=AudioServer.get_bus_effect_instance(1,0)

onready var anode=get_node("AudioStreamPlayer3D")

var prev_array=[]
var this_array=[]
var cmat=[]

func _ready():
	cmat.append(get_node("../debug/audio/audio").material)
	cmat.append(get_node("../bg_particles/cubes").material_override)
	
	for a in range(img_width*img_heigh):
		prev_array.append(0)
		this_array.append(0)

func gen_spect_texture(update_audio):
	
	#fft
	var prev_hz = 0
	for a in range(1, VU_COUNT+1):
		var hz = a * FREQ_MAX / VU_COUNT;
		var magnitude: float = spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
		var energy = 0
		if(update_audio):
			energy=clamp((MIN_DB + clamp(linear2db(magnitude),dB_min,dB_max)) / MIN_DB, 0, 1)
		energy=0.8*prev_array[a-1]+0.2*energy
		this_array[a-1]=int(clamp((energy*255),0,255))
		prev_array[a-1]=energy
		prev_hz = hz
	
	#wave (not implemented)
#	for a in range(img_width):
#		this_array[img_width+a]=0
	
	var byte_array = PoolByteArray(this_array)
	var img = Image.new()
	img.create_from_data(img_width, img_heigh, false, Image.FORMAT_R8, byte_array)
	var texture = ImageTexture.new()
	texture.create_from_image(img, 0)
	return texture
	

var iTime=0
var ptime=0

func _process(delta):
	iTime+=delta
	if(anode.playing):
		ptime=iTime
		var tmpt=gen_spect_texture(true)
		for a in range(cmat.size()):
			cmat[a].set("shader_param/iChannel0",tmpt)
	else:
		if((iTime-ptime)<1):
			var tmpt=gen_spect_texture(false)
			for a in range(cmat.size()):
				cmat[a].set("shader_param/iChannel0",tmpt)
		




