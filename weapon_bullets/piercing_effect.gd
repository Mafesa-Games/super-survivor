extends Node2D

var direction: Vector2
var speed: float = 600
var attack: Attack
var body: Node2D
var gravity_force: float = -0.8
var life_timer: float = 0.0
var life_time_after_bounce: float = 3.6

#var impact_color: Color = Color("00ff2e")
var impact_color: Color = Color("3be60c71")
var transition_color: Color = Color("00ff67")
var final_color: Color = Color("8428ff")
var initial_speed: float = speed

var weapon: Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var bullet_sprite: Sprite2D = $BulletSprite
@onready var bullet_ray: Sprite2D = $BulletRay
#@onready var bullet_ray: PointLight2D = $PointLight2D

@export var piercing_effect_scene: PackedScene = preload("res://weapon_bullets/piercing_effect.tscn")
@export var rebonuce_effect_scene: PackedScene = preload("res://weapon_bullets/rebounce_effect.tscn")

#@onready var piercing_light_1: PointLight2D = $piercing_light_1
#@onready var piercing_light_2: PointLight2D = $piercing_light_2
#@onready var piercing_light_3: PointLight2D = $piercing_light_3
#@onready var piercing_light_4: PointLight2D = $piercing_light_4
#@onready var piercing_light_5: PointLight2D = $piercing_light_5

@onready var piercing_light_1: Sprite2D = $piercing_light_1
@onready var piercing_light_2: Sprite2D = $piercing_light_2
@onready var piercing_light_3: Sprite2D = $piercing_light_3
@onready var piercing_light_4: Sprite2D = $piercing_light_4
@onready var piercing_light_5: Sprite2D = $piercing_light_5



func _ready() -> void:
	piercing_light_1.visible = false
	piercing_light_2.visible = false
	piercing_light_3.visible = false
	piercing_light_4.visible = false
	piercing_light_5.visible = false


func activate(direction: Vector2, speed: float, position: Vector2, rotation: float, attack: Attack, body: Node2D) -> void:
	self.position = position
	self.direction = direction
	self.speed = speed
	#self.speed = speed + randf_range(2000, 6000)
	self.rotation = rotation
	self.attack = attack
	self.body = body
	#randomize_direction()
	change_color()
	
	animation_player = $AnimationPlayer
	var animations = ["piercing_light_1", "piercing_light_2", "piercing_light_3", "piercing_light_4","piercing_light_5"]
	var selected_animation = animations[randi() % animations.size()]
	animation_player.play(selected_animation)

		#animation_player = $AnimationPlayer
		#var animations = ["impact_light_1", "impact_light_2", "impact_light_3", "impact_light_4"]
		#var selected_animation = animations[randi() % animations.size()]
		#animation_player.play(selected_animation)

func randomize_direction() -> void:
	var angle = randf_range(-PI / 17.2, PI / 17.2) # rebounce angle
	direction = direction.rotated(angle)
	rotation = direction.angle()

func change_color() -> void:
	bullet_sprite = $BulletSprite
	bullet_ray = $BulletRay
	
	bullet_sprite.modulate = impact_color
	bullet_ray.modulate = impact_color

func _physics_process(delta: float) -> void:
	bullet_sprite = $BulletSprite
	bullet_ray = $BulletRay

	var movement = direction * speed * delta
	position += movement

	#gravity_force = randf_range(-0.8, -4.8)
	if direction.y < 0:
		direction.y += gravity_force * delta
	else:
		direction.y -= gravity_force * delta

	#speed *= randf_range(0.75, 0.95)
	life_timer += delta

	# Transición de colores basada en la velocidad
	var t: float = speed / initial_speed
	var color: Color
	if t > 0.5:
		color = impact_color.lerp(transition_color, (1 - (t - 1) * 1))
	else:
		color = transition_color.lerp(final_color, (1 - t * 4))

	bullet_sprite.modulate = color
	bullet_ray.modulate = color  # Cambiar el color de la luz
	#bullet_ray.energy = max(0, bullet_ray.energy - delta * 2)
	
	piercing_light_1.modulate = color
	#piercing_light_1.energy = max(0, piercing_light_1.energy - delta * 2)
	
	piercing_light_2.modulate = color
	#piercing_light_2.energy = max(0, piercing_light_2.energy - delta * 2)
	
	piercing_light_3.modulate = color
	#piercing_light_3.energy = max(0, piercing_light_3.energy - delta * 2)
	
	piercing_light_4.modulate = color
	#piercing_light_4.energy = max(0, piercing_light_4.energy - delta * 2)
	
	piercing_light_5.modulate = color
	#piercing_light_5.energy = max(0, piercing_light_5.energy - delta * 2)
	

	if life_timer >= life_time_after_bounce:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body and body.has_method("apply_damage") and body != self.body:
		if randi_range(1, 100) > body.enemy_stats.rebanuce_chance:
			body.apply_damage(attack)
			if body and randi_range(1,100) > body.enemy_stats.penetration_resistence and attack.damage > 5:
				attack.damage = attack.damage * 0.9
			else:
				call_deferred("queue_free")
		else:
			var rebounce_effect = rebonuce_effect_scene.instantiate()
			get_parent().call_deferred("add_child", rebounce_effect)
			rebounce_effect.activate(direction, speed, position, rotation, attack)
			call_deferred("queue_free")
