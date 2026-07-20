extends GutTest
## Unit tests for persistent meta state (MetaState autoload): the Grave Bones currency,
## unlock set, harvest banking, and save/load round-trips. Save-file corruption or a broken
## round-trip would silently wipe player progress, so this is high-value coverage.

const TEST_SAVE := "user://test_save.json"


func before_each() -> void:
	MetaState.reset_all()


func after_all() -> void:
	if FileAccess.file_exists(TEST_SAVE):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(TEST_SAVE))


# ---- currency ----

func test_add_grave_bones_accumulates() -> void:
	MetaState.add_grave_bones(30)
	MetaState.add_grave_bones(20)
	assert_eq(MetaState.grave_bones, 50)


func test_add_ignores_non_positive() -> void:
	MetaState.grave_bones = 10
	MetaState.add_grave_bones(-5)
	MetaState.add_grave_bones(0)
	assert_eq(MetaState.grave_bones, 10)


func test_grave_bones_never_negative() -> void:
	MetaState.grave_bones = 5
	MetaState.grave_bones = -100
	assert_eq(MetaState.grave_bones, 0)


func test_try_spend_succeeds_and_fails_correctly() -> void:
	MetaState.grave_bones = 100
	assert_true(MetaState.try_spend(40))
	assert_eq(MetaState.grave_bones, 60)
	assert_false(MetaState.try_spend(61), "should not spend more than balance")
	assert_eq(MetaState.grave_bones, 60, "balance untouched on failed spend")


# ---- harvest banking ----

func test_bank_harvest_plain_on_loss() -> void:
	var banked := MetaState.bank_harvest(100, false)
	assert_eq(banked, 100)
	assert_eq(MetaState.grave_bones, 100)


func test_bank_harvest_applies_multiplier_on_clear() -> void:
	var banked := MetaState.bank_harvest(100, true)
	assert_eq(banked, int(round(100 * MetaState.SUCCESS_MULTIPLIER)))
	assert_eq(MetaState.grave_bones, banked)


func test_bank_harvest_rounds_non_integer_products() -> void:
	# 101 * 1.5 = 151.5 → round → 152 (locks rounding vs. a future truncate/floor).
	var banked := MetaState.bank_harvest(101, true)
	assert_eq(banked, 152)
	assert_eq(MetaState.grave_bones, 152)


func test_bank_harvest_clamps_negative_base() -> void:
	# Return value must match what was actually banked (never negative).
	var banked := MetaState.bank_harvest(-10, false)
	assert_eq(banked, 0)
	assert_eq(MetaState.grave_bones, 0)


# ---- unlocks ----

func test_unlock_and_query() -> void:
	assert_false(MetaState.is_unlocked("golem"))
	MetaState.unlock("golem")
	assert_true(MetaState.is_unlocked("golem"))
	assert_true("golem" in MetaState.unlocked_ids())


# ---- persistence ----

func test_save_load_round_trip_preserves_state() -> void:
	MetaState.grave_bones = 275
	MetaState.unlock("golem")
	MetaState.unlock("wraith")
	MetaState.save_to(TEST_SAVE)

	MetaState.reset_all()
	assert_eq(MetaState.grave_bones, 0)  # sanity: wiped before load

	MetaState.load_from(TEST_SAVE)
	assert_eq(MetaState.grave_bones, 275)
	assert_true(MetaState.is_unlocked("golem"))
	assert_true(MetaState.is_unlocked("wraith"))


func test_load_missing_file_is_noop() -> void:
	MetaState.grave_bones = 42
	MetaState.load_from("user://does_not_exist_12345.json")
	assert_eq(MetaState.grave_bones, 42, "missing save must not alter state")


func test_load_corrupt_json_does_not_wipe_progress() -> void:
	# The save-wipe nightmare: a corrupt file must be ignored, not clobber state.
	MetaState.grave_bones = 88
	MetaState.unlock("golem")
	var f := FileAccess.open(TEST_SAVE, FileAccess.WRITE)
	f.store_string("{ this is not valid json ")
	f.close()
	MetaState.load_from(TEST_SAVE)
	assert_eq(MetaState.grave_bones, 88, "corrupt save must not wipe balance")
	assert_true(MetaState.is_unlocked("golem"))


func test_from_dict_ignores_wrong_typed_fields() -> void:
	# Parseable JSON but wrong types (hand-edited save) must not inject junk or crash.
	MetaState.from_dict({"grave_bones": "oops", "unlocked": "golem"})
	assert_eq(MetaState.grave_bones, 0)
	assert_eq(MetaState.unlocked_ids().size(), 0, "a String 'unlocked' must not iterate into char unlocks")


func test_from_dict_defaults_are_safe() -> void:
	MetaState.from_dict({})   # empty/partial save
	assert_eq(MetaState.grave_bones, 0)
	assert_eq(MetaState.unlocked_ids().size(), 0)


func test_to_dict_includes_version() -> void:
	assert_eq(MetaState.to_dict().get("version"), MetaState.SAVE_VERSION)
