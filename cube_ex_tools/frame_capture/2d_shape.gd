extends Position3D

# Created by Danil (2020+) https://github.com/danilw
# The MIT License

export(float) var shape_size #=0.2 # collision shape size
export(int) var sec_to_record #=13 # seconds to record, default fps is 60
export(int) var box_size #=20 # recording box size, min is 1

const default_fps=60

# script spawn RigidBody base on 2d tile map
# and save each RigidBody position every fract
# when all Frames recorded frames saved to png file(8bit)

# data in saved png file is 16-bit values saved in every two 8-bit pixels (rgb=xyz position) 
# using 8bit png because WebGl does not support 16bit texture format

const elems=256 # elements to spawn
#const max_image_size=Vector2(2048*2,2048) # 4096*2048 texture
const max_image_size=Vector2(1024*2,1024) # for WebGL because WebGL GLES2 may not support 4k textures

const max_frames=int(max_image_size.y*max_image_size.y)/elems
# 4096*2048 texture=16384 frames, 4 min 33 sec on 60fps
# 2048*1024 texture=4096 frames, 68 sec on 60fps

var frames_to_rec:int=1
var extra_elems:int=0
var image_size:Vector2=Vector2()

onready var tilemap=get_node("2d/TileMap")
onready var rigbody=get_node("body/RigidBody")
onready var spawn=get_node("spawn")

onready var timer_text=get_node("../UI/timer")
onready var saved_text=get_node("../UI/saved")


func _ready():
  frames_to_rec=min(sec_to_record*default_fps,max_frames)
  image_size=Vector2(min(ceil(sqrt(frames_to_rec*elems))*2,max_image_size.x),min(ceil(sqrt(frames_to_rec*elems)),max_image_size.y))
  extra_elems=int((image_size.x/2)*image_size.y)-frames_to_rec*elems
  var tiles=tilemap.get_used_cells_by_id(0)
  for a in range(elems):
    var idx=a%tiles.size()
    var pos=tiles[idx]
    var dupl=rigbody.duplicate(0)
    dupl.translation.z=pos.x*shape_size+0.0015
    dupl.translation.y=-pos.y*shape_size+0.0015
    dupl.translation.x=shape_size*(a/tiles.size())+0.001*(1-2*(int(pos.y)%2))
    spawn.add_child(dupl)
    
  rigbody.queue_free()


var iFrame:int=0

var data=[]

func _process(delta):
  timer_text.text="animation progress: "+format_num(int((float(iFrame)/frames_to_rec)*100))+" %"
  if(frames_to_rec>iFrame):
    var tpos=[]
    for a in range(spawn.get_child_count()):
      var tpos_val=spawn.get_child(a).global_transform.origin
      tpos.append(tpos_val)
    data.append(tpos)
  else:
    on_save()
    set_process(false)
  iFrame+=1


func on_save():
  var path = OS.get_executable_path().get_base_dir().plus_file("frame_capture")
  var dir = Directory.new()
  dir.make_dir(path)
  print("save to "+str(path))
  var extra_data=[]
  for a in range(extra_elems):
    extra_data.append(Vector3())
  data.append(extra_data)
  var data_array=[]
  for a in range(data.size()):
    for b in range(data[a].size()):
      var tpos=data[a][b]
      tpos=tpos+Vector3(box_size/2.0,0,box_size/2.0)
      data_array.append(int(clamp((tpos.x/box_size),0.0,1.0)*65536.0)% 256)
      data_array.append(int(clamp((tpos.x/box_size),0.0,1.0)*65536.0)/ 256)
      data_array.append(int(clamp((tpos.y/box_size),0.0,1.0)*65536.0)% 256)
      data_array.append(int(clamp((tpos.y/box_size),0.0,1.0)*65536.0)/ 256)
      data_array.append(int(clamp((tpos.z/box_size),0.0,1.0)*65536.0)% 256)
      data_array.append(int(clamp((tpos.z/box_size),0.0,1.0)*65536.0)/ 256)
  
  var byte_array = PoolByteArray(data_array)
  
  
  var img = Image.new()
  img.create_from_data(image_size.x, image_size.y, false, Image.FORMAT_RGB8, byte_array)
  img.save_png(path.plus_file("capture2.png"))
  print("done")
  saved_text.visible=true

func format_num(num):
  var a=str(num)
  if(a.length()<2):
    a="0"+a
  return a



















