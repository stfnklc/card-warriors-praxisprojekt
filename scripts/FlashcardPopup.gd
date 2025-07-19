extends CanvasLayer

signal answered(correct: bool)

var current_flashcard: Dictionary

@onready var question_label = $Panel/VBoxContainer/QuestionLabel
@onready var answer_input = $Panel/VBoxContainer/AnswerInput
@onready var submit_button = $Panel/VBoxContainer/SubmitButton

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	submit_button.pressed.connect(_on_submit_pressed)
	hide()

func show_flashcard(flashcard: Dictionary):
	if get_tree() == null:
		return
	current_flashcard = flashcard
	question_label.text = flashcard.question
	answer_input.text = ""
	show()
	get_tree().paused = true  

func _on_submit_pressed():
	var answer = answer_input.text.strip_edges().to_lower()
	var correct_answer = current_flashcard.answer.strip_edges().to_lower()
	var is_correct = (answer == correct_answer)
	hide()
	get_tree().paused = false
	emit_signal("answered", is_correct)
