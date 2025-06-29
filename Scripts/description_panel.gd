extends PanelContainer

# --- NODE REFERENCES ---
# Make sure these paths are correct for your scene!
@onready var icon_display = $MarginC/GridContainer/IconDisplay
@onready var name_label = $MarginC/GridContainer/UpgradeNameLabel
@onready var description_label = $MarginC/GridContainer/DescriptionLabel
@onready var cost_label = $MarginC/GridContainer/CostLabel

# This is the master function that main.gd will call.
func show_info(upgrade_key: String, p_name: String, p_description: String, p_cost: int):
	name_label.text = p_name
	description_label.text = p_description
	
	# If the cost is 999, it means the upgrade is maxed out.
	if p_cost >= 999:
		cost_label.text = "(MAX LEVEL)"
	else:
		cost_label.text = "Cost: %s Juice" % p_cost
	
	icon_display.texture = get_icon_for_upgrade(upgrade_key)	
		
	self.visible = true

func get_icon_for_upgrade(icon_upgrade_key: String) -> Texture:
	match icon_upgrade_key:
		#--------------------------The Core----------------------------\\\\\\\\\\\\\\\\\\\\\\\\\\\//////////////////////////////////
	#---------Idle-------------
		"Snake Clicker": return preload("res://Assets/PNGs/UpgradeIcons/SnakeClickerIcon.png")
		"Get Rich Quick": return preload("res://Assets/PNGs/UpgradeIcons/get_rich_quick_icon.png")
		"Custom Aftertaste": return preload("res://Assets/PNGs/UpgradeIcons/CustomAfterTasteIcon.png")
		"Arcane Flow": return preload("res://Assets/PNGs/UpgradeIcons/ArcaneFlowIcon.png")
		"Pulp Reactor": return preload("res://Assets/PNGs/UpgradeIcons/PulpReactorIcon.png")
		"Unstable Metabolism": return preload("res://Assets/PNGs/UpgradeIcons/UnstableMetabolismIcon.png")
	#-----------Planner-----------
		"Diet Slith": return preload("res://Assets/PNGs/UpgradeIcons/DietSlithIcon.png")
		"Fruit Foresight": return preload("res://Assets/PNGs/UpgradeIcons/FruitForesightIcon.png")
		"Geological Survey": return preload("res://Assets/PNGs/UpgradeIcons/GeologicalSurveyIcon.png")
		"Sovereign Trail": return preload("res://Assets/PNGs/UpgradeIcons/SovereignTrailIcon.png")
		"Meditate": return preload("res://Assets/PNGs/UpgradeIcons/MeditateIcon.png")
		"Garden Weaver": return preload("res://Assets/PNGs/UpgradeIcons/GardenWeaverIcon.png")
	#-----------Ledger------------
		#----Path A
		"Liquid Assets": return preload("res://Assets/PNGs/UpgradeIcons/LiquidAssetsIcon.png")
		"Fast Track": return preload("res://Assets/PNGs/UpgradeIcons/WormholeIcon.png")
		"Gluttons Greed": return preload("res://Assets/PNGs/UpgradeIcons/GluttonsGreedIcon.png")
		"Market Crash": return preload("res://Assets/PNGs/UpgradeIcons/MarketCrashIcon.png")
		#----Path B
		"Principal Pulp": return preload("res://Assets/PNGs/UpgradeIcons/PrincipalPulpIcon.png")
		"Golden Handshake": return preload("res://Assets/PNGs/UpgradeIcons/GoldenHandshakeIcon.png")
		"Juice Press": return preload("res://Assets/PNGs/UpgradeIcons/JuicePressIcon.png")
		"Liquidation": return preload("res://Assets/PNGs/UpgradeIcons/LiquidationIcon.png")
#-------------------------The Harvest-----------------------------\\\\\\\\\\\\\\\\\\\\\////////////////////////////
	#------------Glutton-------------
		"Elephant Sized Portions": return preload("res://Assets/PNGs/UpgradeIcons/ESPortionsIcon.png")
		"More Mice": return preload("res://Assets/PNGs/UpgradeIcons/MoreMiceIcon.png")
		"Golden Seeds": return preload("res://Assets/PNGs/UpgradeIcons/GoldenSeedsIcon.png")
		"Patient Gardener": return preload("res://Assets/PNGs/UpgradeIcons/PatientGardenerIcon.png")
		"Banana Bounty": return preload("res://Assets/PNGs/UpgradeIcons/BananaBountyIcon.png")
		"The Satchel": return preload("res://Assets/PNGs/UpgradeIcons/TheSatchelIcon.png")
	#------------Chef----------------
		"Golden Seed Extract": return preload("res://Assets/PNGs/UpgradeIcons/GoldenSeedExtractIcon.png")
		"Exotic Seeds": return preload("res://Assets/PNGs/UpgradeIcons/ExoticSeedsIcon.png")
		"The Cookbook": return preload("res://Assets/PNGs/UpgradeIcons/TheCookbookIcon.png")
		"Expanded Palate": return preload("res://Assets/PNGs/UpgradeIcons/ExpandedPalateIcon.png")
		"Golden Glaze": return preload("res://Assets/PNGs/UpgradeIcons/GoldenGlazeIcon.png")
		"Custom Cuisine": return preload("res://Assets/PNGs/UpgradeIcons/CustomCuisineIcon.png")
		"Mise en Place": return preload("res://Assets/PNGs/UpgradeIcons/MiseenPlaceIcon.png")
	#-----------Geomancer------------
		"Fertile Ground": return preload("res://Assets/PNGs/UpgradeIcons/FertileGroundIcon.png")
		"Rockmuncher": return preload("res://Assets/PNGs/UpgradeIcons/RockmuncherIcon.png")
		"Mineral Rich Soil": return preload("res://Assets/PNGs/UpgradeIcons/MaterialRichSoilIcon.png")
		"Geode Cracker": return preload("res://Assets/PNGs/UpgradeIcons/GeodeCrackerIcon.png")
		"Tectonic Shift": return preload("res://Assets/PNGs/UpgradeIcons/TectonicShiftIcon.png")
		"Kinetic Feast": return preload("res://Assets/PNGs/UpgradeIcons/KineticFeastIcon.png")
		"Heavy Foundation": return preload("res://Assets/PNGs/UpgradeIcons/HeavyFoundationIcon.png")
		"Stones Burden": return preload("res://Assets/PNGs/UpgradeIcons/StonesBurdenIcon.png")
		"Calculated Risk": return preload("res://Assets/PNGs/UpgradeIcons/CalculatedRiskIcon.png")
#------------------------The Redliner------------------------------\\\\\\\\\\\\\\\\\\\\////////////////////////////
	#-----------Acrobat--------------
		"Slither Sauce": return preload("res://Assets/PNGs/UpgradeIcons/SlitherSauceIcon.png")
		"Tenderizer": return preload("res://Assets/PNGs/UpgradeIcons/TenderizerIcon.png")
		"Juke N Jive": return preload("res://Assets/PNGs/UpgradeIcons/JukeNJiveIcon.png")
		"Afterburner": return preload("res://Assets/PNGs/UpgradeIcons/AfterburnerIcon.png")
		"Pop Rocks": return preload("res://Assets/PNGs/UpgradeIcons/PopRocksIcon.png")
		"Autotomy": return preload("res://Assets/PNGs/UpgradeIcons/AutotomyIcon.png")
	#-----------Frenzy---------------
		"Sugar Rush": return preload("res://Assets/PNGs/UpgradeIcons/SugarRushIcon.png")
		"Chain Reaction": return preload("res://Assets/PNGs/UpgradeIcons/ChainReactionIcon.png")
		"Overdrive": return preload("res://Assets/PNGs/UpgradeIcons/OverdriveIcon.png")
		"Lingering Rush": return preload("res://Assets/PNGs/UpgradeIcons/LingeringRushIcon.png")
		"Juggernaut": return preload("res://Assets/PNGs/UpgradeIcons/JuggernautIcon.png")
		"Zenith": return preload("res://Assets/PNGs/UpgradeIcons/ZenithIcon.png")
	#-----------Survivor-------------
		"Mulligan Munchie": return preload("res://Assets/PNGs/UpgradeIcons/MulliganMunchieIcon.png")
		"Last Stand": return preload("res://Assets/PNGs/UpgradeIcons/LastStandIcon.png")
		"Phoenix Dawn": return preload("res://Assets/PNGs/UpgradeIcons/PhoenixDawnIcon.png")
		"Sacrificial Molt": return preload("res://Assets/PNGs/UpgradeIcons/SacrificialMoltIcon.png")
		"Death Defied": return preload("res://Assets/PNGs/UpgradeIcons/DeathDefiedIcon.png")
		"Martyrdom": return preload("res://Assets/PNGs/UpgradeIcons/MartyrdomIcon.png")
		"New Game S Plus": return preload("res://Assets/PNGs/UpgradeIcons/NewGameSPlusIcon.png")
#-----------------------The Ssscale---------------------------------\\\\\\\\\\\\\\\\\\\/////////////////////////////
	#----------Illusionist/Magician------------
		"Ghost Tail": return preload("res://Assets/PNGs/UpgradeIcons/GhostTailIcon.png")
		"Phase Shift": return preload("res://Assets/PNGs/UpgradeIcons/PhaseShiftIcon.png")
		"Blink": return preload("res://Assets/PNGs/UpgradeIcons/BlinkIcon.png")
		"3 Card Monty": return preload("res://Assets/PNGs/UpgradeIcons/3CardMontyIcon.png")
		"Fractured Self": return preload("res://Assets/PNGs/UpgradeIcons/FracturedSelfIcon.png")
		"Dazzle Pie": return preload("res://Assets/PNGs/UpgradeIcons/DazzlePieIcon.png")
	#----------Architect------------
		"Edge Lord": return preload("res://Assets/PNGs/UpgradeIcons/EdgeLordIcon.png")
		"Zoning Ordinance": return preload("res://Assets/PNGs/UpgradeIcons/ZoningOrdinanceIcon.png")
		"Border Czar": return preload("res://Assets/PNGs/UpgradeIcons/BorderCzarIcon.png")
		"Surveyed Land": return preload("res://Assets/PNGs/UpgradeIcons/SurveyedLandIcon.png")
		"Burrow": return preload("res://Assets/PNGs/UpgradeIcons/BurrowIcon.png")
		"Pocket Garden": return preload("res://Assets/PNGs/UpgradeIcons/PocketGardenIcon.png")
		"Fold Space": return preload("res://Assets/PNGs/UpgradeIcons/FoldSpaceIcon.png")
		"Shatter Reality": return preload("res://Assets/PNGs/UpgradeIcons/ShatterRealityIcon.png")
		"Masters Blueprint": return preload("res://Assets/PNGs/UpgradeIcons/MastersBlueprintIcon.png")
#----------------------Snake Eyes------------------------------------\\\\\\\\\\\\\\\\\\/////////////////////////////
		"Coin Flip Curious": return preload("res://Assets/PNGs/UpgradeIcons/CoinFlipCuriousIcon.png")
		"Passive Income": return preload("res://Assets/PNGs/UpgradeIcons/PassiveIncomeIcon.png")
#-------------------------------Pulpsicle Stand---------------------#\\\\\\\\\\\\\\\\\\//////////////////////////////
		"Synapse Slot": return preload("res://Assets/PNGs/UpgradeIcons/SynapseSlotIcon.png")
		"Chroma Scales": return preload("res://Assets/PNGs/UpgradeIcons/ChromaScalesIcon.png")
		"Serpents Coffer": return preload("res://Assets/PNGs/UpgradeIcons/SerpentsCofferIcon.png")
		"Geode Compass": return preload("res://Assets/PNGs/UpgradeIcons/GeodeCompassIcon.png")
		"Four Leaf Clover": return preload("res://Assets/PNGs/UpgradeIcons/FourLeafCloverIcon.png") 
		"Lasso Larry": return preload("res://Assets/PNGs/UpgradeIcons/LassoLarryIcon.png")
		"Harvest Forecast": return preload("res://Assets/PNGs/UpgradeIcons/HarvestForecastIcon.png") 
#-------------------------------Rotating Items IDs---------------------#\\\\\\\\\\\\\\\\\\//////////////////////////////
	#------------Commons---------
		"juice_box": return preload("res://Assets/PNGs/RotatingItemIcons/juice_box_icon.png")
	#------------Rares-----------
		"handicap": return preload("res://Assets/PNGs/RotatingItemIcons/handicap_icon.png")
	#----------Legendary---------
		"elephant_devoured": return preload("res://Assets/PNGs/RotatingItemIcons/elephant_devoured_icon.png")
		#--------DEFAULT-------
		_:
			return preload("res://Assets/PNGs/basic_square_with_border.png")
	
