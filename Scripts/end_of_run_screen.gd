extends Control

signal restart_pressed
signal quit_pressed

@onready var card_panel: PanelContainer = $CenterContainer/CardPanel
@onready var stamp_label: Label = $CenterContainer/CardPanel/VBox/StampLabel
@onready var subtitle_label: Label = $CenterContainer/CardPanel/VBox/SubtitleLabel
@onready var class_pact_label: Label = $CenterContainer/CardPanel/VBox/ClassPactLabel
@onready var garden_label: Label = $CenterContainer/CardPanel/VBox/StatsGrid/GardenLabel
@onready var score_label: Label = $CenterContainer/CardPanel/VBox/StatsGrid/ScoreLabel
@onready var time_label: Label = $CenterContainer/CardPanel/VBox/StatsGrid/TimeLabel
@onready var fang_banner: Control = $CenterContainer/CardPanel/VBox/FangBanner
@onready var fang_amount_label: Label = $CenterContainer/CardPanel/VBox/FangBanner/FangAmountLabel

@onready var restart_button: Button = $CenterContainer/CardPanel/VBox/ButtonRow/RestartButton
@onready var quit_button: Button = $CenterContainer/CardPanel/VBox/ButtonRow/QuitButton

const LOSS_QUIPS = [
	"Turned into pulp.",
	"Insufficient juice.",
	"Nice try. Run it back.",
	"The garden wins this round.",
	"Ouroboros cosplay gone wrong."
]

const WIN_QUIPS = [
	"Slithered off into the sunset.",
	"100% pure concentrate.",
	"The garden couldn't hold you.",
	"Certified menace."
]

func _ready() -> void:
	visible = false
	restart_button.pressed.connect(func(): restart_pressed.emit())
	quit_button.pressed.connect(func(): quit_pressed.emit())

func show_results(summary: Dictionary) -> void:
	var did_win: bool = summary.get("did_win", false)
	print(did_win)
	# 1. Header Stamp & Tone
	if did_win:
		stamp_label.text = "ESCAPED THE GARDEN"
		stamp_label.modulate = Color.GOLD
		subtitle_label.text = WIN_QUIPS.pick_random()
		card_panel.rotation_degrees = 0.0
	else:
		stamp_label.text = "BATCH SPOILED"
		stamp_label.modulate = Color.CRIMSON
		subtitle_label.text = LOSS_QUIPS.pick_random()
		card_panel.rotation_degrees = -2.0

	# 2. Snapshot Stats
	class_pact_label.text = "%s  •  %s" % [summary.class_key, summary.difficulty_key]
	garden_label.text = "Garden %d: %s" % [summary.garden_reached, summary.garden_name]

	var best_tag = "  (NEW BEST!)" if summary.is_new_high_score else ""
	score_label.text = "Length: %d%s" % [summary.final_score, best_tag]

	var t: float = summary.run_time
	var mins := int(t / 60.0)
	var secs := int(t) % 60
	var tenths := int(fmod(t, 1.0) * 10.0)
	time_label.text = "Time: %d:%02d.%d" % [mins, secs, tenths] if mins > 0 else "Time: %02d.%d" % [secs, tenths]

	# 3. Fangs (Only shown on a first-time class/difficulty win)
	var fangs: int = summary.get("fangs_earned", 0)
	if did_win and fangs > 0:
		fang_banner.visible = true
		fang_amount_label.text = "+%d FANGS  (First Clear!)" % fangs
	else:
		fang_banner.visible = false

	visible = true
