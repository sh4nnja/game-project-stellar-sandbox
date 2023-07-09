extends Node2D

#------------------------------------------------------------------------------#
var spacePhenomenonGenerationThread: Thread

#------------------------------------------------------------------------------#
# IMPORTANT CODE: Load a thread for facilitating background loading
func initiateThreadForLoading(spacePhenomena: Array) -> void:
	
	# Wait for enough time to prepare nodes for texture placement.
	await get_tree().create_timer(4).timeout
	
	# IGNORE: Debug
	print("\nCreating thread for space phenomena texture loading...")
	# IMPORTANT CODE: Checking if other "spacePhenomenaGenerationThread" are active
	if is_instance_valid(spacePhenomenonGenerationThread) and spacePhenomenonGenerationThread.is_started():
		spacePhenomenonGenerationThread.wait_to_finish()
	
	# Create a new thread.
	spacePhenomenonGenerationThread = Thread.new()
	
	# IGNORE: Debug
	print("Thread ", spacePhenomenonGenerationThread, " has been created!\n")
	print("Loading space phenomena textures in the thread...")
	
	# Proceed to the thread function
	spacePhenomenonGenerationThread.start(_initiateSceneLoadingInThread.bind(spacePhenomena))

# IMPORTANT CODE: Thread Function for background space generation. 
func _initiateSceneLoadingInThread(spacePhenomena: Array) -> void:
	# IGNORE: Debug
	print("\nThread function initiated!\n")
	
	# Assign the color to the textures. 
	get_node("spaceParallaxEffectManager/spacePTParallax/spacePhenomenaTexture").modulate = spacePhenomena[1]
	
	# Initiation of textures.
	var spaceAssetPhenomena: NoiseTexture2D = NoiseTexture2D.new()
	
	# Creating the default configuration of the texture.
	spaceAssetPhenomena.width = 4096
	spaceAssetPhenomena.height = 4096
	
	# IGNORE: Debug
	print("Generated a space phenomena texture! ", spaceAssetPhenomena)
	
	# Creates a standard color ramp and noise object to assign in the texture.
	var spaceAssetBasicGenerationColorRamp: Gradient = Gradient.new()
	spaceAssetBasicGenerationColorRamp.offsets = [0, 0.5, 1]
	spaceAssetBasicGenerationColorRamp.colors = [Color.TRANSPARENT, Color(1, 1, 1, 0.25), Color.WHITE]
	spaceAssetBasicGenerationColorRamp.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_LINEAR
	
	var spaceAssetBasicGenerationNoise: FastNoiseLite = FastNoiseLite.new()
	spaceAssetBasicGenerationNoise.seed = spacePhenomena[0]
	spaceAssetBasicGenerationNoise.fractal_octaves = 10
	
	# Configure the adjustments per texture.
	match spacePhenomena[2]:
		1:  # Space phenomenon "HALO" generation.
			spaceAssetBasicGenerationNoise.noise_type = FastNoiseLite.TYPE_PERLIN
			spaceAssetBasicGenerationNoise.frequency = 0.0025
			spaceAssetBasicGenerationNoise.fractal_type = FastNoiseLite.FRACTAL_PING_PONG
			spaceAssetBasicGenerationNoise.fractal_lacunarity = 1
			spaceAssetBasicGenerationNoise.fractal_gain = 0.1
			
			# Assign the generated ramp and noise into the texture and to the node.
			spaceAssetPhenomena.color_ramp = spaceAssetBasicGenerationColorRamp
			spaceAssetPhenomena.noise = spaceAssetBasicGenerationNoise
			get_node("spaceParallaxEffectManager/spacePTParallax/spacePhenomenaTexture").texture = spaceAssetPhenomena
			
		2: # Space Phenomenon "PATCHES"
			spaceAssetBasicGenerationColorRamp.offsets = [0, 0.1, 0.5, 6, 1]
			spaceAssetBasicGenerationColorRamp.colors = [
				Color(lib.generateRandomColor(lib.spaceGasesMinimumColorValue, lib.spaceGasesMaximumColorValue, 1)),
				Color(lib.generateRandomColor(lib.spaceGasesMinimumColorValue, lib.spaceGasesMaximumColorValue, 1)),
				Color.TRANSPARENT,
				Color(lib.generateRandomColor(lib.spaceGasesMinimumColorValue, lib.spaceGasesMaximumColorValue, 1)),
				Color.TRANSPARENT
				]
			spaceAssetBasicGenerationNoise.noise_type = FastNoiseLite.TYPE_PERLIN
			spaceAssetBasicGenerationNoise.frequency = 0.005
			spaceAssetBasicGenerationNoise.fractal_type = FastNoiseLite.FRACTAL_RIDGED
			
			# Assign the generated ramp and noise into the texture and to the node.
			spaceAssetPhenomena.color_ramp = spaceAssetBasicGenerationColorRamp
			spaceAssetPhenomena.noise = spaceAssetBasicGenerationNoise
			get_node("spaceParallaxEffectManager/spacePTParallax/spacePhenomenaTexture").texture = spaceAssetPhenomena
	
	# IGNORE: Debug
	print("Adjusted space phenomena texture! ", spaceAssetPhenomena)
	print("Adjustments (Offsets, Colors, Type): ", spaceAssetBasicGenerationColorRamp.offsets, " ", spaceAssetBasicGenerationColorRamp.colors, " ",  spacePhenomena[2])
	print("Adjustments (Seed): ", spaceAssetBasicGenerationNoise.seed, " ",  "\n")
	print("Loaded space texture! Visually adjusting now. Thread ", spacePhenomenonGenerationThread, " will be terminated.")

#------------------------------------------------------------------------------#
