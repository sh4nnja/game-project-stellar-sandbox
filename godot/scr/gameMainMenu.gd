extends Node2D
#------------------------------------------------------------------------------#

@onready var _gameMainMenuCamera: Camera2D = get_node("gameCamera")
@onready var _userInterfaceQuote: Label = get_node("userInterfaceMenuLayer/userInterfaceMenu/uiLogoGroup/uiLabel")
@onready var _userInterfaceAnimation: AnimationPlayer = get_node("userInterfaceMenuLayer/userInterfaceMenu/uiLogoGroup/uiAnimationPlayer")

@onready var _userInterfaceAnimManager: AnimationTree = get_node("userInterfaceMenuLayer/userInterfaceMenu/uiLogoGroup/uiAnimationManager")

#@onready var _userInterfaceStartExplorationBtn: Button = get_node("userInterfaceMenuLayer/userInterfaceMenu/uiMenuButtonGroup/uiMenuStartExploration")
@onready var _userInterfaceGenerateNewBtn: Button = get_node("userInterfaceMenuLayer/userInterfaceMenu/uiMenuButtonGroup/uiMenuGenerateNewSector")
@onready var _userInterfaceLocateSectorBtn: Button = get_node("userInterfaceMenuLayer/userInterfaceMenu/uiMenuButtonGroup/uiMenuLocateSector")

@onready var _userInterfaceLocateSSKBtn: LineEdit = get_node("userInterfaceMenuLayer/userInterfaceMenu/uiMenuLocateSector/uiInputSSK")

var _gameMainMenuCameraChanged: bool = false
var _userInterfaceLocateFocused: bool = false

#------------------------------------------------------------------------------#
signal _montage

#------------------------------------------------------------------------------#
func _ready() -> void:
	# Starts the animation tree.
	_userInterfaceAnimManager.active = true
	# Connects the signals to its respective functions.
	# Most of these are input buttons. 
	_userInterfaceGenerateNewBtn.connect("discoverSpaceSector", Callable(self, "_generateNewSector"))
	_userInterfaceLocateSectorBtn.connect("locateSpaceSector", Callable(self, "_locateSector"))
	_userInterfaceLocateSSKBtn.connect("locatingSpaceSector", Callable(self, "_locatingSector"))

# Fires when input event happens, every time.
func _input(_event) -> void:
	pass

# Fires when input event happens and no GUI detects it.
# Useful for closing panels by just clicking outside.
func _unhandled_input(event) -> void:
	if event is InputEventMouseButton:
		if _userInterfaceLocateFocused:
			_userInterfaceLocateFocused = false
			_locateSector(1)
			

#------------------------------------------------------------------------------#
# Tween camera position across random positions in the map.
func _montageOnGameScreen() -> void:
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
func _proceedToSector() -> void:
	pass

# Generate new sector.
func _generateNewSector() -> void:
	# Play the loading animation on overlay while generating another sector.
	_userInterfaceAnimation.play("generateNewSectorFade")
	# IMPORTANT CODE: Timer is a must to ensure that the animation overlay will not be late and make the loading visible.
	await get_tree().create_timer(1.1).timeout
	
	# Call a signal to sector manager. To revert textures.
	get_tree().call_group("spaceSectorManager", "revertTexturesOfSpaceTextures", true)

# Locate specified sector.
func _locateSector(mode: int = 0) -> void:
	# Play the locate overlay.
	if mode == 0:
		_userInterfaceAnimation.play("locateSectorOverlay")
		_userInterfaceLocateFocused = true
	else: 
		_userInterfaceAnimation.play_backwards("locateSectorOverlay")

# Locating specified sector.
func _locatingSector() -> void:
	_userInterfaceLocateFocused = false
	_userInterfaceAnimation.play_backwards("locateSectorOverlay")
	# Waiting for the panel to disappear to continue.
	await _userInterfaceAnimation.animation_finished
	_userInterfaceAnimation.play("generateNewSectorFade")
	# IMPORTANT CODE: Timer is a must to ensure that the animation overlay will not be late and make the loading visible.
	await get_tree().create_timer(1.1).timeout
	get_tree().call_group("spaceSectorManager", "revertTexturesOfSpaceTextures", false)
