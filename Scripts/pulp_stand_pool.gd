class_name PulpStandPool
extends RefCounted

const BUNDLE_DIR := "res://Convenience/Bundles/"

var bundles_by_tier: Dictionary = {
	PulpBundleData.Tier.COMMON: [],
	PulpBundleData.Tier.RARE: [],
	PulpBundleData.Tier.LEGENDARY: [],
	PulpBundleData.Tier.CURSE: [],
}

## Tune these weights as you playtest (e.g., 52% Common, 28% Rare, 8% Legendary, 12% Curse)
var tier_weights: Dictionary = {
	PulpBundleData.Tier.COMMON: 52.0,
	PulpBundleData.Tier.RARE: 28.0,
	PulpBundleData.Tier.LEGENDARY: 8.0,
	PulpBundleData.Tier.CURSE: 12.0,
}

func load_all_bundles() -> void:
	for tier in bundles_by_tier:
		bundles_by_tier[tier].clear()
	
	_scan_dir_recursive(BUNDLE_DIR)
	
	var total := 0
	for tier in bundles_by_tier:
		total += bundles_by_tier[tier].size()
	print("PulpStandPool: Loaded %s bundles from: %s" % [total, BUNDLE_DIR])

func _scan_dir_recursive(dir_path: String) -> void:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		push_error("PulpStandPool: Could not open " + dir_path)
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if file_name.begins_with("."):
			file_name = dir.get_next()
			continue

		var full_path := dir_path.path_join(file_name)
		if dir.current_is_dir():
			_scan_dir_recursive(full_path)
		else:
			var clean_name := file_name.trim_suffix(".remap")
			if clean_name.ends_with(".tres") or clean_name.ends_with(".res"):
				var bundle := load(dir_path.path_join(clean_name)) as PulpBundleData
				if bundle:
					if bundle.id == &"":
						var fallback := bundle.display_name if bundle.display_name != "" else clean_name.get_basename()
						bundle.id = StringName(fallback.to_snake_case())
					bundles_by_tier[bundle.tier].append(bundle)
		file_name = dir.get_next()
	dir.list_dir_end()

func roll_bundle(run_state: Object, exclude_id: StringName = &"") -> PulpBundleData:
	var result := _roll_internal(run_state, exclude_id)
	# If excluding the current item emptied the pool (e.g., small test pool), allow rolling again without exclusion
	if result == null and exclude_id != &"":
		result = _roll_internal(run_state, &"")
	return result

func _roll_internal(run_state: Object, exclude_id: StringName) -> PulpBundleData:
	var valid_by_tier: Dictionary = {}
	var total_weight := 0.0

	for tier in tier_weights:
		var eligible: Array[PulpBundleData] = []
		for bundle: PulpBundleData in bundles_by_tier[tier]:
			if (exclude_id == &"" or bundle.id != exclude_id) and is_eligible(bundle, run_state):
				eligible.append(bundle)
		if not eligible.is_empty():
			valid_by_tier[tier] = eligible
			total_weight += tier_weights[tier]

	if total_weight <= 0.0:
		return null

	var roll := randf() * total_weight
	var cursor := 0.0
	for tier in valid_by_tier:
		cursor += tier_weights[tier]
		if roll <= cursor:
			var pool: Array[PulpBundleData] = valid_by_tier[tier]
			return pool[randi() % pool.size()]

	return null

func is_eligible(bundle: PulpBundleData, run_state: Object) -> bool:
	if bundle.exclude_larry and run_state.is_larry_class():
		return false

	if bundle.max_difficulty_tier >= 0 and run_state.current_difficulty_tier > bundle.max_difficulty_tier:
		return false

	if bundle.unique_per_run and run_state.claimed_pulp_bundles.has(bundle.id):
		return false

	if not bundle.unlocks.is_empty():
		var has_unowned := false
		for upg_key in bundle.unlocks:
			if not run_state.is_upgrade_unlocked(upg_key):
				has_unowned = true
				break
		if not has_unowned:
			return false

	for upg_key in bundle.upgrade_deltas:
		if bundle.upgrade_deltas[upg_key] > 0 and upg_key in GameManager.ACTIVE_ABILITIES:
			if not run_state.can_receive_active_ability(upg_key):
				return false

	for upg_key in bundle.max_out_upgrades:
		if upg_key in GameManager.ACTIVE_ABILITIES and not run_state.can_receive_active_ability(upg_key):
			return false
		if run_state.get_upgrade_level_from_key(upg_key) >= run_state.get_upgrade_max_level(upg_key):
			return false

	match bundle.special_effect:
		PulpBundleData.SpecialEffect.DISABLE_CHROMA_SCALES:
			if not run_state.chroma_scales_enabled:
				return false
		PulpBundleData.SpecialEffect.GO_BACK_GARDEN:
			if run_state.current_garden <= 1:
				return false
		PulpBundleData.SpecialEffect.DOUBLE_JUICE:
			if run_state.juice <= 0:
				return false

	if bundle.ability_slot_delta < 0 and run_state.max_ability_slots <= 0:
		return false

	if bundle.tier == PulpBundleData.Tier.CURSE and not bundle.upgrade_deltas.is_empty():
		var can_penalize := false
		for upg_key in bundle.upgrade_deltas:
			if run_state.get_upgrade_level_from_key(upg_key) > 0:
				can_penalize = true
				break
		if not can_penalize:
			return false

	return true
