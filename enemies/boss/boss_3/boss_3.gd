extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_timer: Timer = $Timer
@export var enemy_stats: enemy_type
var direction: Vector2

enum BossState { CHASE, DASH, WAIT, SHOOT, TELEPORT }
var current_state: BossState = BossState.CHASE
var player: CharacterBody2D
var health: float
var is_moving: bool = true

var speed: float = 80
var dash_speed: float = 350
var dash_count: int = 0
var max_dashes: int = 0

const CHASE_TIME: float = 2.0
const DASH_TIME: float = 0.8
const TELEPORT_RANGE: float = 170.0

@onready var projectile_scene = preload("res://enemies/boss/boss_3/boss_3_projectile.tscn")
@onready var damage_popup_scene = preload("res://enemies/damage_popup.tscn")
var damage_popup_instance: Node = null

var is_dying: bool = false 

var is_firing: bool = false
var teleport_count: int = 0
var max_teleports: int = 0
var teleport_projectiles: int = 6 
var teleport_projectile_speed: float = 200.0 
var teleport_delay: float = 0.8

func _ready() -> void:
	health = enemy_stats.health
	start_chase()

func set_player(p: CharacterBody2D) -> void:
	player = p

func _physics_process(delta: float) -> void:
	if not player:
		return
	if not player or is_dying:
		return
		
	match current_state:
		BossState.CHASE:
			chase_state()
		BossState.DASH:
			dash_state()
		BossState.WAIT:
			wait_state()
		BossState.SHOOT:
			pass
		BossState.TELEPORT:
			teleport_state()

func chase_state() -> void:
	direction = (player.position - position).normalized()
	velocity = direction * speed
	move_and_slide()
	update_sprite_direction()

func dash_state() -> void:
	velocity = direction * dash_speed
	move_and_slide()
	update_sprite_direction()

func wait_state() -> void:
	velocity = Vector2.ZERO
	is_moving = false

func shoot_state(num_projectiles: int, num_shots: int, shot_delay: float) -> void:
	if not is_firing:
		is_firing = true
		var shots_fired = 0
		while shots_fired < num_shots and is_firing:
			fire_spread(num_projectiles)
			shots_fired += 1
			if shots_fired < num_shots:
				await get_tree().create_timer(shot_delay).timeout
		is_firing = false
		start_wait(0.5)

func teleport_state() -> void:
	velocity = Vector2.ZERO
	var angle = randf_range(0, 2 * PI)
	var offset = Vector2(cos(angle), sin(angle)) * TELEPORT_RANGE
	position = player.position + offset
	fire_omnidirectional()
	teleport_count += 1
	if teleport_count < max_teleports:
		start_wait(teleport_delay)
	else:
		start_wait(0.3)

func fire_spread(num_projectiles: int) -> void:
	var base_direction = (player.position - position).normalized()
	var angle_step = 60.0 / (num_projectiles - 1) if num_projectiles > 1 else 0
	for i in range(num_projectiles):
		var angle = deg_to_rad(-30 + (i * angle_step))
		var shot_direction = base_direction.rotated(angle)
		spawn_projectile(shot_direction)

func fire_omnidirectional() -> void:
	for i in range(teleport_projectiles):
		var angle = i * (2 * PI / teleport_projectiles)
		var dir = Vector2(cos(angle), sin(angle))
		spawn_projectile(dir, teleport_projectile_speed)

func spawn_projectile(dir: Vector2, custom_speed: float = 150.0) -> void:
	var projectile = projectile_scene.instantiate()
	get_parent().add_child(projectile)
	projectile.position = position
	projectile.direction = dir
	projectile.speed = custom_speed
	projectile.rotation = dir.angle()

func update_sprite_direction() -> void:
	if velocity.x < 0:
		animated_sprite_2d.scale.x = -1
	elif velocity.x > 0:
		animated_sprite_2d.scale.x = 1

func start_chase() -> void:
	current_state = BossState.CHASE
	is_moving = true
	dash_count = 0
	teleport_count = 0
	state_timer.start(CHASE_TIME)

func start_dash() -> void:
	current_state = BossState.DASH
	direction = (player.position - position).normalized()
	dash_count += 1
	state_timer.start(DASH_TIME)

func start_wait(wait_time: float) -> void:
	current_state = BossState.WAIT
	state_timer.start(wait_time)

func start_shoot(num_projectiles: int, num_shots: int, shot_delay: float) -> void:
	current_state = BossState.SHOOT
	shoot_state(num_projectiles, num_shots, shot_delay)

func start_teleport() -> void:
	current_state = BossState.TELEPORT
	teleport_count = 0
	max_teleports = randi_range(3, 5)
	teleport_state()

func pick_random_attack() -> void:
	var attacks = [
		{"state": BossState.DASH, "func": func(): 
			max_dashes = randi_range(2, 4);
			start_dash()},
		{"state": BossState.SHOOT, "func": func(): 
			start_shoot(3, randi_range(3, 5), 0.8)},
		{"state": BossState.TELEPORT, "func": func(): 
			start_teleport()}
	]
	var random_attack = attacks[randi() % attacks.size()]
	random_attack["func"].call()

func _on_timer_timeout() -> void:
	match current_state:
		BossState.CHASE:
			pick_random_attack()
		BossState.DASH:
			if dash_count < max_dashes:
				start_wait(0.4)
			else:
				dash_count = 0
				start_chase()
		BossState.WAIT:
			if dash_count > 0 and dash_count < max_dashes:
				start_dash()
			elif teleport_count > 0 and teleport_count < max_teleports:
				teleport_state()
			else:
				start_chase()
		BossState.SHOOT:
			start_chase()
		BossState.TELEPORT:
			start_chase()

func stop_state() -> void:
	velocity = Vector2.ZERO

func apply_damage(attack: Attack):
	if is_dying:
		return
	
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
		is_dying = true
		is_firing = false

		stop_state()
		
		velocity = Vector2.ZERO
		$CollisionShape2D.set_deferred("disabled", true)
		state_timer.stop()
		await get_tree().create_timer(0.1).timeout
		
		animated_sprite_2d.play("die")
		await animated_sprite_2d.animation_finished
		die()

func show_damage(amount: int, is_critical:bool) -> void:
	if not damage_popup_instance:
		damage_popup_instance = damage_popup_scene.instantiate()
		add_child(damage_popup_instance)
		damage_popup_instance.global_position = global_position + Vector2(0, -20)

	damage_popup_instance.show_damage(amount, is_critical)
	
func die():
	Events.emit_signal("enemy_die", self)
	Events.emit_signal("boss_die", self)
	queue_free()
