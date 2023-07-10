extends Node2D

#------------------------------------------------------------------------------#
var _spacePhenomenonGenerationThread: Thread

#------------------------------------------------------------------------------#
# IMPORTANT CODE: Load a thread for facilitating background loading
func initiateThreadForLoading(spacePhenomena: Array) -> void:
	# IGNORE: Debug
	print("\nCreating thread for space phenomena texture loading...")
	# IMPORTANT CODE: Checking if other "spacePhenomenaGenerationThread" are active
	if is_instance_valid(_spacePhenomenonGenerationThread) and _spacePhenomenonGenerationThread.is_started():
		_spacePhenomenonGenerationThread.wait_to_finish()
	
	# Create a new thread.
	_spacePhenomenonGenerationThread = Thread.new()
	# IGNORE: Debug
	print("Thread ", _spacePhenomenonGenerationThread, " has been created!\n")
	
	# Initiation of textures. Loading the texture will be done in the thread.
	var _spaceTexturePhenomena: NoiseTexture2D = NoiseTexture2D.new()
	get_node("spaceParallaxEffectManager/spacePTParallax/spacePhenomenaTexture").modulate = spacePhenomena[1]
	get_node("spaceParallaxEffectManager/spacePTParallax/spacePhenomenaTexture").texture = _spaceTexturePhenomena
	spacePhenomena.append(_spaceTexturePhenomena)
	# IGNORE: Debug
	print("Generated a space phenomena texture! ", _spaceTexturePhenomena)
	
	# Proceed to the thread function
	_spacePhenomenonGenerationThread.start(_initiateSceneLoadingInThread.bind(spacePhenomena))
	# IGNORE: Debug
	print("Loading space phenomena textures in the thread...")

# IMPORTANT CODE: Thread Function for background space generation. 
func _initiateSceneLoadingInThread(_spacePhenomena: Array) -> void:
	# IGNORE: Debug
	print("\nThread function initiated!\n")
	
	# Creating the default configuration of the texture.
	_spacePhenomena[3].width = 4096
	_spacePhenomena[3].height = 4096
	# IGNORE: Debug
	print("Configured the texture size! ", _spacePhenomena[3])
	
	# Creates a standard color ramp and noise object to assign in the texture.
	var _spacePhenomenaTextureColorRamp: Gradient = Gradient.new()
	_spacePhenomenaTextureColorRamp.offsets = [0, 0.5, 1]
	_spacePhenomenaTextureColorRamp.colors = [Color.TRANSPARENT, Color(1, 1, 1, 0.25), Color.WHITE]
	_spacePhenomenaTextureColorRamp.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_LINEAR
	# IGNORE: Debug
	print("Generated color ramp! ", _spacePhenomenaTextureColorRamp)
	
	var _spacePhenomenaTextureNoise: FastNoiseLite = FastNoiseLite.new()
	_spacePhenomenaTextureNoise.seed = _spacePhenomena[0]
	_spacePhenomenaTextureNoise.fractal_octaves = 10
	# IGNORE: Debug
	print("Generated noise! ", _spacePhenomenaTextureNoise)
	
	# Configure the adjustments per texture.
	match _spacePhenomena[2]:
		1:  # Space phenomenon "HALO" generation.
			_spacePhenomenaTextureNoise.noise_type = FastNoiseLite.TYPE_PERLIN
			_spacePhenomenaTextureNoise.frequency = 0.0025
			_spacePhenomenaTextureNoise.fractal_type = FastNoiseLite.FRACTAL_PING_PONG
			_spacePhenomenaTextureNoise.fractal_lacunarity = 1
			_spacePhenomenaTextureNoise.fractal_gain = 0.1
			# IGNORE: Debug
			print("Adjusted space phenomena texture! ", _spacePhenomena[3])
			
		2: # Space Phenomenon "PATCHES"
			_spacePhenomenaTextureColorRamp.offsets = [0, 0.1, 0.5, 6, 1]
			_spacePhenomenaTextureColorRamp.colors = [
				Color(lib.generateRandomColor(lib.spaceGasesMinimumColorValue, lib.spaceGasesMaximumColorValue, 1)),
				Color(lib.generateRandomColor(lib.spaceGasesMinimumColorValue, lib.spaceGasesMaximumColorValue, 1)),
				Color.TRANSPARENT,
				Color(lib.generateRandomColor(lib.spaceGasesMinimumColorValue, lib.spaceGasesMaximumColorValue, 1)),
				Color.TRANSPARENT
				]
			_spacePhenomenaTextureNoise.noise_type = FastNoiseLite.TYPE_PERLIN
			_spacePhenomenaTextureNoise.frequency = 0.005
			_spacePhenomenaTextureNoise.fractal_type = FastNoiseLite.FRACTAL_RIDGED
			# IGNORE: Debug
			print("Adjusted space phenomena texture! ", _spacePhenomena[3])
	
	# Assign the generated ramp and noise into the texture and to the node.
	_spacePhenomena[3].color_ramp = _spacePhenomenaTextureColorRamp
	_spacePhenomena[3].noise = _spacePhenomenaTextureNoise
	# IGNORE: Debug
	print("Loaded space phenomena texture! Visually adjusting now. Thread ", _spacePhenomenonGenerationThread, " will be terminated.")
	print("#------------------------------------------------------------------------------#")

#------------------------------------------------------------------------------#
