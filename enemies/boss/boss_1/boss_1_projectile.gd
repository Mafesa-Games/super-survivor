extends Area2D

var direction: Vector2 = Vector2.ZERO
var speed: float = 300.0
var damage: int = 25

func _ready() -> void:	
	connect("body_entered", _on_body_entered)
	
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 3.0
	timer.one_shot = true
	timer.connect("timeout", _on_timer_timeout)  # Add nodes in scene 
	timer.start()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body and body.name == "Player":
		Events.emit_signal("do_damage", damage)
	call_deferred("queue_free")

func _on_timer_timeout() -> void:
	queue_free()
