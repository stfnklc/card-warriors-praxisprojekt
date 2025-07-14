extends Control

var flashcards: Array = []

@onready var question_input = $VBoxContainer/HBoxContainer/QuestionInput
@onready var answer_input   = $VBoxContainer/HBoxContainer/AnswerInput
@onready var flashcard_list = $VBoxContainer/FlashcardList
@onready var start_button   = $VBoxContainer/StartButton

func _ready():
	$VBoxContainer/AddButton.pressed.connect(_on_add_flashcard)
	start_button.pressed.connect(_on_start_button_pressed)

func _on_add_flashcard():
	var q = question_input.text.strip_edges()
	var a = answer_input.text.strip_edges()
	if q != "" and a != "":
		flashcards.append({ "question": q, "answer": a })
		flashcard_list.add_item("Q: %s | A: %s" % [q, a])
		question_input.text = ""
		answer_input.text = ""

func _on_start_button_pressed():

	var main_scene = preload("res://scenes/Main.tscn").instantiate()
	main_scene.flashcards = flashcards.duplicate()
	get_tree().root.add_child(main_scene)
	get_tree().set_current_scene(main_scene)   
	queue_free()
