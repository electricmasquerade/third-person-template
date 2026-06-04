extends Control

const c = RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME
const v = RenderingServer.RENDERING_INFO_VIDEO_MEM_USED

@onready var fps_label: Label = $Label

var FPS        = 0
var draw_calls = 0
var frame_time = 0
var video_mem   = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	FPS = Engine.get_frames_per_second()
	draw_calls = RenderingServer.get_rendering_info(c)
	frame_time = delta
	video_mem = RenderingServer.get_rendering_info(v) / 1024.0 / 1024.0
	
	var data = "FPS: %d \nDraw Calls: %d \nFrame Time: %f \nVideo Mem: %f MB" % [
		FPS, 
		draw_calls, 
		frame_time, 
		video_mem]
	fps_label.text = data
