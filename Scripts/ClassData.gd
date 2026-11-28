class_name ClassData extends Resource

@export_category("Flavor_Intro")
@export var display_name: String = "McName Missing"
@export var description: String = "N/A"
@export var artwork_path: String = ""
@export var icon_path: String = ""

@export_category("Meta_Progression")
@export var fang_cost: int = 0

@export_category("Starters/Modifiers")
@export var start_speed: float = 0.3
@export var speed_upgrade_mod: float = 0.9
@export var start_upgrades: Dictionary = {}
@export var start_stats: Dictionary = {}
@export var cost_modifiers: Dictionary = {
	#--------Idle Modifiers-------#
	"Snake Clicker": 0, "Get Rich Quick": 0, "Custom Aftertaste": 0, 
	"Arcane Flow": 0, "Pulp Reactor": 0, "Unstable Metabolism": 0,
	# Planner Path Modifiers
	"Diet Slith": 0, "Fruit Foresight": 0,"Geological Survey": 0, 
	"Sovereign Trail": 0, "Meditate": 0, "Garden Weaver": 0,
	#------The Ledger Modifiers------#
	"Liquid Assets": 0, "Principal Pulp": 0, "Fast Track": 0, "Gluttons Greed": 0,
	"Market Crash": 0, "Golden Handshake": 0, "Juice Press": 0, "Liquidation": 0,
	# Glutton Modifiers
	"Elephant Sized Portions": 0, "More Mice": 0, "Golden Seeds": 0,
	"Patient Gardener": 0, "Banana Bounty": 0, "Golden Seed Extract": 0,
	# Wrangler Modifiers
	"Extended Reach": 0, "Active Gratification": 0, "Lasso Larry": 0, 
	"Double Lasso": 0, "Lasso Rhythm": 0,
		#-----GEODE Modifiers-----#
	"Fertile Ground": 0, "Mineral Rich Soil": 0, 
	"Rockmuncher": 0, "Geode Cracker": 0,  "Calculated Risk": 0,
	# Acrobat Modifiers
	"Slither Sauce": 0, "Tenderizer": 0, "Juke N Jive": 0,
	"Afterburner": 0, "Pop Rocks": 0, "Autotomy": 0,
	#Frenzy Modifiers
	"Sugar Rush": 0, "Chain Reaction": 0, "Overdrive": 0, "Lingering Rush": 0, "Zenith": 0,
	# Survivor Modifiers
	"Mulligan Munchie": 0, "Phoenix Dawn": 0, "Last Stand": 0,
	"Death Defied": 0, "Martyrdom": 0, "New Game S Plus": 0,
	# Illusionist Modifiers
	"Ghost Tail": 0, "Phase Shift": -1, "Blink": 0, "3 Card Monty": 0,
	"Fractured Self": 0, "Dazzle Pie": 0,
	# Architect Modifiers
	"Edge Lord": 0, "Zoning Ordinance": 0, "Border Czar": 0, "Burrow": 0, 
	"Pocket Garden": 0, "Fold Space": 0, "Masters Blueprint": 0, 
	"Shatter Reality": 0,
	#------Gambling Modifiers--------#
	"Coin Flip Curious": 0, "Passive Income": 0,
}
# all modifiers listed UPDATE with upgrade tinkering
