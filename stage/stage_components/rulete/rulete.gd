extends Node2D

var stage: Node2D
var learned_skills = []

const super_granades = "res://weapon_throwable/granade/resourse/super_granade_05.tres"
const super_molotovs = "res://weapon_throwable/molotov/resourse/super_molotov_05.tres"
const super_orbs:= "res://weapon_throwable/rebound_orb/resource/super_orb_5.tres"
const super_fire_balls = "res://weapon_throwable/fire_ball/resourse/super_fire_ball_5.tres"
const super_spining_shields: = "res://weapon_throwable/spining_shield/resourse/super_spining_shield_6.tres"
const super_thunders = "res://weapon_throwable/thunder/resourse/super_thunder_6.tres"

func _ready() -> void:
	stage = get_parent()

func get_active_power_resources() -> Array:	
	var power_indices = {
		"granades": stage.granade_index,
		"molotovs": stage.molotov_index,
		"orbs": stage.orb_index,
		"fire_balls": stage.fire_ball_index,
		"spining_shields": stage.spining_shield_index,
		"thunders": stage.thunder_index
	}
	
	var power_resources = {
		"granades": stage.granades,
		"molotovs": stage.molotovs,
		"orbs": stage.orbs,
		"fire_balls": stage.fire_balls,
		"spining_shields": stage.spining_shields,
		"thunders": stage.thunders
	}
	
	var result = []
	for skill in learned_skills:
		power_indices.erase(skill)
	
	for power in power_indices.keys():
		if power_indices[power] > 0:
			result.append(power_resources[power][0])
	
	return result

@export var hbox_container: HBoxContainer
@export var border_width: float = 2.0
@export var highlight_color: Color = Color(1, 0, 0, 1) 
@export var normal_color: Color = Color(0.5, 0.5, 0.5, 1)
@export var total_duration: float = 6.0
@export var start_interval: float = 0.05
@export var end_interval: float = 0.8

var skill_panels: Array[PanelContainer] = []
var running: bool = false
var selected_index: int = -1

func load_skills(skills: Array) -> void:
	for child in hbox_container.get_children():
		child.queue_free()
	skill_panels.clear()
	
	for skill in skills:
		var panel = PanelContainer.new()
		var style = StyleBoxFlat.new()
		style.border_width_left = border_width
		style.border_width_top = border_width
		style.border_width_right = border_width
		style.border_width_bottom = border_width
		style.border_color = normal_color
		panel.add_theme_stylebox_override("panel", style)

		var icon_rect = TextureRect.new()
		var spell = load(skill)
		
		icon_rect.texture = spell.icon
		icon_rect.custom_minimum_size = Vector2(64, 64)
		icon_rect.expand_mode = TextureRect.SIZE_EXPAND_FILL
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		
		panel.add_child(icon_rect)
		hbox_container.add_child(panel)
		skill_panels.append(panel)

var roulette_window: Window = null

func setup_roulette(skills: Array) -> void:
	if roulette_window:
		roulette_window.queue_free()
	
	# Create a window for the rulette
	roulette_window = Window.new()
	roulette_window.title = "Select Power"
	roulette_window.size = Vector2(400, 150)
	roulette_window.unresizable = true
	add_child(roulette_window)
	
	# Create the main conteiner
	var main_container = VBoxContainer.new()
	roulette_window.add_child(main_container)
	
	# Create a HBoxContainer to the icons
	hbox_container = HBoxContainer.new()
	hbox_container.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox_container.add_theme_constant_override("separation", 10)
	main_container.add_child(hbox_container)
	
	load_skills(skills)
	
	roulette_window.popup_centered()

func start_roulette() -> void:
	get_tree().paused = true
	if running or skill_panels.is_empty():
		return
	
	running = true
	var current_index = 0
	
	# Chose the winner before the animation
	selected_index = randi() % skill_panels.size()
	var total_spins = 3 * skill_panels.size()  # Rulette spins
	var final_index = total_spins + selected_index  # Ensure that it ends in the winner
	
	while current_index <= final_index:
		var progress = float(current_index) / float(final_index)
		var current_interval = lerp(start_interval, end_interval, progress)
		
		for panel in skill_panels:
			var style = panel.get_theme_stylebox("panel") as StyleBoxFlat
			style.border_color = normal_color
		
		var current_style = skill_panels[current_index % skill_panels.size()].get_theme_stylebox("panel") as StyleBoxFlat
		current_style.border_color = highlight_color
		
		await get_tree().create_timer(current_interval).timeout
		current_index += 1
	
	# Get the winning skill
	var winner_skill = skill_panels[selected_index].get_child(0).texture.resource_path 
	add_super_skill(winner_skill)
	
	running = false
	
	await get_tree().create_timer(1).timeout
	get_tree().paused = false
	close_roulette_window()

func close_roulette_window() -> void:
	if roulette_window:
		roulette_window.queue_free()
		roulette_window = null

func add_super_skill(skill_path: String) -> void:
	if "fire_ball" in skill_path:
		learned_skills.append("fire_balls")
		if stage.fire_ball_index == stage.fire_balls.size():
			stage.skills_list.append(super_fire_balls)
			return
		stage.fire_balls.append(super_fire_balls)
	elif "granade" in skill_path:
		learned_skills.append("granades")
		if stage.granade_index == stage.granades.size():
			stage.skills_list.append(super_granades)
			return
		stage.granades.append(super_granades)
	elif "molotov" in skill_path:
		learned_skills.append("molotovs")
		if stage.molotov_index == stage.molotovs.size():
			stage.skills_list.append(super_molotovs)
			return
		stage.molotovs.append(super_molotovs)
	elif "spining_shield" in skill_path:
		learned_skills.append("spining_shields")
		if stage.spining_shield_index == stage.spining_shields.size():
			stage.skills_list.append(super_spining_shields)
			return
		stage.spining_shields.append(super_spining_shields)
	elif "orb" in skill_path:
		learned_skills.append("orbs")
		if stage.orb_index == stage.orbs.size():
			stage.skills_list.append(super_orbs)
			return
		stage.orbs.append(super_orbs)
	elif "thunder" in skill_path:
		learned_skills.append("thunders")
		if stage.thunder_index == stage.thunders.size():
			stage.skills_list.append(super_thunders)
			return
		stage.thunders.append(super_thunders)
	else:
		print("Unknown skill selected:", skill_path)

func lerp(start: float, end: float, weight: float) -> float:
	return start + (end - start) * weight
