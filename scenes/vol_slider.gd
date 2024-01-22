extends HSlider

var bus_id := -1

func _ready() -> void:
	bus_id = AudioServer.get_bus_index("Master")
	await get_tree().process_frame
	value = 5

func _on_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_id, linear_to_db(value * 0.01))
