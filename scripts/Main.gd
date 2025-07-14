extends Node2D

@onready var spawner := $EnemySpawner
var current_wave: int = 1
var base_count: int = 5

#Flashcards
@onready var flashcard_popup = $FlashcardPopup
var flashcards: Array = []
var current_flashcard_index: int = 0


func _ready():
	spawner.wave_cleared.connect(_on_wave_cleared)
	flashcard_popup.answered.connect(_on_flashcard_answered)
	_start_wave()

func _start_wave():
	spawner.enemy_count = base_count * current_wave
	spawner.spawn_wave()
	print("=== Wave %d ===" % current_wave)

func _on_wave_cleared():
	if current_flashcard_index < flashcards.size():
		var card = flashcards[current_flashcard_index]
		current_flashcard_index += 1
		flashcard_popup.show_flashcard(card)
	else:
		_on_flashcard_answered(false)
		
#Flashcard

func set_flashcards(data: Array):
	flashcards = data.duplicate()
	flashcards.shuffle() 
	
func _on_flashcard_answered(correct: bool):
	if correct:
		print("Correct! Granting reward...")
		# TODO: Upgrade here
	else:
		print("Incorrect! No reward.")
	
	current_wave += 1
	_start_wave()
