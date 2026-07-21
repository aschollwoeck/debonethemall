extends GutTest
## Tests the between-level dialogue overlay's sequencing (M3 slice 2). The card walks a list of
## beats and emits `finished` after the last — the signal main.gd relies on to chain into the end
## screen, so a broken sequence would strand the player behind the overlay.

const DialogueCardScript = preload("res://scripts/ui/dialogue_card.gd")


func _beats(n: int) -> Array:
	var a: Array = []
	for i in n:
		a.append({"who": "you", "name": "YOU", "line": "line %d" % i})
	return a


func test_advances_through_beats_then_finishes() -> void:
	var card = DialogueCardScript.new()
	add_child_autofree(card)
	watch_signals(card)
	card.play(_beats(2))
	assert_eq(card.current_index(), 0, "starts on the first beat")
	card._advance()
	assert_eq(card.current_index(), 1, "advances to the second")
	assert_signal_not_emitted(card, "finished")
	card._advance()
	assert_signal_emitted(card, "finished", "finishes after the last beat")


func test_advance_after_finish_does_not_re_emit() -> void:
	var card = DialogueCardScript.new()
	add_child_autofree(card)
	watch_signals(card)
	card.play(_beats(1))
	card._advance()   # finishes (single beat)
	card._advance()   # stray same-frame input — must be a no-op
	assert_signal_emit_count(card, "finished", 1, "finished fires exactly once")


func test_empty_beats_finishes_immediately() -> void:
	var card = DialogueCardScript.new()
	add_child_autofree(card)
	watch_signals(card)
	card.play([])
	assert_signal_emitted(card, "finished", "an empty sequence finishes at once")
