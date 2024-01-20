class_name ShakeWeapon extends Node2D

# references:
# https://kidscancode.org/godot_recipes/3.x/2d/screen_shake/index.html
# https://www.youtube.com/watch?v=tu-Qe66AvtY

const DECAY := 0.8
const MAX_OFFSET := Vector2(50, 50)
const MAX_ROLL = 0.4

var noise := FastNoiseLite.new()
var noise_val := 0
var trauma := 0.0
var trauma_power := 3

func _ready() -> void:
	randomize()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.seed = randi()
	noise.fractal_octaves = 2

const SHAKE_FRAME := 1.0 / 15
var _shake_timer := 0.0
func _process(delta: float) -> void:
	if trauma:
		trauma = max(trauma - DECAY * delta, 0)
		_shake_timer += delta
		if _shake_timer > SHAKE_FRAME:
			_shake_timer = 0.0
			_shake()
	else:
		position = Vector2.ZERO
		rotation = 0

func _shake() -> void:
	var amount := pow(trauma, trauma_power)
	noise_val += 1
	rotation = MAX_ROLL * amount * noise.get_noise_2d(noise.seed, noise_val)
	#var half_bounds := MAX_OFFSET * amount / 2
	#position = Vector2(
		#randf_range(-half_bounds.x, half_bounds.x),
		#randf_range(-half_bounds.y, half_bounds.y)
	#)
	position.x = floor(MAX_OFFSET.x * amount * noise.get_noise_2d(noise.seed * 2, noise_val))
	position.y = floor(MAX_OFFSET.y * amount * noise.get_noise_2d(noise.seed * 3, noise_val))

func add_trauma(amount: float) -> void:
	trauma = min(trauma + amount, 1.0)
