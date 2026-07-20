extends GutTest
## Unit tests for the in-run economy (GameState autoload). Spending/clamping bugs here would
## silently corrupt every run's balance, so they're worth pinning.


func before_each() -> void:
	GameState.bone_dust = 0


func test_reset_run_sets_starting_dust() -> void:
	GameState.reset_run()
	assert_eq(GameState.bone_dust, GameState.STARTING_BONE_DUST)


func test_can_afford() -> void:
	GameState.bone_dust = 50
	assert_true(GameState.can_afford(50))
	assert_true(GameState.can_afford(20))
	assert_false(GameState.can_afford(51))


func test_try_spend_succeeds_when_affordable() -> void:
	GameState.bone_dust = 100
	assert_true(GameState.try_spend(30))
	assert_eq(GameState.bone_dust, 70)


func test_try_spend_fails_and_keeps_balance_when_broke() -> void:
	GameState.bone_dust = 20
	assert_false(GameState.try_spend(50))
	assert_eq(GameState.bone_dust, 20, "balance must be untouched on a failed purchase")


func test_balance_never_goes_negative() -> void:
	GameState.bone_dust = 5
	GameState.bone_dust = -100   # setter clamps to >= 0
	assert_eq(GameState.bone_dust, 0)


func test_add_accumulates() -> void:
	GameState.bone_dust = 10
	GameState.add(15)
	assert_eq(GameState.bone_dust, 25)
