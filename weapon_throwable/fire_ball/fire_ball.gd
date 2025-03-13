extends Area2D

const EXPLOTION = preload("res://weapon_throwable/fire_ball/explosion.tscn")

var last_position: Vector2
var direction: Vector2

var attack: Attack
var speed: float = 50

var critical_chance: float
var critical_damage: float

var hit_enemies: Array = []

var projectile_lifetime: float = 3.0

var makes_piercing: bool = false
var piercing_times: int = 0

var makes_bounce: bool = false
var bounce_times: int = 0

var makes_explosion: bool = false
var explosion_damage: float = 0
var explosion_times: int = 0
var explosion_area: float = 0

var colors := [
	Color.DARK_ORANGE,
	Color.SADDLE_BROWN,
	Color.CHOCOLATE,
	Color.WEB_PURPLE
]
var color_index := 0
var color_time := 0.05
var color_speed := 0.4

func _ready() -> void:
	
	last_position = global_position
	$Sprite2D.modulate = colors[color_index]
	$GPUParticles2D3.emitting = false
	$Timer.wait_time = projectile_lifetime
	$Timer.start()
	
func activate(
	direction: Vector2, 
	position: Vector2, 
	attack: Attack,
	critical_chance:float,
	critical_damage:float,
	speed: float, 
	lifetime: float,
	piercing: bool,
	piercing_count: int,
	bounce: bool,
	bounce_count: int,
	explode: bool,
	explosion_dmg: float,
	explosion_count: int,
	explosion_radius: float
) -> void:
	self.global_position = position
	self.direction = direction
	self.attack = attack
	self.critical_chance = critical_chance
	self.critical_damage = critical_damage
	self.speed = speed
	self.projectile_lifetime = lifetime
	
	self.makes_piercing = piercing
	self.piercing_times = piercing_count
	
	self.makes_bounce = bounce
	self.bounce_times = bounce_count
	
	self.makes_explosion = explode
	self.explosion_damage = explosion_dmg
	self.explosion_times = explosion_count
	self.explosion_area = explosion_radius

	$Timer.wait_time = projectile_lifetime
	

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	update_color(delta)

func update_color(delta: float) -> void:
	color_time += delta
	if color_time >= color_speed:
		color_time = 0.0  
		color_index = (color_index + 1) % colors.size()  
	var current_color = colors[color_index]
	var next_color = colors[(color_index + 1) % colors.size()]
	var t = color_time / color_speed
	$Sprite2D.modulate = current_color.lerp(next_color, t)
	

func _on_body_entered(body: Node2D) -> void:
	if body and body.has_method("apply_damage") and body not in hit_enemies:
		body.apply_damage(attack)
		hit_enemies.append(body)

		if makes_explosion:
			call_deferred("_spawn_explosion", attack)

		if !makes_piercing or piercing_times <= 0:
			speed = 0
			$Sprite2D.visible = false
			$GPUParticles2D.visible = false
			$GPUParticles2D2.visible = false
			$GPUParticles2D3.emitting = true
			call_deferred("_disable_collision_shape")
			$Timer.start(0.8)
		else:
			piercing_times -= 1
			

func explode(attack:Attack):
	call_deferred("_spawn_explosion")

func _spawn_explosion(attack:Attack):
	attack.damage =  attack.player_damage * explosion_damage / 100
	
	var explosion_instance = EXPLOTION.instantiate()
	explosion_instance.position = position
	explosion_instance.activate(attack, explosion_times, explosion_area)
	get_parent().add_child(explosion_instance)

func _disable_collision_shape() -> void:
	$CollisionShape2D.disabled = true

func _on_timer_timeout() -> void:
	queue_free()
