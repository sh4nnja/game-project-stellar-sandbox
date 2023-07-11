extends Node

var _spaceGameProperPath: String = "res://pck/space/spaceGameProper.tscn"
var _userInterfaceMainMenuPath: String = "res://pck/gameMainMenu/gameMainMenu.tscn"
#------------------------------------------------------------------------------#


#------------------------------------------------------------------------------#
func _ready() -> void:
	# IGNORE: Debug
	print("Initiated PseudoTree ", self, " Initiating scene loading.\n")
	
	# Load mainmenu and add to scene.
	_checkLoadedResourceForSceneAdd(_initiateLoadingPackedScenes(_userInterfaceMainMenuPath))
	_checkLoadedResourceForSceneAdd(_initiateLoadingPackedScenes(_spaceGameProperPath))

#------------------------------------------------------------------------------#
# Check resource first then add to pseudotree. Print error if null.
func _checkLoadedResourceForSceneAdd(_object: Resource) -> void:
	if _object != null:
		# IGNORE: Debug
		print("Adding object ", _object, " as a child of PseudoTree ", self)
		call_deferred("add_child", _object.instantiate())
		# IGNORE: Debug
		print("Adding object ", _object, " is successful.")
		print("#------------------------------------------------------------------------------#\n")
	else:
		# IGNORE: Debug
		print("Resource null. Loading failed.")
		print("#------------------------------------------------------------------------------#\n")

func _initiateLoadingPackedScenes(_scenePath: String) -> Resource:
	# Progress bar in array to track loading progress.
	var _sceneLoadingProgress: Array[float] = []
	# Limiter to stop loader on spamming a lot of 0 on loading.
	var _sceneLoadingZero: int = 0
	
	var _sceneLoadingStatus: int = 1
	var _sceneLoadedOutput: Resource
	
	# IGNORE: Debug
	print("Initiating loading scene via string path: ", _scenePath)
	# IMPORTANT CODE: Load the scene files via resource loader to facilitate loading on progress bar.
	ResourceLoader.load_threaded_request(_scenePath)
	# IGNORE: Debug
	print("Proceeding to load ", _scenePath)
	# IMPORTANT CODE: Function 'match' checks for identifying status for visual output.
	while true:
		match _sceneLoadingStatus:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				_sceneLoadingStatus = ResourceLoader.load_threaded_get_status(_scenePath, _sceneLoadingProgress)
				# Prevents zero percent spamming.
				if _sceneLoadingProgress[0] == 0:
					if _sceneLoadingZero < 5:
						# IGNORE: Debug
						print("    Loading ", _scenePath, " Progress: ", snapped(_sceneLoadingProgress[0] * 100, 0.01), "%")
						_sceneLoadingZero += 1
				else:
					# IGNORE: Debug
					print("    Loading ", _scenePath, " Progress: ", snapped(_sceneLoadingProgress[0] * 100, 0.01), "%")
			ResourceLoader.THREAD_LOAD_LOADED:
				# IGNORE: Debug
				print("Loaded ", _scenePath)
				break
			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
				# IGNORE: Debug
				print("Loading ", _scenePath, " has failed. Invalid Resource.")
				_sceneLoadedOutput = null
				break
	_sceneLoadedOutput =  ResourceLoader.load_threaded_get(_scenePath)
	return _sceneLoadedOutput

#------------------------------------------------------------------------------#
