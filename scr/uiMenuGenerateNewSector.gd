extends Button
#------------------------------------------------------------------------------#
@onready var uiMenuGenerateNewSectorAnimation: AnimationPlayer = get_node("uiMenuGenerateNewSectorAnimation")
@onready var uiMenuGenerateNewSectorSFX: AudioStreamPlayer = get_node("uiMenuGenerateSFX")

#------------------------------------------------------------------------------#
signal locateAnotherSpaceSector

#------------------------------------------------------------------------------#
# Play hover animation button when mouse entered button.
func _whenMouseEnteredButton():
	uiMenuGenerateNewSectorAnimation.play("uiMenuGenerateHovered")
	uiMenuGenerateNewSectorSFX.play()

# Play hover animation button when mouse exits button.
func _whenMouseExitedButton():
	uiMenuGenerateNewSectorAnimation.play_backwards("uiMenuGenerateHovered")

# Emit signal to main menu manager.
func _whenMousePressed():
	# IGNORE: Debug
	print("\nGenerate new sector option selected.")
	locateAnotherSpaceSector.emit()

