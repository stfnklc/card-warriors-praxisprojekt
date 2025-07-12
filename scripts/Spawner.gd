extends Node2D
signal wave_cleared

@export var enemy_scene: PackedScene
@export var enemy_count: int = 5
@export var spawn_radius: float = 400.0

var _alive_enemies := []

func spawn_wave():
	_alive_enemies.clear()
	for i in range(enemy_count):
		var enemy = enemy_scene.instantiate()
		# random point on circle
		var angle = randf() * TAU
		enemy.position = Vector2(cos(angle), sin(angle)) * spawn_radius
		enemy.target = get_parent().get_node("Player")
		add_child(enemy)
		_alive_enemies.append(enemy)
		# **Property‑based connect** with bind:
		enemy.tree_exited.connect(_on_enemy_removed)
	print("Spawned %d enemies" % enemy_count)

func _on_enemy_removed(enemy):
	_alive_enemies.erase(enemy)
	if _alive_enemies.is_empty():
		emit_signal("wave_cleared")
