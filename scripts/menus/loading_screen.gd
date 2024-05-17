extends Control

const target_scene_path = "res://scenes/game.tscn"

var loading_status : int
var progress : Array[float]

@onready var progress_bar : ProgressBar = $ProgressBar

func _ready():
	# Request to load target scene
	ResourceLoader.load_threaded_request(target_scene_path)
	
func _process(_delta: float):
	# Update the status:
	loading_status = ResourceLoader.load_threaded_get_status(target_scene_path, progress)
	
	# Check the loading status
	match loading_status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			progress_bar.value = progress[0] * 100 # Change progress bar value
		ResourceLoader.THREAD_LOAD_LOADED:
			# When done loading, change to target scene:
			get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(target_scene_path))
		ResourceLoader.THREAD_LOAD_FAILED:
			# Error occurred
			print("Error. Could not load Resource")
