extends Node2D

#------------------------------------------------------------------------------#
var _spacePhenoTex: NoiseTexture2D

#------------------------------------------------------------------------------#
var _spacePhenoGenThread: Thread

#------------------------------------------------------------------------------#
# Kills the thread when scene exits the tree.
# IMPORTANT CODE: Its a must do to prevent warning and potential crash.
func _exit_tree():
	# Deleting Generation Thread.
	_spacePhenoGenThread = null

#------------------------------------------------------------------------------#
# IMPORTANT CODE: Load a thread for facilitating background loading
func _loadThread(spacePheno: Array) -> void:
	# IGNORE: Debug
	print("\nCreating thread for space phenomena texture loading...")
	# IMPORTANT CODE: Checking if other "spacePhenomenaGenerationThread" are active
	if is_instance_valid(_spacePhenoGenThread) and _spacePhenoGenThread.is_started():
		_spacePhenoGenThread.wait_to_finish()
	
	# Create a new thread.
	_spacePhenoGenThread = Thread.new()
	# IGNORE: Debug
	print("Thread ", _spacePhenoGenThread, " has been created!\n")
	
	# Initiation of textures. Loading the texture will be done in the thread.
	_spacePhenoTex = NoiseTexture2D.new()
	get_node("spacePllxMngr/spacePTPllx/spacePhenoTex").modulate = spacePheno[1]
	get_node("spacePllxMngr/spacePTPllx/spacePhenoTex").texture = _spacePhenoTex
	spacePheno.append(_spacePhenoTex)
	# IGNORE: Debug
	print("Generated a space phenomena texture! ", _spacePhenoTex)
	
	# Proceed to the thread function
	_spacePhenoGenThread.start(_genSpacePheno.bind(spacePheno))
	# IGNORE: Debug
	print("Loading space phenomena textures in the thread...")

# IMPORTANT CODE: Thread Function for background space generation. 
func _genSpacePheno(_spacePheno: Array) -> void:
	# IGNORE: Debug
	print("\nThread function initiated!\n")
	
	# Creating the default configuration of the texture.
	_spacePheno[3].width = lib.sectSize
	_spacePheno[3].height = lib.sectSize
	# IGNORE: Debug
	print("Configured the texture size! ", _spacePheno[3])
	
	# Creates a standard color ramp and noise object to assign in the texture.
	var _spacePhenoTexColorRamp: Gradient = Gradient.new()
	_spacePhenoTexColorRamp.offsets = [0, 0.5, 1]
	_spacePhenoTexColorRamp.colors = [Color.TRANSPARENT, Color(1, 1, 1, 0.25), Color.WHITE]
	_spacePhenoTexColorRamp.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_LINEAR
	# IGNORE: Debug
	print("Generated color ramp! ", _spacePhenoTexColorRamp)
	
	var _spacePhenoTexNoise: FastNoiseLite = FastNoiseLite.new()
	_spacePhenoTexNoise.seed = _spacePheno[0]
	_spacePhenoTexNoise.fractal_octaves = 10
	# IGNORE: Debug
	print("Generated noise! ", _spacePhenoTexNoise)
	
	# Configure the adjustments per texture.
	match _spacePheno[2]:
		1:  # Space phenomenon "HALO" generation.
			_spacePhenoTexNoise.noise_type = FastNoiseLite.TYPE_PERLIN
			_spacePhenoTexNoise.frequency = 0.0025
			_spacePhenoTexNoise.fractal_type = FastNoiseLite.FRACTAL_PING_PONG
			_spacePhenoTexNoise.fractal_lacunarity = 1
			_spacePhenoTexNoise.fractal_gain = 0.1
			# IGNORE: Debug
			print("Adjusted space phenomena texture! ", _spacePheno[3])
			
		2: # Space Phenomenon "PATCHES"
			_spacePhenoTexColorRamp.offsets = [0, 0.1, 0.5, 6, 1]
			_spacePhenoTexColorRamp.colors = [
				Color(lib.genRandColor(lib.gasColorMinRnge, lib.gasColorMaxRnge, 1)),
				Color(lib.genRandColor(lib.gasColorMinRnge, lib.gasColorMaxRnge, 1)),
				Color.TRANSPARENT,
				Color(lib.genRandColor(lib.gasColorMinRnge, lib.gasColorMaxRnge, 1)),
				Color.TRANSPARENT
				]
			_spacePhenoTexNoise.noise_type = FastNoiseLite.TYPE_PERLIN 
			_spacePhenoTexNoise.frequency = 0.005
			_spacePhenoTexNoise.fractal_type = FastNoiseLite.FRACTAL_RIDGED
			# IGNORE: Debug
			print("Adjusted space phenomena texture! ", _spacePheno[3])
	
	# Assign the generated ramp and noise into the texture and to the node.
	_spacePheno[3].color_ramp = _spacePhenoTexColorRamp
	_spacePheno[3].noise = _spacePhenoTexNoise
	
	# Removes objects from variable so when set the main texture to null, they will also be changed to null.
	_spacePhenoTexColorRamp = null
	_spacePhenoTexNoise = null
	
	# IGNORE: Debug
	print("Loaded space phenomena texture! Visually adjusting now. Thread ", _spacePhenoGenThread, " will be terminated.")
	print("#------------------------------------------------------------------------------#")

# Removing textures first in the nodes before generating another.
# IMPORTANT CODE: This is a must do due to space sector generation mechanic on menu.
func revertSpacePhenomenaTexturesToDefault() -> void:
	# IGNORE: Debug
	print("Texture of nodes has been cleared.")
	_spacePhenoTex = null
	get_node("spacePllxMngr/spacePTPllx/spacePhenoTex").texture = null
#------------------------------------------------------------------------------#
