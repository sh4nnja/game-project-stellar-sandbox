extends Node2D
#------------------------------------------------------------------------------#
@onready var _starParticles: CPUParticles2D = get_node("spaceParallaxEffectManager/spaceST1Parallax/spaceStarParticles")

#------------------------------------------------------------------------------#
var _spaceGenerationThread: Thread

var _spaceSectorKey: String = "[|{0}|{1}|{2}|{3}|{4}|{5}|]"

# Initiation of textures.
var _spaceAssetsIndex: int = 1

#------------------------------------------------------------------------------#
# Default space generation on start (Without "spaceSectorManager.tscn", scene manager). 
# Check "lib.gd" -> CONFIGURATION section for default values. 
func _ready() -> void:
	# Change "lockDefault" to true when you want to maintain default configuration.
	# "lockDefault" will run if you started this scene as standalone (Without "spaceSectorManager.tscn", scene manager).
	var lockDefault: bool = false
	if lockDefault or get_parent() == get_tree().root:
		initiateThreadForLoading(
			[
				[
					lib.generateRandomNumber(lib.spaceMinimumSpawnSeed, lib.spaceMaximumSpawnSeed, "int", true), 
					lib.generateRandomColor(),
					lib.generateRandomColor(),
					lib.generateRandomColor(),
					lib.generateRandomColor(),
					lib.generateRandomNumber(1, 2)
				]
			]
		)
	
	_starParticles.preprocess = lib.generateRandomNumber(100, 300)

#------------------------------------------------------------------------------#
# IMPORTANT CODE: Load a thread for facilitating background loading
func initiateThreadForLoading(spaceArray: Array) -> void:
	# IGNORE: Debug
	print("\nCreating thread for background texture loading...")
	# IMPORTANT CODE: Checking if other "spaceGenerationThreads" are active
	if is_instance_valid(_spaceGenerationThread) and _spaceGenerationThread.is_started():
		_spaceGenerationThread.wait_to_finish()
	
	# Create a new thread.
	_spaceGenerationThread = Thread.new()
	# IGNORE: Debug
	print("Thread ", _spaceGenerationThread, " has been created!\n")
	
	# Initiation of textures. Loading the texture will be done in the thread.
	var _spaceBackgroundTexture: NoiseTexture2D = NoiseTexture2D.new()
	var _spaceGasesTexture: NoiseTexture2D = NoiseTexture2D.new()
	var _spaceGases1Texture: NoiseTexture2D = NoiseTexture2D.new()
	var _spaceGases2Texture: NoiseTexture2D = NoiseTexture2D.new()
	var _spaceStarsTexture: NoiseTexture2D = NoiseTexture2D.new()
	var _spaceStars1Texture: NoiseTexture2D = NoiseTexture2D.new()
	
	get_node("spaceParallaxEffectManager/spaceBGTParallax/spaceBackgroundTexture").texture = _spaceBackgroundTexture
	get_node("spaceParallaxEffectManager/spaceGTParallax/spaceGasesTexture").texture = _spaceGasesTexture
	get_node("spaceParallaxEffectManager/spaceGT1Parallax/spaceGasesTexture1").texture = _spaceGases1Texture
	get_node("spaceParallaxEffectManager/spaceGT2Parallax/spaceGasesTexture2").texture = _spaceGases2Texture
	get_node("spaceParallaxEffectManager/spaceSTParallax/spaceStarTexture").texture = _spaceStarsTexture
	get_node("spaceParallaxEffectManager/spaceST1Parallax/spaceStarTexture1").texture = _spaceStars1Texture
	
	get_node("spaceParallaxEffectManager/spaceGTParallax/spaceGasesTexture").modulate = spaceArray[0][2]
	get_node("spaceParallaxEffectManager/spaceGT1Parallax/spaceGasesTexture1").modulate = spaceArray[0][3]
	get_node("spaceParallaxEffectManager/spaceGT2Parallax/spaceGasesTexture2").modulate = spaceArray[0][4]
	
	spaceArray.append([_spaceBackgroundTexture, _spaceGasesTexture, _spaceGases1Texture, _spaceGases2Texture, _spaceStarsTexture, _spaceStars1Texture])
	
	# Proceed to the thread function
	_spaceGenerationThread.start(_initiateSceneLoadingInThread.bind(spaceArray))
	# IGNORE: Debug
	print("Printing array contents to be sent in thread ", _spaceGenerationThread, ": ", spaceArray)
	# IGNORE: Debug
	print("\nLoading space background textures in the thread...")

# IMPORTANT CODE: Thread Function for background space generation. 
func _initiateSceneLoadingInThread(spaceArray: Array) -> void:
	# IGNORE: Debug
	print("\nThread function initiated!\n")
	print("Generating textures now.")
	# Loop basic information to the textures.
	for _spaceTextureGenerationIteration in range(6):
		# Creating the default configuration of the textures.
		spaceArray[1][_spaceTextureGenerationIteration].width = 4096
		spaceArray[1][_spaceTextureGenerationIteration].height = 4096
		spaceArray[1][_spaceTextureGenerationIteration].generate_mipmaps = false
		# IGNORE: Debug
		print("    Generated a space texture! ", spaceArray[1][_spaceTextureGenerationIteration])
		
		# Creates a standard color ramp and noise object to assign in the texture.
		var _spaceTextureColorRamp: Gradient = Gradient.new()
		spaceArray[1][_spaceTextureGenerationIteration].color_ramp = _spaceTextureColorRamp
		_spaceTextureColorRamp.offsets = [0.5, 1]
		_spaceTextureColorRamp.colors = [Color.TRANSPARENT, Color.WHITE]
		_spaceTextureColorRamp.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CUBIC
		# IGNORE: Debug
		print("    Generated color ramp! ", _spaceTextureColorRamp)
		
		var _spaceTextureNoise: FastNoiseLite = FastNoiseLite.new()
		spaceArray[1][_spaceTextureGenerationIteration].noise = _spaceTextureNoise
		_spaceTextureNoise.seed = spaceArray[0][0]
		_spaceTextureNoise.fractal_octaves = 10
		# IGNORE: Debug
		print("    Generated noise! ", _spaceTextureNoise)
		
		# Configure the adjustments per texture.
		# IMPORTANT CODE: Print statements per index is necessary for debugging and MUST NOT be removed.
		# IMPORTANT CODE: It checks for what texture has failed loading as threads don't receive error messages.
		if _spaceAssetsIndex == 1:
			# Space background generation.
			_spaceTextureNoise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
			_spaceTextureColorRamp.offsets = [0.5, 1]
			_spaceTextureColorRamp.colors = [Color("1a001a"), spaceArray[0][1]]
			# IGNORE: Debug
			print("    Adjusted space background texture! ", spaceArray[1][_spaceTextureGenerationIteration])
		elif _spaceAssetsIndex in range(2, 5):  
			# Space gases generation.
			# Decide to show texture or not.
			if spaceArray[0][_spaceAssetsIndex] != "00000000":
				# Adjusts texture based on index.
				if _spaceAssetsIndex == 2:
					_spaceTextureNoise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
				elif _spaceAssetsIndex == 3: 
					_spaceTextureNoise.noise_type = FastNoiseLite.TYPE_PERLIN
				elif _spaceAssetsIndex == 4:
					_spaceTextureNoise.noise_type = FastNoiseLite.TYPE_PERLIN
					_spaceTextureColorRamp.offsets = [0.25, 1]
			else:
				# Removes the objects in texture if texture is not visible to save memory.
				spaceArray[1][_spaceTextureGenerationIteration].noise = null
				spaceArray[1][_spaceTextureGenerationIteration].color_ramp = null
				# IGNORE: Debug
				print("    Queue Free'd' a texture because modulate is 0. ", spaceArray[1][_spaceTextureGenerationIteration])
			print("    Adjusted a space gas texture! ", spaceArray[1][_spaceTextureGenerationIteration], " Index: ", _spaceAssetsIndex)
		elif _spaceAssetsIndex > 4: 
			# Space star generation.
			_spaceTextureNoise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
			_spaceTextureNoise.frequency = 0.15
			_spaceTextureNoise.fractal_octaves = 5
			_spaceTextureNoise.fractal_gain = 2
			if _spaceAssetsIndex == 5:
				_spaceTextureColorRamp.offsets = [0.85, 1]
				# IGNORE: Debug
				print("    Adjusted a space star texture! ", spaceArray[1][_spaceTextureGenerationIteration])
			elif _spaceAssetsIndex == 6:
				_spaceTextureColorRamp.offsets = [0.80, 1]
				# IGNORE: Debug
				print("    Adjusted a space star texture! ", spaceArray[1][_spaceTextureGenerationIteration])
		# Increase index by 1 to determine what type of adjustments to add in the textures.
		# IGNORE: Debug
		print("    Iteration complete! Incrementing. \n")
		_spaceAssetsIndex += 1
	
	# IGNORE: Debug
	print("Loaded space sector! Visually adjusting now. Thread ", _spaceGenerationThread, " will be terminated.")
	print("Generated Space Sector Key (SSK): ", _spaceSectorKey.format(spaceArray[0]))
	print("#------------------------------------------------------------------------------#")

#------------------------------------------------------------------------------#
