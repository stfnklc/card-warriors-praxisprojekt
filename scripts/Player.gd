extends CharacterBody2D

#Bullet
@export var bullet_scene: PackedScene
@export var shoot_cooldown := 0.3
var time_since_last_shot := 0.0


@export var speed: float = 200.0
@export var max_hp := 5
var hp: int


func _physics_process(delta):
	var dir = Vector2.ZERO
	dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	if dir != Vector2.ZERO:
		dir = dir.normalized() * speed
	velocity = dir
	move_and_slide()
	
	time_since_last_shot += delta
	if Input.is_action_pressed("shoot") and time_since_last_shot >= shoot_cooldown:
		shoot()
		time_since_last_shot = 0.0
		
func _ready():
	hp = max_hp


func shoot():
	var bullet = bullet_scene.instantiate()
	var mouse_pos = get_global_mouse_position()
	bullet.global_position = global_position
	bullet.direction = (mouse_pos - global_position).normalized()
	get_tree().current_scene.add_child(bullet)
	
func take_damage(damage: int):
	hp -= damage
	print("Player HP:", hp)
	if hp <= 0:
		die()

func die():
	print("Player died!")
