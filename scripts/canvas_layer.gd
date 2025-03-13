extends CanvasLayer
#@onready var player: CharacterBody2D = %Player
#@onready var progress_bar: ProgressBar = $ProgressBar
#@onready var label: Label = $Label
#
#
#
#
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#progress_bar.value = player.exp
	#Events.connect("got_exp",_on_got_exp)
#
#
#
#func _on_got_exp( exp, lvl ) -> void:
	#progress_bar.value = exp
	#label.text = "lvl: " + str(lvl)
	#
