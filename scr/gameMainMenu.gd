extends Node2D

#------------------------------------------------------------------------------#
@onready var _gameMainMenuCamera: Camera2D = get_node("gameCamera")

signal _montage
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
# Tween camera position across random positions in the map.
func _montageOnGameScreen():
	var _montageTweenObject: Tween = create_tween()
	var _montageCameraPosition: Vector2 = lib.generateRandomSeparateVector2(-2048, 2048)
	var _montageCameraZoom: Vector2 = lib.generateRandomVector2(3, 4)
	var _montageCameraAnimationDuration: float = lib.generateRandomNumber(20, 30, "float")
	_montageTweenObject.tween_property(_gameMainMenuCamera, "zoom", _montageCameraZoom, 2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_montageTweenObject.tween_property(_gameMainMenuCamera, "global_position", _montageCameraPosition, _montageCameraAnimationDuration).set_ease(Tween.EASE_OUT)
	await _montageTweenObject.finished
	_montage.emit()

