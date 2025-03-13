extends ProgressBar

var duration: float = 5.0
var elapsed_time: float = 0.0
var is_filling: bool = false


func start_fill(time: float) -> void:
	duration = time
	elapsed_time = 0.0
	value = 0
	is_filling = true

func _process(delta: float) -> void:
	if is_filling:
		elapsed_time += delta
		value = lerp(0, 100, elapsed_time / duration)
		if elapsed_time >= duration:
			value = 100
			is_filling = false
			self.queue_free()
