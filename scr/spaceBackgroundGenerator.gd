extends Node2D
#------------------------------------------------------------------------------#
@onready var spaceParallaxManager: ParallaxBackground = get_node("spaceParallaxEffectManager")

#------------------------------------------------------------------------------#
var spaceGenerationThread: Thread

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
			lib.generateRandomNumber(lib.spaceMinimumSpawnSeed, lib.spaceMaximumSpawnSeed, "int", true), 
			lib.generateRandomColor(lib.spaceGasesMinimumColorValue, lib.spaceGasesMaximumColorValue),
			lib.generateRandomColor(lib.spaceGasesMinimumColorValue, lib.spaceGasesMaximumColorValue),
			lib.generateRandomColor(lib.spaceGasesMinimumColorValue, lib.spaceGasesMaximumColorValue),
			]
		)

#------------------------------------------------------------------------------#
# IMPORTANT CODE: Load a thread for facilitating background loading
func initiateThreadForLoading(spaceArray: Array) -> void:
	
	# Wait for enough time to prepare nodes for texture placement.
	await get_tree().create_timer(5).timeout
	
	# IGNORE: Debug
	print("\nCreating thread for background texture loading...")
	# IMPORTANT CODE: Checking if other "spaceGenerationThreads" are active
	if is_instance_valid(spaceGenerationThread) and spaceGenerationThread.is_started():
		spaceGenerationThread.wait_to_finish()
	
	# Create a new thread.
	spaceGenerationThread = Thread.new()
	
	# IGNORE: Debug
	print("Thread ", spaceGenerationThread, " has been created!\n")
	print("Loading space background textures in the thread...")
	
	# Proceed to the thread function
	spaceGenerationThread.start(_initiateSceneLoadingInThread.bind(spaceArray))

# IMPORTANT CODE: Thread Function for background space generation. 
func _initiateSceneLoadingInThread(spaceArray: Array) -> void:
	# IGNORE: Debug
	print("\nThread function initiated!\n")
	
	# Assign the color to the textures. 
	get_node("spaceParallaxEffectManager/spaceGTParallax/spaceGasesTexture").modulate = spaceArray[1]
	get_node("spaceParallaxEffectManager/spaceGT1Parallax/spaceGasesTexture1").modulate = spaceArray[2]
	get_node("spaceParallaxEffectManager/spaceGT2Parallax/spaceGasesTexture2").modulate = spaceArray[3]
	
	# Initiation of textures.
	var spaceAssetBackground: NoiseTexture2D = NoiseTexture2D.new()
	var spaceAssetGases: NoiseTexture2D = NoiseTexture2D.new()
	var spaceAssetGases1: NoiseTexture2D = NoiseTexture2D.new()
	var spaceAssetGases2: NoiseTexture2D = NoiseTexture2D.new()
	var spaceAssetStars: NoiseTexture2D = NoiseTexture2D.new()
	var spaceAssetStars1: NoiseTexture2D = NoiseTexture2D.new()
	
	# Put in array to use in loop.
	var spaceAssets: Array = [spaceAssetBackground, spaceAssetGases, spaceAssetGases1, spaceAssetGases2, spaceAssetStars, spaceAssetStars1]
	var spaceAssetsIndex: int = 1
	
	# Loop basic information to the textures.
	for spaceAssetBasicGeneration in spaceAssets:
		
		# Creating the default configuration of the textures.
		spaceAssetBasicGeneration.width = 4096
		spaceAssetBasicGeneration.height = 4096
		spaceAssetBasicGeneration.generate_mipmaps = false
#		spaceAssetBasicGeneration.normalize = false
		
		# IGNORE: Debug
		print("Generated a space texture! ", spaceAssetBasicGeneration)
		
		# Creates a standard color ramp and noise object to assign in the texture.
		var spaceAssetBasicGenerationColorRamp: Gradient = Gradient.new()
		spaceAssetBasicGenerationColorRamp.offsets = [0.5, 1]
		spaceAssetBasicGenerationColorRamp.colors = [Color.TRANSPARENT, Color.WHITE]
		spaceAssetBasicGenerationColorRamp.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CUBIC
		
		var spaceAssetBasicGenerationNoise: FastNoiseLite = FastNoiseLite.new()
		spaceAssetBasicGenerationNoise.seed = spaceArray[0]
		spaceAssetBasicGenerationNoise.fractal_octaves = 10
		
		# Configure the adjustments per texture.
		match spaceAssetsIndex:
			1:  # Space background generation.
				spaceAssetBasicGenerationNoise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
				spaceAssetBasicGenerationColorRamp.offsets = [0, 1]
				spaceAssetBasicGenerationColorRamp.colors = [Color.BLACK, Color.WHITE]
				
				# Assign the generated ramp and noise into the texture and to the node.
				spaceAssetBasicGeneration.color_ramp = spaceAssetBasicGenerationColorRamp
				spaceAssetBasicGeneration.noise = spaceAssetBasicGenerationNoise
				get_node("spaceParallaxEffectManager/spaceBGTParallax/spaceBackgroundTexture").texture = spaceAssetBackground
				
				# Increase index by 1 to determine what type of adjustments to add in the textures.
				spaceAssetsIndex += 1
			
			2:  # Space gas generation.
				# Decide to show texture or not.
				if lib.generateRandomNumber(0, 1, "int", false) == 1:
					spaceAssetBasicGenerationNoise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
					
					# Assign the generated ramp and noise into the texture and to the node.
					spaceAssetBasicGeneration.color_ramp = spaceAssetBasicGenerationColorRamp
					spaceAssetBasicGeneration.noise = spaceAssetBasicGenerationNoise
					get_node("spaceParallaxEffectManager/spaceGTParallax/spaceGasesTexture").texture = spaceAssetGases
				
				else:
					spaceAssetGases = null
					get_node("spaceParallaxEffectManager/spaceGTParallax/spaceGasesTexture").visible = false
					
					# IGNORE: Debug
					print("Texture ", spaceAssetBasicGeneration, " is hidden.")
				
				# Increase index by 1 to determine what type of adjustments to add in the textures.
				spaceAssetsIndex += 1
			
			3:  # Space gas 1 generation.
				# Decide to show texture or not.
				if lib.generateRandomNumber(0, 1, "int", false) == 1:
					spaceAssetBasicGenerationNoise.noise_type = FastNoiseLite.TYPE_PERLIN
					
					# Assign the generated ramp and noise into the texture and to the node.
					spaceAssetBasicGeneration.color_ramp = spaceAssetBasicGenerationColorRamp
					spaceAssetBasicGeneration.noise = spaceAssetBasicGenerationNoise
					get_node("spaceParallaxEffectManager/spaceGT1Parallax/spaceGasesTexture1").texture = spaceAssetGases1
				
				else:
					spaceAssetGases1 = null
					get_node("spaceParallaxEffectManager/spaceGT1Parallax/spaceGasesTexture1").visible = false
					
					# IGNORE: Debug
					print("Hidden ", spaceAssetBasicGeneration, " texture.")
				
				# Increase index by 1 to determine what type of adjustments to add in the textures.
				spaceAssetsIndex += 1
			
			4:  # Space gas 2 generation.
				# Decide to show texture or not.
				if lib.generateRandomNumber(0, 1, "int", false) == 1:
					spaceAssetBasicGenerationNoise.noise_type = FastNoiseLite.TYPE_PERLIN
					spaceAssetBasicGenerationColorRamp.offsets = [0.25, 1]
				
					# Assign the generated ramp and noise into the texture and to the node.
					spaceAssetBasicGeneration.color_ramp = spaceAssetBasicGenerationColorRamp
					spaceAssetBasicGeneration.noise = spaceAssetBasicGenerationNoise
					get_node("spaceParallaxEffectManager/spaceGT2Parallax/spaceGasesTexture2").texture = spaceAssetGases2
				
				else:
					spaceAssetGases2 = null
					get_node("spaceParallaxEffectManager/spaceGT2Parallax/spaceGasesTexture2").visible = false
					
					# IGNORE: Debug
					print("Texture ", spaceAssetBasicGeneration, " is hidden.")
				
				# Increase index by 1 to determine what type of adjustments to add in the textures.
				spaceAssetsIndex += 1
			
			5:  # Space star generation.
				spaceAssetBasicGenerationNoise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
				spaceAssetBasicGenerationColorRamp.offsets = [0.85, 1]
				spaceAssetBasicGenerationNoise.frequency = 0.15
				spaceAssetBasicGenerationNoise.fractal_octaves = 5
				spaceAssetBasicGenerationNoise.fractal_gain = 2
				
				# Assign the generated ramp and noise into the texture and to the node.
				spaceAssetBasicGeneration.color_ramp = spaceAssetBasicGenerationColorRamp
				spaceAssetBasicGeneration.noise = spaceAssetBasicGenerationNoise
				get_node("spaceParallaxEffectManager/spaceSTParallax/spaceStarTexture").texture = spaceAssetStars
				
				# Increase index by 1 to determine what type of adjustments to add in the textures.
				spaceAssetsIndex += 1
			
			6:  # Space star 1 generation.
				spaceAssetBasicGenerationNoise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
				spaceAssetBasicGenerationColorRamp.offsets = [0.80, 1]
				spaceAssetBasicGenerationNoise.frequency = 0.15
				spaceAssetBasicGenerationNoise.fractal_octaves = 5
				spaceAssetBasicGenerationNoise.fractal_gain = 2
				
				# Assign the generated ramp and noise into the texture and to the node.
				spaceAssetBasicGeneration.color_ramp = spaceAssetBasicGenerationColorRamp
				spaceAssetBasicGeneration.noise = spaceAssetBasicGenerationNoise
				get_node("spaceParallaxEffectManager/spaceST1Parallax/spaceStarTexture1").texture = spaceAssetStars1
				
				# Increase index by 1 to determine what type of adjustments to add in the textures.
				spaceAssetsIndex += 1
		
		# IGNORE: Debug
		print("Adjusted space texture! ", spaceAssetBasicGeneration, " Index: ", spaceAssetsIndex - 1)
		print("Adjustments (Offsets, Colors, Mode): ", spaceAssetBasicGenerationColorRamp.offsets, " ", spaceAssetBasicGenerationColorRamp.colors, " ", spaceAssetBasicGenerationColorRamp.interpolation_mode)
		print("Adjustments (Seed): ", spaceAssetBasicGenerationNoise.seed, " ",  "\n")
	
	# IGNORE: Debug
	print("Loaded space texture! Visually adjusting now. Thread ", spaceGenerationThread, " will be terminated.")

#------------------------------------------------------------------------------#
