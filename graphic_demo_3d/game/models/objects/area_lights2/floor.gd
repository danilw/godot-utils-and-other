extends MeshInstance

onready var l1

func _ready():
	
	# save .exr to .data 
#	exr_to_data("g_ltc_mag.exr")
#	exr_to_data("g_ltc_mat.exr")
	
	# save .exr to .gd 
#	exr_to_data_v2("g_ltc_mag.exr")
#	exr_to_data_v2("g_ltc_mat.exr")

	# does not work in web
#	load_from_data()
	
	# this work, uncomment this to have it work in web
	# and remove Ltc Mat/Mag textures from material on this mesh
#	load_from_data_v2()
	
	var alights=get_node("../alights")
	for a in range(alights.get_child_count()):
		self.material_override.set("shader_param/light_pos"+str(a),alights.get_child(a).translation)
		self.material_override.set("shader_param/light_width"+str(a),alights.get_child(a).mesh.size.x*0.5)
		self.material_override.set("shader_param/light_height"+str(a),alights.get_child(a).mesh.size.y*0.5)
		var rotx=alights.get_child(a).rotation
		var da = Vector3(sin(rotx.y)*cos(rotx.x),-(sin(rotx.x)),cos(rotx.x) * cos(rotx.y))
		self.material_override.set("shader_param/light_normal"+str(a),da);
	
	l1=alights.get_node("l1")
	
	

# Godot-web build does not support EXR format look like
# GL ERROR :GL_INVALID_OPERATION : glTexImage2D: invalid internalformat/format/type combination GL_RGBA32F_EXT/GL_RGBA/GL_HALF_FLOAT

# loading from GDScript work (it produce 264kb GDScript to load 64*64 image, great...)
func exr_to_data_v2(exr):
	var img=load("res://game/models/objects/area_lights2/"+exr) as StreamTexture
	var data=img.get_data()
	data.convert(Image.FORMAT_RGBAF)
	data.lock()
	print(data.get_format()) #Image.FORMAT_RGBAH = 15
#	print(data.get_pixel(57,5))
	
	var path = OS.get_executable_path().get_base_dir().plus_file("exr_tmp")
	var dir = Directory.new()
	dir.make_dir(path)
	var save_file = File.new()
	save_file.open(path+"/"+exr+".gd", File.WRITE)
	save_file.store_line("extends Spatial")
	save_file.store_line("")
	save_file.store_line("func _ready():")
	save_file.store_line(" pass")
	save_file.store_line("var data_array=[")
	var bytearr=data.get_data()
	var pb=Array(bytearr)
	var text=""
	for a in range(pb.size()):
		text+=str(pb[a])+", "
		if((a%10)==0):
			save_file.store_line(text)
			text=""
	save_file.store_line(text)
	save_file.store_line("]")
	save_file.store_line("func get_data():")
	save_file.store_line(" return PoolByteArray(data_array)")
	save_file.close()
	data.unlock()

# look like it work
func load_from_data_v2():
	var array_width = 64
	var array_heigh = 64
	var array_mag = get_node("../data_mag").get_data()
	var array_mat = get_node("../data_mat").get_data()
	var img_mag = Image.new()
	img_mag.create_from_data(array_width, array_heigh, false, Image.FORMAT_RGBAF, array_mag)
	var img_mat = Image.new()
	img_mat.create_from_data(array_width, array_heigh, false, Image.FORMAT_RGBAF, array_mat)
#	img_mag.lock()
#	print(img_mag.get_format())
#	print(img_mag.get_pixel(57,5))
#	img_mag.unlock()
	
	var texture_mag = ImageTexture.new()
	texture_mag.create_from_image(img_mag, 0)
	var texture_mat = ImageTexture.new()
	texture_mat.create_from_image(img_mat, 0)
	self.material_override.set("shader_param/ltc_mat",texture_mat)
	self.material_override.set("shader_param/ltc_mag",texture_mag)

# does not work in web
func exr_to_data(exr):
	var img=load("res://game/models/objects/area_lights2/"+exr) as StreamTexture
	var data=img.get_data()
	data.lock()
	print(data.get_format()) #Image.FORMAT_RGBAH = 15
#	print(data.get_pixel(57,5))
	
	var path = OS.get_executable_path().get_base_dir().plus_file("exr_tmp")
	var dir = Directory.new()
	dir.make_dir(path)
	var save_file = File.new()
	save_file.open(path+"/"+exr, File.WRITE)
	save_file.store_buffer(data.get_data())
	save_file.close()
	data.unlock()

# does not work in web
func load_from_data():
	var array_width = 64
	var array_heigh = 64
	var load_file_mag = File.new()
	var load_file_mat = File.new()
	load_file_mag.open("res://game/models/objects/area_lights2/g_ltc_mag.data", File.READ)
	load_file_mat.open("res://game/models/objects/area_lights2/g_ltc_mat.data", File.READ)
	var array_mag = load_file_mag.get_buffer(array_width*array_width*8)
	var array_mat = load_file_mat.get_buffer(array_width*array_width*8)
	load_file_mag.close()
	load_file_mat.close()
	var img_mag = Image.new()
	img_mag.create_from_data(array_width, array_heigh, false, Image.FORMAT_RGBAH, array_mag)
	var img_mat = Image.new()
	img_mat.create_from_data(array_width, array_heigh, false, Image.FORMAT_RGBAH, array_mat)
#	img_mag.lock()
#	print(img_mag.get_format())
#	print(img_mag.get_pixel(57,5))
#	img_mag.unlock()
	
	var texture_mag = ImageTexture.new()
	texture_mag.create_from_image(img_mag, 0)
	var texture_mat = ImageTexture.new()
	texture_mat.create_from_image(img_mat, 0)
	self.material_override.set("shader_param/ltc_mat",texture_mat)
	self.material_override.set("shader_param/ltc_mag",texture_mag)
	

var iTime=0
func _process(delta):
	iTime+=delta
	self.material_override.set("shader_param/iTime",iTime);
	l1.material_override.set("shader_param/iTime",iTime);














