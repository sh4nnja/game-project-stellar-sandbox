extends Button
#------------------------------------------------------------------------------#

@onready var uiMenuLocateSectorAnimation: AnimationPlayer = get_node("uiMenuLocateSectorAnimation")
@onready var uiMenuLocateSectorSFX: AudioStreamPlayer = get_node("uiMenuLocateSectorSFX")

#------------------------------------------------------------------------------#
signal locateSpaceSector

#------------------------------------------------------------------------------#
# Play hover animation button when mouse entered button.
func _whenMouseEnteredButton() -> void:
	uiMenuLocateSectorAnimation.play("uiMenuLocateHovered")
	uiMenuLocateSectorSFX.play()

# Play hover animation button when mouse exits button.
func _whenMouseExitedButton() -> void:
	uiMenuLocateSectorAnimation.play_backwards("uiMenuLocateHovered")

# Emit signal to main menu manager.
func _whenMousePressed() -> void:
	uiMenuLocateSectorAnimation.play_backwards("uiMenuLocateHovered")
	locateSpaceSector.emit()
	
	# FORMAT: Release focus on the button.
	release_focus()

