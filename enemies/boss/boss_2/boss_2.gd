extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var state_timer: Timer = $Timer
@export var enemy_stats: enemy_type
var direction

enum BossState { CHASE, PREPARE_DASH, DASH, AIMING, SHOOTING_FAN, SHOOTING_CIRCLE, STOP, WAIT }
enum ShootingPattern { FAN, CIRCLE }

var chase: bool = true
var speed: float = 100
var dash_speed: float = 400
var player: CharacterBody2D
var current_state: BossState = BossState.CHASE
var target_position: Vector2
var is_moving: bool = true
var health: float
var dash_count: int = 0
const MAX_DASHES: int = 3
const DASH_WAIT_TIME: float = 0.3

var current_pattern: ShootingPattern = ShootingPattern.FAN
var rotation_offset: float = 0.0

var is_firing: bool = false
var shots_fired_fan: int = 0
const MAX_SHOTS_FAN: int = 3
const SHOT_DELAY_FAN: float = 1.0
const SPREAD_ANGLE: float = 30.0

var shots_fired_circle: int = 0
const MAX_SHOTS_CIRCLE: int = 15
const CIRCLE_RAYS: int = 5

const CHASE_TIME: float = 3.0
const PREPARE_TIME: float = 0.10
const DASH_TIME: float = 0.75
const AIMING_TIME: float = 1.0
const SHOOTING_TIME: float = 0.5
const STOP_TIME: float = 0.1
const WAIT_TIME: float = 0.1

@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var projectile_scene = preload("res://enemies/boss/boss_2/boss_2_projectile.tscn")
@onready var damage_popup_scene = preload("res://enemies/damage_popup.tscn")
var damage_popup_instance: Node = null

var is_dying: bool = false 

func _ready() -> void: 
	health = enemy_stats.health     
	is_dying = false
	current_pattern = ShootingPattern.FAN
	start_chase()

func set_player(p: CharacterBody2D) -> void:
	player = p

func _physics_process(delta: float) -> void:
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
		BossState.SHOOTING_FAN:
			pass 
		BossState.SHOOTING_CIRCLE:
			shooting_circle_state()
		BossState.STOP:
			stop_state()
		BossState.WAIT:
			wait_state()

func chase_state() -> void:
	var direction = (player.position - position).normalized()
	velocity = direction * speed
	move_and_slide()
	update_sprite_direction()

func prepare_dash_state() -> void:
	velocity = Vector2.ZERO
	target_position = player.position
	is_moving = false
	direction = (target_position - position).normalized()

func dash_state() -> void:
	velocity = direction * dash_speed
	move_and_slide()
	update_sprite_direction()

func aiming_state() -> void:
	velocity = Vector2.ZERO
	if current_pattern == ShootingPattern.FAN:
		is_firing = false
		shots_fired_fan = 0
	else:
		shots_fired_circle = 0
		rotation_offset = 0.0

func shooting_fan_state() -> void:
	if not is_firing:
		is_firing = true
		shots_fired_fan = 0
		fire_fan_sequence()

func fire_fan_sequence() -> void:
	if shots_fired_fan < MAX_SHOTS_FAN and is_firing:
		shoot_fan_pattern()
		shots_fired_fan += 1
		
		if shots_fired_fan < MAX_SHOTS_FAN:
			await get_tree().create_timer(SHOT_DELAY_FAN).timeout
			fire_fan_sequence()
		else:
			await get_tree().create_timer(SHOT_DELAY_FAN).timeout
			is_firing = false
			current_state = BossState.STOP
			current_pattern = ShootingPattern.CIRCLE
			start_stop()

func shoot_fan_pattern() -> void:
	if not player:
		return
		
	var direction = (player.position - position).normalized()
	
	spawn_projectile(direction)
	
	var left_direction = direction.rotated(deg_to_rad(-SPREAD_ANGLE))
	spawn_projectile(left_direction)
	
	var right_direction = direction.rotated(deg_to_rad(SPREAD_ANGLE))
	spawn_projectile(right_direction)

func shooting_circle_state() -> void:
	animated_sprite_2d.play("roll") 
	shoot_circle_pattern()
	shots_fired_circle += 1
	
	if shots_fired_circle >= MAX_SHOTS_CIRCLE:
		current_state = BossState.STOP
		animated_sprite_2d.play("idle") 
		current_pattern = ShootingPattern.FAN
		start_stop()
	else:
		current_state = BossState.WAIT
		start_wait()

func shoot_circle_pattern() -> void:
	var angle_step = 360.0 / CIRCLE_RAYS
	var base_angle = rotation_offset
	
	for i in range(CIRCLE_RAYS):
		var angle = base_angle + (i * angle_step)
		var shot_direction = Vector2.RIGHT.rotated(deg_to_rad(angle))
		spawn_projectile(shot_direction)
	
	rotation_offset += 10.0 
	if rotation_offset >= 360.0:
		rotation_offset -= 360.0

func stop_state() -> void:
	velocity = Vector2.ZERO

func wait_state() -> void:
	velocity = Vector2.ZERO

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
	dash_count = 0
	state_timer.start(CHASE_TIME)

func start_prepare_dash() -> void:
	current_state = BossState.PREPARE_DASH
	is_moving = true
	state_timer.start(PREPARE_TIME)

func start_dash() -> void:
	current_state = BossState.DASH
	state_timer.start(DASH_TIME)

func start_aiming() -> void:
	current_state = BossState.AIMING
	state_timer.start(AIMING_TIME)

func start_shooting() -> void:
	if current_pattern == ShootingPattern.FAN:
		current_state = BossState.SHOOTING_FAN
		shooting_fan_state()
		state_timer.start(SHOOTING_TIME * 3 * MAX_SHOTS_FAN)
	else:
		current_state = BossState.SHOOTING_CIRCLE
		state_timer.start(SHOOTING_TIME)

func start_stop() -> void:
	current_state = BossState.STOP
	state_timer.start(STOP_TIME)

func start_wait() -> void:
	current_state = BossState.WAIT
	state_timer.start(WAIT_TIME)

func _on_timer_timeout() -> void:
	match current_state:
		BossState.CHASE:
			start_prepare_dash()
		BossState.PREPARE_DASH:
			start_dash()
		BossState.DASH:
			dash_count += 1
			if dash_count < MAX_DASHES:
				current_state = BossState.STOP
				state_timer.start(DASH_WAIT_TIME)
			else:
				start_aiming()
		BossState.AIMING:
			start_shooting()
		BossState.SHOOTING_FAN:
			if not is_firing:
				start_stop()
		BossState.SHOOTING_CIRCLE:
			pass
		BossState.STOP:
			if dash_count < MAX_DASHES and current_state != BossState.SHOOTING_FAN:
				start_prepare_dash()
			else:
				start_chase()
		BossState.WAIT:
			start_shooting()

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
		
		current_state = BossState.STOP
		velocity = Vector2.ZERO
		$CollisionShape2D.set_deferred("disabled", true)
		state_timer.stop()
		await get_tree().create_timer(STOP_TIME).timeout
		
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
