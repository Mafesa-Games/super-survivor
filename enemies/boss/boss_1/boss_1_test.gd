extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_timer: Timer = $Timer
@export var enemy_stats: enemy_type
var direction

enum BossState { CHASE, PREPARE_DASH, DASH, AIMING, SHOOTING, STOP }

var chase: bool = true
var speed: float = 100
var dash_speed: float = 400
var player: CharacterBody2D
var current_state: BossState = BossState.CHASE
var target_position: Vector2
var is_moving: bool = true
var health: float

const CHASE_TIME: float = 3.0
const PREPARE_TIME: float = 0.10
const DASH_TIME: float = 0.75
const AIMING_TIME: float = 2.0  # Tiempo apuntando antes de disparar
const SHOOTING_TIME: float = 0.5  # Duración del estado de disparo
const STOP_TIME: float = 0.1
const SPREAD_ANGLE: float = 30.0  # Ángulo de dispersión para los disparos laterales

# Precargar la escena del proyectil
@onready var projectile_scene = preload("res://enemies/boss/boss_1/boss_1_projectile.tscn")
#@export var projectile_scene: PackedScene 

func _ready() -> void: 
	health = enemy_stats.health     
	start_chase()

func set_player(p: CharacterBody2D) -> void:
	player = p

func _physics_process(delta: float) -> void:
	var direction
	if not player:
		
		return
		
	match current_state:
		BossState.CHASE:
			chase_state()
		BossState.PREPARE_DASH:
			prepare_dash_state()
		BossState.DASH:
			dash_state()
		BossState.AIMING:
			aiming_state()
		BossState.SHOOTING:
			shooting_state()
		BossState.STOP:
			stop_state()

func chase_state() -> void:
	var direction = (player.position - position).normalized()
	velocity = direction * speed
	move_and_slide()
	update_sprite_direction()

func prepare_dash_state() -> void:
	velocity = Vector2.ZERO
	if is_moving:
		target_position = player.position
		is_moving = false
		direction = (target_position - position).normalized()

func dash_state() -> void:

	velocity = direction * dash_speed
	move_and_slide()
	update_sprite_direction()

func aiming_state() -> void:
	velocity = Vector2.ZERO
	# Aquí podrías añadir una animación de apuntado
	#look_at(player.position) # gira viendo el player

func shooting_state() -> void:
	shoot_projectiles()

	current_state = BossState.STOP
	start_stop()

func stop_state() -> void:
	velocity = Vector2.ZERO

func shoot_projectiles() -> void:
	var direction = (player.position - position).normalized()
	
	# Disparo central
	spawn_projectile(direction)
	
	# Disparo izquierdo
	var left_direction = direction.rotated(deg_to_rad(-SPREAD_ANGLE))
	spawn_projectile(left_direction)
	
	# Disparo derecho
	var right_direction = direction.rotated(deg_to_rad(SPREAD_ANGLE))
	spawn_projectile(right_direction)
	

func spawn_projectile(direction: Vector2) -> void:
	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)
	projectile.position = position
	projectile.direction = direction
	projectile.rotation = direction.angle()

func update_sprite_direction() -> void:
	if velocity.x < 0:
		animated_sprite_2d.scale.x = -1
	elif velocity.x > 0:
		animated_sprite_2d.scale.x = 1

func start_chase() -> void:
	current_state = BossState.CHASE
	is_moving = true
	state_timer.start(CHASE_TIME)
	#print("Estado: Persecución")

func start_prepare_dash() -> void:
	current_state = BossState.PREPARE_DASH
	state_timer.start(PREPARE_TIME)
	#print("Estado: Preparando Dash")

func start_dash() -> void:
	current_state = BossState.DASH
	state_timer.start(DASH_TIME)
	#print("Estado: Ejecutando Dash")

func start_aiming() -> void:
	current_state = BossState.AIMING
	state_timer.start(AIMING_TIME)
	#print("Estado: Apuntando")

func start_shooting() -> void:
	current_state = BossState.SHOOTING
	state_timer.start(SHOOTING_TIME)
	#print("Estado: Disparando")

func start_stop() -> void:
	current_state = BossState.STOP
	state_timer.start(STOP_TIME)
	#print("Estado: Detenido")

func _on_timer_timeout() -> void:
	match current_state:
		BossState.CHASE:
			start_prepare_dash()
		BossState.PREPARE_DASH:
			start_dash()
		BossState.DASH:
			start_aiming()
		BossState.AIMING:
			start_shooting()
		BossState.STOP:
			start_chase()

func apply_damage(attack: Attack):
	var damage = attack.damage
	var chance:= randi_range(1, 100)
	var critical:= false
	if chance < attack.critical_chance:
		damage = attack.damage * attack.critical_multiplier
		critical = true
	health -= damage    
	show_damage(damage)
	if health <= 0:
		await show_damage("kill")
		die()

func show_damage(amount) -> void:
	%damage_label.text = str(amount)
	%damage_label.visible = true
	await get_tree().create_timer(0.2).timeout
	%damage_label.visible = false

func die():
	Events.emit_signal("enemy_die", self)
	Events.emit_signal("boss_die", self)
	queue_free()
