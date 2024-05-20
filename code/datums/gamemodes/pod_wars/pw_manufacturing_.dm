/obj/machinery/manufacturer/pod_wars
	name = "ship component fabricator"
	desc = "A manufacturing unit calibrated to produce parts for ships."
	icon_state = "fab-hangar"
	icon_base = "hangar"
	var/team_num = 0			//NT = 1, SY = 2
	free_resource_amt = 20
	free_resources = list(
		/obj/item/material_piece/mauxite,
		/obj/item/material_piece/pharosium,
		/obj/item/material_piece/molitz
	)
	available = list(
		/datum/manufacture/pod/preassembeled_parts,
		/datum/manufacture/putt/preassembeled_parts,
		/datum/manufacture/pod_wars/lock,
		/datum/manufacture/engine2,
		/datum/manufacture/engine3,
		/datum/manufacture/pod/lock,
		/datum/manufacture/cargohold,
		/datum/manufacture/storagehold,
		/datum/manufacture/orescoop,
		/datum/manufacture/conclave,
		/datum/manufacture/communications/mining,
		/datum/manufacture/pod/weapon/mining_podwars,
		/datum/manufacture/pod/weapon/mining/drill,
		/datum/manufacture/pod/weapon/ltlaser,
		/datum/manufacture/pod/weapon/mining_weak,
		/datum/manufacture/pod/weapon/taser,
		/datum/manufacture/pod/weapon/laser/short,
		/datum/manufacture/pod/weapon/laser,
		/datum/manufacture/pod/weapon/disruptor,
		/datum/manufacture/pod/weapon/disruptor/light,
		/datum/manufacture/pod/weapon/shotgun
	)

	New()
		START_TRACKING
		..()

	disposing()
		STOP_TRACKING
		..()

	claim_free_resources(datum/game_mode/pod_wars/PW)
		if (team_num == TEAM_NANOTRASEN)
			src.resource_amounts = PW.team_NT.resources
		else if (team_num == TEAM_SYNDICATE)
			src.resource_amounts = PW.team_SY.resources
		..()

	attack_hand(var/mob/user)
		if (get_pod_wars_team_num(user) != src.team_num)
			boutput(user, SPAN_ALERT("This machine's design makes no sense to you, you can't figure out how to use it!"))
			return

		..()

/obj/machinery/manufacturer/pod_wars/nanotrasen
	name = "\improper NanoTrasen ship component fabricator"
	team_num = TEAM_NANOTRASEN
	available = list(
		/datum/manufacture/pod/preassembeled_parts,
		/datum/manufacture/putt/preassembeled_parts,
		/datum/manufacture/pod_wars/lock,
		/datum/manufacture/engine2,
		/datum/manufacture/engine3,
		/datum/manufacture/pod/lock,
		/datum/manufacture/cargohold,
		/datum/manufacture/storagehold,
		/datum/manufacture/orescoop,
		/datum/manufacture/conclave,
		/datum/manufacture/communications/mining,
		/datum/manufacture/pod/weapon/mining_podwars,
		/datum/manufacture/pod/weapon/mining/drill,
		/datum/manufacture/pod/weapon/ltlaser,
		/datum/manufacture/pod/weapon/mining_weak,
		/datum/manufacture/pod/weapon/taser,
		/datum/manufacture/pod/weapon/laser/short,
		/datum/manufacture/pod/weapon/laser,
		/datum/manufacture/pod/weapon/disruptor,
		/datum/manufacture/pod/weapon/disruptor/light,
		/datum/manufacture/pod/weapon/shotgun,
		/datum/manufacture/pod_wars/pod/armor_light/nt,
		/datum/manufacture/pod_wars/pod/armor_robust/nt

	)

/obj/machinery/manufacturer/pod_wars/syndicate
	name = "\improper Syndicate ship component fabricator"
	team_num = TEAM_SYNDICATE
	available = list(
		/datum/manufacture/pod/preassembeled_parts,
		/datum/manufacture/putt/preassembeled_parts,
		/datum/manufacture/pod_wars/lock,
		/datum/manufacture/engine2,
		/datum/manufacture/engine3,
		/datum/manufacture/pod/lock,
		/datum/manufacture/cargohold,
		/datum/manufacture/storagehold,
		/datum/manufacture/orescoop,
		/datum/manufacture/conclave,
		/datum/manufacture/communications/mining,
		/datum/manufacture/pod/weapon/mining_podwars,
		/datum/manufacture/pod/weapon/mining/drill,
		/datum/manufacture/pod/weapon/ltlaser,
		/datum/manufacture/pod/weapon/mining_weak,
		/datum/manufacture/pod/weapon/taser,
		/datum/manufacture/pod/weapon/laser/short,
		/datum/manufacture/pod/weapon/laser,
		/datum/manufacture/pod/weapon/disruptor,
		/datum/manufacture/pod/weapon/disruptor/light,
		/datum/manufacture/pod/weapon/shotgun,
		/datum/manufacture/pod_wars/pod/armor_light/sy,
		/datum/manufacture/pod_wars/pod/armor_robust/sy
		)

////////////////pod-weapons//////////////////
/datum/manufacture/pod/weapon/mining_weak
	name = "Mining Phaser System"
	item_requirements = list(/datum/manufacturing_requirement/metal = 10,
							 /datum/manufacturing_requirement/conductive = 10,
							)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/bad_mining)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/pod/weapon/mining_podwars
	name = "Plasma Cutter System"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 50,
							 /datum/manufacturing_requirement/conductive/high = 50,
							 /datum/manufacturing_requirement/telecrystal = 10,
							)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/mining)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/pod/weapon/taser
	name = "Mk.1 Combat Taser"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 20,
							 /datum/manufacturing_requirement/conductive = 20,
							 /datum/manufacturing_requirement/crystal = 30,
							)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/taser)
	time = 10 SECONDS
	create  = 1
	category = "Tool"

/datum/manufacture/pod/weapon/laser
	name = "Mk.2 Scout Laser"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 25,
							 /datum/manufacturing_requirement/conductive = 40,
							 /datum/manufacturing_requirement/crystal = 30,
							)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/laser)
	time = 10 SECONDS
	create  = 1
	category = "Tool"

/datum/manufacture/pod/weapon/laser/short
	name = "Mk.2 CQ Laser"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 20,
							 /datum/manufacturing_requirement/conductive = 20,
							 /datum/manufacturing_requirement/crystal = 20,
							)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/laser/short)
	time = 10 SECONDS

/datum/manufacture/pod/weapon/disruptor
	name = "Heavy Disruptor Array"
	item_requirements = list(/datum/manufacturing_requirement/metal/superdense = 20,
							 /datum/manufacturing_requirement/conductive/high = 20,
							 /datum/manufacturing_requirement/crystal = 50,
							 /datum/manufacturing_requirement/telecrystal = 20,
							)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/disruptor)
	time = 10 SECONDS
	create  = 1
	category = "Tool"

/datum/manufacture/pod/weapon/disruptor/light
	name = "Mk.3 Disruptor"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 20,
							 /datum/manufacturing_requirement/conductive = 30,
							 /datum/manufacturing_requirement/crystal = 30,
							)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/disruptor_light)
	time = 10 SECONDS
	create  = 1
	category = "Tool"

/datum/manufacture/pod/weapon/ass_laser
	name = "Mk.4 Assault Laser"
	item_requirements = list(/datum/manufacturing_requirement/metal/superdense = 35,
							 /datum/manufacturing_requirement/conductive/high = 30,
							 /datum/manufacturing_requirement/crystal = 30,
							 /datum/manufacturing_requirement/telecrystal = 30,
							)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/laser_ass)
	time = 10 SECONDS
	create  = 1
	category = "Tool"

/datum/manufacture/pod/weapon/shotgun
	name = "SPE-12 Ballistic System"
	item_requirements = list(/datum/manufacturing_requirement/metal/superdense = 50,
							 /datum/manufacturing_requirement/conductive/high = 40,
							 /datum/manufacturing_requirement/crystal = 10,
							)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/gun)
	time = 10 SECONDS
	create  = 1
	category = "Tool"

////////////pod-armor///////////////////////

ABSTRACT_TYPE(/datum/manufacture/pod_wars)

ABSTRACT_TYPE(/datum/manufacture/pod_wars/pod)

/datum/manufacture/pod_wars/pod/armor_light
	name = "Light NT Pod Armor"
	item_requirements = list(/datum/manufacturing_requirement/metal/superdense = 50,
							 /datum/manufacturing_requirement/conductive = 50,
							)
	item_outputs = list(/obj/item/podarmor/armor_light)
	time = 20 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/pod_wars/pod/armor_light/nt
	name = "Light NT Pod Armor"
	item_outputs = list(/obj/item/podarmor/nt_light)

/datum/manufacture/pod_wars/pod/armor_light/sy
	name = "Light Syndicate Pod Armor"
	item_outputs = list(/obj/item/podarmor/sy_light)

/datum/manufacture/pod_wars/pod/armor_robust
	name = "Heavy Pod Armor"
	item_requirements = list(/datum/manufacturing_requirement/metal/superdense = 50,
							 /datum/manufacturing_requirement/conductive/high = 30,
							 /datum/manufacturing_requirement/crystal/dense = 10,
							)
	item_outputs = list(/obj/item/podarmor/armor_heavy)
	time = 30 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/pod_wars/pod/armor_robust/nt
	name = "Robust NT Pod Armor"
	item_outputs = list(/obj/item/podarmor/nt_robust)

/datum/manufacture/pod_wars/pod/armor_robust/sy
	name = "Robust Syndicate Pod Armor"
	item_outputs = list(/obj/item/podarmor/sy_robust)

//costs a good bit more than the standard jetpack. for balance reasons here. to make jetpacks a commodity.
/datum/manufacture/pod_wars/jetpack
	name = "Jetpack"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 30,
							 /datum/manufacturing_requirement/conductive = 50,
							)
	item_outputs = list(/obj/item/tank/jetpack)
	time = 60 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/pod_wars/jetpack/syndicate
	name = "Jetpack"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 30,
							 /datum/manufacturing_requirement/conductive = 50,
							)
	item_outputs = list(/obj/item/tank/jetpack/syndicate)
	time = 60 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/pod_wars/industrialboots
	name = "Mechanised Boots"
	item_requirements = list(/datum/manufacturing_requirement/metal/superdense = 50,
							 /datum/manufacturing_requirement/conductive/high = 50,
							 /datum/manufacturing_requirement/energy/high = 70,
							 /datum/manufacturing_requirement/dense/super = 50,
							)
	item_outputs = list(/obj/item/clothing/shoes/industrial)
	time = 120 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/pod_wars/accumulator
	name = "Mineral Accumulator"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 25,
							 /datum/manufacturing_requirement/conductive/high = 15,
							 /datum/manufacturing_requirement/dense = 2,
							)
	item_outputs = list(/obj/machinery/oreaccumulator)
	time = 120 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/pod_wars/accumulator/syndicate
	name = "Syndicate Mineral Accumulator"
	item_outputs = list(/obj/machinery/oreaccumulator/pod_wars/syndicate)

/datum/manufacture/pod_wars/accumulator/nanotrasen
	name = "NanoTrasen Mineral Accumulator"
	item_outputs = list(/obj/machinery/oreaccumulator/pod_wars/nanotrasen)

/datum/manufacture/pod_wars/medical_refill
	name = "NanoMed Refill Cartridge"
	item_outputs = list(/obj/item/vending/restock_cartridge/medical)
	item_requirements = list(/datum/manufacturing_requirement/metal = 25,
							 /datum/manufacturing_requirement/fabric = 25,
							 /datum/manufacturing_requirement/dense = 20,
							)
	time = 60 SECONDS
	category = "Ammo"

/obj/machinery/manufacturer/mining/pod_wars/
	var/team_num = 0

	New()
		START_TRACKING
		available -= /datum/manufacture/ore_accumulator
		available -= /datum/manufacture/jetpack

		available -= /datum/manufacture/industrialboots
		available += /datum/manufacture/pod_wars/industrialboots

		hidden = list()
		..()

	disposing()
		STOP_TRACKING
		..()

	claim_free_resources(datum/game_mode/pod_wars/PW)
		if (team_num == TEAM_NANOTRASEN)
			src.resource_amounts = PW.team_NT.resources
		else if (team_num == TEAM_SYNDICATE)
			src.resource_amounts = PW.team_SY.resources
		..()

/obj/machinery/manufacturer/mining/pod_wars/syndicate
	team_num = TEAM_SYNDICATE

	New()
		available += /datum/manufacture/pod_wars/accumulator/syndicate
		available += /datum/manufacture/pod_wars/jetpack/syndicate
		..()

/obj/machinery/manufacturer/mining/pod_wars/nanotrasen
	team_num = TEAM_NANOTRASEN

	New()
		available += /datum/manufacture/pod_wars/accumulator/nanotrasen
		available += /datum/manufacture/pod_wars/jetpack
		..()

/obj/machinery/manufacturer/medical/pod_wars
	New()
		available += /datum/manufacture/medical_backpack
		available += /datum/manufacture/pod_wars/medical_refill
		..()


/datum/manufacture/pod_wars/cell_high
	name = "Standard Large Weapon Cell"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 5,
							 /datum/manufacturing_requirement/conductive/high = 20,
							 /datum/manufacturing_requirement/energy = 30,
							)
	item_outputs = list(/obj/item/ammo/power_cell/high_power)
	time = 1 SECONDS
	create = 1
	category = "Ammo"

/datum/manufacture/pod_wars/cell_higher
	name = "Standard Bubs Weapon Cell"
	item_requirements = list(/datum/manufacturing_requirement/metal/superdense = 5,
							 /datum/manufacturing_requirement/conductive/high = 20,
							 /datum/manufacturing_requirement/energy = 60,
							 /datum/manufacturing_requirement/telecrystal = 20,
							)
	item_outputs = list(/obj/item/ammo/power_cell/higher_power)
	time = 1 SECONDS
	create = 1
	category = "Ammo"

////////////////////////////

/datum/manufacture/pod_wars/cell_pod_wars_basic
	name = "Basic Self-Charging Weapon Cell"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 10,
							 /datum/manufacturing_requirement/dense = 20,
							 /datum/manufacturing_requirement/conductive/high = 30,
							 /datum/manufacturing_requirement/energy = 30,
							)
	item_outputs = list(/obj/item/ammo/power_cell/self_charging/pod_wars_basic)
	time = 1 SECONDS
	create = 1
	category = "Ammo"

/datum/manufacture/pod_wars/cell_pod_wars_standard
	name = "Standard Self-Charging Weapon Cell"
	item_requirements = list(/datum/manufacturing_requirement/dense/super = 30,
							 /datum/manufacturing_requirement/conductive/high = 60,
							 /datum/manufacturing_requirement/energy = 50,
							 /datum/manufacturing_requirement/telecrystal = 10,
							)
	item_outputs = list(/obj/item/ammo/power_cell/self_charging/pod_wars_standard)
	time = 1 SECONDS
	create = 1
	category = "Ammo"

/datum/manufacture/pod_wars/cell_pod_wars_high
	name = "Robust Self-Charging Weapon Cell"
	item_requirements = list(/datum/manufacturing_requirement/dense/super = 30,
							 /datum/manufacturing_requirement/conductive/high = 70,
							 /datum/manufacturing_requirement/energy/high = 30,
							 /datum/manufacturing_requirement/telecrystal = 30,
							)
	item_outputs = list(/obj/item/ammo/power_cell/self_charging/pod_wars_high)
	time = 1 SECONDS
	create = 1
	category = "Ammo"



//It's cheap, use it!
/datum/manufacture/pod_wars/lock
	name = "Pod Lock (ID Card)"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							)
	item_outputs = list(/obj/item/shipcomponent/secondary_system/lock/pw_id)
	time = 1 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/pod_wars/barricade
	name = "Deployable Barricade"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 5,
							)
	item_outputs = list(/obj/item/deployer/barricade)
	time = 1 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/pod_wars/energy_concussion_grenade

	name = "Concussion Grenade"
	item_requirements = list(/datum/manufacturing_requirement/metal = 5,
							 /datum/manufacturing_requirement/conductive = 5,
							 /datum/manufacturing_requirement/telecrystal = 5,
							)
	item_outputs = list(/obj/item/old_grenade/energy_concussion)
	time = 1 SECONDS
	create = 1
	category = "Weapon"

/datum/manufacture/pod_wars/energy_frag_grenade

	name = "Blast Grenade"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 5,
							 /datum/manufacturing_requirement/conductive/high = 5,
							 /datum/manufacturing_requirement/telecrystal = 5,
							)
	item_outputs = list(/obj/item/old_grenade/energy_frag)
	time = 1 SECONDS
	create = 1
	category = "Weapon"

/datum/manufacture/pod_wars/handcuffs

	name = "Handcuffs"
	item_requirements = list(/datum/manufacturing_requirement/metal = 5,
							)
	item_outputs = list(/obj/item/handcuffs)
	time = 2 SECONDS
	create = 1
	category = "Weapon"


/obj/machinery/chem_dispenser/medical
	name = "medical reagent dispenser"
	desc = "It dispenses chemicals. Mostly harmless ones, but who knows?"
	dispensable_reagents = list("antihol", "charcoal", "epinephrine", "mutadone", "proconvertin", "atropine",\
		 "salbutamol", "anti_rad",\
		"oculine", "mannitol", "saline",\
		"salicylic_acid", "blood",\
		"menthol", "antihistamine")

	icon_state = "dispenser"
	icon_base = "dispenser"
	dispenser_name = "Medical"


/obj/machinery/chem_dispenser/medical/fortuna
	dispensable_reagents = list("antihol", "charcoal", "epinephrine", "mutadone", "proconvertin", "filgrastim", "atropine",\
	"salbutamol", "perfluorodecalin", "synaptizine", "anti_rad",\
	"oculine", "mannitol", "penteticacid", "saline",\
	"salicylic_acid", "blood", \
	"menthol", "antihistamine", "smelling_salt")

/obj/machinery/manufacturer/general/pod_wars
	New()
		#ifdef RP_MODE
		available += /datum/manufacture/pod_wars/handcuffs
		#endif
		available += /datum/manufacture/pod_wars/barricade
		available += /datum/manufacture/pod_wars/energy_frag_grenade
		available += /datum/manufacture/pod_wars/energy_concussion_grenade
		available += /datum/manufacture/pod_wars/cell_pod_wars_basic
		available += /datum/manufacture/pod_wars/cell_pod_wars_standard
		available += /datum/manufacture/pod_wars/cell_pod_wars_high
		available += /datum/manufacture/pod_wars/cell_high
		available += /datum/manufacture/pod_wars/cell_higher

		hidden = list()
		..()
