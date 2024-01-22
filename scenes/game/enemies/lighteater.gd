extends CharacterBody3D

enum BirdState {
	SEARCH,
	ABSORB,
	SHOOT,
}

const SPEED = 5.0

@export var sprite: AnimatedSprite3D
@export var vision: Vision

var drive_vector := Vector3.ZERO
var absorb_timer := 0.0
var health := 2
var ammo := 0
const ABSORB_LENGTH := 1.0

var state : BirdState = BirdState.SEARCH:
	set(x):
		state = x
		match state:
			BirdState.SEARCH:
				sprite.play("default")
			BirdState.ABSORB:
				sprite.play("absorb")
				await sprite.animation_finished
				next_state(BirdState.SHOOT)
			BirdState.SHOOT:
				sprite.play("shoot")
				await sprite.animation_finished
				shoot()
				next_state(BirdState.SEARCH)

func _next_state(s: BirdState) -> void:
	state = s
func next_state(s: BirdState) -> void:
	_next_state.call_deferred(s)

func _physics_process(delta: float) -> void:
	var direction := drive_vector.normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()

func _process(delta: float) -> void:
	if state == BirdState.SEARCH:
		var light_target : Node3D
		var light_dist := INF
		var player_target : Player
		for i in vision.seen:
			var dist := i.global_position.distance_to(global_position)
			if i is Player:
				player_target = i
			if i is LightProjectile:
				if i.sender != self:
					if dist < light_dist:
						light_target = i
						light_dist = dist 
			if i is Lantern:
				if i.lantern_state != Lantern.LanternState.UNLIT:
					if dist < light_dist:
						light_target = i
						light_dist = dist
		if light_target:
			drive_vector = (light_target.global_position - global_position).normalized()
		else:
			if player_target:
				drive_vector = -(player_target.global_position - global_position).normalized()
	else:
		drive_vector = Vector3.ZERO

func shoot() -> void:
	var target : Node3D
	for i in vision.seen:
		if i is Player:
			target = i
	if target:
		var proj_temp := load("res://scenes/game/bird_light_projectile.tscn") as PackedScene
		var proj := proj_temp.instantiate() as BirdLightProjectile
		proj.sender = self
		var move := Vector3(target.global_position - global_position)
		get_parent().add_child(proj)
		proj.global_position = global_position + move.normalized() * 1.0
		proj.apply_central_impulse(move.normalized() * BirdLightProjectile.HIT_SPEED)

func damage(damage: int, damage_type: Global.DamageType, source: Node) -> void:
	if damage_type == Global.DamageType.MAGIC:
		if state == BirdState.SEARCH:
			next_state(BirdState.ABSORB)
		source.queue_free()
	else:
		health -= damage
		damage_check()

func damage_check() -> void:
	if health <= 0:
		var tw := (sprite as SpriteBase3D).create_tween()
		tw.tween_property((sprite as SpriteBase3D), "modulate:a", 0.0, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
		await tw.finished
		queue_free()
