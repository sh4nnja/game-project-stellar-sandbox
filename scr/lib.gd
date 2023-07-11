#------------------------------------------------------------------------------#
# PENTANNEX STUDIOS ---------------------------------------------------------- #
# ---------------------------------------------------------------------------- #
# PentaCODEXX LIBRARY -------------------------------------------------------- #
# VERSION 0.2 ---------------------------------------------------------------- #
# ---------------------------------------------------------------------------- #
# PROJECT K ------------------------------------------------------------------ #
# VERSION ALPHA -------------------------------------------------------------- #
#------------------------------------------------------------------------------#
extends Node
#------------------------------------------------------------------------------#
# GLOBAL CONFIGURATION 
#------------------------------------------------------------------------------#
var spaceMinimumSpawnSeed: int = -9223372036854775807
var spaceMaximumSpawnSeed: int = 9223372036854775807

var spaceGasesMinimumColorValue: float = 0.01
var spaceGasesMaximumColorValue: float = 1.00
var spaceGasesColorOpacity: float = 0.5

var spaceSectorEncryptionKey: int = 42
#------------------------------------------------------------------------------#
# GLOBAL OBJECTS
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
# GLOBAL INITIATION 
#------------------------------------------------------------------------------#

































#------------------------------------------------------------------------------#
# GLOBAL GENERATORS 
#------------------------------------------------------------------------------#
# Generating random numbers. 
func generateRandomNumber(minVal: float, maxVal: float, type: String = "int", includeNegatives: bool = false):
	# "minVal" for lowest value.
	# "maxVal" for highest value.
	# "type" for type of datatype; self-explanatory.
		# "randomInt" for random whole number without minimum and maximum values.
		# "randomFloat" for random decimal number without minimum and maximum value. Snapped to hundredths (0.01).
	# "includeNegatives" for including negative numbers in generation.
	var rng: Object = RandomNumberGenerator.new()
	rng.randomize()
	var output
	if includeNegatives: output = rng.randf_range(minVal, maxVal) * (rng.randi() % 2 * 2 - 1)
	else: output = rng.randf_range(minVal, maxVal)
	match type:
		"int": output = round(output)
		"float": output = snappedf(output, 0.001)
		"randomInt": output = rng.randi()
		"randomfloat": output = snappedf(rng.randf(), 0.01)
	return output

# Generator Vector2 values with same x, y values.
func generateRandomVector2(minVal: float, maxVal: float, type: String = "int", includeNegatives: bool = false) -> Vector2:
	var output: Vector2 = Vector2()
	var returnOutput: float
	returnOutput = generateRandomNumber(minVal, maxVal, type, includeNegatives)
	output = Vector2(returnOutput, returnOutput)
	return output

# Generator Vector2 values with different x, y values.
func generateRandomSeparateVector2(minVal: float, maxVal: float, type: String = "int", includeNegatives: bool = true) -> Vector2:
	var output: Vector2 = Vector2()
	output.x = generateRandomNumber(minVal, maxVal, type, includeNegatives)
	output.y = generateRandomNumber(minVal, maxVal, type, includeNegatives)
	return output

# Generator Color values with opacity manipulation "opacity". Maximum value, "1.0".
func generateRandomColor(minVal: float = spaceGasesMinimumColorValue, maxVal: float = spaceGasesMaximumColorValue, opacity: float = spaceGasesColorOpacity) -> String:
	var color: Color = Color(
		generateRandomNumber(minVal, maxVal, "float",  false), 
		generateRandomNumber(minVal, maxVal, "float", false), 
		generateRandomNumber(minVal, maxVal, "float",  false),
		opacity
	)
	var colorHtml: String = color.to_html(true)
	return colorHtml

#------------------------------------------------------------------------------#
# GLOBAL TOOLS 
#------------------------------------------------------------------------------#
# Reparant a child node "child" to another node "newParent".
func reparentNode(child: Node, newParent: Node) -> void:
	var oldParent = child.get_parent()
	oldParent.remove_child(child)
	newParent.add_child(child)

# Take a Screenshot.
func takeScreenShot(vprt: Viewport) -> void:
	if OS.has_feature("standalone"):
		pass
	else:
		var tx: Texture = vprt.get_texture()
		var img: Image = tx.get_data()
		img.flip_y()
		var _save = img.save_png("res://exportSS.png")

#------------------------------------------------------------------------------#
# ARCHIVES 
# DANGER ZONE: Rewrite the code if you will get a snippet from here.
#------------------------------------------------------------------------------#
#var lifeModulates: Array = [Color(1, 1, 1), Color(1, 0.5, 0), Color(1, 0, 0), Color(0, 1, 1), Color(.5, .5, .5), Color(.1, .1, .1), Color(0, 1, 0.5)]
#
#var camera: Node
#var noise: Object = OpenSimplexNoise.new()
#var noiseSpeed: float = 1
#var noiseStrength: float = 10
#var noiseDecay: float = 5
#var noiseTrack: float = 0.0
#var shakeStrength: float
#var amount: float = 1
#var doShake: bool = false
########################################
########### TRAIL MANAGER ##############
########################################
#func trailManager(trail: Node, node: Node, trailLength: int) -> void:
#	var trailPoint: Vector2 = node.global_position
#	trail.global_position = Vector2(0, 0)
#	trail.global_rotation = 0
#	trail.add_point(trailPoint)
#	while trail.get_point_count() > trailLength:
#		trail.remove_point(0)
#
########################################
########### ROCK FRAGMENT FX ###########
########################################
#func rockFragmentFX(position: Vector2, projectile: String, color: Color, scale: float) -> void:
#	if physicsNode:
#		var rFInst: Object = rockFragment.instance()
#		rFInst.self_modulate = color
#		rFInst.global_position = position
#		match projectile:
#			"collision": 
#				amount = 5
#				rFInst.rAmount = 175
#				rFInst.rScale = scale
#			"blaster": 
#				rFInst.rAmount = 50
#				rFInst.rScale = scale
#			"explosion":
#				rFInst.rAmount = 150
#				rFInst.rScale = scale
#				rFInst.scale = Vector2(12, 12)
#				combatTextManager(position, "Critical", Color(1, 1, 1))
#		physicsNode.add_child(rFInst)
#		rFInst = null
#	pass
########################################
######## CIRCLE EXPLOSION FX ###########
########################################
#func circleExplosionFX(position: Vector2, scale: Vector2) -> void:
#	if physicsNode:
#		var cEInst: Object = circleEx.instance()
#		cEInst.scale = scale
#		cEInst.cAmount = 256
#		physicsNode.add_child(cEInst)
#		cEInst.global_position = position
#		cEInst = null
#	pass
#
########################################
########### COMBAT TEXTS FX ############
########################################
#func combatTextManager(position: Vector2, mode: String, color: Color) -> void:
#	if physicsNode:
#		var cTInst: Node = combatText.instance()
#		cTInst.mode = mode
#		cTInst.color = color 
#		physicsNode.call_deferred("add_child", cTInst)
#		cTInst.global_position = position + generateRandomSeparateVector2(96, 128, "int", true)
#	pass
#
########################################
########### CAMERA SHAKE FX ############
########################################
#func screenShakeManager(delta) -> void:
#	if playerNode:
#		camera = playerNode.get_node_or_null("ship/camera")
#		noise.seed = lib.generateRandomNumber(0, 0, "randomInt", false)
#		noise.period = 2
#		if doShake:
#			shakeStrength = noiseStrength * amount * (camera.zoom.x / 2)
#			camera.zoom -= Vector2(0.05, 0.05)
#			doShake = false
#		noiseTrack += delta * noiseSpeed
#		shakeStrength = lerp(shakeStrength, 0, noiseDecay * delta)
#		if camera:
#			camera.offset = Vector2(noise.get_noise_2d(1, noiseTrack) * shakeStrength, noise.get_noise_2d(5, noiseTrack) * shakeStrength)

#func movementCode() -> void:
#	if lib.checkIfDesktopElseMobile():
#		look_at(get_global_mouse_position())
#		if Input.is_action_pressed("fw"):
#			velocity += transform.x * speed
#			interface.animateBar(false)
#		elif Input.is_action_just_released("fw"):
#			interface.animateBar(true)
#	else:
#		pass

#func checkIfDesktopElseMobile() -> bool:
#	var platform: String
#	platform = OS.get_name()
#	if platform in ["Android", "BlackBerry 10", "iOS"]:
#		return false
#	else:
#		return true
