extends BaseStage


@onready var play_games_sign_in_client: PlayGamesSignInClient = %PlayGamesSignInClient
var first_request:= true
func _enter_tree() -> void:
	GodotPlayGameServices.initialize()

func _ready() -> void:
	%Player.player_died.connect(_on_player_died)
	Events.connect("enemy_die", _on_enemy_die)
	Events.connect("got_exp",_on_got_exp)
	Events.connect("boss_die",_on_boss_die)
	
	skills_list.append(granades[granade_index])
	skills_list.append(molotovs[molotov_index])
	skills_list.append(orbs[orb_index])
	skills_list.append(fire_balls[fire_ball_index])
	skills_list.append(spining_shields[spining_shield_index])
	skills_list.append(thunders[thunder_index])
	
	skills_left_to_learn.append(granades[granade_index])
	skills_left_to_learn.append(molotovs[molotov_index])
	skills_left_to_learn.append(orbs[orb_index])
	skills_left_to_learn.append(fire_balls[fire_ball_index])
	skills_left_to_learn.append(spining_shields[spining_shield_index])
	skills_left_to_learn.append(thunders[thunder_index])
	
	%ProgressBar.value = %Player.exp
	%EnemieSpawner.set_player(%Player)
	create_simple_weapon_menu()
	
	%HTTPRequest.request_completed.connect(_on_request_completed)
	if not GodotPlayGameServices.android_plugin:
		print("Plugin Not Found!")
	else:
		play_games_sign_in_client.sign_in()


func _on_player_died() -> void:
	death_menu()

func death_menu():
	get_tree().paused = true
	%Window.popup_centered()
	%Window.visible = true
	
	var weapons_node = %Player.find_child("Weapons")
	var weapons = weapons_node.get_children()
	
	var weapon_display = %Window.get_node_or_null("WeaponDisplay")
	if weapon_display == null:
		weapon_display = VBoxContainer.new()
		weapon_display.name = "WeaponDisplay"
		%Window.get_node("VBoxContainer").add_child(weapon_display)
	
	for child in weapon_display.get_children():
		child.queue_free()
	
	for weapon in weapons:
		var weapon_row = HBoxContainer.new()
		weapon_display.add_child(weapon_row)
		
		var weapon_icon = TextureRect.new()
		if weapon.icon is CompressedTexture2D:
			weapon_icon.texture = weapon.icon
		weapon_icon.custom_minimum_size = Vector2(64, 64)
		weapon_icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		weapon_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		weapon_row.add_child(weapon_icon)
		
		var weapon_label_name = Label.new()
		weapon_label_name.text = weapon.name if weapon.name else "Unknown Weapon"
		weapon_row.add_child(weapon_label_name)
		
		var text = Label.new()
		text.text = "--->  Damage done: "
		weapon_row.add_child(text)
		var weapon_label_damage = Label.new()
		weapon_label_damage.text = str(weapon.damage_done) if "damage_done" in weapon else "0"
		weapon_row.add_child(weapon_label_damage)
	
	%Window/VBoxContainer/PlayAgain.pressed.connect(func(): 
		get_tree().paused = false
		get_tree().reload_current_scene()
	)
	
	%Window/VBoxContainer/MainMenu.pressed.connect(func(): 
		get_tree().paused = false
	)
	
func _on_stage_time_timeout() -> void:
	stage_time += 1
	var minutes = stage_time / 60
	var seconds = stage_time % 60
	
	spawned_count += %EnemieSpawner.enemy_generator(stage_time)
	%GameTimer.text = str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2)
	%EnemiesSpawned.text = "enemies: " + str(spawned_count)
	%ItemSpawner.spawn_item()

func select_weapon(weapon_name: String) -> void:
	var weapon_instance
	if weapon_name == "glock":
		weapon_instance = weapon_glock.instantiate()
		weapon_instance.weapon_resorce = load(weapon_glocks[0])
		weapon_glock_index = 1
		skills_list.append(weapon_glocks[weapon_glock_index])
	else:  # katana
		weapon_instance = weapon_sword.instantiate()
		weapon_instance.weapon_resorce = load(weapon_swords[0])
		weapon_sword_index = 1
		skills_list.append(weapon_swords[weapon_sword_index])
	
	#%Player.add_child(weapon_instance)
	%Player.find_child("Weapons").add_child(weapon_instance)
	%SelectWeaponWindow.queue_free()
	get_tree().paused = false

func create_simple_weapon_menu() -> void:
	var vbox = VBoxContainer.new()
	%SelectWeaponWindow.add_child(vbox)
	
	var glock_button = Button.new()
	glock_button.text = "Glock"
	glock_button.pressed.connect(func(): select_weapon("glock"))
	vbox.add_child(glock_button)
	
	var katana_button = Button.new()
	katana_button.text = "sword"
	katana_button.pressed.connect(func(): select_weapon("sword"))
	vbox.add_child(katana_button)
	
	%SelectWeaponWindow.popup_centered()
	%SelectWeaponWindow.visible = true
	


func _on_user_authenticated(is_authenticated: bool) -> void:
	play_games_sign_in_client.request_server_side_access("262369909138-4ttj127a8ts5sehn730nf7tsthce9623.apps.googleusercontent.com",false)


func _on_server_authenticated(code: String) -> void:
	var data = {"code":code}
	var json = JSON.stringify(data)
	var headers = ["Content-Type: application/json"]
	%HTTPRequest.request("https://super-survival-server-production.up.railway.app/api/log-in", headers, HTTPClient.METHOD_POST, json)
	print(code)


func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json)
	if first_request:
		first_request = false
		var jwt = "Authorization: Bearer " + json.jwtToken
		var headers2 = ["Content-Type: application/json", jwt]
		%HTTPRequest.request("https://super-survival-server-production.up.railway.app/api/auth/player", headers2)
	else:
		%Player.damage = json.attack
		%Player.max_hp = json.hp
		%Player.critical_chance = json.criticalChance
		%Player.critical_multiplier = json.criticalMultiplier
