class_name ShakeWeapon extends Node2D

# references:
# https://kidscancode.org/godot_recipes/3.x/2d/screen_shake/index.html
# https://www.youtube.com/watch?v=tu-Qe66AvtY

const DECAY := 0.8
const MAX_OFFSET := Vector2(100, 75)
const MAX_ROLL = 0.2

var noise := FastNoiseLite.new()
var noise_val := 0
var trauma := 0.0
var trauma_power := 3

func _ready() -> void:
	randomize()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.seed = randi()
	noise.fractal_octaves = 2

func _process(delta: float) -> void:
	position = Vector2.ZERO
	if trauma:
		trauma = max(trauma - DECAY * delta, 0)
		_shake()

func _shake() -> void:
	var amount := pow(trauma, trauma_power)
	noise_val += 1
	rotation = MAX_ROLL * amount * noise.get_noise_2d(noise.seed, noise_val)
	position.x = floor(MAX_OFFSET.x * amount * noise.get_noise_2d(noise.seed * 2, noise_val))
	position.y = floor(MAX_OFFSET.y * amount * noise.get_noise_2d(noise.seed * 3, noise_val))

func add_trauma(amount: float) -> void:
	trauma = min(trauma + amount, 1.0)
