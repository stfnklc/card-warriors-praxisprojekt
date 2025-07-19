extends RefCounted
class_name LeitnerState

const FPATH := "user://leitner.json"
const PERCENTAGES := [0.6, 0.3, 0.1]  

var cards: Array         
var schedule: Array      
var schedule_idx: int    
var session_length: int  

func _init(raw_cards: Array) -> void:
	cards = []
	for i in range(raw_cards.size()):
		cards.append({
			"id":       i,
			"question": raw_cards[i].question,
			"answer":   raw_cards[i].answer,
			"box":      1
		})
	session_length = cards.size()
	schedule = []
	schedule_idx = 0

func build_schedule() -> void:
	var L = session_length
	var n1 = max(1, round(PERCENTAGES[0] * L))
	var n2 = max(1, round(PERCENTAGES[1] * L))
	var n3 = max(1, round(PERCENTAGES[2] * L))
	var sum = n1 + n2 + n3
	if sum != L:
		var diff = L - sum
		if n1 >= n2 and n1 >= n3:
			n1 += diff
		elif n2 >= n1 and n2 >= n3:
			n2 += diff
		else:
			n3 += diff
	schedule.clear()
	for i in range(n1): schedule.append(1)
	for i in range(n2): schedule.append(2)
	for i in range(n3): schedule.append(3)
	_shuffle_array(schedule)
	schedule_idx = 0

func _shuffle_array(arr: Array) -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	for i in range(arr.size() - 1, 0, -1):
		var j = rng.randi_range(0, i)
		var tmp = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp

func next_card() -> Dictionary:
	if schedule_idx >= schedule.size():
		build_schedule()
	var box_num = schedule[schedule_idx]
	schedule_idx += 1
	var candidates = cards.filter(func(c): return c.box == box_num)
	if candidates.is_empty():
		candidates = cards.duplicate()
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	return candidates[rng.randi_range(0, candidates.size() - 1)]

func handle_answer(card_id: int, correct: bool) -> void:
	for c in cards:
		if c.id == card_id:
			if correct:
				c.box = min(c.box + 1, 3)
			else:
				c.box = 1
			break
	save_state()
	print("🔄 State after answer: ", cards)


func merge_new_cards(raw_cards: Array, first_save: bool=false) -> void:
	var existing_q := {}
	for c in cards:
		existing_q[c.question] = true
	var next_id = cards.size()
	for fc in raw_cards:
		if not existing_q.has(fc.question):
			cards.append({
				"id":       next_id,
				"question": fc.question,
				"answer":   fc.answer,
				"box":      1
			})
			existing_q[fc.question] = true
			next_id += 1
			print("➕ Added new card:", fc.question)
	session_length = cards.size()
	build_schedule()
	if first_save:
		save_state()

func save_state() -> void:
	var data = {
		"cards":        cards,
		"schedule":     schedule,
		"schedule_idx": schedule_idx
	}
	var text = JSON.stringify(data)
	var f = FileAccess.open(FPATH, FileAccess.ModeFlags.WRITE)
	if not f:
		push_error("Could not open %s for writing" % FPATH)
		return
	f.store_string(text)
	f.close()
	print("💾 Saved Leitner JSON:", text)

static func load_state(raw_cards: Array) -> LeitnerState:
	var state = LeitnerState.new(raw_cards)
	if FileAccess.file_exists(FPATH):
		var f = FileAccess.open(FPATH, FileAccess.ModeFlags.READ)
		if f:
			var text = f.get_as_text()
			f.close()
			var json = JSON.new()
			var err  = json.parse(text)
			if err == OK:
				var doc = json.get_data()
				if typeof(doc) == TYPE_DICTIONARY:
					state.cards         = doc["cards"]
					state.schedule      = doc["schedule"]
					state.schedule_idx  = doc["schedule_idx"]
					state.session_length = state.cards.size()
					state.merge_new_cards(raw_cards, false)
					return state
				else:
					push_error("Leitner JSON is not a Dictionary.")
			else:
				push_error("Failed to parse Leitner JSON: %s" % json.get_error_message())
	state.merge_new_cards(raw_cards, true)
	return state
