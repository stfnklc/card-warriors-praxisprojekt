extends Node2D

@onready var spawner := $EnemySpawner
var current_wave: int = 1
var base_count: int = 5

func _ready():
	# Hook up the “wave cleared” signal so we can spawn the next wave
	spawner.connect("wave_cleared", Callable(self, "_on_wave_cleared"))
	_start_wave()

func _start_wave():
	spawner.enemy_count = base_count * current_wave
	spawner.spawn_wave()
	print("=== Wave %d ===" % current_wave)

func _on_wave_cleared():
	current_wave += 1
	if current_wave > 3:
		print("All waves done! (Later: spawn boss here.)")
	else:
		_start_wave()
