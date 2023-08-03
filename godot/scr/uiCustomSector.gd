extends Control
#------------------------------------------------------------------------------#
@onready var uiSeed: LineEdit = get_node("uiMenuConfig/uiSeedPanel/uiSeed")
@onready var uiColorP: ColorPicker = get_node("uiMenuConfig/uiColorPanel/uiColorCont/uiColorPickerG")
@onready var uiColorP1: ColorPicker = get_node("uiMenuConfig/uiColorPanel/uiColorCont/uiColorPickerG1")
@onready var uiColorP2: ColorPicker = get_node("uiMenuConfig/uiColorPanel/uiColorCont/uiColorPickerG2")

@onready var uiMenuBg: TextureRect = get_node("uiMenuPanel/uiMenuBg")
@onready var uiMenuG: TextureRect = get_node("uiMenuPanel/uiMenuG")
@onready var uiMenuG1: TextureRect = get_node("uiMenuPanel/uiMenuG1")
@onready var uiMenuG2: TextureRect = get_node("uiMenuPanel/uiMenuG2")
@onready var uiMenuS: TextureRect = get_node("uiMenuPanel/uiMenuS")
@onready var uiMenuS1: TextureRect = get_node("uiMenuPanel/uiMenuS1")

#------------------------------------------------------------------------------#
var seedNum: int
var gasColors: Array[Color] = [Color.WHITE, Color.WHITE, Color.WHITE]

#------------------------------------------------------------------------------#
# Signal when text is changed.
func whenSeedTextChanged(text: String):
	if !text.is_valid_int():
		pass

# Signals when changing colors.
func whenCPickerChanged(color: Color):
	gasColors[0] = color

func whenCPicker1Changed(color: Color):
	gasColors[1] = color

func whenCPicker2Changed(color: Color):
	gasColors[2] = color

#------------------------------------------------------------------------------#
func updateGas() -> void:
	pass
