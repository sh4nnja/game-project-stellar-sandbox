extends CharacterBody2D
#------------------------------------------------------------------------------#

@onready var bodySprite: Sprite2D = get_node("shipParts/shipBody")
@onready var thrusterSprite: Sprite2D = get_node("shipParts/shipThruster")
@onready var cockpitSprite: Sprite2D = get_node("shipParts/shipCockpit")

@onready var shipTrails: Node2D = get_node("shipTrails")
@onready var shipTrailInner: Line2D = get_node("shipTrails/shipTrailInside")
@onready var shipTrailOuter: Line2D = get_node("shipTrails/shipTrailOutside")

@onready var shipCamera: Camera2D = get_node("shipCamera")

var shipTrailCurve: Curve2D = Curve2D.new()
#------------------------------------------------------------------------------#
var shipParts: Array = [bodySprite, thrusterSprite, cockpitSprite]

#------------------------------------------------------------------------------#
const SPEED: float = 5.0

var canMove: bool = false
var speed: float = SPEED
var friction: float = 1

#------------------------------------------------------------------------------#
var trailLength: int = 10


#------------------------------------------------------------------------------#
func _ready() -> void:
	# Limit camera.
	shipCamera.limit_top = -lib.spaceSectorSize / 2
	shipCamera.limit_bottom = lib.spaceSectorSize / 2
	shipCamera.limit_left = -lib.spaceSectorSize / 2
	shipCamera.limit_right = lib.spaceSectorSize / 2

func _input(_event) -> void:
	# Moves the ship when left mouse button is pressed.
	canMove = true if Input.is_action_pressed("fwd") else false

func _physics_process(delta) -> void:
	_manageMovement(delta)
	_emitTrails()

#------------------------------------------------------------------------------#
# Manages ship colors.
func changeShipColor(doRandomColor: bool, shipColorArray: Array) -> void:
	if doRandomColor:
		for shipToColor in shipParts:
			shipToColor.modulate = lib.generateRandomColor(lib.spaceGasesMinimumColorValue, lib.spaceGasesMaximumColorValue)
	else:
		var shipIndex: int = 0
		for shipToColor in shipParts:
			shipToColor.modulate = shipColorArray[shipIndex]
			shipIndex += 1

# Manages ship movement throughout the space.
func _manageMovement(gDelta: float) -> void:
	# Make the ship look at the mouse position.
	var shipRot: float = (get_global_mouse_position() - global_position).angle()
	rotation = lerp_angle(rotation, shipRotation, gDelta * 3)
	
	# Facilitates movement.
	if canMove:
		velocity += transform.x * speed 
	velocity = lerp(velocity, Vector2(0, 0), friction * gDelta)
	move_and_slide()

# Emit trails from boosters.
func _emitTrails() -> void:
	for shipTrail in shipTrails.get_children():
		shipTrailCurve.add_point(shipTrails.global_position)
		if shipTrailCurve.get_baked_points().size() > trailLength:
			shipTrailCurve.remove_point(0)
		shipTrail.points = shipTrailCurve.get_baked_points()
