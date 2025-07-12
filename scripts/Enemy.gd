extends CharacterBody2D

@export var speed: float = 100.0
@export var max_hp := 3
var hp := max_hp

@onready var hurtbox = $Hurtbox
@export var contact_damage := 1


var target: Node2D  

func _physics_process(_delta):
	if not target:
		return
	var dir = (target.global_position - global_position)
	if dir.length() > 0:
		velocity = dir.normalized() * speed
		move_and_slide()
		
func _ready():
	hurtbox.body_entered.connect(_on_body_entered)

func take_damage(dmg: int):
	hp -= dmg
	if hp <= 0:
		queue_free()

func _on_body_entered(body):
	if body.name == "Player" and body.has_method("take_damage"):
		body.take_damage(contact_damage)
