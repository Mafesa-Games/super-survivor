extends Area2D

var direction: Vector2 = Vector2.ZERO
var speed: float = 300.0
var damage: int = 25

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
var timer = Timer.new()
var time_passed: float = 0.0

func _ready() -> void:
	connect("body_entered", on_body_entered)
	
	add_child(timer)
	timer.wait_time = 3.0
	timer.one_shot = true
	timer.connect("timeout", on_timer_timeout)
	timer.start()

	animated_sprite_2d.modulate = Color.RED

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	
	time_passed += delta
	var color_value = (sin(time_passed * 2 * PI / 3.0) + 1) / 2
	var current_color = Color(
		lerp(1.0, 0.0, color_value),
		0.0,
		lerp(0.0, 1.0, color_value)
	)
	animated_sprite_2d.modulate = current_color

func on_body_entered(body: Node2D) -> void:
	if body and body.name == "Player":
		Events.emit_signal("do_damage", damage)
	call_deferred("queue_free")

func on_timer_timeout() -> void:
	queue_free()
