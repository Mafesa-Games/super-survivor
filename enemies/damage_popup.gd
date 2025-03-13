extends Node2D

@onready var damage_label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	damage_label.visible = false

func show_damage(amount: int, is_critical: bool) -> void:
	if damage_label.visible:
		animation_player.stop()
		damage_label.visible = false

	if is_critical:
		damage_label.text = str(amount) + " !"
		damage_label.add_theme_color_override("font_color", Color.YELLOW)
		damage_label.add_theme_font_size_override("font_size", 11)
		
		damage_label.add_theme_color_override("font_outline_color", Color.DARK_GOLDENROD)
		damage_label.add_theme_constant_override("outline_size", 3)
	else:
		damage_label.text = str(amount)
		damage_label.add_theme_color_override("font_color", Color.BLACK)
		damage_label.add_theme_font_size_override("font_size", 11)
		
		damage_label.add_theme_color_override("font_outline_color", Color.BLACK)
		damage_label.add_theme_constant_override("outline_size", 2)

	damage_label.visible = true
	animation_player.play("show_damage")
	await animation_player.animation_finished
	damage_label.visible = false
