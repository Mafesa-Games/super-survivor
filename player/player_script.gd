extends CharacterBody2D

@onready var joystick: Node2D = $"../CanvasLayer/Joystick"

const RELOAD_BAR = preload("res://player/reload_bar.tscn")
@onready var animated_sprite_2d: AnimatedSprite2D = %AnimatedSprite2D

var weapons: Array = ["res://weapons_fire/Glock/resourse/pistola_00.tres"]

var direction: Vector2 = Vector2.ZERO
var exp: float = 0
var lvl: int = 1

var max_hp:= 0.0: set = set_max_hp
var hp: float = 0: set = set_hp
var speed: float = 0
var defense: float = 0

var life_steal:float = 0
var attack_speed:float = 0
var critical_chance:float = 0
var critical_multiplier:float = 0
var dodge_chance:float = 0
var hp_regeneration:float = 0
var explosion_damage:float = 0
var explosion_size:float = 0
var pickup_range:float = 0

var damage: float = 0
var is_dead: bool = false

signal player_died

func _ready() -> void:
	damage = global_status.damage
	max_hp = global_status.hp
	speed = global_status.speed
	defense = global_status.defense
	life_steal = global_status.life_steal
	attack_speed = global_status.attack_speed
	critical_chance = global_status.critical_chance
	critical_multiplier = global_status.critical_multiplier
	dodge_chance = global_status.dodge_chance
	hp_regeneration = global_status.hp_regeneration
	explosion_damage = global_status.explosion_damage
	explosion_size = global_status.explosion_size
	pickup_range = global_status.pickup_range
	
	%PickArea/PickAreaShape.shape.radius = pickup_range

	Events.connect("do_damage", _on_recive_damage)
	Events.connect("reload_weapon", _on_reload_wepon)

func _physics_process(delta: float) -> void:
	var overlapping_mobs = %HurtBox.get_overlapping_bodies()
	var direction = joystick.posVector

	if direction.length() > 0:
		direction = direction.normalized()
		if direction.x > 0:
			%AnimatedSprite2D.flip_h = false
		elif direction.x < 0:
			%AnimatedSprite2D.flip_h = true
		
	velocity = direction * speed
	move_and_slide()

	if overlapping_mobs.size() > 0:
		for mob in overlapping_mobs:
			take_damage(mob.enemy_stats.damage * delta)

func stop_weapons():
	for weapon in %Weapons.get_children():
				if weapon.has_method("stop_weapon"):
					weapon.stop_weapon()

func take_damage(damage: float):
	if is_dead:
		return

	hp -= damage
	%HealthBar.value = hp
	
	if hp <= 0:
		is_dead = true
		stop_weapons()
		set_physics_process(false)
		animated_sprite_2d.play("die")
		await animated_sprite_2d.animation_finished
		emit_signal("player_died")
	else:
		animated_sprite_2d.play("hit")
		await animated_sprite_2d.animation_finished
		animated_sprite_2d.play("idle")

func _on_recive_damage(damage) -> void:
	take_damage(damage)

func _on_pick_area_area_entered(area: Area2D) -> void:
	if area.type == "experience":
		get_exp(area)

func get_exp(area: Area2D) -> void:
	exp += area.exp / lvl
	if exp >= 100:
		exp = 0
		lvl += 1
	Events.emit_signal("got_exp", exp, lvl)
	area.queue_free()

func _on_reload_wepon(time) -> void:
	var r_bar = RELOAD_BAR.instantiate()
	add_child(r_bar)
	r_bar.start_fill(time)

func set_max_hp(new_hp:float) -> void:
	var differ := new_hp - max_hp
	max_hp = new_hp
	%HealthBar.max_value = new_hp
	hp += differ

func set_hp(new_hp: float) -> void:
	hp = clamp(new_hp, 0, max_hp)
	%HealthBar.value = hp
	
	var hp_percentage = hp / max_hp
	var style = %HealthBar.get_theme_stylebox("fill")
	if hp_percentage <= 0.1:
		style.bg_color = Color.GREEN 
	else:
		style.bg_color = Color.WHITE

func magnet() -> void:
	var Experience = get_tree().current_scene.find_child("Experience")
	for exp in Experience.get_children():
		get_exp(exp)
