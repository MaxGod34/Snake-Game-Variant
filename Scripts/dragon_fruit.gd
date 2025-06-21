extends Area2D

class_name DragonFruit
var fruit_type = "DragonFruit"

var is_ripe = false
var time_left_to_ripen: float = -1.0 # -1 means the timer is not active
var is_bounty_target = false
var active_tween: Tween = null
