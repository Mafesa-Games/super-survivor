extends Sprite2D

@export var maxLength = 3500
@onready var joyring: Sprite2D = $"../Joyring"
@onready var joystick_stick: Node2D = $".."

var drag_position = Vector2.ZERO
var is_dragging = false
var touch_position = Vector2.ZERO
var dedo_position = Vector2.ZERO


func _ready():
	joyring.hide()
	hide()

func _process(delta):	
	if drag_position.length_squared() < maxLength:
		global_position = dedo_position
	else:
		var angle = touch_position.angle_to_point(dedo_position)
		global_position.x = touch_position.x +  cos(angle) * 35
		global_position.y = touch_position.y +  sin(angle) * 35

func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			
			# Show joystick at touch position			
			touch_position = event.position
			global_position = touch_position
			joyring.global_position = touch_position
			dedo_position = touch_position
			drag_position = Vector2.ZERO
			joyring.show()
			show()
			
			is_dragging = true
		else:
			# Hide joystick when touch is released
			hide()
			joyring.hide()
			is_dragging = false
			joystick_stick.posVector = Vector2.ZERO

			
	elif event is InputEventScreenDrag and is_dragging:
		# Calculate the drag position relative to joystick background		
		drag_position = event.position - touch_position
		dedo_position = event.position
		# Update joystick stick position
		joystick_stick.posVector = drag_position
