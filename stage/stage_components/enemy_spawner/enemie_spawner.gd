extends Node2D

var monster_distance: int = 250
var monster_angle : float
var random_direction : Vector2

var stage_time:= 0
var player: CharacterBody2D

const ENEMY_SCENE = preload("res://enemies/enemy_scene.tscn")

#enemies
const GREEN_ZOMBIE := "Green Zombie"
const RED_ZOMBIE := "Red Zombie"
const BLUE_ZOMBIE := "Blue Zombie"
const YELLOW_ZOMBIE := "Yellow Zombie"
const BIG_GREEN_ZOMBIE := "Big Green Zombie"
const BIG_RED_ZOMBIE := "Big Red Zombie"
const BIG_BLUE_ZOMBIE := "Big Blue Zombie"
const BIG_YELLOW_ZOMBIE := "Big Yellow Zombie"

const GREEN_RANGE_ZOMBIE := "Green Range Zombie"
const RED_RANGE_ZOMBIE := "Red Range Zombie"
const BLUE_RANGE_ZOMBIE := "Blue Range Zombie"
const YELLOW_RANGE_ZOMBIE := "Yellow Range Zombie"

# Special enemies
const EXPLOSIVE_SLIME = "Explosive Slime"

const BOSS_1 := "Boss 1"
const BOSS_2 := "Boss 2"
const BOSS_3 := "Boss 3"

const ENEMY_SCENES = {
	GREEN_ZOMBIE : preload("res://enemies/common/green_zombie.tscn"),
	RED_ZOMBIE: preload("res://enemies/common/red_zombie.tscn"),
	BLUE_ZOMBIE: preload("res://enemies/common/blue_zombie.tscn"),
	YELLOW_ZOMBIE: preload("res://enemies/common/yellow_zombie.tscn"),
	
	BIG_GREEN_ZOMBIE:  preload("res://enemies/common/green_zombie.tscn"),
	BIG_RED_ZOMBIE: preload("res://enemies/common/red_zombie.tscn"),
	BIG_BLUE_ZOMBIE: preload("res://enemies/common/blue_zombie.tscn"),
	BIG_YELLOW_ZOMBIE: preload("res://enemies/common/yellow_zombie.tscn"),
	GREEN_RANGE_ZOMBIE: preload("res://enemies/range_enemy/green_range_zombie.tscn"),
	RED_RANGE_ZOMBIE: preload("res://enemies/range_enemy/red_range_zombie.tscn"),
	BLUE_RANGE_ZOMBIE: preload("res://enemies/range_enemy/blue_range_zombie.tscn"),
	YELLOW_RANGE_ZOMBIE: preload("res://enemies/range_enemy/yellow_range_zombie.tscn"),
	
	EXPLOSIVE_SLIME : preload("res://enemies/common/explosive/explosive_slime.tscn"),
	
	BOSS_1: preload("res://enemies/boss/boss_1/boss_1.tscn"),
	BOSS_2: preload("res://enemies/boss/boss_2/boss_2.tscn"),
	BOSS_3: preload("res://enemies/boss/boss_3/boss_3.tscn")
	
}
const ENEMY_RESOURCES = {
	GREEN_ZOMBIE: preload("res://enemies/common/green_zombie.tres"),
	RED_ZOMBIE: preload("res://enemies/common/red_zombie.tres"),
	BLUE_ZOMBIE: preload("res://enemies/common/blue_zombie.tres"),
	YELLOW_ZOMBIE: preload("res://enemies/common/yellow_zombie.tres"),
	
	BIG_GREEN_ZOMBIE: preload("res://enemies/common/big_green_zombie.tres"),
	BIG_RED_ZOMBIE: preload("res://enemies/common/big_red_zombie.tres"),
	BIG_BLUE_ZOMBIE: preload("res://enemies/common/big_blue_zombie.tres"),
	BIG_YELLOW_ZOMBIE: preload("res://enemies/common/big_yellow_zombie.tres"),
	
	GREEN_RANGE_ZOMBIE: preload("res://enemies/range_enemy/green_range_zombie.tres"),
	RED_RANGE_ZOMBIE: preload("res://enemies/range_enemy/red_range_zombie.tres"),
	BLUE_RANGE_ZOMBIE: preload("res://enemies/range_enemy/blue_range_zombie.tres"),
	YELLOW_RANGE_ZOMBIE: preload("res://enemies/range_enemy/yellow_range_zombie.tres"),
	
	EXPLOSIVE_SLIME: preload("res://enemies/common/explosive/explosive_slime.tres"),
	
	BOSS_1: preload("res://enemies/boss/boss_1/boss_1.tres"),
	BOSS_2: preload("res://enemies/boss/boss_2/boss_2.tres"),
	BOSS_3: preload("res://enemies/boss/boss_3/boss_3.tres")
	
}


func set_player(p1: CharacterBody2D) -> void : 
	player = p1

func generate_boss(type: String, kill_enemies = false, pause_timer = false):
	if kill_enemies:
		var enemies = get_tree().current_scene.find_child("Enemies")
		for enemie in enemies.get_children():
			enemie.die()
	
	if pause_timer:
		var timer = get_tree().current_scene.find_child("StageTime")
		timer.stop()
	generate_enemy(player.position, type)
	
func enemy_generator(stage_time: int) -> int:
	self.stage_time = stage_time
	var num_enemies = get_enemy_count_based_on_time(stage_time)
	if num_enemies > 0:
		generate_enemies(num_enemies)
	if stage_time == 5 || stage_time == 10 || stage_time == 15:
		#generate_boss(BOSS_3, true, true)
		generate_boss(EXPLOSIVE_SLIME)
		generate_boss(BIG_GREEN_ZOMBIE)
	if stage_time == 35:
		generate_boss(BOSS_1, true, true)
		generate_boss(BIG_GREEN_ZOMBIE)
		generate_boss(BIG_GREEN_ZOMBIE)
		generate_boss(EXPLOSIVE_SLIME)
		generate_boss(EXPLOSIVE_SLIME)
		generate_boss(EXPLOSIVE_SLIME)
		generate_boss(BIG_GREEN_ZOMBIE)
	if stage_time == 40 || stage_time == 50:
		generate_boss(EXPLOSIVE_SLIME)
		generate_boss(EXPLOSIVE_SLIME)
		generate_boss(EXPLOSIVE_SLIME)
		generate_boss(BIG_RED_ZOMBIE)
		generate_boss(BIG_RED_ZOMBIE)
		generate_boss(BIG_RED_ZOMBIE)
	if stage_time == 65:
		generate_boss(BOSS_2, true, true)
		generate_boss(EXPLOSIVE_SLIME)
		generate_boss(EXPLOSIVE_SLIME)
		generate_boss(EXPLOSIVE_SLIME)
		generate_boss(BIG_RED_ZOMBIE)
		generate_boss(BIG_RED_ZOMBIE)
		generate_boss(BIG_RED_ZOMBIE)
	if stage_time == 70 || stage_time == 80:
		generate_boss(BIG_BLUE_ZOMBIE)
		generate_boss(BIG_BLUE_ZOMBIE)
		generate_boss(BIG_BLUE_ZOMBIE)
	if stage_time == 95:
		generate_boss(BOSS_3, true, true)
		generate_boss(EXPLOSIVE_SLIME)
		generate_boss(EXPLOSIVE_SLIME)
		generate_boss(EXPLOSIVE_SLIME)
		generate_boss(EXPLOSIVE_SLIME)
		generate_boss(EXPLOSIVE_SLIME)
		generate_boss(BIG_BLUE_ZOMBIE)
		generate_boss(BIG_BLUE_ZOMBIE)
		generate_boss(BIG_BLUE_ZOMBIE)
	if stage_time == 110 || stage_time == 120 || stage_time == 130:
		generate_boss(BIG_YELLOW_ZOMBIE)
		generate_boss(BIG_YELLOW_ZOMBIE)
		generate_boss(BIG_YELLOW_ZOMBIE)
	if stage_time == 240 || stage_time == 250 || stage_time == 260:
		generate_boss(BIG_YELLOW_ZOMBIE)
		generate_boss(BIG_YELLOW_ZOMBIE)
		generate_boss(BIG_YELLOW_ZOMBIE)
	if stage_time == 360:
		generate_boss(BIG_GREEN_ZOMBIE)
		generate_boss(BIG_RED_ZOMBIE)
		generate_boss(BIG_BLUE_ZOMBIE)
		generate_boss(BIG_YELLOW_ZOMBIE)
	return num_enemies


func get_enemy_count_based_on_time(time: int) -> int:
	if time >= 550:
		return randi() % 50 + 10
	if time >= 500:
		return randi() % 30 + 6
	elif time >= 450:
		return randi() % 20 + 3
	elif time >= 400:
		return randi() % 10
	elif time >= 350:
		return randi() % 4
	elif time >= 340:
		return 30
	elif time >= 247:
		return 3 + randi() % 4
	elif time >= 240:
		return 35
	elif time >= 230:
		return 1
	elif time >= 180:
		return 2
	elif time >= 90:
		return 1
	elif time >= 60:
		return randi() % 2 + 1
	elif time >= 20:
		return 2
	else:
		return 1

func get_enemy_types_with_weights(time: int) -> Dictionary:
	if time >= 350:
		return { RED_ZOMBIE: 15,
				YELLOW_ZOMBIE: 45,
				BLUE_ZOMBIE:20,
				GREEN_RANGE_ZOMBIE: 20
				}
	if time >= 340:
		return { 
			RED_ZOMBIE: 90,
			GREEN_RANGE_ZOMBIE: 10
		}
	elif time >= 247:
		return {
			RED_ZOMBIE:60,
			YELLOW_ZOMBIE:30,
			YELLOW_RANGE_ZOMBIE: 10
		}
	elif time >= 240:
		return {
			GREEN_ZOMBIE: 95,
			YELLOW_RANGE_ZOMBIE: 5
			
		}
	elif time >= 180:
		return {
			BLUE_ZOMBIE: 85,
			YELLOW_ZOMBIE: 5,
			BLUE_RANGE_ZOMBIE: 10
		}
	elif time >= 90:
		return {			
			BLUE_ZOMBIE: 90,
			RED_RANGE_ZOMBIE: 10
		}
	elif time >= 60:
		return {
			GREEN_ZOMBIE: 30,
			RED_ZOMBIE: 60,
			GREEN_RANGE_ZOMBIE: 10
		}
	else:
		return {
			GREEN_ZOMBIE: 99,
			GREEN_RANGE_ZOMBIE: 1
		}

func select_enemy_based_on_weights(weights: Dictionary):
	var total_weight = 0
	var cumulative_table = []
	for key in weights.keys():
		total_weight += weights[key]
		cumulative_table.append({"type": key, "weight": total_weight})

	var random_value = randi() % total_weight
	for entry in cumulative_table:
		if random_value < entry["weight"]:
			return entry["type"]

	return cumulative_table[-1]["type"] 

func generate_enemies(n: int) -> void:
	if !player:
		return
	var root = get_tree().current_scene
	var enemy_weights = get_enemy_types_with_weights(stage_time)
	
	for i in range(n):
		var enemy_type = select_enemy_based_on_weights(enemy_weights)
		generate_enemy(player.position, enemy_type)


func generate_enemy(origin: Vector2, enemy_type: String):
	if not ENEMY_SCENES.has(enemy_type):
		push_error("Enemy type not found: " + enemy_type)
		return
		
	var root = get_tree().current_scene.find_child("Enemies")
	var monster_angle = randf_range(0, PI * 2)
	var monster_pos: Vector2 = Vector2(cos(monster_angle), sin(monster_angle)) * monster_distance
	
	var enemy_scene = ENEMY_SCENES[enemy_type]
	var enemy_stats =  ENEMY_RESOURCES[enemy_type]
	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.enemy_stats = enemy_stats
	enemy_instance.position = monster_pos + origin
	enemy_instance.player = player
	root.call_deferred("add_child", enemy_instance)
