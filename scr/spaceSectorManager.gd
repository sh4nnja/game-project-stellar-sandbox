extends Node2D
#------------------------------------------------------------------------------#
@onready var _spaceBackgroundGenerator: Node2D = get_node("spaceBackgroundGenerator")
@onready var _spacePhenomenaGenerator: Node2D = get_node("spacePhenomenaGenerator")
#@onready var _spaceEnvironment: WorldEnvironment = get_node("spaceEnvironment")

#------------------------------------------------------------------------------#
var _spaceSectorRandomGeneration: bool = true

var _spaceSectorSeed: int
var _spaceSectorBackground: String
var _spaceSectorGases: Array = []
var _spaceSectorPhenomena: int

#------------------------------------------------------------------------------#
func _ready() -> void:
	_initiateSpaceSector()

#------------------------------------------------------------------------------#
# IMPORTANT CODE: Initiate chunks to align to main seed with offset via position.
func _initiateSpaceSector() -> void:
	# IGNORE: Debug
	print("Initializing Space Sector Key...")
	
	# Creates the seed for the galaxy.
	# Manages if you want a seed with presets.
	if _spaceSectorRandomGeneration:
		_spaceSectorSeed = lib.generateRandomNumber(
							# Refer to "lib.gd" -> CONFIGURATION section for values.
							lib.spaceMinimumSpawnSeed,
							lib.spaceMaximumSpawnSeed,
							# IGNORE this section, part of number generation.
							# Refer to "lib.gd" -> "Global Generators" section -> "generateRandomNumber() method".
							"int", true 
						)
		
		# Creates the background color accent of the space:
		_spaceSectorBackground = lib.generateRandomColor()
	
		# Create 3 colors for clouds with a loop.
		for _spaceSectorGasesIteration in range(3):
			if lib.generateRandomNumber(0, 5) != 1:
				_spaceSectorGases.append(lib.generateRandomColor())
			else:
				_spaceSectorGases.append("00000000")
		
		# Generate what kind of phenomena will be seen at the feature space.
		_spaceSectorPhenomena = lib.generateRandomNumber(1, 2) 
	
	else:
		# Assign chunks of the preset number to the parameters. 
		var spaceSectorKey: String = "[|9011575311019540480|154e2080|00000000|71f7ed80|f7478380|1|]"
		_spaceSectorSeed = int(spaceSectorKey.get_slice("|", 1))
		_spaceSectorBackground = (spaceSectorKey.get_slice("|", 2))
		_spaceSectorGases.append(spaceSectorKey.get_slice("|", 3))
		_spaceSectorGases.append(spaceSectorKey.get_slice("|", 4))
		_spaceSectorGases.append(spaceSectorKey.get_slice("|", 5))
		_spaceSectorPhenomena = int(spaceSectorKey.get_slice("|", 6))
	
	# Wait for the scene to be created.
	await get_tree().create_timer(1).timeout
	# Proceed to generation of space phenomena.
	_spacePhenomenaGenerator.initiateThreadForLoading([_spaceSectorSeed, _spaceSectorGases[0], _spaceSectorPhenomena])
	# IGNORE: Debug
	print("Started space generation.")
	
	# Wait for the scene to be created.
	await get_tree().create_timer(1).timeout
	# Proceed to generation of space.
	_spaceBackgroundGenerator.initiateThreadForLoading([[_spaceSectorSeed, _spaceSectorBackground, _spaceSectorGases[0], _spaceSectorGases[1], _spaceSectorGases[2], _spaceSectorPhenomena]])
	# IGNORE: Debug
	print("Started space phenomena generation.")

#------------------------------------------------------------------------------#
