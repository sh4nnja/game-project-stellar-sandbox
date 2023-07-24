extends Button
#------------------------------------------------------------------------------#

@onready var uiMenuStartAnimation: AnimationPlayer = get_node("uiMenuStartAnimation")
@onready var uiMenuStartSFX: AudioStreamPlayer = get_node("uiMenuStartSFX")

#------------------------------------------------------------------------------#
signal exploreSpaceSector

#------------------------------------------------------------------------------#
# Play hover animation button when mouse entered button.
func _whenMouseEnteredButton() -> void:
	uiMenuStartAnimation.play("uiMenuStartExplorationHovered")
	uiMenuStartSFX.play()

# Play hover animation button when mouse exits button.
func _whenMouseExitedButton() -> void:
	uiMenuStartAnimation.play_backwards("uiMenuStartExplorationHovered")
	await uiMenuStartAnimation.animation_finished
	uiMenuStartAnimation.play("uiMenuStartHighlight")

# Emit signal to main menu manager.
func _whenMousePressed() -> void:
	exploreSpaceSector.emit()
	
	# FORMAT: Release focus on the button.
	release_focus()

#------------------------------------------------------------------------------#
