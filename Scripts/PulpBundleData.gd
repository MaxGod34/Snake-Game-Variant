class_name PulpBundleData extends Resource

enum Tier { COMMON, RARE, LEGENDARY, CURSE }

enum SpecialEffect{
	NONE,
	JUICE_EQUAL_GARDEN,
	GO_BACK_GARDEN,
	DOUBLE_JUICE,
	REVERSE_CONTROLS,
	BLOCK_MARKET_RECESSION,
	DISABLE_CHROMA_SCALES,
}

@export var id: StringName
@export var display_name: String
@export_multiline var description: String
@export var icon: Texture2D
@export var tier: Tier = Tier.COMMON

@export_group("Payload")
@export var upgrade_deltas: Dictionary = {} # ("Edge Lord": 1)
@export var unlocks: Array[String] = []
@export var max_out_upgrades: Array[String] = []
@export var ability_slot_delta: int = 0
@export var special_effect: SpecialEffect = SpecialEffect.NONE

@export_group("Eligibility Guards")
@export var exclude_larry: bool = false
@export var max_difficulty_tier: int = -1
@export var unique_per_run: bool = false
