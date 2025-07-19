extends Node2D

@onready var spawner := $EnemySpawner
var current_wave: int = 1
var base_count: int = 5

#Flashcards
@onready var flashcard_popup = $FlashcardPopup
var raw_flashcards: Array = []  
var state: LeitnerState = null
var current_card: Dictionary


func _ready():
	spawner.wave_cleared.connect(_on_wave_cleared)
	flashcard_popup.answered.connect(_on_flashcard_answered)

#Flashcard
func set_flashcards(data: Array) -> void:

	raw_flashcards = data.duplicate()
	print("--- Loaded Flashcards ---")
	for i in range(raw_flashcards.size()):
		var fc = raw_flashcards[i]
		print("%d) Q: %s  |  A: %s" % [i + 1, fc.question, fc.answer])
	print("-------------------------")
	
	state = LeitnerState.load_state(raw_flashcards)
	print("--- Leitner Boxes ---")
	for c in state.cards:
		# cards have: { id, question, answer, box }
		print("%d) Box %d → Q: %s  |  A: %s" %
			[c.id + 1, c.box, c.question, c.answer])
	print("---------------------")
	
	state.merge_new_cards(raw_flashcards)
	print("--- After merge, deck contains %d cards, boxes: ---" % state.cards.size())
	for c in state.cards:
		print("   [%d] Box %d → %s" % [c.id, c.box, c.question])

	current_wave = 1
	call_deferred("_start_wave")

func _on_flashcard_answered(correct: bool):
	state.handle_answer(current_card.id, correct)
	if correct:
		print("Correct! Grant reward…")
		# TODO: 
	else:
		print("Incorrect — no reward.")
	current_wave += 1
	_start_wave()

func _start_wave():
	spawner.enemy_count = base_count * current_wave
	spawner.spawn_wave()
	print("=== Wave %d ===" % current_wave)

func _on_wave_cleared():
	current_card = state.next_card()
	flashcard_popup.show_flashcard(current_card)
