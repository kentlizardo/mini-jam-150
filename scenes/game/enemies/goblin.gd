class_name Goblin extends Enemy

@export var melee: Vision
var melee_timer := 0.0
var melee_cooldown := 0.8

func _ready() -> void:
	sprite.play("hidden")

func _enter_fakelight() -> void:
	sprite.play("default")

func _exit_fakelight() -> void:
	sprite.play("hidden")

func _process(delta: float) -> void:
	if is_instance_valid(melee):
		if melee.seen.size() > 0:
			melee_timer += delta
			if melee_timer >= melee_cooldown:
				for obj: Node3D in melee.seen:
					if obj.has_method("damage"):
						obj.damage(1, Global.DamageType.PHYSICAL, self)
				melee_timer = 0.0
		else:
			melee_timer = 0.0
