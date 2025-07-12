extends Area2D

@export var speed: float = 500.0
@export var direction: Vector2 = Vector2.ZERO
@export var lifetime: float = 2.0  # seconds

var time_alive := 0.0

func _physics_process(delta):
	position += direction.normalized() * speed * delta
	time_alive += delta
	if time_alive >= lifetime:
		queue_free()
		
func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body is CharacterBody2D and body.has_method("take_damage"):
		body.take_damage(1)
		queue_free()
