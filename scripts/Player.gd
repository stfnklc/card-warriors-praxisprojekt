extends CharacterBody2D

@export var speed: float = 200.0

func _physics_process(_delta):
	var dir = Vector2.ZERO
	dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	if dir != Vector2.ZERO:
		dir = dir.normalized() * speed
	velocity = dir
	move_and_slide()
