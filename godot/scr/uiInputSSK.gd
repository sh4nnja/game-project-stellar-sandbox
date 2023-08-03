extends LineEdit
#------------------------------------------------------------------------------#

@onready var _uiSSKAnimation: AnimationPlayer = get_node("uiSSKAnimation")
@onready var _uiLocSSKBtn: Button = get_node("uiLocSSKBtn")
@onready var _uiLocSSKBtnAnim: AnimationPlayer = get_node("uiLocSSKBtn/uiLocSSKAnim")
@onready var _uiSSKSFX: AudioStreamPlayer = get_node("uiSSKSFX")
@onready var _uiSSKNote: Label = get_node("uiSSKNote")

#------------------------------------------------------------------------------#
signal locatingSpaceSector

#------------------------------------------------------------------------------#
var _uiSKKFocus: bool = false
var _uiSKKHover: bool = false
var _uiSSKLocMode: bool = true

#------------------------------------------------------------------------------#
func _ready() -> void:
	placeholder_text = lib.SSK

# Emits when the textBox is selected.
func _gui_input(event) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_uiSKKFocus = true

# Emits when the textBox is deselected.
func _unhandled_input(event) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if _uiSKKFocus: 
				_uiSKKFocus = false
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
# NOTE: Tinatamad ako magrename ng signals WHAHAHA jk
func whenUiSSKAnimFinished(_anim: String) -> void:
	# FORMAT: Waits for the animation to stop before pausing.
	# FORMAT: This way, the hover anim will not glitch when selected.
	if _uiSKKFocus:
		_uiSSKAnimation.pause()

# Fires when textbox is hovered.
func _whenMouseEntered() -> void:
	_uiSKKHover = true
	if !_uiSKKFocus:
		_uiSSKAnimation.play("uiInputSSKHovered")
		_uiSSKSFX.play()

# Fires when textbox exits hover.
func _whenMouseExited() -> void:
	_uiSKKHover = false
	if !_uiSKKFocus:
		_uiSSKAnimation.play_backwards("uiInputSSKHovered")

func _whenSSKLocBtnMouseEntered():
	if !_uiLocSSKBtn.disabled:
		_uiLocSSKBtnAnim.play("uiInputSSKLocateHovered")
		_uiSSKSFX.play()

func _whenSSKLocBtnMouseExited():
	if !_uiLocSSKBtn.disabled:
		_uiLocSSKBtnAnim.play_backwards("uiInputSSKLocateHovered")

func _whenSSKLocBtnPressed():
	if !_uiSSKLocMode:
		# If there's valid text in SSK Input, this will fire.
		locatingSpaceSector.emit()
		await _uiSSKAnimation.animation_finished
		_uiSSKAnimation.play_backwards("uiInputSSKHovered")
		text = ""
		_whenTextChanged(text)
	else:
		# If there's no text in SSK Input, the button will enter copy SSK mode.
		DisplayServer.clipboard_set(lib.SSK)
		_uiLocSSKBtn.text = "Copied To Clipboard!"
		await get_tree().create_timer(1).timeout
		_uiLocSSKBtn.text = "Retrieve Key"

#------------------------------------------------------------------------------#
# Fires when user inputs text in the textbox.
# IMPORTANT CODE: Check SSK for irregularities. Provide random if user agrees.
func _whenTextChanged(_stringText: String) -> void:
	# Matches UI Color for validity of text.
	match _checkSSK(_stringText):
		# Default, " "
		0: 
			modulate = Color.WHITE
			_uiLocSSKBtn.disabled = false
			_uiSSKNote.text = ""
			# Changes to copy SSK if no text is placed.
			_uiLocSSKBtn.text = "Retrieve Key"
			_uiSSKLocMode = true
			
		# Invalid SSK
		1: 
			modulate = Color.RED
			_uiLocSSKBtn.disabled = true
			_uiSSKNote.text = "Invalid SSK. Check for 'key' errors."
			# Changes to locate SSK if text is placed.
			_uiLocSSKBtn.text = "Locate Sector"
			_uiSSKLocMode = false
		# Valid SSK Format, But presets are error. Will replace them randomly.
		2: 
			modulate = Color.AQUA
			_uiLocSSKBtn.disabled = false
			_uiSSKNote.text = "Warning! Corrupted SSK. Might affect location protocol."
			# Changes to locate SSK if text is placed.
			_uiLocSSKBtn.text = "Locate Sector"
			_uiSSKLocMode = false
		# Valid and Accepted SSK Format, no change done.
		3: 
			modulate = Color.GREEN
			_uiSSKNote.text = "Valid SSK. Welcome home."
			# Changes to locate SSK if text is placed.
			_uiLocSSKBtn.text = "Locate Sector"
			_uiSSKLocMode = false
			lib.SSK = _stringText

# Update the placeholder once the sector key has been created.
func updatePlaceholderText() -> void:
	placeholder_text = lib.SSK

# Signal when node properties are changed. Useful for UI when disabling mouse passes.
func whenNodePropChanged():
	if _uiLocSSKBtn:
		if mouse_filter == Control.MOUSE_FILTER_STOP:
			_uiLocSSKBtn.mouse_filter = Control.MOUSE_FILTER_STOP
		elif mouse_filter == Control.MOUSE_FILTER_IGNORE:
			_uiLocSSKBtn.mouse_filter = Control.MOUSE_FILTER_IGNORE
