extends LineEdit
#------------------------------------------------------------------------------#

@onready var _uiInputSSKAnimation: AnimationPlayer = get_node("uiInputSSKAnimation")
@onready var _uiInputSSKLocateBtn: Button = get_node("uiInputSSKLocate")
@onready var _uiInputNotice: Label = get_node("uiInputSSKNote")

#------------------------------------------------------------------------------#
signal locatingSpaceSector

#------------------------------------------------------------------------------#
var _uiInputSKKOnFocus: bool = false
var _uiInputSKKOnHover: bool = false
var _uiInputSSKLocateMode: bool = true

#------------------------------------------------------------------------------#
func _ready() -> void:
	placeholder_text = lib.SSK

# Emits when the textBox is selected.
func _gui_input(event) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_uiInputSKKOnFocus = true

# Emits when the textBox is deselected.
func _unhandled_input(event) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if _uiInputSKKOnFocus: 
				_uiInputSKKOnFocus = false
				_whenMouseExited() 
				release_focus()

#------------------------------------------------------------------------------#
# Checks SSK for validity and then updating it to the library for space generation.
func _checkSSK(SSK: String) -> int:
	var _SSKValidity: Array[int] = [1, 1, 1, 1, 1, 1, 1]
	var _SSKOverallValidity: int
	# IGNORE: Debug
	print("Checking SSK validity.")
	
	# SSK Validation Snippet.
	# Checks first if first and last values are enclosed with brackets '['.
	if SSK != "":
		if SSK[0] == '[' and SSK[SSK.length() - 1] == ']':
			# IGNORE: Debug
			print("    Validated SSK: Both brackets are present.")
			_SSKValidity[0] = 3
			# The number 8 counts as 7 (INDEX)
			if SSK.get_slice_count('|') == 8: 
				# IGNORE: Debug
				print("    Validated SSK: 7 Delimiters are present.")
				_SSKValidity[1] = 3
				if SSK.get_slice("|", 6) in ["1", "2"]:
					# IGNORE: Debug
					print("    Validated SSK: ", SSK.get_slice("|", 6), " is a valid space phenomena.")
					_SSKValidity[2] = 3
					for _sskColor in range(4):
						if SSK.get_slice("|", _sskColor + 2).is_valid_html_color():
							# IGNORE: Debug
							print("    Validated SSK: Color ", SSK.get_slice("|", _sskColor + 2), " is a valid color.")
							_SSKValidity[_sskColor + 3] = 3
						else:
							# IGNORE: Debug
							print("    Validated SSK with warning: Invalid color code ", SSK.get_slice("|", _sskColor + 2), ".")    
							_SSKValidity[_sskColor + 3] = 2
				else: 
					# IGNORE: Debug
					print("    Invalidated SSK: Invalid phenomena variant.")   
			else:
				# IGNORE: Debug
				print("    Invalidated SSK: Invalid delimiter count. Must be 7.")   
		else:
			# IGNORE: Debug
			print("    Invalidated SSK: Missing brackets.")  
	else: _SSKValidity = [0, 0, 0, 0, 0, 0, 0]
	
	# Visual return to SSK Input.
	if _SSKValidity == [3, 3, 3, 3, 3, 3, 3]:
		_SSKOverallValidity = 3
	elif _SSKValidity == [0, 0, 0, 0, 0, 0, 0]:
		_SSKOverallValidity = 0
	else:
		if _SSKValidity.has(2):
			_SSKOverallValidity = 2
		elif  _SSKValidity.has(1):
			_SSKOverallValidity = 1
	
	print("SSK validity: ", _SSKValidity)
	return _SSKOverallValidity

#------------------------------------------------------------------------------#
func whenUiInputSSKAnimationFinished(_anim: String) -> void:
	# FORMAT: Waits for the animation to stop before pausing.
	# FORMAT: This way, the hover anim will not glitch when selected.
	if _uiInputSKKOnFocus:
		_uiInputSSKAnimation.pause()

# Fires when textbox is hovered.
func _whenMouseEntered() -> void:
	_uiInputSKKOnHover = true
	if !_uiInputSKKOnFocus:
		_uiInputSSKAnimation.play("uiInputSSKHovered")

# Fires when textbox exits hover.
func _whenMouseExited() -> void:
	_uiInputSKKOnHover = false
	if !_uiInputSKKOnFocus:
		_uiInputSSKAnimation.play_backwards("uiInputSSKHovered")

func _whenLocateBtnMouseEntered():
	if !_uiInputSSKLocateBtn.disabled:
		_uiInputSSKAnimation.play("uiInputSSKLocateHovered")

func _whenLocateBtnMouseExited():
	if !_uiInputSSKLocateBtn.disabled:
		_uiInputSSKAnimation.play_backwards("uiInputSSKLocateHovered")

func _whenUIInputSSKLocatePressed():
	if !_uiInputSSKLocateMode:
		# If there's valid text in SSK Input, this will fire.
		locatingSpaceSector.emit()
		await _uiInputSSKAnimation.animation_finished
		_uiInputSSKAnimation.play_backwards("uiInputSSKHovered")
		text = ""
		_whenTextChanged(text)
	else:
		# If there's no text in SSK Input, the button will enter copy SSK mode.
		DisplayServer.clipboard_set(lib.SSK)
		_uiInputSSKLocateBtn.text = "SSK Copied!"
		await get_tree().create_timer(1).timeout
		_uiInputSSKLocateBtn.text = "Retrieve Key"

#------------------------------------------------------------------------------#
# Fires when user inputs text in the textbox.
# IMPORTANT CODE: Check SSK for irregularities. Provide random if user agrees.
func _whenTextChanged(_stringText: String) -> void:
	# Matches UI Color for validity of text.
	match _checkSSK(_stringText):
		# Default, " "
		0: 
			modulate = Color.WHITE
			_uiInputSSKLocateBtn.disabled = true
			_uiInputNotice.text = ""
			# Changes to copy SSK if no text is placed.
			_uiInputSSKLocateBtn.text = "Retrieve Key"
			_uiInputSSKLocateMode = true
			
		# Invalid SSK
		1: 
			modulate = Color.RED
			_uiInputSSKLocateBtn.disabled = true
			_uiInputNotice.text = "Invalid SSK. Check for 'key' errors."
			# Changes to locate SSK if text is placed.
			_uiInputSSKLocateBtn.text = "Locate Sector"
			_uiInputSSKLocateMode = false
		# Valid SSK Format, But presets are error. Will replace them randomly.
		2: 
			modulate = Color.AQUA
			_uiInputSSKLocateBtn.disabled = false
			_uiInputNotice.text = "Warning! Corrupted SSK. Might affect location protocol."
			# Changes to locate SSK if text is placed.
			_uiInputSSKLocateBtn.text = "Locate Sector"
			_uiInputSSKLocateMode = false
		# Valid and Accepted SSK Format, no change done.
		3: 
			modulate = Color.GREEN
			_uiInputNotice.text = "Valid SSK. Welcome home."
			# Changes to locate SSK if text is placed.
			_uiInputSSKLocateBtn.text = "Locate Sector"
			_uiInputSSKLocateMode = false
			lib.SSK = _stringText

# Update the placeholder once the sector key has been created.
func updatePlaceholderText() -> void:
	placeholder_text = lib.SSK
