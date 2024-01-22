extends Control

@export var text : RichTextLabel

func _ready() -> void:
	visible = true
	var tw := create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 4.0).from(0.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	await tw.finished
	await get_tree().create_timer(3.0).timeout
	var tw2 := create_tween()
	tw2.tween_property(text, "modulate:a", 0.0, 4.0).from(1.0).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
