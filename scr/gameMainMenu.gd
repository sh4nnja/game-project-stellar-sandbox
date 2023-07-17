extends Node2D

#------------------------------------------------------------------------------#
@onready var _gameMainMenuCamera: Camera2D = get_node("gameCamera")
@onready var _userInterfaceQuote: Label = get_node("userInterfaceMenuLayer/userInterfaceMenu/uiLogoGroup/uiLabel")

#@onready var _userInterfaceStartExplorationBtn: Button = get_node("userInterfaceMenuLayer/userInterfaceMenu/uiMenuButtonGroup/uiMenuStartExploration")
@onready var _userInterfaceGenerateNewBtn: Button = get_node("userInterfaceMenuLayer/userInterfaceMenu/uiMenuButtonGroup/uiMenuGenerateNewSector")

var _gameMainMenuCameraChanged: bool = false

signal _montage

#------------------------------------------------------------------------------#

func _ready():
	_userInterfaceGenerateNewBtn.connect("locateAnotherSpaceSector", Callable(self, "_generateNewSector"))

#------------------------------------------------------------------------------#
# Tween camera position across random positions in the map.
func _montageOnGameScreen():
	# Locks the camera to be changed.
	if !_gameMainMenuCameraChanged:
		_gameMainMenuCameraChanged = true
		var _montageCameraZoom: Vector2 = lib.generateRandomVector2(4, 5)
		_gameMainMenuCamera.zoom = _montageCameraZoom
	# Gets a random quote to show on the title.
	_userInterfaceQuote.text = lib.userInterfaceQuotes[lib.generateRandomNumber(0,  lib.userInterfaceQuotes.size() - 1)]
	# IMPORTANT CODE: Manages camera animation on main menu.
	var _montageTweenObject: Tween = create_tween()
	@warning_ignore("integer_division")
	var _montageCameraPosition: Vector2 = lib.generateRandomSeparateVector2(-lib.spaceSectorSize / 2, lib.spaceSectorSize / 2)
	var _montageCameraAnimationDuration: float = lib.generateRandomNumber(60, 120, "float")
	_montageTweenObject.tween_property(_gameMainMenuCamera, "global_position", _montageCameraPosition, _montageCameraAnimationDuration).set_ease(Tween.EASE_OUT)
	await _montageTweenObject.finished
	_montage.emit()

# Proceed to sector.

# Generate new sector.
func _generateNewSector() -> void:
	print("Loading new sector...\n")
	get_tree().call_group("spaceSectorManager", "revertTexturesOfSpaceTextures")
