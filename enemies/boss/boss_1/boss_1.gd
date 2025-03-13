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
var dash_count: int = 0
const MAX_DASHES: int = 3
const DASH_WAIT_TIME: float = 0.3

const CHASE_TIME: float = 3.0
const PREPARE_TIME: float = 0.10
const DASH_TIME: float = 0.75
const AIMING_TIME: float = 0.4
const SHOOTING_TIME: float = 0.5
const STOP_TIME: float = 0.1
const SPREAD_ANGLE: float = 30.0

# Shooting stats
var is_firing: bool = false
var shots_fired: int = 0
const MAX_SHOTS: int = 3
const SHOT_DELAY: float = 1.0

@onready var projectile_scene = preload("res://enemies/boss/boss_1/boss_1_projectile.tscn")
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@onready var damage_popup_scene = preload("res://enemies/damage_popup.tscn")
var damage_popup_instance: Node = null

var is_dying: bool = false 

func _ready() -> void: 
	health = enemy_stats.health     
	is_dying = false
	start_chase()

func set_player(p: CharacterBody2D) -> void:
	player = p

func _physics_process(delta: float) -> void:
	if not player or is_dying:
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
			pass
		BossState.STOP:
			stop_state()

func chase_state() -> void:
	var direction = (player.position - position).normalized()
	velocity = direction * speed
	move_and_slide()
	update_sprite_direction()

func prepare_dash_state() -> void:
	velocity = Vector2.ZERO
	target_position = player.position
	direction = (target_position - position).normalized()
	is_moving = false

func dash_state() -> void:
	velocity = direction * dash_speed
	move_and_slide()
	update_sprite_direction()
	

func aiming_state() -> void:
	velocity = Vector2.ZERO
	# aim animation

func shooting_state() -> void:
	if not is_firing:
		is_firing = true
		shots_fired = 0
		fire_sequence()

func fire_sequence() -> void:
	if shots_fired < MAX_SHOTS and is_firing:
		shoot_single_shot()
		shots_fired += 1
		
		if shots_fired < MAX_SHOTS:
			state_timer.start(SHOT_DELAY)
			await state_timer.timeout
			fire_sequence()
		else:
			state_timer.start(SHOT_DELAY)
			await state_timer.timeout
			is_firing = false
			current_state = BossState.STOP
			start_stop()

func shoot_single_shot() -> void:
	if not player:
		return
		
	var direction = (player.position - position).normalized()
	
	# Central Shoot
	spawn_projectile(direction)
	
	var left_direction = direction.rotated(deg_to_rad(-SPREAD_ANGLE))
	spawn_projectile(left_direction)
	
	var right_direction = direction.rotated(deg_to_rad(SPREAD_ANGLE))
	spawn_projectile(right_direction)

func stop_state() -> void:
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
	current_state = BossState.SHOOTING
	shooting_state()
	state_timer.start(SHOOTING_TIME * 3) 

func start_stop() -> void:
	current_state = BossState.STOP
	state_timer.start(STOP_TIME)

func _on_timer_timeout() -> void:
	if is_firing: 
		return
	
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
		BossState.STOP:
			if dash_count < MAX_DASHES:
				start_prepare_dash()
			else:
				start_chase()
		BossState.SHOOTING:
			if not is_firing:
				start_stop()

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
		
		state_timer.start(STOP_TIME)
		await state_timer.timeout
		
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
