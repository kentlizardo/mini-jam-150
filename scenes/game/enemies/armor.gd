extends CharacterBody3D
const SPEED = 2.0

enum ArmorState {
	SEARCH,
	VULNERABLE,
	DYING,
}

@export var sprite: AnimatedSprite3D
@export var vision: Vision

@export var melee: Vision
var melee_timer := 0.0
var melee_cooldown := 0.8

var drive_vector := Vector3.ZERO
var health := 3

var state : ArmorState = ArmorState.SEARCH:
	set(x):
		state = x
		match state:
			ArmorState.SEARCH:
				sprite.play("default")
			ArmorState.VULNERABLE:
				sprite.play("vulnerable")
				await get_tree().create_timer(6.0).timeout
				if state != ArmorState.DYING:
					next_state(ArmorState.SEARCH)
			ArmorState.DYING:
				var tw := create_tween()
				tw.tween_property(sprite, "modulate:a", 0.0, 0.8).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
				await tw.finished
				queue_free()

func _next_state(s: ArmorState) -> void:
	state = s
func next_state(s: ArmorState) -> void:
	_next_state.call_deferred(s)

func _physics_process(delta: float) -> void:
	var direction := drive_vector.normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	var player := get_tree().get_first_node_in_group("player") as Node3D
	if player:
		look_at(player.global_position)
	move_and_slide()

func _process(delta: float) -> void:
	if state == ArmorState.SEARCH:
		var player_target : Player
		for i in vision.seen:
			if i is Player:
				player_target = i
		if player_target:
			drive_vector = (player_target.global_position - global_position).normalized()
		else:
			drive_vector = Vector3.ZERO
		if is_instance_valid(melee):
			if melee.seen.size() > 0:
				melee_timer += delta
				if melee_timer >= melee_cooldown:
					for obj: Node3D in melee.seen:
						if is_ancestor_of(obj) or obj == self:
							continue
						if obj.has_method("damage"):
							obj.damage(1, Global.DamageType.PHYSICAL, self)
					melee_timer = 0.0
		else:
			melee_timer = 0.0
	else:
		drive_vector = Vector3.ZERO

func _on_hurt_box_damaged(damage: int) -> void:
	next_state(ArmorState.VULNERABLE)
	print("vulnerable")

func damage_check() -> void:
	if health <= 0:
		next_state(ArmorState.DYING)

func _on_shield_damaged(damage: int) -> void:
	if state == ArmorState.VULNERABLE:
		health -= damage
		Util.hit_marker(sprite)
		damage_check()
