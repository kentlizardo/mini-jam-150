class_name PersonalLightSprite extends Sprite2D

const HIT_POS := Vector2(-59, 31)

var target_position := Vector2.ZERO

const FRAME_LENGTH := 1.0 / 30.0
var anim_delta := 0.0
func _process(delta: float) -> void:
	anim_delta += delta
	if anim_delta >= FRAME_LENGTH:
		anim_delta = 0.0
		position = target_position
