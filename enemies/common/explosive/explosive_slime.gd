extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var enemy_stats: enemy_type
var chase: bool = true
var shake_intensity = 1.0
var shake_timer: int = 0
var speed: float
var health: int
var player: CharacterBody2D

@onready var damage_popup_scene = preload("res://enemies/damage_popup.tscn")
var damage_popup_instance: Node = null

@onready var explosion_sprite: AnimatedSprite2D = $ExplosionSprite
@onready var explosion_area: Area2D = $ExplosionArea

var explosion_damage: int = 25

var is_dead = false

# explosion color
var color_start: Color = Color("#180000")
var color_end: Color = Color("#c8b38f")
var color_timer: float = 0.0
var color_speed: float = 40

func _ready() -> void:
	animated_sprite.play("walk")
	speed = enemy_stats.speed
	health = enemy_stats.health
	explosion_sprite.visible = false

func _process(delta: float) -> void:
	color_timer += delta * color_speed
	var t = (sin(color_timer) + 1) / 2
	explosion_sprite.modulate = color_start.lerp(color_end, t)

func _physics_process(delta: float) -> void:
	if health <= 0:
		return
	
	var direction = global_position.direction_to(player.global_position)
	if shake_timer != 0:
		shake_timer -= 1
		animated_sprite.global_position = position + Vector2(randf_range(-shake_intensity, shake_intensity), randf_range(-shake_intensity, shake_intensity) - 8)
		if shake_timer == 0:
			animated_sprite.global_position = position + Vector2(0, -8)
			speed += 20
	
	velocity = direction * speed
	move_and_slide()
	
	if velocity.x < 0:
		animated_sprite.scale.x = -1
	elif velocity.x > 0:
		animated_sprite.scale.x = 1

func apply_damage(attack: Attack) -> void:
	var damage = attack.damage
	var chance := randi_range(1, 100)
	var critical := false
	if chance < attack.critical_chance:
		damage = attack.damage * attack.critical_multiplier
		critical = true
	health -= damage
	show_damage(damage, critical)
	attack.weapon.damage_done += damage
	
	if health <= 0:
		die()
	elif attack.shake > 0 && shake_timer == 0:
		shake_timer = attack.shake
		speed -= 20

func show_damage(amount: int, is_critical:bool) -> void:
	if not damage_popup_instance:
		damage_popup_instance = damage_popup_scene.instantiate()
		add_child(damage_popup_instance)
		damage_popup_instance.global_position = global_position + Vector2(0, -20)

	damage_popup_instance.show_damage(amount, is_critical)


func die():
	if is_dead:
		return
	is_dead = true
	velocity = Vector2.ZERO
	$CollisionShape2D.set_deferred("disabled", true)
	animated_sprite.visible = false
	explosion_sprite.visible = true
	explosion_sprite.play("explode")

	for body in explosion_area.get_overlapping_bodies():
		if body.name == "Player":
			Events.emit_signal("do_damage", explosion_damage)

	await explosion_sprite.animation_finished
	Events.emit_signal("enemy_die", self)
	queue_free()
