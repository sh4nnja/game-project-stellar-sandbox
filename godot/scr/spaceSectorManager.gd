extends Node2D
#------------------------------------------------------------------------------#
@onready var _spaceBgGen: Node2D = get_node("spaceBgGen")
@onready var _spacePhenoGen: Node2D = get_node("spacePhenoGen")
#@onready var _spaceEnvironment: WorldEnvironment = get_node("spaceEnvironment")

#------------------------------------------------------------------------------#
var _spaceSectRandGen: bool = false

var _spaceSectKey: String = "[|{0}|{1}|{2}|{3}|{4}|{5}|]"
var _spaceSectSeed: int
var _spaceSectBg: String
var _spaceSectGas: Array = []
var _spaceSectPheno: int

#------------------------------------------------------------------------------#
func _ready() -> void:
	_loadSpaceSector()

#------------------------------------------------------------------------------#
# IMPORTANT CODE: Initiate chunks to align to main seed with offset via position.
func _loadSpaceSector() -> void:
	# IGNORE: Debug
	print("Initializing Space Sector Key...")
	
	# Creates the seed for the galaxy.
	# Manages if you want a seed with presets.
	if _spaceSectRandGen:
		_spaceSectSeed = lib.genRand(
							# Refer to "lib.gd" -> CONFIGURATION section for values.
							lib.minSpawnSeed,
							lib.maxSpawnSeed,
							# IGNORE this section, part of number generation.
							# Refer to "lib.gd" -> "Global Generators" section -> "generateRandomNumber() method".
							"int", true 
						)
		
		# Creates the background color accent of the space:
		_spaceSectBg = lib.genRandColor()
	
		# Create 3 colors for clouds with a loop.
		for _spaceSectorGasesIteration in range(3):
			if lib.genRand(0, 5) != 1:
				_spaceSectGas.append(lib.genRandColor())
			else:
				_spaceSectGas.append("00000000")
		
		# Generate what kind of phenomena will be seen at the feature space.
		_spaceSectPheno = lib.genRand(1, 2) 
		_spaceSectRandGen = false
	
	else:
		# Assign chunks of the preset number to the parameters. 
		var spaceSectorKey: String = lib.SSK
		_spaceSectSeed = int(spaceSectorKey.get_slice("|", 1))
		_spaceSectBg = spaceSectorKey.get_slice("|", 2) if spaceSectorKey.get_slice("|", 2).is_valid_html_color() else lib.generateRandomColor()
		for _i in range(3):
			_spaceSectGas.append(spaceSectorKey.get_slice("|", _i + 3) if spaceSectorKey.get_slice("|", _i + 3).is_valid_html_color() else lib.generateRandomColor())
		_spaceSectPheno = int(spaceSectorKey.get_slice("|", 6))
	
	# IGNORE: Debug
	print("Generated Space Sector Key (SSK): ", _spaceSectKey.format([_spaceSectSeed, _spaceSectBg, _spaceSectGas[0], _spaceSectGas[1], _spaceSectGas[2], _spaceSectPheno]))
	
	# Update SSK Key and send signals to any placeholders.
	lib.SSK = _spaceSectKey.format([_spaceSectSeed, _spaceSectBg, _spaceSectGas[0], _spaceSectGas[1], _spaceSectGas[2], _spaceSectPheno])
	get_tree().call_group("SSKInput", "updatePlaceholderText")
	
	# Wait for the scene to be created.
	await get_tree().create_timer(0.05).timeout
	# Proceed to generation of space phenomena.
	_spacePhenoGen._loadThread([_spaceSectSeed, _spaceSectGas[0], _spaceSectPheno])
	# IGNORE: Debug
	print("Started space generation.")
	
	# Wait for the scene to be created.
	await get_tree().create_timer(0.05).timeout
	# Proceed to generation of space.
	_spaceBgGen._loadThread([[_spaceSectSeed, _spaceSectBg, _spaceSectGas[0], _spaceSectGas[1], _spaceSectGas[2], _spaceSectPheno]])
	# IGNORE: Debug
	print("Started space phenomena generation.")

# Reverts textures to default. Clearing memory for new generation.
# IMPORTANT CODE: This is the method TO BE USED in other scripts when changing background.
func revertTexturesOfSpaceTextures(isGenerationRandom: bool) -> void:
	_spaceSectRandGen = isGenerationRandom
	_spaceSectGas.clear()
	_spaceBgGen.revertSpaceTexturesToDefault()
	_spacePhenoGen.revertSpacePhenomenaTexturesToDefault()
	# Wait for the scene to be adjusted.
	await get_tree().create_timer(0.05).timeout
	# FORMAT: Just to separate different phases.
	print(" ")
	_loadSpaceSector()

#------------------------------------------------------------------------------#
