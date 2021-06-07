extends GridContainer

# include render logic

onready var global_v=get_tree().get_root().get_node("scene")

var save_folder="out_img"
func _ready():
	var dir = Directory.new()
	var path = OS.get_executable_path().get_base_dir().plus_file(save_folder)
	dir.make_dir(path)
	get_node("../imgl").connect("file_selected",self,"_on_file_select")
	get_node("../imgl").connect("popup_hide",self,"_on_file_hide")
	get_node("../warn").connect("confirmed",self,"_render_confirm")

var render_once=false
var pass_one_frame=true
var ftps=0
var iFrame=0
var iFrame1=0
var once_a=false
var glow_frames=0

var serr=false
var err=0
func save_frame(name):
	var image = get_node("../../Viewport").get_texture().get_data()
	#image.flip_y()
	var path = OS.get_executable_path().get_base_dir().plus_file(save_folder)
	var dir = Directory.new()
	dir.make_dir(path)
	err=image.save_png(path.plus_file(name+".png"))
	if err!=0:
		serr=true

func do_task():
	if(render_once)&&(iFrame<glow_frames+1)&&(!serr):
		if(pass_one_frame):
			if(ftps>10):
				ftps=0
				pass_one_frame=false
				gen_data(true,false,0)
			else:
				ftps+=1
			return
		if(iFrame==0)&&(iFrame1==0):
			get_node("../../Viewport").render_target_update_mode=Viewport.UPDATE_ALWAYS
		if(iFrame==1)&&(iFrame1==0):
			save_frame("orig_"+str(iFrame))
		if(iFrame>1)&&(iFrame1==0):
			save_frame("glow_"+str(iFrame-1))
		if(iFrame>0)&&(iFrame1==0):
			gen_data(true,true,iFrame)
		get_node("../../Viewport/Sprite").material.set("shader_param/iFrame",iFrame)
		get_node("../../Viewport/Sprite").material.set("shader_param/iFrame1",iFrame1)
		get_node("../pct/Label").text="Progress: Frame - "+str(iFrame+1)
		iFrame1+=1
		if(iFrame1>=14*8):
			iFrame1=0
			iFrame+=1
			get_node("../pct/ProgressBar2").value=0
		get_node("../pct/ProgressBar").value=(float(iFrame)/(glow_frames+1))*100
		get_node("../pct/ProgressBar2").value=(float(iFrame1)/(14*8))*100
	else:
		if(once_a):
			if(iFrame==1)&&(!serr):
				save_frame("orig_"+str(iFrame))
			if(iFrame>1)&&(!serr):
				save_frame("glow_"+str(iFrame-1))
			if(serr):
				get_node("../serr").dialog_text="Error on save file: "+str(err)
				get_node("../serr").popup_centered(Vector2(320, 240))
			get_node("../../Viewport").render_target_update_mode=Viewport.UPDATE_DISABLED
			iFrame=0
			iFrame1=0
			render_once=false
			once_a=false
			self.visible=true
			serr=false
			err=0
			ftps=0
			pass_one_frame=true
			get_node("../pct").visible=false
		

func _process(delta):
	do_task()
	if(get_node("vc/rtx").pressed):
		update_box_data()

var r3=false
func _on_hs_pressed():
	r3=!r3
	get_node("../../bg").material.set("shader_param/render3",r3)
	get_node("../../elems").visible=!get_node("../../elems").visible
	for a in range(get_node("vc").get_child_count()-1):
		get_node("vc").get_child(a).visible=!get_node("vc").get_child(a).visible

var once_rconfirm=true

func _on_re_pressed():
	if(once_rconfirm):
		get_node("../warn").popup_centered(Vector2(640, 480))
	else:
		_render_confirm()

func _render_confirm():
	once_rconfirm=false
	get_node("../../Viewport2").render_target_update_mode=Viewport.UPDATE_DISABLED
	get_node("../../Viewport3").render_target_update_mode=Viewport.UPDATE_DISABLED
	get_node("../../bg").material.set("shader_param/render2",false)
	get_node("vc/rtx").pressed=false
	r3=true
	get_node("../../bg").material.set("shader_param/render3",r3)
	for a in range(get_node("vc").get_child_count()-1):
		get_node("vc").get_child(a).visible=false
	get_node("../../bg").material.set("shader_param/render",true)
	self.visible=false
	get_node("../pct").visible=true
	get_node("../../elems").visible=false
	get_node("../pct/ProgressBar").value=0
	get_node("../pct/ProgressBar2").value=0
	get_node("../pct/Label").text="Progress: Frame - "+str(0+1)
	render_once=true
	once_a=true

func _on_x_text_changed(new_text):
	var res=Vector2(get_node("vc/hb/x").text.to_int(),get_node("vc/hb/y").text.to_int())
	if(res.x<1)||(res.x>4096):
		get_node("vc/hb/x").text=str(clamp(res.x,10,4096))
	res=Vector2(get_node("vc/hb/x").text.to_int(),get_node("vc/hb/y").text.to_int())
	if(res.x>=1)&&(res.x<=4096)&&(res.y>=1)&&(res.y<=4096):
		get_node("../../bg").material.set("shader_param/l_res",res)

func _on_y_text_changed(new_text):
	var res=Vector2(get_node("vc/hb/x").text.to_int(),get_node("vc/hb/y").text.to_int())
	if(res.y<1)||(res.y>4096):
		get_node("vc/hb/y").text=str(clamp(res.y,10,4096))
	res=Vector2(get_node("vc/hb/x").text.to_int(),get_node("vc/hb/y").text.to_int())
	if(res.x>=1)&&(res.x<=4096)&&(res.y>=1)&&(res.y<=4096):
		get_node("../../bg").material.set("shader_param/l_res",res)

var image_texture
func _on_file_select(path):
	get_node("vc").visible=true
	var img = Image.new()
	img.load(path)
	if(!is_instance_valid(img)):
		return
	image_texture=ImageTexture.new()
	image_texture.create_from_image(img, 0)
	get_node("../../bg").material.set("shader_param/iChannel1",image_texture)
	get_node("../../Viewport/Sprite").material.set("shader_param/iChannel1",image_texture)
	get_node("../../Viewport2/Sprite").material.set("shader_param/iChannel1",image_texture)

func _on_file_hide():
	get_node("vc").visible=true

func _on_bgib_pressed():
	get_node("vc").visible=false
	get_node("../imgl").popup_centered(Vector2(640, 480))


func _on_hp_pressed():
	get_node("../info").popup_centered(Vector2(640, 480))

onready var elems=get_node("../../elems")
onready var elem_text=preload("res://text_ctrl.tscn")
onready var elem_circle=preload("res://circle_ctrl.tscn")
onready var elem_line=preload("res://line_ctrl.tscn")
onready var elem_box=preload("res://box_ctrl.tscn")
onready var elem_tri=preload("res://tri_ctrl.tscn")

func _on_at_pressed():
	if(global_v.live_text_elem<global_v.max_elems):
		var s=elem_text.instance()
		var rect=21
		s.rect_position=global_v.iResolution/2-Vector2(rect/2,rect/2)
		elems.call_deferred("add_child",s,true)
	else:
		get_node("../maxe").popup_centered(Vector2(320, 240))


func _on_al_pressed():
	if(global_v.live_line_elem<global_v.max_elems):
		var s=elem_line.instance()
		var rect=21
		s.rect_position=global_v.iResolution/2-Vector2(rect/2,rect/2)
		elems.call_deferred("add_child",s,true)
	else:
		get_node("../maxe").popup_centered(Vector2(320, 240))


func _on_al2_pressed():
	if(global_v.live_circle_elem<global_v.max_elems):
		var s=elem_circle.instance()
		var rect=21
		s.rect_position=global_v.iResolution/2-Vector2(rect/2,rect/2)
		elems.call_deferred("add_child",s,true)
	else:
		get_node("../maxe").popup_centered(Vector2(320, 240))


func update_box_data():
	if(global_v.iTime>0):
		gen_data(false,false,0)

# [0] [0]=size or array
# [1] [0-1]=position, [2] box size, [3-5]color [6]glow
func gen_array_line(arr,a,b,c,d,e,f,g,h):
	arr.append(a)
	arr.append(b)
	arr.append(c)
	arr.append(d)
	arr.append(e)
	arr.append(f)
	arr.append(g)
	arr.append(h)

func pass_float(array):
	var stream = StreamPeerBuffer.new()
	var data_in_bytes = PoolByteArray([])
	for i in array:
	    stream.clear()
	    stream.put_float(i)
	    stream.seek(0)
	    for j in range(4):
	        data_in_bytes.append(stream.get_8())
	return data_in_bytes

const itri=4
const ibox=3
const icircle=2
const iline=1
const itext=0

var t_glow_counter=0

func gen_box_data(count,glowa,glowb,glowc):
	var array = []
	var elemsn=get_node("../../elems")
	gen_array_line(array,count,0,0,0,0,0,0,0)
	for a in range(elemsn.get_child_count()):
		if(!is_instance_valid(elemsn.get_child(a).get_child(0))):
			continue
		if(!elemsn.get_child(a).get_child(0).has_method("get_self_type")):
			continue
		if(elemsn.get_child(a).get_child(0).self_type==ibox):
			var pos=elemsn.get_child(a).rect_position
			var ss=elemsn.get_child(a).get_child(0).self_size/global_v.iResolution.y
			var col=elemsn.get_child(a).get_child(0).self_color
			var rot=elemsn.get_child(a).get_child(0).self_rot
			var glowx=0
			if(elemsn.get_child(a).get_child(0).self_render):
				glowx=1
				t_glow_counter+=1
			if(glowa)&&(!glowb):
				glowx=0
			if(glowa)&&(glowb):
				if(glowx==1)&&(t_glow_counter==glowc):
					glowx=1
				else:
					glowx=0
			pos+=Vector2(21/2,21/2)
			pos=pos/global_v.iResolution.y
			pos.y=1-pos.y
			pos=pos-(global_v.iResolution/global_v.iResolution.y)*0.5
			gen_array_line(array,pos.x,pos.y,ss,col.r,col.g,col.b,deg2rad(rot),glowx)
	
	var array_width = 8
	var array_heigh = count+1

	var byte_array = pass_float(array)
	var img = Image.new()
	
	img.create_from_data(array_width, array_heigh, false, Image.FORMAT_RF, byte_array)

	var b_array = ImageTexture.new()
	b_array.create_from_image(img, 0)
	
	get_node("../../Viewport2/Sprite").material.set("shader_param/box_array",b_array)
	get_node("../../Viewport/Sprite").material.set("shader_param/box_array",b_array)

func gen_circle_data(count,glowa,glowb,glowc):
	var array = []
	var elemsn=get_node("../../elems")
	gen_array_line(array,count,0,0,0,0,0,0,0)
	for a in range(elemsn.get_child_count()):
		if(!is_instance_valid(elemsn.get_child(a).get_child(0))):
			continue
		if(!elemsn.get_child(a).get_child(0).has_method("get_self_type")):
			continue
		if(elemsn.get_child(a).get_child(0).self_type==icircle):
			var pos=elemsn.get_child(a).rect_position
			var ss=elemsn.get_child(a).get_child(0).self_size/global_v.iResolution.y
			var col=elemsn.get_child(a).get_child(0).self_color
			var glowx=0
			if(elemsn.get_child(a).get_child(0).self_render):
				glowx=1
				t_glow_counter+=1
			if(glowa)&&(!glowb):
				glowx=0
			if(glowa)&&(glowb):
				if(glowx==1)&&(t_glow_counter==glowc):
					glowx=1
				else:
					glowx=0
			pos+=Vector2(21/2,21/2)
			pos=pos/global_v.iResolution.y
			pos.y=1-pos.y
			pos=pos-(global_v.iResolution/global_v.iResolution.y)*0.5
			gen_array_line(array,pos.x,pos.y,ss,col.r,col.g,col.b,0,glowx)
	
	var array_width = 8
	var array_heigh = count+1

	var byte_array = pass_float(array)
	var img = Image.new()
	
	img.create_from_data(array_width, array_heigh, false, Image.FORMAT_RF, byte_array)

	var b_array = ImageTexture.new()
	b_array.create_from_image(img, 0)
	
	get_node("../../Viewport2/Sprite").material.set("shader_param/circle_array",b_array)
	get_node("../../Viewport/Sprite").material.set("shader_param/circle_array",b_array)

func gen_tri_data(count,glowa,glowb,glowc):
	var array = []
	var elemsn=get_node("../../elems")
	gen_array_line(array,count,0,0,0,0,0,0,0)
	for a in range(elemsn.get_child_count()):
		if(!is_instance_valid(elemsn.get_child(a).get_child(0))):
			continue
		if(!elemsn.get_child(a).get_child(0).has_method("get_self_type")):
			continue
		if(elemsn.get_child(a).get_child(0).self_type==itri):
			var pos=elemsn.get_child(a).rect_position
			var ss=elemsn.get_child(a).get_child(0).self_size/global_v.iResolution.y #unused
			var col=elemsn.get_child(a).get_child(0).self_color
			var rot=elemsn.get_child(a).get_child(0).self_rot
			var glowx=0
			if(elemsn.get_child(a).get_child(0).self_render):
				glowx=1
				t_glow_counter+=1
			if(glowa)&&(!glowb):
				glowx=0
			if(glowa)&&(glowb):
				if(glowx==1)&&(t_glow_counter==glowc):
					glowx=1
				else:
					glowx=0
			pos+=Vector2(21/2,21/2)
			pos=pos/global_v.iResolution.y
			pos.y=1-pos.y
			pos=pos-(global_v.iResolution/global_v.iResolution.y)*0.5
			gen_array_line(array,pos.x,pos.y,ss,col.r,col.g,col.b,deg2rad(rot),glowx)
	
	var array_width = 8
	var array_heigh = count+1

	var byte_array = pass_float(array)
	var img = Image.new()
	
	img.create_from_data(array_width, array_heigh, false, Image.FORMAT_RF, byte_array)

	var b_array = ImageTexture.new()
	b_array.create_from_image(img, 0)
	
	get_node("../../Viewport2/Sprite").material.set("shader_param/tri_array",b_array)
	get_node("../../Viewport/Sprite").material.set("shader_param/tri_array",b_array)

func gen_array_line_l(arr,a,b,c,d,e,f,g,h):
	arr.append(a)
	arr.append(b)
	arr.append(c)
	arr.append(d)
	arr.append(e)
	arr.append(f)
	arr.append(g)
	arr.append(h)

# [0] [0]=size or array
# [1] [0-1]=position, [2] size, [3-5]color, [6]rotation, [7]glow
func gen_line_data(count,glowa,glowb,glowc):
	var array = []
	var elemsn=get_node("../../elems")
	gen_array_line_l(array,count,0,0,0,0,0,0,0)
	for a in range(elemsn.get_child_count()):
		if(!is_instance_valid(elemsn.get_child(a).get_child(0))):
			continue
		if(!elemsn.get_child(a).get_child(0).has_method("get_self_type")):
			continue
		if(elemsn.get_child(a).get_child(0).self_type==iline):
			var pos=elemsn.get_child(a).rect_position
			var ss=elemsn.get_child(a).get_child(0).self_size/global_v.iResolution.y
			var col=elemsn.get_child(a).get_child(0).self_color
			var rot=elemsn.get_child(a).get_child(0).self_rot
			var glowx=0
			if(elemsn.get_child(a).get_child(0).self_render):
				glowx=1
				t_glow_counter+=1
			if(glowa)&&(!glowb):
				glowx=0
			if(glowa)&&(glowb):
				if(glowx==1)&&(t_glow_counter==glowc):
					glowx=1
				else:
					glowx=0
			pos+=Vector2(21/2,21/2)
			pos=pos/global_v.iResolution.y
			pos.y=1-pos.y
			pos=pos-(global_v.iResolution/global_v.iResolution.y)*0.5
			gen_array_line_l(array,pos.x,pos.y,ss,col.r,col.g,col.b,deg2rad(rot),glowx)
	
	var array_width = 8
	var array_heigh = count+1

	var byte_array = pass_float(array)
	var img = Image.new()
	
	img.create_from_data(array_width, array_heigh, false, Image.FORMAT_RF, byte_array)

	var b_array = ImageTexture.new()
	b_array.create_from_image(img, 0)
	
	get_node("../../Viewport2/Sprite").material.set("shader_param/line_array",b_array)
	get_node("../../Viewport/Sprite").material.set("shader_param/line_array",b_array)

func gen_array_line_t(arr,a,b,c,d,e,f,g,h,i):
	arr.append(a)
	arr.append(b)
	arr.append(c)
	arr.append(d)
	arr.append(e)
	arr.append(f)
	arr.append(g)
	for ax in range(10):
		arr.append(h[ax])
	arr.append(i)

# [0] [0]=size or array
# [1] [0-1]=position, [2] size, [3-5]color, [6]rotation, [7-17]text [18]glow
func gen_text_data(count,glowa,glowb,glowc):
	var array = []
	var elemsn=get_node("../../elems")
	gen_array_line_t(array,count,0,0,0,0,0,0,[0,0,0,0,0,0,0,0,0,0],0)
	for a in range(elemsn.get_child_count()):
		if(!is_instance_valid(elemsn.get_child(a).get_child(0))):
			continue
		if(!elemsn.get_child(a).get_child(0).has_method("get_self_type")):
			continue
		if(elemsn.get_child(a).get_child(0).self_type==itext):
			var pos=elemsn.get_child(a).rect_position
			var ss=elemsn.get_child(a).get_child(0).self_size
			var col=elemsn.get_child(a).get_child(0).self_color
			var rot=elemsn.get_child(a).get_child(0).self_rot
			var text=elemsn.get_child(a).get_child(0).self_text
			var glowx=0
			if(elemsn.get_child(a).get_child(0).self_render):
				glowx=1
				t_glow_counter+=1
			if(glowa)&&(!glowb):
				glowx=0
			if(glowa)&&(glowb):
				if(glowx==1)&&(t_glow_counter==glowc):
					glowx=1
				else:
					glowx=0
			var texta=Array(text.to_ascii())
			for b in range(10-texta.size()):
				texta.append(32)
			#pos+=Vector2(21/2,21/2)
			pos=pos/global_v.iResolution.y
			pos.y=1-pos.y
			pos=pos-(global_v.iResolution/global_v.iResolution.y)*0.5
			gen_array_line_t(array,pos.x,pos.y,ss,col.r,col.g,col.b,deg2rad(rot),texta,glowx)
	
	var array_width = 18
	var array_heigh = count+1

	var byte_array = pass_float(array)
	var img = Image.new()
	
	img.create_from_data(array_width, array_heigh, false, Image.FORMAT_RF, byte_array)

	var b_array = ImageTexture.new()
	b_array.create_from_image(img, 0)
	get_node("../../Viewport2/Sprite").material.set("shader_param/text_array",b_array)
	get_node("../../Viewport/Sprite").material.set("shader_param/text_array",b_array)

# bool,bool,int [enable glow control][enable glow by ID(false=no glow at all)][ID]
func gen_data(glowa,glowb,glowc):
	var elemsn=get_node("../../elems")
	var box_count=0
	var circle_count=0
	var line_count=0
	var text_count=0
	var tri_count=0
	glow_frames=0
	t_glow_counter=0
	for a in range(elemsn.get_child_count()):
		if(!is_instance_valid(elemsn.get_child(a).get_child(0))):
			continue
		if(!elemsn.get_child(a).get_child(0).has_method("get_self_type")):
			continue
		if(elemsn.get_child(a).get_child(0).self_type==ibox):
			box_count+=1
		if(elemsn.get_child(a).get_child(0).self_type==icircle):
			circle_count+=1
		if(elemsn.get_child(a).get_child(0).self_type==iline):
			line_count+=1
		if(elemsn.get_child(a).get_child(0).self_type==itext):
			text_count+=1
		if(elemsn.get_child(a).get_child(0).self_type==itri):
			tri_count+=1
		if(elemsn.get_child(a).get_child(0).self_render):
			glow_frames+=1
	
	gen_box_data(box_count,glowa,glowb,glowc)
	gen_circle_data(circle_count,glowa,glowb,glowc)
	gen_tri_data(tri_count,glowa,glowb,glowc)
	gen_line_data(line_count,glowa,glowb,glowc)
	gen_text_data(text_count,glowa,glowb,glowc)

func _on_al3_pressed():
	if(global_v.live_box_elem<global_v.max_elems):
		var s=elem_box.instance()
		var rect=21
		s.rect_position=global_v.iResolution/2-Vector2(rect/2,rect/2)
		elems.call_deferred("add_child",s,true)
	else:
		get_node("../maxe").popup_centered(Vector2(320, 240))


func _on_rtx_toggled(button_pressed):
	get_node("../../bg").material.set("shader_param/render",!button_pressed)
	get_node("../../bg").material.set("shader_param/render2",button_pressed)
	if(button_pressed):
		get_node("../../Viewport2").render_target_update_mode=Viewport.UPDATE_ALWAYS
		get_node("../../Viewport3").render_target_update_mode=Viewport.UPDATE_ALWAYS
	else:
		get_node("../../Viewport2").render_target_update_mode=Viewport.UPDATE_DISABLED
		get_node("../../Viewport3").render_target_update_mode=Viewport.UPDATE_DISABLED


func _on_opx_item_selected(ID):
	if(ID==0):
		get_node("../../Viewport").size=Vector2(1280,720)
		var tx=ImageTexture.new()
		tx.create(1280,720,Image.FORMAT_RGBAF)
		get_node("../../Viewport/Sprite").texture=tx
		
	if(ID==1):
		get_node("../../Viewport").size=Vector2(1920,1080)
		var tx=ImageTexture.new()
		tx.create(1920,1080,Image.FORMAT_RGBAF)
		get_node("../../Viewport/Sprite").texture=tx
	if(ID==2):
		get_node("../../Viewport").size=Vector2(3840,2160)
		var tx=ImageTexture.new()
		tx.create(3840,2160,Image.FORMAT_RGBAF)
		get_node("../../Viewport/Sprite").texture=tx

func _on_al4_pressed():
	if(global_v.live_tri_elem<global_v.max_elems):
		var s=elem_tri.instance()
		var rect=21
		s.rect_position=global_v.iResolution/2-Vector2(rect/2,rect/2)
		elems.call_deferred("add_child",s,true)
	else:
		get_node("../maxe").popup_centered(Vector2(320, 240))


func _on_bgib2_pressed():
	image_texture=load("res://textures/px.png") as Texture
	if(!is_instance_valid(image_texture)):
		return
	get_node("../../bg").material.set("shader_param/iChannel1",image_texture)
	get_node("../../Viewport/Sprite").material.set("shader_param/iChannel1",image_texture)
	get_node("../../Viewport2/Sprite").material.set("shader_param/iChannel1",image_texture)
