extends CharacterBody2D

@export var speed: float = 100.0
var target: Node2D  # we’ll assign this at spawn time

func _physics_process(_delta):
	if not target:
		return
	var dir = (target.global_position - global_position)
	if dir.length() > 0:
		velocity = dir.normalized() * speed
		move_and_slide()
