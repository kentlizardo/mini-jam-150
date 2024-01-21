class_name Goblin extends Enemy

func _ready() -> void:
	sprite.play("hidden")

func _enter_fakelight() -> void:
	sprite.play("default")

func _exit_fakelight() -> void:
	sprite.play("hidden")
