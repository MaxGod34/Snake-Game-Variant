extends Area2D

class_name IronCherry
var fruit_type = "IronCherry"

var is_ripe = false
var time_left_to_ripen: float = -1.0 # -1 means the timer is not active
var is_bounty_target = false
var active_tween: Tween = null
