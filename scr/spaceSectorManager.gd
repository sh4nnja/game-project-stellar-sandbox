extends Node2D
#------------------------------------------------------------------------------#
@onready var spaceBackgroundGenerator: Node2D = get_node("spaceBackgroundGenerator")
@onready var spacePhenomenaGenerator: Node2D = get_node("spacePhenomenaGenerator")
@onready var spaceEnvironment: WorldEnvironment = get_node("spaceEnvironment")

#------------------------------------------------------------------------------#
var spaceSectorSeed: int
var spaceSectorGases: Array = []
var spaceSectorSize: Vector2


var spaceSectorPhenomena: int

#------------------------------------------------------------------------------#
func _ready() -> void:
	_initiateSpaceSector()

#------------------------------------------------------------------------------#
# IMPORTANT CODE: Initiate chunks to align to main seed with offset via position.
func _initiateSpaceSector() -> void:
	# IGNORE: Debug
	print("Initializing Space Data...")
	spaceSectorSeed = lib.generateRandomNumber(
						# Refer to "lib.gd" -> CONFIGURATION section for values.
						lib.spaceMinimumSpawnSeed,
						lib.spaceMaximumSpawnSeed,
						# IGNORE this section, part of number generation.
						# Refer to "lib.gd" -> "Global Generators" section -> "generateRandomNumber() method".
						"int", true 
					)
	
	# Create 3 colors for clouds with a loop.
	for _i in range(3):
		spaceSectorGases.append(
							lib.generateRandomColor(
								# Refer to "lib.gd" -> CONFIGURATION section for values.
								lib.spaceGasesMinimumColorValue,
								lib.spaceGasesMaximumColorValue,
							)
						)
	
	# Generate what kind of phenomena will be seen at the feature space.
	spaceSectorPhenomena = lib.generateRandomNumber(1, 2, "int", false) 
	
	# IGNORE: Debug
	print("Initialized Space Data! (Seed, Color, Color1, Color2, Phenomena type): " + str(spaceSectorSeed) + ", " + str(spaceSectorGases[0]) + ", " + str(spaceSectorGases[1]) + ", " + str(spaceSectorGases[2])+ ", " + str(spaceSectorPhenomena))
	
	# Proceed to generation of space.
	spaceBackgroundGenerator.initiateThreadForLoading([spaceSectorSeed, spaceSectorGases[0], spaceSectorGases[1], spaceSectorGases[2]])
	
	# Proceed to generation of space phenomena.
	spacePhenomenaGenerator.initiateThreadForLoading([spaceSectorSeed, spaceSectorGases[0], spaceSectorPhenomena])

#------------------------------------------------------------------------------#
