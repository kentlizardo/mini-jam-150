class_name Lantern extends StaticBody3D

var FAKE_LIGHT := load("res://scenes/game/fake_light.tscn") as PackedScene
var PROJ_LIGHT := load("res://scenes/game/light_projectile.tscn") as PackedScene
var PROJ_BLUELIGHT := load("res://scenes/game/blue_light_projectile.tscn") as PackedScene

signal transmuted(next_light: Node3D)

enum LanternState {
	UNLIT,
	LIT,
	BLUE,
}

@export var sprite : AnimatedSprite3D

var lantern_state := LanternState.UNLIT:
	set(x):
		if is_instance_valid(light):
			light.queue_free()
		lantern_state = x
		if lantern_state != LanternState.UNLIT:
			light = FAKE_LIGHT.instantiate()
			add_child(light)
		match lantern_state:
			LanternState.LIT:
				sprite.play("lit")
			LanternState.BLUE:
				sprite.play("blue")
			LanternState.UNLIT:
				sprite.play("default")
		last_sender = null
var last_sender : Node3D

var light : FakeLight
var health := 3

var norm_sprite := load("res://assets/textures/light.png") as Texture2D
func damage(damage: int, damage_type: Global.DamageType, source: Node) -> void:
	if damage_type == Global.DamageType.MAGIC:
		if source is LightProjectile:
			if source.normal_sprite.texture == norm_sprite:
				lantern_state = LanternState.LIT
				source.transmuted.emit(self)
			else:
				lantern_state = LanternState.BLUE
			last_sender = source.sender
		else:
			lantern_state = LanternState.BLUE
		source.queue_free()
	else:
		health -= 1
		damage_check()

func damage_check() -> void:
	if health <= 0:
		match lantern_state:
			LanternState.LIT:
				var droplight := PROJ_LIGHT.instantiate() as LightProjectile
				get_parent().add_child(droplight)
				droplight.global_position = global_position
				droplight.sender = last_sender
				transmuted.emit(droplight)
			LanternState.BLUE:
				var droplight := PROJ_BLUELIGHT.instantiate() as LightProjectile
				get_parent().add_child(droplight)
				droplight.global_position = global_position
				droplight.sender = last_sender
		queue_free()

func dispel_light() -> void:
	if lantern_state == LanternState.LIT:
		lantern_state = LanternState.UNLIT

func recall() -> void:
	var droplight := PROJ_LIGHT.instantiate()
	get_parent().add_child(droplight)
	var r : Vector3 = Player.current_player.global_position - global_position
	droplight.global_position = global_position + r.normalized() * 1.0
	droplight.sender = last_sender
	transmuted.emit(droplight)
	lantern_state = LanternState.UNLIT
