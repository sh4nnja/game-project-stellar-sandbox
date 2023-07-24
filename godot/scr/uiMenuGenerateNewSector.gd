extends Button
#------------------------------------------------------------------------------#

@onready var uiMenuGenerateNewSectorAnimation: AnimationPlayer = get_node("uiMenuGenerateNewSectorAnimation")
@onready var uiMenuGenerateNewSectorSFX: AudioStreamPlayer = get_node("uiMenuGenerateSFX")

#------------------------------------------------------------------------------#
signal discoverSpaceSector

#------------------------------------------------------------------------------#
# Play hover animation button when mouse entered button.
func _whenMouseEnteredButton() -> void:
	uiMenuGenerateNewSectorAnimation.play("uiMenuGenerateHovered")
	uiMenuGenerateNewSectorSFX.play()

# Play hover animation button when mouse exits button.
func _whenMouseExitedButton() -> void:
	uiMenuGenerateNewSectorAnimation.play_backwards("uiMenuGenerateHovered")

# Emit signal to main menu manager.
func _whenMousePressed() -> void:
	uiMenuGenerateNewSectorAnimation.play_backwards("uiMenuGenerateHovered")
	# IGNORE: Debug
	print("\nGenerate new sector option selected.")
	discoverSpaceSector.emit()
	
	# FORMAT: Release focus on the button.
	release_focus()

