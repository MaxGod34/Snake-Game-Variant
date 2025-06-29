extends Button

# This signal tells the parent tab when this node is clicked or hovered.
signal node_pressed(upgrade_key)
signal node_mouse_entered(upgrade_key)
signal node_mouse_exited(upgrade_key)

var upgrade_key: String = ""

func _ready():
	# Connect our own internal signals.
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func get_node_icon_for_upgrade(icon_upgrade_key: String):
	match icon_upgrade_key:
#--------------------------The Core----------------------------\\\\\\\\\\\\\\\\\\\\\\\\\\\//////////////////////////////////
	#---------Idle-------------
		"Snake Clicker": self.icon = preload("res://Assets/PNGs/UpgradeIcons/SnakeClickerIcon.png")
		"Get Rich Quick": self.icon = preload("res://Assets/PNGs/UpgradeIcons/get_rich_quick_icon.png")
		"Custom Aftertaste": self.icon = preload("res://Assets/PNGs/UpgradeIcons/CustomAfterTasteIcon.png")
		"Arcane Flow": self.icon = preload("res://Assets/PNGs/UpgradeIcons/ArcaneFlowIcon.png")
		"Pulp Reactor": self.icon = preload("res://Assets/PNGs/UpgradeIcons/PulpReactorIcon.png")
		"Unstable Metabolism": self.icon = preload("res://Assets/PNGs/UpgradeIcons/UnstableMetabolismIcon.png")
	#-----------Planner-----------
		"Diet Slith": self.icon = preload("res://Assets/PNGs/UpgradeIcons/DietSlithIcon.png")
		"Fruit Foresight": self.icon = preload("res://Assets/PNGs/UpgradeIcons/FruitForesightIcon.png")
		"Geological Survey": self.icon = preload("res://Assets/PNGs/UpgradeIcons/GeologicalSurveyIcon.png")
		"Sovereign Trail": self.icon = preload("res://Assets/PNGs/UpgradeIcons/SovereignTrailIcon.png")
		"Meditate": self.icon = preload("res://Assets/PNGs/UpgradeIcons/MeditateIcon.png")
		"Garden Weaver": self.icon = preload("res://Assets/PNGs/UpgradeIcons/GardenWeaverIcon.png")
	#-----------Ledger------------
		#----Path A
		"Liquid Assets": self.icon = preload("res://Assets/PNGs/UpgradeIcons/LiquidAssetsIcon.png")
		"Fast Track": self.icon = preload("res://Assets/PNGs/UpgradeIcons/WormholeIcon.png")
		"Gluttons Greed": self.icon = preload("res://Assets/PNGs/UpgradeIcons/GluttonsGreedIcon.png")
		"Market Crash": self.icon = preload("res://Assets/PNGs/UpgradeIcons/MarketCrashIcon.png")
		#----Path B
		"Principal Pulp": self.icon = preload("res://Assets/PNGs/UpgradeIcons/PrincipalPulpIcon.png")
		"Golden Handshake": self.icon = preload("res://Assets/PNGs/UpgradeIcons/GoldenHandshakeIcon.png")
		"Juice Press": self.icon = preload("res://Assets/PNGs/UpgradeIcons/JuicePressIcon.png")
		"Liquidation": self.icon = preload("res://Assets/PNGs/UpgradeIcons/LiquidationIcon.png")
#-------------------------The Harvest-----------------------------\\\\\\\\\\\\\\\\\\\\\////////////////////////////
	#------------Glutton-------------
		"Elephant Sized Portions": self.icon = preload("res://Assets/PNGs/UpgradeIcons/ESPortionsIcon.png")
		"More Mice": self.icon = preload("res://Assets/PNGs/UpgradeIcons/MoreMiceIcon.png")
		"Golden Seeds": self.icon = preload("res://Assets/PNGs/UpgradeIcons/GoldenSeedsIcon.png")
		"Patient Gadener": self.icon = preload("res://Assets/PNGs/UpgradeIcons/PatientGardenerIcon.png")
		"Banana Bounty": self.icon = preload("res://Assets/PNGs/UpgradeIcons/BananaBountyIcon.png")
		"The Satchel": self.icon = preload("res://Assets/PNGs/UpgradeIcons/TheSatchelIcon.png")
	#------------Chef----------------
		"Golden Seed Extract": self.icon = preload("res://Assets/PNGs/UpgradeIcons/GoldenSeedExtractIcon.png")
		"Exotic Seeds": self.icon = preload("res://Assets/PNGs/UpgradeIcons/ExoticSeedsIcon.png")
		"The Cookbook": self.icon = preload("res://Assets/PNGs/UpgradeIcons/TheCookbookIcon.png")
		"Expanded Palate": self.icon = preload("res://Assets/PNGs/UpgradeIcons/ExpandedPalateIcon.png")
		"Golden Glaze": self.icon = preload("res://Assets/PNGs/UpgradeIcons/GoldenGlazeIcon.png")
		"Custom Cuisine": self.icon = preload("res://Assets/PNGs/UpgradeIcons/CustomCuisineIcon.png")
		"Mise en Place": self.icon = preload("res://Assets/PNGs/UpgradeIcons/MiseenPlaceIcon.png")
	#-----------Geomancer------------
		"Fertile Ground": self.icon = preload("res://Assets/PNGs/UpgradeIcons/FertileGroundIcon.png")
		"Rockmuncher": self.icon = preload("res://Assets/PNGs/UpgradeIcons/RockmuncherIcon.png")
		"Material Rich Soil": self.icon = preload("res://Assets/PNGs/UpgradeIcons/MaterialRichSoilIcon.png")
		"Geode Cracker": self.icon = preload("res://Assets/PNGs/UpgradeIcons/GeodeCrackerIcon.png")
		"Tectonic Shift": self.icon = preload("res://Assets/PNGs/UpgradeIcons/TectonicShiftIcon.png")
		"Kinetic Feast": self.icon = preload("res://Assets/PNGs/UpgradeIcons/KineticFeastIcon.png")
		"Heavy Foundation": self.icon = preload("res://Assets/PNGs/UpgradeIcons/HeavyFoundationIcon.png")
		"Stones Burden": self.icon = preload("res://Assets/PNGs/UpgradeIcons/StonesBurdenIcon.png")
		"Calculated Risk": self.icon = preload("res://Assets/PNGs/UpgradeIcons/CalculatedRiskIcon.png")
#------------------------The Redliner------------------------------\\\\\\\\\\\\\\\\\\\\////////////////////////////
	#-----------Acrobat--------------
		"Slither Sauce": self.icon = preload("res://Assets/PNGs/UpgradeIcons/SlitherSauceIcon.png")
		"Tenderizer": self.icon = preload("res://Assets/PNGs/UpgradeIcons/TenderizerIcon.png")
		"Juke N Jive": self.icon = preload("res://Assets/PNGs/UpgradeIcons/JukeNJiveIcon.png")
		"Afterburner": self.icon = preload("res://Assets/PNGs/UpgradeIcons/AfterburnerIcon.png")
		"Pop Rocks": self.icon = preload("res://Assets/PNGs/UpgradeIcons/PopRocksIcon.png")
		"Autotomy": self.icon = preload("res://Assets/PNGs/UpgradeIcons/AutotomyIcon.png")
	#-----------Frenzy---------------
		"Sugar Rush": self.icon = preload("res://Assets/PNGs/UpgradeIcons/SugarRushIcon.png")
		"Chain Reaction": self.icon = preload("res://Assets/PNGs/UpgradeIcons/ChainReactionIcon.png")
		"Overdrive": self.icon = preload("res://Assets/PNGs/UpgradeIcons/OverdriveIcon.png")
		"Lingering Rush": self.icon = preload("res://Assets/PNGs/UpgradeIcons/LingeringRushIcon.png")
		"Juggernaut": self.icon = preload("res://Assets/PNGs/UpgradeIcons/JuggernautIcon.png")
		"Zenith": self.icon = preload("res://Assets/PNGs/UpgradeIcons/ZenithIcon.png")
	#-----------Survivor-------------
		"Mulligan Munchie": self.icon = preload("res://Assets/PNGs/UpgradeIcons/MulliganMunchieIcon.png")
		"Last Stand": self.icon = preload("res://Assets/PNGs/UpgradeIcons/LastStandIcon.png")
		"Phoenix Dawn": self.icon = preload("res://Assets/PNGs/UpgradeIcons/PhoenixDawnIcon.png")
		"Sacrificial Molt": self.icon = preload("res://Assets/PNGs/UpgradeIcons/SacrificialMoltIcon.png")
		"Death Defied": self.icon = preload("res://Assets/PNGs/UpgradeIcons/DeathDefiedIcon.png")
		"Martyrdom": self.icon = preload("res://Assets/PNGs/UpgradeIcons/MartyrdomIcon.png")
		"New Game S Plus": self.icon = preload("res://Assets/PNGs/UpgradeIcons/NewGameSPlusIcon.png")
#-----------------------The Ssscale---------------------------------\\\\\\\\\\\\\\\\\\\/////////////////////////////
	#----------Illusionist/Magician------------
		"Ghost Tail": self.icon = preload("res://Assets/PNGs/UpgradeIcons/GhostTailIcon.png")
		"Phase Shift": self.icon = preload("res://Assets/PNGs/UpgradeIcons/PhaseShiftIcon.png")
		"Blink": self.icon = preload("res://Assets/PNGs/UpgradeIcons/BlinkIcon.png")
		"3 Card Monty": self.icon = preload("res://Assets/PNGs/UpgradeIcons/3CardMontyIcon.png")
		"Fractured Self": self.icon = preload("res://Assets/PNGs/UpgradeIcons/FracturedSelfIcon.png")
		"Dazzle Pie": self.icon = preload("res://Assets/PNGs/UpgradeIcons/DazzlePieIcon.png")
	#----------Architect------------
		"Edge Lord": self.icon = preload("res://Assets/PNGs/UpgradeIcons/EdgeLordIcon.png")
		"Zoning Ordinance": self.icon = preload("res://Assets/PNGs/UpgradeIcons/ZoningOrdinanceIcon.png")
		"Border Czar": self.icon = preload("res://Assets/PNGs/UpgradeIcons/BorderCzarIcon.png")
		"Surveyed Land": self.icon = preload("res://Assets/PNGs/UpgradeIcons/SurveyedLandIcon.png")
		"Burrow": self.icon = preload("res://Assets/PNGs/UpgradeIcons/BurrowIcon.png")
		"Pocket Garden": self.icon = preload("res://Assets/PNGs/UpgradeIcons/PocketGardenIcon.png")
		"Fold Space": self.icon = preload("res://Assets/PNGs/UpgradeIcons/FoldSpaceIcon.png")
		"Shatter Reality": self.icon = preload("res://Assets/PNGs/UpgradeIcons/ShatterRealityIcon.png")
		"Masters Blueprint": self.icon = preload("res://Assets/PNGs/UpgradeIcons/MastersBlueprintIcon.png")
#----------------------Snake Eyes------------------------------------\\\\\\\\\\\\\\\\\\/////////////////////////////
		"Coin Flip Curious": self.icon = preload("res://Assets/PNGs/UpgradeIcons/CoinFlipCuriousIcon.png")
		"Passive Income": self.icon = preload("res://Assets/PNGs/UpgradeIcons/PassiveIncomeIcon.png")



# This is the master function that the tab controller will call.
func update_display(p_upgrade_key: String, current_level: int, max_level: int, is_unlocked: bool, main_theme_color: Color, accent_theme_color: Color):
	self.upgrade_key = p_upgrade_key
	
	# Set the button's icon texture.
	get_node_icon_for_upgrade(p_upgrade_key)
	# self.icon = preload(...)

	# We now create a unique StyleBox for each of the button's states.

	# -- The "Normal" Style (when the button is active and clickable) --
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0, 0, 0, 0.4)
	style_normal.border_width_top = 8
	style_normal.border_width_bottom = 8
	style_normal.border_width_left = 8
	style_normal.border_width_right = 8
	
	if current_level >= max_level:
		style_normal.border_color = main_theme_color # A solid gold/accent border when maxed
	else:
		style_normal.border_color = accent_theme_color # The default border color
	
	
	# -- The "Disabled" Style --
	var style_disabled = style_normal.duplicate() # Start with the same settings
	style_disabled.border_color = Color(0.3, 0.3, 0.3, 0.5) # A dull gray for the border
	#----Hovered
	var style_hovered = style_normal.duplicate()
	style_hovered.border_color = Color(main_theme_color.r, main_theme_color.g, main_theme_color.b, max(main_theme_color.a - 0.3, 0.0))
	#----Pressed
	var style_pressed = style_normal.duplicate()
	var pressed_color = main_theme_color.lightened(0.3)
	pressed_color.a = min(main_theme_color.a + 0.2, 1.0)
	style_pressed.border_color = pressed_color
	# Now, apply these new styles to the button's theme.
	self.add_theme_stylebox_override("normal", style_normal)
	self.add_theme_stylebox_override("disabled", style_disabled)
	self.add_theme_stylebox_override("hover", style_hovered)
	self.add_theme_stylebox_override("focus", style_hovered)
	self.add_theme_stylebox_override("pressed", style_pressed)
	
	# --- Update Level Indicators ---
	var indicator_container = $IndicatorContainer
	for child in indicator_container.get_children():
		child.queue_free()
		
	for i in range(1, max_level + 1):
		var block = ColorRect.new()
		block.custom_minimum_size = Vector2(12, 12)
		# We now use the theme color for the "empty" blocks.
		block.color = Color.GOLD if i <= current_level else accent_theme_color.darkened(0.5)
		block.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		block.anchor_left = 0.0
		block.anchor_top = 1.0
		block.anchor_right = 1.0
		block.anchor_bottom = 1.0
		indicator_container.add_child(block)
			
	# Dim the entire node if the prerequisites aren't met
	if not is_unlocked:
		modulate = Color(0.5, 0.5, 0.5)
		disabled = true
	else:
		modulate = Color.WHITE
		disabled = (current_level >= max_level)

# --- Signal Forwarders ---
func _on_pressed():
	emit_signal("node_pressed", upgrade_key)

func _on_mouse_entered():
	emit_signal("node_mouse_entered", upgrade_key)

func _on_mouse_exited():
	emit_signal("node_mouse_exited")
