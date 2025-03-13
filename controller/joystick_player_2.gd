extends Node2D
class_name Joystick

@export var deadzone: float = 0.5 # Deadzone entre 0 y 1 (valores normalizados)

var posVector: Vector2 = Vector2.ZERO

func _input(event):
	if event is InputEventJoypadMotion:
		if event.axis == JOY_AXIS_LEFT_X:
			posVector.x = event.axis_value
		elif event.axis == JOY_AXIS_LEFT_Y:
			posVector.y = -event.axis_value # Invertir eje Y para que arriba sea positivo
		
		# Aplicar deadzone
		if posVector.length() < deadzone:
			posVector = Vector2.ZERO
		else:
			posVector = posVector.normalized() * ((posVector.length() - deadzone) / (1 - deadzone))
