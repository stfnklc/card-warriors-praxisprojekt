extends Control

var flashcards: Array = []

const LeitnerState = preload("res://scripts/Leitner.gd")

@onready var question_input = $VBoxContainer/HBoxContainer/QuestionInput
@onready var answer_input   = $VBoxContainer/HBoxContainer/AnswerInput
@onready var flashcard_list = $VBoxContainer/FlashcardList
@onready var add_button = $VBoxContainer/AddButton
@onready var delete_button = $VBoxContainer/HBoxContainer2/DeleteButton
@onready var start_button   = $VBoxContainer/HBoxContainer2/StartButton

func _ready():
	var saved_state = LeitnerState.load_state([])  
	for c in saved_state.cards:
		# Map each persistent card into your local UI array
		flashcards.append({
			"question": c.question,
			"answer":   c.answer
		})
	_update_flashcard_list()
	add_button.pressed.connect(_on_add_flashcard)
	delete_button.pressed.connect(_on_delete_flashcard)
	start_button.pressed.connect(_on_start_button_pressed)

func _on_add_flashcard():
	var q = question_input.text.strip_edges()
	var a = answer_input.text.strip_edges()
	if q != "" and a != "":
		flashcards.append({ "question": q, "answer": a })
		flashcard_list.add_item("Q: %s | A: %s" % [q, a])
		question_input.text = ""
		answer_input.text = ""
		_update_flashcard_list()

func _on_delete_flashcard():
	var selected = flashcard_list.get_selected_items()
	if selected.is_empty():
		return  # nothing selected
	var idx = selected[0]
	flashcards.remove_at(idx)
	flashcard_list.remove_item(idx)
	_update_flashcard_list()

func _on_start_button_pressed():
	if flashcards.is_empty():
		push_error("Please add at least one flashcard.")
		return
	var state = LeitnerState.new(flashcards)
	state.merge_new_cards(flashcards, true)  
	var main_scene = preload("res://scenes/Main.tscn").instantiate()
	main_scene.set_flashcards(flashcards)
	get_tree().root.add_child(main_scene)
	get_tree().set_current_scene(main_scene)   
	queue_free()
	
func _update_flashcard_list() -> void:
	flashcard_list.clear()
	for i in range(flashcards.size()):
		var fc = flashcards[i]
		flashcard_list.add_item("%d) Q: %s | A: %s" % [i + 1, fc.question, fc.answer])
