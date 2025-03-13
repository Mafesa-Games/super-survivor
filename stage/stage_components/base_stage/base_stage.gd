extends Node
class_name BaseStage

const MAX_SKILLS := 5

#pickeables
const EXPERIENCE_SCENE = preload("res://drops/experience_scene.tscn")
const GREEN_EXP = preload("res://drops/experience/green_exp.tres")
const BOSS_SUPER_SKILL = preload("res://drops/boss_super_skill/boss_super_skill.tscn")


var stage_time:= 0

var killed_count:= 0
var spawned_count:= 0
var current_lvl:= 1

var weapon_glock_index: int = 0
var weapon_sword_index: int = 0

var granade_index: int = 0
var molotov_index:int = 0
var orb_index: int = 0
var fire_ball_index: int = 0
var spining_shield_index: int = 0
var thunder_index: int = 0

var lvls_up:= 0
var skills_left_to_learn: Array

var weapon_glock  = preload("res://weapons_fire/Glock/weapon.tscn") # weapon 1
var weapon_sword = preload("res://weapons_fire/sword/sword.tscn") # weapon 2

const weapon_glocks: Array = ["res://weapons_fire/Glock/resourse/pistola_01.tres","res://weapons_fire/Glock/resourse/pistola_02.tres","res://weapons_fire/Glock/resourse/pistola_03.tres","res://weapons_fire/Glock/resourse/pistola_04.tres","res://weapons_fire/Glock/resourse/pistola_05.tres"]
const weapon_swords: Array = ["res://weapons_fire/sword/resourse/katana_00.tres","res://weapons_fire/sword/resourse/katana_01.tres","res://weapons_fire/sword/resourse/katana_02.tres","res://weapons_fire/sword/resourse/katana_03.tres","res://weapons_fire/sword/resourse/katana_04.tres"]


# pasive skills
var skills_list: Array = ["res://spells/stage_spells/hp_100.tres","res://spells/stage_spells/speed_20.tres"]
# Throwable weapons and their respective level-up resources. 
# We instance the throwable weapon on the %Player. >>> _on_skill_selected function
const MOLOTOV_WEAPON = preload("res://weapon_throwable/molotov/molotov_weapon.tscn")
const GRANADE_WEAPON = preload("res://weapon_throwable/granade/granade_weapon.tscn")

const ORB = preload("res://weapon_throwable/rebound_orb/orb_weapon.tscn")
const FIRE_BALL_WEAPON = preload("res://weapon_throwable/fire_ball/fire_ball_weapon.tscn")
const THUNDER = preload("res://weapon_throwable/thunder/thunder_weapon.tscn")
const SPINING_SHIELD_WEAPON = preload("res://weapon_throwable/spining_shield/spining_shield_weapon.tscn")

var granades: Array = ["res://weapon_throwable/granade/resourse/granade_01.tres","res://weapon_throwable/granade/resourse/granade_02.tres","res://weapon_throwable/granade/resourse/granade_03.tres","res://weapon_throwable/granade/resourse/granade_04.tres","res://weapon_throwable/granade/resourse/granade_05.tres"]
var molotovs: Array = ["res://weapon_throwable/molotov/resourse/molotov_00.tres","res://weapon_throwable/molotov/resourse/molotov_01.tres","res://weapon_throwable/molotov/resourse/molotov_02.tres","res://weapon_throwable/molotov/resourse/molotov_03.tres","res://weapon_throwable/molotov/resourse/molotov_04.tres"]
var orbs: Array = ["res://weapon_throwable/rebound_orb/resource/orb_0.tres","res://weapon_throwable/rebound_orb/resource/orb_1.tres","res://weapon_throwable/rebound_orb/resource/orb_2.tres","res://weapon_throwable/rebound_orb/resource/orb_3.tres","res://weapon_throwable/rebound_orb/resource/orb_4.tres"]
var fire_balls: Array = ["res://weapon_throwable/fire_ball/resourse/fire_ball_0.tres","res://weapon_throwable/fire_ball/resourse/fire_ball_1.tres","res://weapon_throwable/fire_ball/resourse/fire_ball_2.tres","res://weapon_throwable/fire_ball/resourse/fire_ball_3.tres","res://weapon_throwable/fire_ball/resourse/fire_ball_4.tres"]
var spining_shields: Array=["res://weapon_throwable/spining_shield/resourse/spining_shield_1.tres","res://weapon_throwable/spining_shield/resourse/spining_shield_2.tres","res://weapon_throwable/spining_shield/resourse/spining_shield_3.tres","res://weapon_throwable/spining_shield/resourse/spining_shield_4.tres","res://weapon_throwable/spining_shield/resourse/spining_shield_5.tres"]
var thunders: Array = ["res://weapon_throwable/thunder/resourse/thunder_1.tres","res://weapon_throwable/thunder/resourse/thunder_2.tres","res://weapon_throwable/thunder/resourse/thunder_3.tres","res://weapon_throwable/thunder/resourse/thunder_4.tres","res://weapon_throwable/thunder/resourse/thunder_5.tres"]


func _process(_delta) -> void:
	if lvls_up > 0:
		_on_level_up()
		lvls_up -= 1

func _on_level_up() -> void:
	get_tree().paused = true
	if skills_left_to_learn.size() <= skills_list.size() - 3 - MAX_SKILLS:
		for skill in skills_left_to_learn:
			skills_list.erase(skill)
	
	var random_skills = [] 
	while random_skills.size() < min(3, skills_list.size()): 
		var skill = skills_list[randi() % skills_list.size()] 
		if not random_skills.has(skill): 
			random_skills.append(skill)

	clear_children(%LevelUpWindow)
	
	var padding_container = MarginContainer.new()
	padding_container.add_theme_constant_override("margin_left", 20)
	padding_container.add_theme_constant_override("margin_right", 20)
	padding_container.add_theme_constant_override("margin_top", 20)
	padding_container.add_theme_constant_override("margin_bottom", 20)
	%LevelUpWindow.add_child(padding_container)
	
	var main_container = VBoxContainer.new()
	padding_container.add_child(main_container)
	main_container.custom_minimum_size = Vector2(300, 0)
	
	var title = Label.new()
	title.text = "LEVEL UP!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	title.custom_minimum_size = Vector2(0, 60)
	main_container.add_child(title)
	
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	main_container.add_child(spacer)
	
	var skills_container = VBoxContainer.new()
	skills_container.add_theme_constant_override("separation", 10)
	main_container.add_child(skills_container)
	
	for skill in random_skills:
		var panel = PanelContainer.new()
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.2, 0.2, 0.2, 0.9)
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		style.border_color = Color.REBECCA_PURPLE
		style.corner_radius_top_left = 2
		style.corner_radius_top_right = 2
		style.corner_radius_bottom_left = 2
		style.corner_radius_bottom_right = 2
		style.content_margin_left = 4
		style.content_margin_right = 4
		style.content_margin_top = 4
		style.content_margin_bottom = 4
		panel.add_theme_stylebox_override("panel", style)
		skills_container.add_child(panel)
		
		var skill_content = HBoxContainer.new()
		panel.add_child(skill_content)
		
		var spell = load(skill)
		
		var icon_rect = TextureRect.new()
		icon_rect.texture = spell.icon
		icon_rect.custom_minimum_size = Vector2(64, 64)
		icon_rect.expand_mode = TextureRect.SIZE_EXPAND_FILL
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		skill_content.add_child(icon_rect)
		
		var icon_spacer = Control.new()
		icon_spacer.custom_minimum_size = Vector2(10, 0)
		skill_content.add_child(icon_spacer)
		
		var skill_name = Label.new()
		skill_name.text = spell.name
		skill_name.add_theme_font_size_override("font_size", 16)
		skill_name.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		skill_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		skill_content.add_child(skill_name)
		
		panel.gui_input.connect(func(event): 
			if event is InputEventMouseButton:
				if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
					_on_skill_selected.call(skill)
		)
		
		panel.mouse_entered.connect(func():
			style.bg_color = Color(0.3, 0.3, 0.3, 0.9)
			panel.add_theme_stylebox_override("panel", style)
		)
		
		panel.mouse_exited.connect(func():
			style.bg_color = Color(0.2, 0.2, 0.2, 0.9)
			panel.add_theme_stylebox_override("panel", style)
		)
		
	%LevelUpWindow.popup_centered()
	%LevelUpWindow.grab_focus()

func find_child_by_name(parent: Node, child_name: String) -> Node:
	for child in parent.get_children():
		if child.name == child_name:
			return child
	return null

func _on_skill_selected(skill_path: String) -> void:
	var spell = load(skill_path)
	if spell.name == "Glock":
		
		skills_list.erase(skill_path)
		var Glock = find_child_by_name(%Player/Weapons,"Glock")
		Glock.weapon_resorce = spell
		weapon_glock_index += 1
		if weapon_glock_index < weapon_glocks.size():
			skills_list.append(weapon_glocks[weapon_glock_index])
		
	elif spell.name == "sword":
		
		skills_list.erase(skill_path)
		var sword = find_child_by_name(%Player/Weapons,"Sword")
		sword.weapon_resorce = spell
		weapon_sword_index += 1
		if weapon_sword_index < weapon_swords.size():
			skills_list.append(weapon_swords[weapon_sword_index])
		
	elif spell.name == "Granade":
		skills_list.erase(skill_path)
		if granade_index == 0:
			skills_left_to_learn.erase(granades[granade_index])
			var weapon_instance = GRANADE_WEAPON.instantiate()
			weapon_instance.weapon_resorce = spell
			weapon_instance.type = 0
			weapon_instance.name = "Granade"
			#%Player.add_child(weapon_instance)
			%Player.find_child("Weapons").add_child(weapon_instance)
		else:
			var granade = find_child_by_name(%Player/Weapons,"Granade")
			granade.weapon_resorce = spell
		granade_index += 1
		if granade_index < granades.size():
			skills_list.append(granades[granade_index])
		
	elif spell.name == "Orb":
		
		skills_list.erase(skill_path)
		if orb_index == 0:
			skills_left_to_learn.erase(orbs[orb_index])
			var weapon_instance = ORB.instantiate()
			weapon_instance.weapon_resorce = spell
			weapon_instance.name = "Orb"
			%Player.find_child("Weapons").add_child(weapon_instance)
		else:
			var orb = find_child_by_name(%Player/Weapons,"Orb")
			orb.weapon_resorce = spell
		orb_index += 1
		if orb_index < orbs.size():
			skills_list.append(orbs[orb_index])
		
	elif spell.name == "Fire Ball":
		
		skills_list.erase(skill_path)
		if fire_ball_index == 0:
			skills_left_to_learn.erase(fire_balls[fire_ball_index])
			var weapon_instance = FIRE_BALL_WEAPON.instantiate()
			weapon_instance.weapon_resorce = spell
			weapon_instance.name = "Fire Ball"
			%Player.find_child("Weapons").add_child(weapon_instance)
		else:
			var fire_ball = find_child_by_name(%Player/Weapons,"Fire Ball")
			fire_ball.weapon_resorce = spell
		fire_ball_index += 1
		if fire_ball_index < fire_balls.size():
			skills_list.append(fire_balls[fire_ball_index])
		
	elif spell.name == "Spining Shield":
		skills_list.erase(skill_path)
		if spining_shield_index == 0:
			skills_left_to_learn.erase(spining_shields[spining_shield_index])
			var weapon_instance = SPINING_SHIELD_WEAPON.instantiate()
			weapon_instance.weapon_resorce = spell
			weapon_instance.name = "Spining Shield"
			%Player.find_child("Weapons").add_child(weapon_instance)
		else:
			var spining_shield = find_child_by_name(%Player/Weapons,"Spining Shield")
			spining_shield.weapon_resorce = spell
			spining_shield.update_weapon_stats()
		spining_shield_index += 1
		if spining_shield_index < spining_shields.size():
			skills_list.append(spining_shields[spining_shield_index])
			
	elif spell.name == "thunder":
		
		skills_list.erase(skill_path)
		if thunder_index == 0:
			skills_left_to_learn.erase(thunders[thunder_index])
			var weapon_instance = THUNDER.instantiate()
			weapon_instance.weapon_resorce = spell
			weapon_instance.name = "thunder"
			%Player.find_child("Weapons").add_child(weapon_instance)
		else:
			var thunder = find_child_by_name(%Player/Weapons,"thunder")
			thunder.weapon_resorce = spell
			#orbit_orb.update_weapon_stats()
		thunder_index += 1
		if thunder_index < thunders.size():
			skills_list.append(thunders[thunder_index])
	elif spell.name == "Molotov":
		
		skills_list.erase(skill_path)
		if molotov_index == 0:
			skills_left_to_learn.erase(molotovs[molotov_index])
			var weapon_instance = MOLOTOV_WEAPON.instantiate()
			weapon_instance.weapon_resorce = spell
			weapon_instance.type = 1
			weapon_instance.name = "Molotov"
			%Player.find_child("Weapons").add_child(weapon_instance)
		else:
			var molotov = find_child_by_name(%Player/Weapons,"Molotov")
			molotov.weapon_resorce = spell
		molotov_index += 1
		if molotov_index < molotovs.size():
			skills_list.append(molotovs[molotov_index])
		
	else:
		%Player.max_hp += spell.hp
		%Player.speed += spell.speed
		%Player.defense += spell.defense
		%Player.life_steal += spell.life_steal
		%Player.attack_speed+= spell.attack_speed
		%Player.critical_chance += spell.critical_chance
		%Player.critical_multiplier += spell.critical_multiplier
		%Player.dodge_chance+= spell.dodge_chance
		%Player.hp_regeneration += spell.hp_regeneration
		%Player.explosion_damage += spell.explosion_damage
		%Player.explosion_size += spell.explosion_size
		%Player.pickup_range += spell.pickup_range
		%Player.damage += spell.damage
	
	get_tree().paused = false
	%LevelUpWindow.hide()

func clear_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()

func _on_got_exp(exp, lvl) -> void:
	%ProgressBar.value = exp
	%Label.text = "lvl: " + str(lvl)
	if lvl > current_lvl:
		current_lvl = lvl
		lvls_up += 1

func _on_boss_die(boss) -> void:
	%StageTime.start(1)
	var rulete = BOSS_SUPER_SKILL.instantiate()
	rulete.position = boss.position
	add_child(rulete)

func _on_enemy_die(enemy) -> void:
	var exp_instance = EXPERIENCE_SCENE.instantiate()
	exp_instance.exp_resource = GREEN_EXP
	exp_instance.position = enemy.position
	exp_instance.exp = enemy.enemy_stats.exp
	%Experience.add_child(exp_instance)
	
	killed_count += 1
	%EnemiesKilled.text = "killed: " + str(killed_count)
