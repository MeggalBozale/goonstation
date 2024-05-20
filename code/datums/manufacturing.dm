proc/get_nice_mat_name_for_manufacturers(mat)
	if(mat in material_category_names)
		return material_category_names[mat]
	else
		var/datum/material/nice_mat = getMaterial(mat)
		if (istype(nice_mat))
			return capitalize(nice_mat.getName())
		return capitalize(mat) //if all else fails (probably a category instead of a material)

ABSTRACT_TYPE(/datum/manufacture)
/datum/manufacture
	var/name = null                // Name of the schematic
	var/list/item_requirements = null   // Materials required to Amount required (generate from `mats` if null)
	var/list/item_names = list()   // Player-read name of each material
	var/list/item_outputs = list() // What the schematic outputs
	var/randomise_output = 0
	// 0 - will create each item in the list once per loop (see manufacturer.dm Line 755)
	// 1 - will pick() a random item in the list once per loop
	// 2 - will pick() a random item before the loop begins then output one of the selected item each loop
	var/create = 1                 // How many times it'll make each thing in the list
	var/time = 5                   // How long it takes to build
	var/category = null            // Tool, Clothing, Resource, Component, Machinery or Miscellaneous
	var/sanity_check_exemption = 0
	var/apply_material = 0

	New()
		..()
		if(isnull(item_requirements) && length(item_outputs) == 1) // TODO generalize to multiple outputs (currently no such manufacture recipes exist)
			var/item_type = item_outputs[1]
			src.use_generated_costs(item_type)

		if(isnull(item_requirements))
			item_requirements = list() // a bunch of places expect this to be non-null, like the sanity check
		if (!length(src.item_names))
			for (var/path in src.item_requirements)
				src.item_names += get_nice_mat_name_for_manufacturers(path)
		if (!sanity_check_exemption)
			src.sanity_check()

	proc/use_generated_costs(obj/item_type)
		var/typeinfo/obj/typeinfo = get_type_typeinfo(item_type)
		if(istype(typeinfo) && islist(typeinfo.mats))
			item_requirements = list()
			for(var/mat in typeinfo.mats)
				var/amt = typeinfo.mats[mat]
				if(isnull(amt))
					amt = 1
				item_requirements[mat] = amt

	proc/sanity_check()
		for (var/requirement in src.item_requirements)
			if (isnull(src.item_requirements[requirement]))
				logTheThing(LOG_DEBUG, null, "<b>Manufacturer:</b> [src.name]/[src.type] schematic requirement list not properly configured")
		if (length(src.item_requirements) != length(src.item_names))
			logTheThing(LOG_DEBUG, null, "<b>Manufacturer:</b> [src.name]/[src.type] schematic requirement list not properly configured")
			qdel(src)
			return
		if (!src.item_outputs.len)
			logTheThing(LOG_DEBUG, null, "<b>Manufacturer:</b> [src.name]/[src.type] schematic output list not properly configured")
			qdel(src)
			return

	proc/modify_output(var/obj/machinery/manufacturer/M, var/atom/A, var/list/materials)
		// use this if you want the outputted item to be customised in any way by the manufacturer
		if (M.malfunction && length(M.text_bad_output_adjective) > 0 && prob(66))
			A.name = "[pick(M.text_bad_output_adjective)] [A.name]"
			//A.quality -= rand(25,50)
		if (src.apply_material && length(materials) > 0)
			A.setMaterial(M.get_our_material(materials[materials[1]]))
		return 1

/datum/manufacture/mechanics
	name = "Reverse-Engineered Schematic"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							 /datum/manufacturing_requirement/conductive = 1,
							 /datum/manufacturing_requirement/crystal = 1,
							)
	item_outputs = list(/obj/item/electronics/frame)
	var/frame_path = null
	///generate costs based off of frame_path in New(), e.g.: for pre-spawned cloner blueprints
	var/generate_costs = FALSE

	New()
		. = ..()
		if(src.generate_costs)
			src.item_requirements = list()
			src.use_generated_costs(frame_path)

	modify_output(var/obj/machinery/manufacturer/M, var/atom/A, var/list/materials)
		if (!(..()))
			return

		if (istype(A,/obj/item/electronics/frame/))
			var/obj/item/electronics/frame/F = A
			if (ispath(src.frame_path))
				if(src.apply_material && length(materials) > 0)
					F.removeMaterial()
					var/atom/thing = new frame_path(F)
					thing.setMaterial(M.get_our_material(materials[materials[1]]))
					F.deconstructed_thing = thing
				else
					F.store_type = src.frame_path
				F.name = "[src.name] frame"
				F.viewstat = 2
				F.secured = 2
				F.icon_state = "dbox"
			else
				qdel(F)
				return 1

/******************** Cloner *******************/

/datum/manufacture/mechanics/clonepod
	name = "cloning pod"
	time = 30 SECONDS
	create = 1
	frame_path = /obj/machinery/clonepod
	generate_costs = TRUE

/datum/manufacture/mechanics/clonegrinder
	name = "enzymatic reclaimer"
	time = 18 SECONDS
	create = 1
	frame_path = /obj/machinery/clonegrinder
	generate_costs = TRUE

/datum/manufacture/mechanics/clone_scanner
	name = "cloning machine scanner"
	time = 30 SECONDS
	create = 1
	frame_path = /obj/machinery/clone_scanner
	generate_costs = TRUE


/******************** Loafer *******************/

/datum/manufacture/mechanics/loafer
	name = "loafer (deploy on plating)"
	time = 30 SECONDS
	create = 1
	frame_path = /obj/disposalpipe/loafer

/******************** Communications Dish *******************/

/datum/manufacture/mechanics/comms_dish
	name = "Communications Dish"
	item_requirements = list(/datum/manufacturing_requirement/metal = 20,
							 /datum/manufacturing_requirement/metal/dense = 10,
							 /datum/manufacturing_requirement/insulated = 20,
							 /datum/manufacturing_requirement/conductive = 20,
							)
	time = 60 SECONDS
	create = 1
	frame_path = /obj/machinery/communications_dish

/******************** AI Law Rack *******************/

/datum/manufacture/mechanics/lawrack
	name = "AI Law Rack Mount"
	item_requirements = list(/datum/manufacturing_requirement/metal = 20,
							 /datum/manufacturing_requirement/metal/dense = 5,
							 /datum/manufacturing_requirement/insulated = 10,
							 /datum/manufacturing_requirement/conductive = 10,
							)
	time = 60 SECONDS
	create = 1
	frame_path = /obj/machinery/lawrack

/******************** AI display (temp) *******************/

/datum/manufacture/mechanics/ai_status_display
	name = "AI display"
	time = 5 SECONDS
	create = 1
	frame_path = /obj/machinery/ai_status_display
	generate_costs = TRUE

/******************** Laser beam things *******************/

/datum/manufacture/mechanics/laser_mirror
	name = "Laser Mirror"
	item_requirements = list(/datum/manufacturing_requirement/metal = 10,
							 /datum/manufacturing_requirement/crystal = 10,
							 /datum/manufacturing_requirement/reflective = 30,
							)
	frame_path = /obj/laser_sink/mirror
	time = 45 SECONDS
	create = 1

/datum/manufacture/mechanics/laser_splitter //I'm going to regret this
	name = "Beam Splitter"
	item_requirements = list(/datum/manufacturing_requirement/metal = 20,
							 /datum/manufacturing_requirement/crystal/dense = 20,
							 /datum/manufacturing_requirement/reflective = 30,
							)
	frame_path = /obj/laser_sink/splitter
	time = 90 SECONDS
	create = 1
/datum/manufacture/mechanics/gunbot
	name = "Security Robot"
	item_requirements = list(/datum/manufacturing_requirement/energy = 10,
							 /datum/manufacturing_requirement/metal/dense = 10,
							 /datum/manufacturing_requirement/conductive = 10,
							)
	frame_path = /mob/living/critter/robotic/gunbot
	time = 15 SECONDS
	create = 1

/*
/datum/manufacture/iron
	// purely a test
	name = "Iron"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							)
	item_outputs = list("reagent-iron")
	time = 1 SECONDS
	create = 10
	category = "Resource"
*/

/datum/manufacture/crowbar
	name = "Crowbar"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							)
	item_outputs = list(/obj/item/crowbar/green)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/screwdriver
	name = "Screwdriver"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							)
	item_outputs = list(/obj/item/screwdriver/green)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/wirecutters
	name = "Wirecutters"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							)
	item_outputs = list(/obj/item/wirecutters/green)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/wrench
	name = "Wrench"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							)
	item_outputs = list(/obj/item/wrench/green)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/crowbar/yellow
	name = "Crowbar"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							)
	item_outputs = list(/obj/item/crowbar/yellow)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/screwdriver/yellow
	name = "Screwdriver"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							)
	item_outputs = list(/obj/item/screwdriver/yellow)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/wirecutters/yellow
	name = "Wirecutters"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							)
	item_outputs = list(/obj/item/wirecutters/yellow)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/wrench/yellow
	name = "Wrench"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							)
	item_outputs = list(/obj/item/wrench/yellow)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/flashlight
	name = "Flashlight"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							 /datum/manufacturing_requirement/conductive = 1,
							 /datum/manufacturing_requirement/crystal = 1,
							)
	item_outputs = list(/obj/item/device/light/flashlight)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/vuvuzela
	name = "Vuvuzela"
	item_requirements = list(/datum/manufacturing_requirement/any = 1,
							)
	item_outputs = list(/obj/item/instrument/vuvuzela)
	time = 5 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/harmonica
	name = "Harmonica"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							)
	item_outputs = list(/obj/item/instrument/harmonica)
	time = 5 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/bottle
	name = "Glass Bottle"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 1,
							)
	item_outputs = list(/obj/item/reagent_containers/food/drinks/bottle/soda)
	time = 4 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/saxophone
	name = "Saxophone"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 15,
							)
	item_outputs = list(/obj/item/instrument/saxophone)
	time = 7 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/whistle
	name = "Whistle"
	item_requirements = list(/datum/manufacturing_requirement/metal/superdense = 5,
							)
	item_outputs = list(/obj/item/instrument/whistle)
	time = 3 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/trumpet
	name = "Trumpet"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 10,
							)
	item_outputs = list(/obj/item/instrument/trumpet)
	time = 6 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/bagpipe
	name = "Bagpipe"
	item_requirements = list(/datum/manufacturing_requirement/fabric 10,
							 /datum/manufacturing_requirement/metal/dense = 25,
							)
	item_outputs = list(/obj/item/instrument/bagpipe)
	time = 5 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/fiddle
	name = "Fiddle"
	item_requirements = list(/datum/manufacturing_requirement/wood = 25,
							 /datum/manufacturing_requirement/fabric 10,
							)
	item_outputs = list(/obj/item/instrument/fiddle)
	time = 5 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/bikehorn
	name = "Bicycle Horn"
	item_requirements = list(/datum/manufacturing_requirement/any = 1,
							)
	item_outputs = list(/obj/item/instrument/bikehorn)
	time = 5 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/stunrounds
	name = ".38 Stunner Rounds"
	item_requirements = list(/datum/manufacturing_requirement/metal = 3,
							 /datum/manufacturing_requirement/conductive = 2,
							 /datum/manufacturing_requirement/crystal = 2,
							)
	item_outputs = list(/obj/item/ammo/bullets/a38/stun)
	time = 20 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/bullet_22
	name = ".22 Bullets"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 30,
							 /datum/manufacturing_requirement/conductive = 24,
							)
	item_outputs = list(/obj/item/ammo/bullets/bullet_22)
	time = 30 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/bullet_12g_nail
	name = "12 gauge nailshot"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 40,
							 /datum/manufacturing_requirement/conductive = 30,
							)
	item_outputs = list(/obj/item/ammo/bullets/nails)
	time = 30 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/bullet_smoke
	name = "40mm Smoke Grenade"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 30,
							 /datum/manufacturing_requirement/conductive = 25,
							)
	item_outputs = list(/obj/item/ammo/bullets/smoke)
	time = 35 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/extinguisher
	name = "Fire Extinguisher"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 1,
							 /datum/manufacturing_requirement/crystal = 1,
							)
	item_outputs = list(/obj/item/extinguisher)
	time = 8 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/welder
	name = "Welding Tool"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 1,
							 /datum/manufacturing_requirement/conductive = 1,
							)
	item_outputs = list(/obj/item/weldingtool/green)
	time = 8 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/welder/yellow
	name = "Welding Tool"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 1,
							 /datum/manufacturing_requirement/conductive = 1,
							)
	item_outputs = list(/obj/item/weldingtool/yellow)
	time = 8 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/soldering
	name = "Soldering Iron"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 1,
							 /datum/manufacturing_requirement/conductive = 2,
							)
	item_outputs = list(/obj/item/electronics/soldering)
	time = 8 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/stapler
	name = "Staple Gun"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 2,
							 /datum/manufacturing_requirement/conductive = 1,
							)
	item_outputs = list(/obj/item/staple_gun)
	time = 10 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/multitool
	name = "Multi Tool"
	item_outputs = list(/obj/item/device/multitool)
	time = 8 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/t_scanner
	name = "T-ray scanner"
	item_outputs = list(/obj/item/device/t_scanner)
	time = 8 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/weldingmask
	name = "Welding Mask"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 2,
							 /datum/manufacturing_requirement/crystal = 2,
							)
	item_outputs = list(/obj/item/clothing/head/helmet/welding)
	time = 10 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/light_bulb
	name = "Light Bulb Box"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 1,
							)
	item_outputs = list(/obj/item/storage/box/lightbox/bulbs)
	time = 4 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/red_bulb
	name = "Red Light Bulb Box"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 1,
							 /datum/manufacturing_requirement/conductive = 1,
							)
	item_outputs = list(/obj/item/storage/box/lightbox/bulbs/red)
	time = 8 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/yellow_bulb
	name = "Yellow Light Bulb Box"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 1,
							 /datum/manufacturing_requirement/conductive = 1,
							)
	item_outputs = list(/obj/item/storage/box/lightbox/bulbs/yellow)
	time = 8 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/green_bulb
	name = "Green Light Bulb Box"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 1,
							 /datum/manufacturing_requirement/conductive = 1,
							)
	item_outputs = list(/obj/item/storage/box/lightbox/bulbs/green)
	time = 8 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/cyan_bulb
	name = "Cyan Light Bulb Box"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 1,
							 /datum/manufacturing_requirement/conductive = 1,
							)
	item_outputs = list(/obj/item/storage/box/lightbox/bulbs/cyan)
	time = 8 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/blue_bulb
	name = "Blue Light Bulb Box"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 1,
							 /datum/manufacturing_requirement/conductive = 1,
							)
	item_outputs = list(/obj/item/storage/box/lightbox/bulbs/blue)
	time = 8 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/purple_bulb
	name = "Purple Light Bulb Box"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 1,
							 /datum/manufacturing_requirement/conductive = 1,
							)
	item_outputs = list(/obj/item/storage/box/lightbox/bulbs/purple)
	time = 8 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/blacklight_bulb
	name = "Blacklight Bulb Box"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 1,
							 /datum/manufacturing_requirement/conductive = 1,
							)
	item_outputs = list(/obj/item/storage/box/lightbox/bulbs/blacklight)
	time = 8 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/light_tube
	name = "Light Tube Box"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 1,
							)
	item_outputs = list(/obj/item/storage/box/lightbox/tubes)
	time = 4 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/red_tube
	name = "Red Light Tube Box"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 1,
							 /datum/manufacturing_requirement/conductive = 1,
							)
	item_outputs = list(/obj/item/storage/box/lightbox/tubes/red)
	time = 8 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/yellow_tube
	name = "Yellow Light Tube Box"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 1,
							 /datum/manufacturing_requirement/conductive = 1,
							)
	item_outputs = list(/obj/item/storage/box/lightbox/tubes/yellow)
	time = 8 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/green_tube
	name = "Green Light Tube Box"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 1,
							 /datum/manufacturing_requirement/conductive = 1,
							)
	item_outputs = list(/obj/item/storage/box/lightbox/tubes/green)
	time = 8 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/cyan_tube
	name = "Cyan Light Tube Box"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 1,
							 /datum/manufacturing_requirement/conductive = 1,
							)
	item_outputs = list(/obj/item/storage/box/lightbox/tubes/cyan)
	time = 8 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/blue_tube
	name = "Blue Light Tube Box"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 1,
							 /datum/manufacturing_requirement/conductive = 1,
							)
	item_outputs = list(/obj/item/storage/box/lightbox/tubes/blue)
	time = 8 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/purple_tube
	name = "Purple Light Tube Box"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 1,
							 /datum/manufacturing_requirement/conductive = 1,
							)
	item_outputs = list(/obj/item/storage/box/lightbox/tubes/purple)
	time = 8 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/blacklight_tube
	name = "Blacklight Tube Box"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 1,
							 /datum/manufacturing_requirement/conductive = 1,
							)
	item_outputs = list(/obj/item/storage/box/lightbox/tubes/blacklight)
	time = 8 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/table_folding
	name = "Folding Table"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							 /datum/manufacturing_requirement/any = 2,
							)
	item_outputs = list(/obj/item/furniture_parts/table/folding)
	time = 20 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/metal
	name = "Metal Sheet"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							)
	item_outputs = list(/obj/item/sheet)
	time = 2 SECONDS
	create = 1
	category = "Resource"
	apply_material = 1

/datum/manufacture/metalR
	name = "Reinforced Metal"
	item_requirements = list(/datum/manufacturing_requirement/metal = 2,
							)
	item_outputs = list(/obj/item/sheet)
	time = 12 SECONDS
	create = 1
	category = "Resource"
	apply_material = 1

	modify_output(var/obj/machinery/manufacturer/M, var/atom/A, var/list/materials)
		..()
		var/obj/item/sheet/S = A
		S.set_reinforcement(getMaterial(materials["MET-1"]))

/datum/manufacture/glass
	name = "Glass Panel"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 5,
							)
	item_outputs = list(/obj/item/sheet)
	time = 8 SECONDS
	create = 5
	category = "Resource"
	apply_material = 1

/datum/manufacture/glassR
	name = "Reinforced Glass Panel"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 1,
							 /datum/manufacturing_requirement/metal/dense = 1,
							)
	item_outputs = list(/obj/item/sheet/glass/reinforced)
	time = 12 SECONDS
	create = 1
	category = "Resource"
	apply_material = 1

	modify_output(var/obj/machinery/manufacturer/M, var/atom/A, var/list/materials)
		..()
		var/obj/item/sheet/S = A
		S.set_reinforcement(getMaterial(materials["CRY-1"]))

/datum/manufacture/rods2
	name = "Metal Rods (x2)"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 1,
							)
	item_outputs = list(/obj/item/rods)
	time = 3 SECONDS
	category = "Resource"
	apply_material = 1

	modify_output(var/obj/machinery/manufacturer/M, var/atom/A)
		..()
		var/obj/item/sheet/S = A // this way they are instantly stacked rather than just 2 rods
		S.amount = 2
		S.inventory_counter.update_number(S.amount)

/datum/manufacture/atmos_can
	name = "Portable Gas Canister"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 3,
							)
	item_outputs = list(/obj/machinery/portable_atmospherics/canister)
	time = 10 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/fluidcanister
	name = "Fluid Canister"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 15,
							)
	item_outputs = list(/obj/machinery/fluid_canister)
	time = 10 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/chembarrel
	name = "Chemical Barrel"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 6,
							 /datum/manufacturing_requirement/cobryl = 9,
							)
	item_outputs = list(/obj/reagent_dispensers/chemicalbarrel)
	time = 30 SECONDS
	create = 1
	category = "Machinery"

	red
		item_outputs = list(/obj/reagent_dispensers/chemicalbarrel/red)
	yellow
		item_outputs = list(/obj/reagent_dispensers/chemicalbarrel/yellow)

/datum/manufacture/shieldgen
	name = "Energy-Shield Gen."
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 20,
							 /datum/manufacturing_requirement/conductive = 10,
							 /datum/manufacturing_requirement/crystal = 5,
							)
	item_outputs = list(/obj/machinery/shieldgenerator/energy_shield/nocell)
	time = 60 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/doorshieldgen
	name = "Door-Shield Gen."
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 20,
							 /datum/manufacturing_requirement/conductive = 15,
							)
	item_outputs = list(/obj/machinery/shieldgenerator/energy_shield/doorlink/nocell)
	time = 60 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/meteorshieldgen
	name = "Meteor-Shield Gen."
	item_requirements = list(/datum/manufacturing_requirement/metal = 10,
							 /datum/manufacturing_requirement/metal/dense = 10,
							 /datum/manufacturing_requirement/conductive = 10,
							)
	item_outputs = list(/obj/machinery/shieldgenerator/meteorshield/nocell)
	time = 30 SECONDS
	create = 1
	category = "Machinery"

//// cogwerks - gas extraction stuff


/datum/manufacture/air_can
	name = "Air Canister"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 3,
							 /datum/manufacturing_requirement/molitz = 4,
							 /datum/manufacturing_requirement/viscerite = 12,
							)
	item_outputs = list(/obj/machinery/portable_atmospherics/canister/air)
	time = 50 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/air_can/large
	name = "High-Volume Air Canister"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 3,
							 /datum/manufacturing_requirement/molitz = 10,
							 /datum/manufacturing_requirement/viscerite = 30,
							)
	item_outputs = list(/obj/machinery/portable_atmospherics/canister/air/large)
	time = 100 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/co2_can
	name = "CO2 Canister"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 3,
							 /datum/manufacturing_requirement/char = 10,
							)
	item_outputs = list(/obj/machinery/portable_atmospherics/canister/carbon_dioxide)
	time = 100 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/o2_can
	name = "O2 Canister"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 3,
							 /datum/manufacturing_requirement/molitz = 10,
							)
	item_outputs = list(/obj/machinery/portable_atmospherics/canister/oxygen)
	time = 100 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/plasma_can
	name = "Plasma Canister"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 3,
							 /datum/manufacturing_requirement/plasmastone = 10,
							)
	item_outputs = list(/obj/machinery/portable_atmospherics/canister/toxins)
	time = 100 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/n2_can
	name = "N2 Canister"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 3,
							 /datum/manufacturing_requirement/viscerite = 10,
							)
	item_outputs = list(/obj/machinery/portable_atmospherics/canister/nitrogen)
	time = 100 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/n2o_can
	name = "N2O Canister"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 3,
							 /datum/manufacturing_requirement/koshmarite = 10,
							)
	item_outputs = list(/obj/machinery/portable_atmospherics/canister/sleeping_agent)
	time = 100 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/red_o2_grenade
	name = "Red Oxygen Grenade"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 2,
							 /datum/manufacturing_requirement/conductive = 2,
							 /datum/manufacturing_requirement/molitz = 10,
							 /datum/manufacturing_requirement/char = 1,
							)
	item_outputs = list(/obj/item/old_grenade/oxygen)
	time = 10 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/engivac
	name = "Material Vacuum"
	item_requirements = list(/datum/manufacturing_requirement/metal = 10,
							 /datum/manufacturing_requirement/conductive = 5,
							 /datum/manufacturing_requirement/crystal = 5,
							)
	item_outputs = list(/obj/item/engivac)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/lampmanufacturer
	name = "Lamp Manufacturer"
	item_requirements = list(/datum/manufacturing_requirement/metal = 5,
							 /datum/manufacturing_requirement/conductive = 10,
							 /datum/manufacturing_requirement/crystal = 20,
							)
	item_outputs = list(/obj/item/lamp_manufacturer/organic)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/condenser
	name = "Chemical Condenser"
	item_requirements = list(/datum/manufacturing_requirement/molitz = 5,
							)
	item_outputs = list(/obj/item/reagent_containers/glass/condenser)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/fractionalcondenser
	name = "Fractional Condenser"
	item_requirements = list(/datum/manufacturing_requirement/molitz = 6,
							)
	item_outputs = list(/obj/item/reagent_containers/glass/condenser/fractional)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/beaker_lid_box
	name = "Beaker Lid Box"
	item_requirements = list(/datum/manufacturing_requirement/rubber = 2,
							)
	item_outputs = list(/obj/item/storage/box/beaker_lids)
	time = 5 SECONDS
	create = 1
	category = "Tool"


/datum/manufacture/bunsen_burner
	name = "Bunsen Burner"
	item_requirements = list(/datum/manufacturing_requirement/pharosium = 5,
							)
	item_outputs = list(/obj/item/bunsen_burner)
	time = 5 SECONDS
	create = 1
	category = "Tool"

////////////////////////////////

/datum/manufacture/player_module
	name = "Vending Module"
	item_requirements = list(/datum/manufacturing_requirement/conductive = 2,
							)
	item_outputs = list(/obj/item/machineboard/vending/player)
	time = 5 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cable
	name = "Electrical Cable Coil"
	item_requirements = list(/datum/manufacturing_requirement/insulated = 10,
							 /datum/manufacturing_requirement/conductive = 10,
							)
	item_outputs = list(/obj/item/cable_coil)
	time = 3 SECONDS
	create = 1
	category = "Resource"
	apply_material = 0

	modify_output(var/obj/machinery/manufacturer/M, var/atom/A,var/list/materials)
		..()
		var/obj/item/cable_coil/coil = A
		coil.setInsulator(getMaterial(materials[item_paths[1]]))
		coil.setConductor(getMaterial(materials[item_paths[2]]))
		return 1

/datum/manufacture/cable/reinforced
	name = "Reinforced Cable Coil"
	item_outputs = list(/obj/item/cable_coil/reinforced)
	time = 10 SECONDS

/datum/manufacture/RCD
	name = "Rapid Construction Device"
	item_requirements = list(/datum/manufacturing_requirement/metal/superdense = 20,
							 /datum/manufacturing_requirement/crystal/dense = 10,
							 /datum/manufacturing_requirement/conductive/high = 10,
							 /datum/manufacturing_requirement/energy/high = 10,
							)
	item_outputs = list(/obj/item/rcd)
	time = 90 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/RCDammo
	name = "Compressed Matter Cartridge"
	item_requirements = list(/datum/manufacturing_requirement/dense = 30,
							)
	item_outputs = list(/obj/item/rcd_ammo)
	time = 10 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/RCDammomedium
	name = "Medium Compressed Matter Cartridge"
	item_requirements = list(/datum/manufacturing_requirement/dense/super = 30,
							)
	item_outputs = list(/obj/item/rcd_ammo/medium)
	time = 20 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/RCDammolarge
	name = "Large Compressed Matter Cartridge"
	item_requirements = list(/datum/manufacturing_requirement/uqill = 20,
							)
	item_outputs = list(/obj/item/rcd_ammo/big)
	time = 30 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/sds
	name = "Syndicate Destruction System"
	item_requirements = list(/datum/manufacturing_requirement/metal/superdense = 16,
							 /datum/manufacturing_requirement/dense = 12,
							 /datum/manufacturing_requirement/conductive = 8,
							)
	item_outputs = list(/obj/item/syndicate_destruction_system)
	time = 90 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/civilian_headset
	name = "Civilian Headset"
	item_requirements = list(/datum/manufacturing_requirement/metal = 2,
							 /datum/manufacturing_requirement/conductive = 1,
							)
	item_outputs = list(/obj/item/device/radio/headset)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/jumpsuit_assistant
	name = "Staff Assistant Jumpsuit"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/under/rank/assistant)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/jumpsuit
	name = "Grey Jumpsuit"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/under/color/grey)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/shoes
	name = "Black Shoes"
	item_requirements = list(/datum/manufacturing_requirement/fabric 3,
							)
	item_outputs = list(/obj/item/clothing/shoes/black)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/shoes_white
	name = "White Shoes"
	item_requirements = list(/datum/manufacturing_requirement/fabric 3,
							)
	item_outputs = list(/obj/item/clothing/shoes/white)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/flippers
	name = "Flippers"
	item_requirements = list(/datum/manufacturing_requirement/rubber = 5,
							)
	item_outputs = list(/obj/item/clothing/shoes/flippers)
	time = 8 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/cleaner_grenade
	name = "Cleaner Grenade"
	item_requirements = list(/datum/manufacturing_requirement/insulated = 8,
							 /datum/manufacturing_requirement/crystal = 8,
							 /datum/manufacturing_requirement/molitz = 10,
							 /datum/manufacturing_requirement/ice = 10,
							)
	item_outputs = list(/obj/item/chem_grenade/cleaner)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/pocketoxyex
	name = "Extended Capacity Pocket Oxygen Tank"
	item_requirements = list(/datum/manufacturing_requirement/dense/super = 10,
							 /datum/manufacturing_requirement/insulated = 20,
							 /datum/manufacturing_requirement/rubber = 5,
							)
	item_outputs = list(/obj/item/tank/emergency_oxygen/extended/empty)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/******************** Medical **************************/

/datum/manufacture/scalpel
	name = "Scalpel"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							)
	item_outputs = list(/obj/item/scalpel)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/circular_saw
	name = "Circular Saw"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							)
	item_outputs = list(/obj/item/circular_saw)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/surgical_scissors
	name = "Surgical Scissors"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							)
	item_outputs = list(/obj/item/scissors/surgical_scissors)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/hemostat
	name = "Hemostat"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							)
	item_outputs = list(/obj/item/hemostat)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/surgical_spoon
	name = "Enucleation Spoon"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							)
	item_outputs = list(/obj/item/surgical_spoon)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/suture
	name = "Suture"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							)
	item_outputs = list(/obj/item/suture)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/deafhs
	name = "Auditory Headset"
	item_requirements = list(/datum/manufacturing_requirement/conductive = 3,
							 /datum/manufacturing_requirement/crystal = 3,
							)
	item_outputs = list(/obj/item/device/radio/headset/deaf)
	time = 40 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/visor
	name = "VISOR Prosthesis"
	item_requirements = list(/datum/manufacturing_requirement/conductive = 3,
							 /datum/manufacturing_requirement/crystal = 3,
							)
	item_outputs = list(/obj/item/clothing/glasses/visor)
	time = 40 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/glasses
	name = "Prescription Glasses"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							 /datum/manufacturing_requirement/crystal = 2,
							)
	item_outputs = list(/obj/item/clothing/glasses/regular)
	time = 20 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/hypospray
	name = "Hypospray"
	item_requirements = list(/datum/manufacturing_requirement/metal = 2,
							 /datum/manufacturing_requirement/conductive = 2,
							 /datum/manufacturing_requirement/crystal = 2,
							)
	item_outputs = list(/obj/item/reagent_containers/hypospray)
	time = 40 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/prodocs
	name = "ProDoc Healthgoggles"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							 /datum/manufacturing_requirement/crystal = 2,
							)
	item_outputs = list(/obj/item/clothing/glasses/healthgoggles)
	time = 20 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/latex_gloves
	name = "Latex Gloves"
	item_requirements = list(/datum/manufacturing_requirement/fabric 1,
							)
	item_outputs = list(/obj/item/clothing/gloves/latex)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/body_bag
	name = "Body Bag"
	item_requirements = list(/datum/manufacturing_requirement/fabric 3,
							)
	item_outputs = list(/obj/item/body_bag)
	time = 15 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/cyberheart
	name = "Cyberheart"
	item_requirements = list(/datum/manufacturing_requirement/metal = 3,
							 /datum/manufacturing_requirement/conductive = 3,
							 /datum/manufacturing_requirement/any = 2,
							)
	item_outputs = list(/obj/item/organ/heart/cyber)
	time = 25 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cyberbutt
	name = "Cyberbutt"
	item_requirements = list(/datum/manufacturing_requirement/metal = 2,
							 /datum/manufacturing_requirement/conductive = 2,
							 /datum/manufacturing_requirement/any = 2,
							)
	item_outputs = list(/obj/item/clothing/head/butt/cyberbutt)
	time = 15 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cardboard_ai
	name = "Cardboard 'AI'"
	item_requirements = list(/datum/manufacturing_requirement/cardboard = 1,
							)
	item_outputs = list(/obj/item/clothing/suit/cardboard_box/ai)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/cyberappendix
	name = "Cyberappendix"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							 /datum/manufacturing_requirement/conductive = 1,
							 /datum/manufacturing_requirement/any = 1,
							)
	item_outputs = list(/obj/item/organ/appendix/cyber)
	time = 15 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cyberpancreas
	name = "Cyberpancreas"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							 /datum/manufacturing_requirement/conductive = 1,
							 /datum/manufacturing_requirement/any = 1,
							)
	item_outputs = list(/obj/item/organ/pancreas/cyber)
	time = 15 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cyberspleen
	name = "Cyberspleen"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							 /datum/manufacturing_requirement/conductive = 1,
							 /datum/manufacturing_requirement/any = 1,
							)
	item_outputs = list(/obj/item/organ/spleen/cyber)
	time = 15 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cyberintestines
	name = "Cyberintestines"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							 /datum/manufacturing_requirement/conductive = 1,
							 /datum/manufacturing_requirement/any = 1,
							)
	item_outputs = list(/obj/item/organ/intestines/cyber)
	time = 15 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cyberstomach
	name = "Cyberstomach"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							 /datum/manufacturing_requirement/conductive = 1,
							 /datum/manufacturing_requirement/any = 1,
							)
	item_outputs = list(/obj/item/organ/stomach/cyber)
	time = 15 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cyberkidney
	name = "Cyberkidney"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							 /datum/manufacturing_requirement/conductive = 1,
							 /datum/manufacturing_requirement/any = 1,
							)
	item_outputs = list(/obj/item/organ/kidney/cyber)
	time = 15 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cyberliver
	name = "Cyberliver"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							 /datum/manufacturing_requirement/conductive = 1,
							 /datum/manufacturing_requirement/any = 1,
							)
	item_outputs = list(/obj/item/organ/liver/cyber)
	time = 15 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cyberlung_left
	name = "Left Cyberlung"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							 /datum/manufacturing_requirement/conductive = 1,
							 /datum/manufacturing_requirement/any = 1,
							)
	item_outputs = list(/obj/item/organ/lung/cyber/left)
	time = 15 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cyberlung_right
	name = "Right Cyberlung"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							 /datum/manufacturing_requirement/conductive = 1,
							 /datum/manufacturing_requirement/any = 1,
							)
	item_outputs = list(/obj/item/organ/lung/cyber/right)
	time = 15 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cybereye
	name = "Cybereye"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 2,
							 /datum/manufacturing_requirement/metal = 1,
							 /datum/manufacturing_requirement/conductive = 2,
							 /datum/manufacturing_requirement/insulated = 1,
							)
	item_outputs = list(/obj/item/organ/eye/cyber/configurable)
	time = 20 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cybereye_sunglass
	name = "Polarized Cybereye"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 3,
							 /datum/manufacturing_requirement/metal = 1,
							 /datum/manufacturing_requirement/conductive = 2,
							 /datum/manufacturing_requirement/insulated = 1,
							)
	item_outputs = list(/obj/item/organ/eye/cyber/sunglass)
	time = 25 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cybereye_sechud
	name = "Security HUD Cybereye"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 3,
							 /datum/manufacturing_requirement/metal = 1,
							 /datum/manufacturing_requirement/conductive = 2,
							 /datum/manufacturing_requirement/insulated = 1,
							)
	item_outputs = list(/obj/item/organ/eye/cyber/sechud)
	time = 25 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cybereye_thermal
	name = "Thermal Imager Cybereye"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 3,
							 /datum/manufacturing_requirement/metal = 1,
							 /datum/manufacturing_requirement/conductive = 2,
							 /datum/manufacturing_requirement/insulated = 1,
							)
	item_outputs = list(/obj/item/organ/eye/cyber/thermal)
	time = 25 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cybereye_meson
	name = "Mesonic Imager Cybereye"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 3,
							 /datum/manufacturing_requirement/metal = 1,
							 /datum/manufacturing_requirement/conductive = 2,
							 /datum/manufacturing_requirement/insulated = 1,
							)
	item_outputs = list(/obj/item/organ/eye/cyber/meson)
	time = 25 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cybereye_spectro
	name = "Spectroscopic Imager Cybereye"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 3,
							 /datum/manufacturing_requirement/metal = 1,
							 /datum/manufacturing_requirement/conductive = 2,
							 /datum/manufacturing_requirement/insulated = 1,
							)
	item_outputs = list(/obj/item/organ/eye/cyber/spectro)
	time = 25 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cybereye_prodoc
	name = "ProDoc Healthview Cybereye"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 3,
							 /datum/manufacturing_requirement/metal = 1,
							 /datum/manufacturing_requirement/conductive = 2,
							 /datum/manufacturing_requirement/insulated = 1,
							)
	item_outputs = list(/obj/item/organ/eye/cyber/prodoc)
	time = 25 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cybereye_camera
	name = "Camera Cybereye"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 3,
							 /datum/manufacturing_requirement/metal = 1,
							 /datum/manufacturing_requirement/conductive = 2,
							 /datum/manufacturing_requirement/insulated = 1,
							)
	item_outputs = list(/obj/item/organ/eye/cyber/camera)
	time = 25 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/cybereye_laser
	name = "Laser Cybereye"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 3,
							 /datum/manufacturing_requirement/metal = 1,
							 /datum/manufacturing_requirement/conductive = 2,
							 /datum/manufacturing_requirement/insulated = 1,
							 /datum/manufacturing_requirement/erebite = 1,
							)
	item_outputs = list(/obj/item/organ/eye/cyber/laser)
	time = 40 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/implant_health
	name = "Health Monitor Implant"
	item_requirements = list(/datum/manufacturing_requirement/conductive = 3,
							 /datum/manufacturing_requirement/crystal = 3,
							)
	item_outputs = list(/obj/item/implantcase/health)
	time = 40 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/implant_antirot
	name = "Rotbusttec Implant"
	item_requirements = list(/datum/manufacturing_requirement/conductive = 2,
							 /datum/manufacturing_requirement/crystal = 2,
							)
	item_outputs = list(/obj/item/implantcase/antirot)
	time = 30 SECONDS
	create = 1
	category = "Resource"

#ifdef ENABLE_ARTEMIS
/******************** Artemis **************************/

/datum/manufacture/nav_sat
	name = "Navigation Satellite"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 1,
							)
	item_outputs = list(/obj/nav_sat)
	time = 45 SECONDS
	create = 1
	category = "Component"

#endif
/datum/manufacture/stress_ball
	name = "Stress Ball"
	item_requirements = list(/datum/manufacturing_requirement/fabric 1,
							)
	item_outputs = list(/obj/item/toy/plush/small/stress_ball)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/floppydisk //Cloning disks
	name = "Floppy Disk"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							 /datum/manufacturing_requirement/conductive = 1,
							)
	item_outputs = list(/obj/item/disk/data/floppy)
	time = 5 SECONDS
	create = 1
	category = "Resource"

/******************** Robotics **************************/

/datum/manufacture/robo_frame
	name = "Cyborg Frame"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = ROBOT_FRAME_COST*10,
							)
	item_outputs = list(/obj/item/parts/robot_parts/robot_frame)
	time = 45 SECONDS
	create = 1
	category = "Component"
	apply_material = 1

/datum/manufacture/full_cyborg_standard
	name = "Standard Cyborg Parts"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = (ROBOT_CHEST_COST+ROBOT_HEAD_COST+ROBOT_LIMB_COST*4)*10,
							)
	item_outputs = list(/obj/item/parts/robot_parts/chest/standard,/obj/item/parts/robot_parts/head/standard,
/obj/item/parts/robot_parts/arm/right/standard,/obj/item/parts/robot_parts/arm/left/standard,
/obj/item/parts/robot_parts/leg/right/standard,/obj/item/parts/robot_parts/leg/left/standard)
	time = 120 SECONDS
	create = 1
	category = "Component"
	apply_material = 1

/datum/manufacture/full_cyborg_light
	name = "Light Cyborg Parts"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = (ROBOT_CHEST_COST+ROBOT_HEAD_COST+ROBOT_LIMB_COST*4)*ROBOT_LIGHT_COST_MOD*10,
							)
	item_outputs = list(/obj/item/parts/robot_parts/chest/light,/obj/item/parts/robot_parts/head/light,
/obj/item/parts/robot_parts/arm/right/light,/obj/item/parts/robot_parts/arm/left/light,
/obj/item/parts/robot_parts/leg/right/light,/obj/item/parts/robot_parts/leg/left/light)
	time = 62 SECONDS
	create = 1
	category = "Component"
	apply_material = 1

/datum/manufacture/robo_chest
	name = "Cyborg Chest"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = ROBOT_CHEST_COST*10,
							)
	item_outputs = list(/obj/item/parts/robot_parts/chest/standard)
	time = 30 SECONDS
	create = 1
	category = "Component"
	apply_material = 1

/datum/manufacture/robo_chest_light
	name = "Light Cyborg Chest"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = ROBOT_CHEST_COST*ROBOT_LIGHT_COST_MOD*10,
							)
	item_outputs = list(/obj/item/parts/robot_parts/chest/light)
	time = 15 SECONDS
	create = 1
	category = "Component"
	apply_material = 1

/datum/manufacture/robo_head
	name = "Cyborg Head"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = ROBOT_HEAD_COST*10,
							)
	item_outputs = list(/obj/item/parts/robot_parts/head/standard)
	time = 30 SECONDS
	create = 1
	category = "Component"
	apply_material = 1

/datum/manufacture/robo_head_screen
	name = "Cyborg Screen Head"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = ROBOT_SCREEN_METAL_COST*10,
							 /datum/manufacturing_requirement/conductive = 2,
							 /datum/manufacturing_requirement/crystal = 6,
							)
	item_outputs = list(/obj/item/parts/robot_parts/head/screen)
	time = 24 SECONDS
	create = 1
	category = "Component"
	apply_material = 1

/datum/manufacture/robo_head_light
	name = "Light Cyborg Head"
	item_requirements = list(/datum/manufacturing_requirement/metal = ROBOT_HEAD_COST*ROBOT_LIGHT_COST_MOD*10,
							)
	item_outputs = list(/obj/item/parts/robot_parts/head/light)
	time = 15 SECONDS
	create = 1
	category = "Component"
	apply_material = 1

/datum/manufacture/robo_arm_r
	name = "Cyborg Arm (Right)"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = ROBOT_LIMB_COST*10,
							)
	item_outputs = list(/obj/item/parts/robot_parts/arm/right/standard)
	time = 15 SECONDS
	create = 1
	category = "Component"
	apply_material = 1

/datum/manufacture/robo_arm_r_light
	name = "Light Cyborg Arm (Right)"
	item_requirements = list(/datum/manufacturing_requirement/metal = ROBOT_LIMB_COST*ROBOT_LIGHT_COST_MOD*10,
							)
	item_outputs = list(/obj/item/parts/robot_parts/arm/right/light)
	time = 8 SECONDS
	create = 1
	category = "Component"
	apply_material = 1

/datum/manufacture/robo_arm_l
	name = "Cyborg Arm (Left)"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = ROBOT_LIMB_COST*10,
							)
	item_outputs = list(/obj/item/parts/robot_parts/arm/left/standard)
	time = 15 SECONDS
	create = 1
	category = "Component"
	apply_material = 1

/datum/manufacture/robo_arm_l_light
	name = "Light Cyborg Arm (Left)"
	item_requirements = list(/datum/manufacturing_requirement/metal = ROBOT_LIMB_COST*ROBOT_LIGHT_COST_MOD*10,
							)
	item_outputs = list(/obj/item/parts/robot_parts/arm/left/light)
	time = 8 SECONDS
	create = 1
	category = "Component"
	apply_material = 1

/datum/manufacture/robo_leg_r
	name = "Cyborg Leg (Right)"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = ROBOT_LIMB_COST*10,
							)
	item_outputs = list(/obj/item/parts/robot_parts/leg/right/standard)
	time = 15 SECONDS
	create = 1
	category = "Component"
	apply_material = 1

/datum/manufacture/robo_leg_r_light
	name = "Light Cyborg Leg (Right)"
	item_requirements = list(/datum/manufacturing_requirement/metal = ROBOT_LIMB_COST*ROBOT_LIGHT_COST_MOD*10,
							)
	item_outputs = list(/obj/item/parts/robot_parts/leg/right/light)
	time = 8 SECONDS
	create = 1
	category = "Component"
	apply_material = 1

/datum/manufacture/robo_leg_l
	name = "Cyborg Leg (Left)"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = ROBOT_LIMB_COST*10,
							)
	item_outputs = list(/obj/item/parts/robot_parts/leg/left/standard)
	time = 15 SECONDS
	create = 1
	category = "Component"
	apply_material = 1

/datum/manufacture/robo_leg_l_light
	name = "Light Cyborg Leg (Left)"
	item_requirements = list(/datum/manufacturing_requirement/metal = ROBOT_LIMB_COST*ROBOT_LIGHT_COST_MOD*10,
							)
	item_outputs = list(/obj/item/parts/robot_parts/leg/left/light)
	time = 8 SECONDS
	create = 1
	category = "Component"
	apply_material = 1

/datum/manufacture/robo_leg_treads
	name = "Cyborg Treads"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = ROBOT_TREAD_METAL_COST*2*10,
							 /datum/manufacturing_requirement/conductive = 6,
							)
	item_outputs = list(/obj/item/parts/robot_parts/leg/left/treads, /obj/item/parts/robot_parts/leg/right/treads)
	time = 15 SECONDS
	create = 1
	category = "Component"
	apply_material = 1

/datum/manufacture/robo_module
	name = "Blank Cyborg Module"
	item_requirements = list(/datum/manufacturing_requirement/conductive = 2,
							 /datum/manufacturing_requirement/any = 3,
							)
	item_outputs = list(/obj/item/robot_module)
	time = 40 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/powercell
	name = "Power Cell"
	item_requirements = list(/datum/manufacturing_requirement/metal = 4,
							 /datum/manufacturing_requirement/conductive = 4,
							 /datum/manufacturing_requirement/any = 4,
							)
	item_outputs = list(/obj/item/cell/supercell)
	time = 30 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/powercellE
	name = "Erebite Power Cell"
	item_requirements = list(/datum/manufacturing_requirement/metal = 4,
							 /datum/manufacturing_requirement/any = 4,
							 /datum/manufacturing_requirement/erebite = 2,
							)
	item_outputs = list(/obj/item/cell/erebite)
	time = 45 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/powercellC
	name = "Cerenkite Power Cell"
	item_requirements = list(/datum/manufacturing_requirement/metal = 4,
							 /datum/manufacturing_requirement/any = 4,
							 /datum/manufacturing_requirement/cerenkite = 2,
							)
	item_outputs = list(/obj/item/cell/cerenkite)
	time = 45 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/powercellH
	name = "Hyper Capacity Power Cell"
	item_requirements = list(/datum/manufacturing_requirement/dense/super = 5,
							 /datum/manufacturing_requirement/conductive/high = 10,
							 /datum/manufacturing_requirement/energy/high = 10,
							)
	item_outputs = list(/obj/item/cell/hypercell)
	time = 120 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/core_frame
	name = "AI Core Frame"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 20,
							)
	item_outputs = list(/obj/ai_core_frame)
	time = 50 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/shell_frame
	name = "AI Shell Frame"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 12,
							)
	item_outputs = list(/obj/item/shell_frame)
	time = 25 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/ai_interface
	name = "AI Interface Board"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 3,
							 /datum/manufacturing_requirement/conductive = 5,
							 /datum/manufacturing_requirement/crystal = 2,
							)
	item_outputs = list(/obj/item/ai_interface)
	time = 35 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/latejoin_brain
	name = "Spontaneous Intelligence Creation Core"
	item_requirements = list(/datum/manufacturing_requirement/metal = 6,
							 /datum/manufacturing_requirement/conductive = 5,
							 /datum/manufacturing_requirement/any = 3,
							)
	item_outputs = list(/obj/item/organ/brain/latejoin)
	time = 35 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/shell_cell
	name = "AI Shell Power Cell"
	item_requirements = list(/datum/manufacturing_requirement/metal = 2,
							 /datum/manufacturing_requirement/conductive = 2,
							 /datum/manufacturing_requirement/any = 1,
							)
	item_outputs = list(/obj/item/cell/shell_cell)
	time = 20 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/flash
	name = "Flash"
	item_requirements = list(/datum/manufacturing_requirement/metal = 3,
							 /datum/manufacturing_requirement/conductive = 5,
							 /datum/manufacturing_requirement/crystal = 5,
							)
	item_outputs = list(/obj/item/device/flash)
	time = 15 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/borg_linker
	name = "AI Linker"
	item_requirements = list(/datum/manufacturing_requirement/metal = 2,
							 /datum/manufacturing_requirement/crystal = 1,
							 /datum/manufacturing_requirement/conductive = 2,
							)
	item_outputs = list(/obj/item/device/borg_linker)
	time = 15 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/asimov_laws
	name = "Standard Asimov Law Module Set"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 30,
							)
	item_outputs = list(/obj/item/aiModule/asimov1,/obj/item/aiModule/asimov2,/obj/item/aiModule/asimov3)
	time = 60 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/corporate_laws
	name = "Nanotrasen Law Module Set"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 30,
							)
	item_outputs = list(/obj/item/aiModule/nanotrasen1,/obj/item/aiModule/nanotrasen2,/obj/item/aiModule/nanotrasen3)
	time = 60 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robocop_laws
	name = "RoboCop Law Module Set"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 40,
							)
	item_outputs = list(/obj/item/aiModule/robocop1,/obj/item/aiModule/robocop2,/obj/item/aiModule/robocop3,/obj/item/aiModule/robocop4)
	time = 60 SECONDS
	create = 1
	category = "Component"

// Robotics Research

/datum/manufacture/implanter
	name = "Implanter"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							)
	item_outputs = list(/obj/item/implanter)
	time = 3 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/secbot
	name = "Security Drone"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 30,
							 /datum/manufacturing_requirement/conductive/high = 20,
							 /datum/manufacturing_requirement/energy = 20,
							)
	item_outputs = list(/obj/machinery/bot/secbot)
	time = 120 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/floorbot
	name = "Construction Drone"
	item_requirements = list(/datum/manufacturing_requirement/metal = 15,
							 /datum/manufacturing_requirement/conductive = 10,
							 /datum/manufacturing_requirement/any = 5,
							)
	item_outputs = list(/obj/machinery/bot/floorbot)
	time = 60 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/medbot
	name = "Medical Drone"
	item_requirements = list(/datum/manufacturing_requirement/metal = 20,
							 /datum/manufacturing_requirement/conductive = 15,
							 /datum/manufacturing_requirement/energy = 5,
							)
	item_outputs = list(/obj/machinery/bot/medbot)
	time = 90 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/firebot
	name = "Firefighting Drone"
	item_requirements = list(/datum/manufacturing_requirement/metal = 15,
							 /datum/manufacturing_requirement/conductive = 10,
							 /datum/manufacturing_requirement/any = 5,
							)
	item_outputs = list(/obj/machinery/bot/firebot)
	time = 60 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/cleanbot
	name = "Sanitation Drone"
	item_requirements = list(/datum/manufacturing_requirement/metal = 15,
							 /datum/manufacturing_requirement/conductive = 10,
							 /datum/manufacturing_requirement/any = 5,
							)
	item_outputs = list(/obj/machinery/bot/cleanbot)
	time = 60 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/digbot
	name = "Mining Drone"
	item_requirements = list(/datum/manufacturing_requirement/metal = 15,
							 /datum/manufacturing_requirement/metal/dense = 5,
							 /datum/manufacturing_requirement/conductive = 10,
							 /datum/manufacturing_requirement/any = 5,
							)
	item_outputs = list(/obj/machinery/bot/mining)
	time = 10 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/robup_jetpack
	name = "Propulsion Upgrade"
	item_requirements = list(/datum/manufacturing_requirement/conductive = 3,
							 /datum/manufacturing_requirement/metal = 5,
							)
	item_outputs = list(/obj/item/roboupgrade/jetpack)
	time = 60 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robup_speed
	name = "Speed Upgrade"
	item_requirements = list(/datum/manufacturing_requirement/conductive = 3,
							 /datum/manufacturing_requirement/crystal = 5,
							)
	item_outputs = list(/obj/item/roboupgrade/speed)
	time = 60 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robup_mag
	name = "Magnetic Traction Upgrade"
	item_requirements = list(/datum/manufacturing_requirement/conductive = 5,
							 /datum/manufacturing_requirement/crystal = 3,
							)
	item_outputs = list(/obj/item/roboupgrade/magboot)
	time = 60 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robup_recharge
	name = "Recharge Pack"
	item_requirements = list(/datum/manufacturing_requirement/conductive = 5,
							)
	item_outputs = list(/obj/item/roboupgrade/rechargepack)
	time = 60 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robup_repairpack
	name = "Repair Pack"
	item_requirements = list(/datum/manufacturing_requirement/conductive = 5,
							)
	item_outputs = list(/obj/item/roboupgrade/repairpack)
	time = 60 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robup_physshield
	name = "Force Shield Upgrade"
	item_requirements = list(/datum/manufacturing_requirement/conductive/high = 2,
							 /datum/manufacturing_requirement/metal/dense = 10,
							 /datum/manufacturing_requirement/energy/high = 2,
							)
	item_outputs = list(/obj/item/roboupgrade/physshield)
	time = 90 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robup_fireshield
	name = "Heat Shield Upgrade"
	item_requirements = list(/datum/manufacturing_requirement/conductive/high = 2,
							 /datum/manufacturing_requirement/crystal = 10,
							)
	item_outputs = list(/obj/item/roboupgrade/fireshield)
	time = 90 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robup_aware
	name = "Recovery Upgrade"
	item_requirements = list(/datum/manufacturing_requirement/conductive/high = 2,
							 /datum/manufacturing_requirement/crystal = 5,
							 /datum/manufacturing_requirement/conductive = 5,
							)
	item_outputs = list(/obj/item/roboupgrade/aware)
	time = 90 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robup_efficiency
	name = "Efficiency Upgrade"
	item_requirements = list(/datum/manufacturing_requirement/dense = 3,
							 /datum/manufacturing_requirement/conductive/high = 10,
							)
	item_outputs = list(/obj/item/roboupgrade/efficiency)
	time = 120 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robup_repair
	name = "Self-Repair Upgrade"
	item_requirements = list(/datum/manufacturing_requirement/dense = 3,
							 /datum/manufacturing_requirement/metal/superdense = 10,
							)
	item_outputs = list(/obj/item/roboupgrade/repair)
	time = 120 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robup_teleport
	name = "Teleport Upgrade"
	item_requirements = list(/datum/manufacturing_requirement/conductive = 10,
							 /datum/manufacturing_requirement/dense = 1,
							 /datum/manufacturing_requirement/energy/high = 10,
							)
	item_outputs = list(/obj/item/roboupgrade/teleport)
	time = 120 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robup_expand
	name = "Expansion Upgrade"
	item_requirements = list(/datum/manufacturing_requirement/crystal/dense = 3,
							 /datum/manufacturing_requirement/energy/extreme = 1,
							)
	item_outputs = list(/obj/item/roboupgrade/expand)
	time = 120 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robup_meson
	name = "Optical Meson Upgrade"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 2,
							 /datum/manufacturing_requirement/conductive = 4,
							)
	item_outputs = list(/obj/item/roboupgrade/opticmeson)
	time = 90 SECONDS
	create = 1
	category = "Component"
/* shit done be broked
/datum/manufacture/robup_thermal
	name = "Optical Thermal Upgrade"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 4,
							 /datum/manufacturing_requirement/conductive = 8,
							)
	item_outputs = list(/obj/item/roboupgrade/opticthermal)
	time = 90 SECONDS
	create = 1
	category = "Component"
*/
/datum/manufacture/robup_healthgoggles
	name = "ProDoc Healthgoggle Upgrade"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 4,
							 /datum/manufacturing_requirement/conductive = 6,
							)
	item_outputs = list(/obj/item/roboupgrade/healthgoggles)
	time = 90 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robup_sechudgoggles
	name = "Security HUD Upgrade"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 4,
							 /datum/manufacturing_requirement/conductive = 6,
							)
	item_outputs = list(/obj/item/roboupgrade/sechudgoggles)
	time = 90 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robup_spectro
	name = "Spectroscopic Scanner Upgrade"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 4,
							 /datum/manufacturing_requirement/conductive = 6,
							)
	item_outputs = list(/obj/item/roboupgrade/spectro)
	time = 90 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/robup_visualizer
	name = "Construction Visualizer"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 4,
							 /datum/manufacturing_requirement/conductive = 6,
							)
	item_outputs = list(/obj/item/roboupgrade/visualizer)
	time = 90 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/implant_robotalk
	name = "Machine Translator Implant"
	item_requirements = list(/datum/manufacturing_requirement/conductive = 3,
							 /datum/manufacturing_requirement/crystal = 3,
							)
	item_outputs = list(/obj/item/implantcase/robotalk)
	time = 40 SECONDS
	create = 1
	category = "Resource"


/datum/manufacture/sbradio
	name = "Station Bounced Radio"
	item_requirements = list(/datum/manufacturing_requirement/conductive = 2,
							 /datum/manufacturing_requirement/crystal = 2,
							)
	item_outputs = list(/obj/item/device/radio)
	time = 20 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/thrusters
	name = "Alastor Pattern Thrusters"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = ROBOT_THRUSTER_COST*2*10,
							)
	item_outputs = list(/obj/item/parts/robot_parts/leg/right/thruster,/obj/item/parts/robot_parts/leg/left/thruster)
	time = 120 SECONDS
	create = 1
	category = "Component"
	apply_material = 1

/******************** Science **************************/

/datum/manufacture/biosuit
	name = "Biosuit Set"
	item_requirements = list(/datum/manufacturing_requirement/fabric 5,
							 /datum/manufacturing_requirement/crystal = 2,
							)
	item_outputs = list(/obj/item/clothing/suit/hazard/bio_suit,/obj/item/clothing/head/bio_hood)
	time = 10 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/spectrogoggles
	name = "Spectroscopic Scanner Goggles"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							 /datum/manufacturing_requirement/crystal = 2,
							)
	item_outputs = list(/obj/item/clothing/glasses/spectro)
	time = 20 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/gasmask
	name = "Gas Mask"
	item_requirements = list(/datum/manufacturing_requirement/fabric 2,
							 /datum/manufacturing_requirement/metal/dense = 4,
							 /datum/manufacturing_requirement/crystal = 2,
							)
	item_outputs = list(/obj/item/clothing/mask/gas)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/dropper
	name ="Dropper"
	item_requirements = list(/datum/manufacturing_requirement/insulated = 1,
							 /datum/manufacturing_requirement/crystal = 2,
							)
	item_outputs = list(/obj/item/reagent_containers/dropper)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/mechdropper
	name ="Mechanical Dropper"
	item_requirements = list(/datum/manufacturing_requirement/metal = 3,
							 /datum/manufacturing_requirement/conductive = 3,
							)
	item_outputs = list(/obj/item/reagent_containers/dropper/mechanical)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/gps
	name ="Space GPS"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							 /datum/manufacturing_requirement/conductive = 1,
							)
	item_outputs = list(/obj/item/device/gps)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/reagentscanner
	name ="Reagent Scanner"
	item_requirements = list(/datum/manufacturing_requirement/metal = 2,
							 /datum/manufacturing_requirement/conductive = 2,
							 /datum/manufacturing_requirement/crystal = 1,
							)
	item_outputs = list(/obj/item/device/reagentscanner)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/artifactforms
	name ="Artifact Analysis Forms"
	item_requirements = list(/datum/manufacturing_requirement/metal = 2,
							 /datum/manufacturing_requirement/fabric 5,
							)
	item_outputs = list(/obj/item/paper_bin/artifact_paper)
	time = 10 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/audiotape
	name ="Audio Tape"
	item_requirements = list(/datum/manufacturing_requirement/metal = 2,
							)
	item_outputs = list(/obj/item/audio_tape)
	time = 4 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/audiolog
	name ="Audio Log"
	item_requirements = list(/datum/manufacturing_requirement/metal = 3,
							 /datum/manufacturing_requirement/conductive = 5,
							)
	item_outputs = list(/obj/item/device/audio_log)
	time = 5 SECONDS
	create = 1
	category = "Tool"

// Mining Gear
#ifndef UNDERWATER_MAP
/datum/manufacture/mining_magnet
	name = "Mining Magnet Replacement Parts"
	item_requirements = list(/datum/manufacturing_requirement/dense = 5,
							 /datum/manufacturing_requirement/metal/superdense = 30,
							 /datum/manufacturing_requirement/conductive/high = 30,
							)
	item_outputs = list(/obj/item/magnet_parts)
	time = 120 SECONDS
	create = 1
	category = "Component"
#endif

/datum/manufacture/pick
	name = "Pickaxe"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 1,
							)
	item_outputs = list(/obj/item/mining_tool)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/powerpick
	name = "Powered Pick"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 2,
							 /datum/manufacturing_requirement/conductive = 5,
							)
	item_outputs = list(/obj/item/mining_tool/powered/pickaxe)
	time = 10 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/blastchargeslite
	name = "Low-Yield Mining Explosives (x5)"
	item_requirements = list(/datum/manufacturing_requirement/metal = 3,
							 /datum/manufacturing_requirement/crystal = 3,
							 /datum/manufacturing_requirement/conductive = 7,
							)
	item_outputs = list(/obj/item/breaching_charge/mining/light)
	time = 40 SECONDS
	create = 5
	category = "Resource"

/datum/manufacture/blastcharges
	name = "Mining Explosives (x5)"
	item_requirements = list(/datum/manufacturing_requirement/metal = 7,
							 /datum/manufacturing_requirement/crystal = 7,
							 /datum/manufacturing_requirement/conductive = 15,
							)
	item_outputs = list(/obj/item/breaching_charge/mining)
	time = 60 SECONDS
	create = 5
	category = "Resource"

/datum/manufacture/powerhammer
	name = "Power Hammer"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 15,
							 /datum/manufacturing_requirement/metal/superdense = 7,
							 /datum/manufacturing_requirement/conductive = 10,
							)
	item_outputs = list(/obj/item/mining_tool/powered/hammer)
	time = 70 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/drill
	name = "Laser Drill"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 15,
							 /datum/manufacturing_requirement/conductive/high = 10,
							)
	item_outputs = list(/obj/item/mining_tool/powered/drill)
	time = 90 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/conc_gloves
	name = "Concussive Gauntlets"
	item_requirements = list(/datum/manufacturing_requirement/metal/superdense = 15,
							 /datum/manufacturing_requirement/conductive/high = 15,
							 /datum/manufacturing_requirement/energy = 2,
							)
	item_outputs = list(/obj/item/clothing/gloves/concussive)
	time = 120 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/ore_accumulator
	name = "Mineral Accumulator"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 25,
							 /datum/manufacturing_requirement/conductive/high = 15,
							 /datum/manufacturing_requirement/dense = 2,
							)
	item_outputs = list(/obj/machinery/oreaccumulator)
	time = 120 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/eyes_meson
	name = "Optical Meson Scanner"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 3,
							 /datum/manufacturing_requirement/conductive = 2,
							)
	item_outputs = list(/obj/item/clothing/glasses/toggleable/meson)
	time = 10 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/atmos_goggles
	name = "Pressure Visualization Goggles"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 3,
							 /datum/manufacturing_requirement/conductive = 2,
							)
	item_outputs = list(/obj/item/clothing/glasses/toggleable/atmos)
	time = 10 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/geoscanner
	name = "Geological Scanner"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							 /datum/manufacturing_requirement/conductive = 1,
							 /datum/manufacturing_requirement/crystal = 1,
							)
	item_outputs = list(/obj/item/oreprospector)
	time = 8 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/ore_scoop
	name = "Ore Scoop"
	item_names = list("Metal","Conductive Material","Crystal")
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							 /datum/manufacturing_requirement/conductive = 1,
							 /datum/manufacturing_requirement/crystal = 1,
							)
	item_outputs = list(/obj/item/ore_scoop)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/geigercounter
	name = "Geiger Counter"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							 /datum/manufacturing_requirement/conductive = 1,
							 /datum/manufacturing_requirement/crystal = 1,
							)
	item_outputs = list(/obj/item/device/geiger)
	time = 8 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/industrialarmor
	name = "Industrial Space Armor Set"
	item_requirements = list(/datum/manufacturing_requirement/metal/superdense = 15,
							 /datum/manufacturing_requirement/conductive/high = 10,
							 /datum/manufacturing_requirement/crystal/dense = 5,
							)
	item_outputs = list(/obj/item/clothing/suit/space/industrial,/obj/item/clothing/head/helmet/space/industrial)
	time = 90 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/industrialboots
	name = "Mechanised Boots"
	item_outputs = list(/obj/item/clothing/shoes/industrial)
	time = 40 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/jetpackmkII
	name = "Jetpack MKII"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 15,
							 /datum/manufacturing_requirement/conductive/high = 10,
							 /datum/manufacturing_requirement/energy = 5,
							)
	item_outputs = list(/obj/item/tank/jetpack/jetpackmk2)
	time = 40 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/breathmask
	name = "Breath Mask"
	item_requirements = list(/datum/manufacturing_requirement/fabric 1,
							)
	item_outputs = list(/obj/item/clothing/mask/breath)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/gastank
	name = "Gas tank"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 1,
							)
	item_outputs = list(/obj/item/tank/empty)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/miniplasmatank
	name = "Mini plasma tank"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 1,
							)
	item_outputs = list(/obj/item/tank/mini_plasma/empty)
	time = 5 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/minioxygentank
	name = "Mini oxygen tank"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 1,
							)
	item_outputs = list(/obj/item/tank/mini_oxygen/empty)
	time = 5 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/patch
	name = "Chemical Patch"
	item_requirements = list(/datum/manufacturing_requirement/fabric 1,
							)
	item_outputs = list(/obj/item/reagent_containers/patch)
	time = 5 SECONDS
	create = 2
	category = "Resource"

/datum/manufacture/mender
	name = "Auto Mender"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 5,
							 /datum/manufacturing_requirement/crystal = 4,
							 /datum/manufacturing_requirement/gold = 5,
							)
	item_outputs = list(/obj/item/reagent_containers/mender)
	time = 30 SECONDS
	create = 2
	category = "Resource"

/datum/manufacture/penlight
	name = "Penlight"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							 /datum/manufacturing_requirement/crystal = 1,
							)
	item_outputs = list(/obj/item/device/light/flashlight/penlight)
	time = 2 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/stethoscope
	name = "Stethoscope"
	item_requirements = list(/datum/manufacturing_requirement/metal = 2,
							 /datum/manufacturing_requirement/crystal = 1,
							)
	item_outputs = list(/obj/item/medicaldiagnosis/stethoscope)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/spacesuit
	name = "Space Suit Set"
	item_requirements = list(/datum/manufacturing_requirement/fabric 3,
							 /datum/manufacturing_requirement/metal = 3,
							 /datum/manufacturing_requirement/crystal = 2,
							)
	item_outputs = list(/obj/item/clothing/suit/space,/obj/item/clothing/head/helmet/space)
	time = 15 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/engspacesuit
	name = "Engineering Space Suit Set"
	item_requirements = list(/datum/manufacturing_requirement/fabric 3,
							 /datum/manufacturing_requirement/metal = 3,
							 /datum/manufacturing_requirement/crystal = 2,
							)
	item_outputs = list(/obj/item/clothing/suit/space/engineer,/obj/item/clothing/head/helmet/space/engineer)
	time = 15 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/engdivesuit
	name = "Engineering Diving Suit Set"
	item_requirements = list(/datum/manufacturing_requirement/fabric 3,
							 /datum/manufacturing_requirement/metal = 3,
							 /datum/manufacturing_requirement/crystal = 2,
							)
	item_outputs = list(/obj/item/clothing/suit/space/diving/engineering,/obj/item/clothing/head/helmet/space/engineer/diving/engineering)
	time = 15 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/lightengspacesuit
	name = "Light Engineering Space Suit Set"
	item_requirements = list(/datum/manufacturing_requirement/fabric 10,
							 /datum/manufacturing_requirement/metal/superdense = 5,
							 /datum/manufacturing_requirement/crystal = 2,
							 /datum/manufacturing_requirement/organic_or_rubber = 5,
							)
	item_outputs = list(/obj/item/clothing/suit/space/light/engineer,/obj/item/clothing/head/helmet/space/light/engineer)
	time = 15 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/oresatchel
	name = "Ore Satchel"
	item_requirements = list(/datum/manufacturing_requirement/fabric 5,
							)
	item_outputs = list(/obj/item/satchel/mining)
	time = 5 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/oresatchelL
	name = "Large Ore Satchel"
	item_requirements = list(/datum/manufacturing_requirement/fabric 25,
							 /datum/manufacturing_requirement/metal/superdense = 3,
							)
	item_outputs = list(/obj/item/satchel/mining/large)
	time = 15 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/jetpack
	name = "Jetpack"
	item_requirements = list(/datum/manufacturing_requirement/metal/superdense = 10,
							 /datum/manufacturing_requirement/conductive/high = 20,
							)
	item_outputs = list(/obj/item/tank/jetpack)
	time = 60 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/microjetpack
	name = "Micro Jetpack"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 5,
							 /datum/manufacturing_requirement/conductive = 10,
							)
	item_outputs = list(/obj/item/tank/jetpack/micro)
	time = 30 SECONDS
	create = 1
	category = "Clothing"

/// Ship Items -- OLD COMPONENTS

/datum/manufacture/engine
	name = "Warp-1 Engine"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 3,
							 /datum/manufacturing_requirement/conductive = 5,
							)
	item_outputs = list(/obj/item/shipcomponent/engine)
	time = 10 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/engine2
	name = "Helios Mark-II Engine"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 20,
							 /datum/manufacturing_requirement/metal/superdense = 10,
							 /datum/manufacturing_requirement/conductive/high = 15,
							)
	item_outputs = list(/obj/item/shipcomponent/engine/helios)
	time = 90 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/engine3
	name = "Hermes 3.0 Engine"
	item_requirements = list(/datum/manufacturing_requirement/metal/superdense = 20,
							 /datum/manufacturing_requirement/conductive/high = 20,
							 /datum/manufacturing_requirement/energy = 5,
							)
	item_outputs = list(/obj/item/shipcomponent/engine/hermes)
	time = 120 SECONDS
	create = 1
	category = "Resource"


/datum/manufacture/podgps
	name = "Ship's Navigation GPS"
	item_requirements = list(/datum/manufacturing_requirement/metal = 5,
							 /datum/manufacturing_requirement/conductive = 5,
							)
	item_outputs = list(/obj/item/shipcomponent/secondary_system/gps)
	time = 12 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/cargohold
	name = "Cargo Hold"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 20,
							)
	item_outputs = list(/obj/item/shipcomponent/secondary_system/cargo)
	time = 12 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/storagehold
	name = "Storage Hold"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 20,
							)
	item_outputs = list(/obj/item/shipcomponent/secondary_system/storage)
	time = 12 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/orescoop
	name = "Alloyed Solutions Ore Scoop/Hold"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 20,
							 /datum/manufacturing_requirement/conductive = 10,
							)
	item_outputs = list(/obj/item/shipcomponent/secondary_system/orescoop)
	time = 12 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/communications
	name = "Robustco Communication Array"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 10,
							 /datum/manufacturing_requirement/conductive = 20,
							)
	item_outputs = list(/obj/item/shipcomponent/communications)
	time = 12 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/communications/mining
	name = "NT Magnet Link Array"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 10,
							 /datum/manufacturing_requirement/conductive = 20,
							)
	item_outputs = list(/obj/item/shipcomponent/communications/mining)
	time = 12 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/conclave
	name = "Conclave A-1984 Sensor System"
	item_requirements = list(/datum/manufacturing_requirement/energy = 1,
							 /datum/manufacturing_requirement/crystal = 5,
							 /datum/manufacturing_requirement/conductive/high = 2,
							)
	item_outputs = list(/obj/item/shipcomponent/sensor/mining)
	time = 5 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/shipRCD
	name = "Duracorp Construction Device"
	item_requirements = list(/datum/manufacturing_requirement/metal/superdense = 5,
							 /datum/manufacturing_requirement/dense = 1,
							 /datum/manufacturing_requirement/conductive = 10,
							)
	item_outputs = list(/obj/item/shipcomponent/secondary_system/cargo)
	time = 90 SECONDS
	create = 1
	category = "Resource"

//  cogwerks - clothing manufacturer datums

/datum/manufacture/backpack
	name = "Backpack"
	item_requirements = list(/datum/manufacturing_requirement/fabric 8,
							)
	item_outputs = list(/obj/item/storage/backpack)
	time = 10 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/backpack_red
	name = "Red Backpack"
	item_requirements = list(/datum/manufacturing_requirement/fabric 8,
							)
	item_outputs = list(/obj/item/storage/backpack/empty/red)
	time = 10 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/backpack_green
	name = "Green Backpack"
	item_requirements = list(/datum/manufacturing_requirement/fabric 8,
							)
	item_outputs = list(/obj/item/storage/backpack/empty/green)
	time = 10 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/backpack_blue
	name = "Blue Backpack"
	item_requirements = list(/datum/manufacturing_requirement/fabric 8,
							)
	item_outputs = list(/obj/item/storage/backpack/empty/blue)
	time = 10 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/satchel
	name = "Satchel"
	item_requirements = list(/datum/manufacturing_requirement/fabric 8,
							)
	item_outputs = list(/obj/item/storage/backpack/satchel/empty)
	time = 10 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/satchel_red
	name = "Red Satchel"
	item_requirements = list(/datum/manufacturing_requirement/fabric 8,
							)
	item_outputs = list(/obj/item/storage/backpack/satchel/empty/red)
	time = 10 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/satchel_green
	name = "Green Satchel"
	item_requirements = list(/datum/manufacturing_requirement/fabric 8,
							)
	item_outputs = list(/obj/item/storage/backpack/satchel/empty/green)
	time = 10 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/satchel_blue
	name = "Blue Satchel"
	item_requirements = list(/datum/manufacturing_requirement/fabric 8,
							)
	item_outputs = list(/obj/item/storage/backpack/satchel/empty/blue)
	time = 10 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/shoes_brown
	name = "Brown Shoes"
	item_requirements = list(/datum/manufacturing_requirement/fabric 2,
							)
	item_outputs = list(/obj/item/clothing/shoes/brown)
	time = 2 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/hat_white
	name = "White Hat"
	item_requirements = list(/datum/manufacturing_requirement/fabric 2,
							)
	item_outputs = list(/obj/item/clothing/head/white)
	time = 2 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/hat_black
	name = "Black Hat"
	item_requirements = list(/datum/manufacturing_requirement/fabric 2,
							)
	item_outputs = list(/obj/item/clothing/head/black)
	time = 2 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/hat_blue
	name = "Blue Hat"
	item_requirements = list(/datum/manufacturing_requirement/fabric 2,
							)
	item_outputs = list(/obj/item/clothing/head/blue)
	time = 2 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/hat_red
	name = "Red Hat"
	item_requirements = list(/datum/manufacturing_requirement/fabric 2,
							)
	item_outputs = list(/obj/item/clothing/head/red)
	time = 2 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/hat_green
	name = "Green Hat"
	item_requirements = list(/datum/manufacturing_requirement/fabric 2,
							)
	item_outputs = list(/obj/item/clothing/head/green)
	time = 2 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/hat_yellow
	name = "Yellow Hat"
	item_requirements = list(/datum/manufacturing_requirement/fabric 2,
							)
	item_outputs = list(/obj/item/clothing/head/yellow)
	time = 2 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/hat_pink
	name = "Pink Hat"
	item_requirements = list(/datum/manufacturing_requirement/fabric 2,
							)
	item_outputs = list(/obj/item/clothing/head/pink)
	time = 2 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/hat_orange
	name = "Orange Hat"
	item_requirements = list(/datum/manufacturing_requirement/fabric 2,
							)
	item_outputs = list(/obj/item/clothing/head/orange)
	time = 2 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/hat_purple
	name = "Purple Hat"
	item_requirements = list(/datum/manufacturing_requirement/fabric 2,
							)
	item_outputs = list(/obj/item/clothing/head/purple)
	time = 2 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/hat_tophat
	name = "Top Hat"
	item_requirements = list(/datum/manufacturing_requirement/fabric 3,
							)
	item_outputs = list(/obj/item/clothing/head/that)
	time = 3 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/hat_ltophat
	name = "Large Top Hat"
	item_requirements = list(/datum/manufacturing_requirement/fabric 5,
							)
	item_outputs = list(/obj/item/clothing/head/longtophat)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/jumpsuit_white
	name = "White Jumpsuit"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/under/color/white)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/jumpsuit_red
	name = "Red Jumpsuit"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/under/color/red)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/jumpsuit_yellow
	name = "Yellow Jumpsuit"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/under/color/yellow)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/jumpsuit_green
	name = "Green Jumpsuit"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/under/color/green)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/jumpsuit_pink
	name = "Pink Jumpsuit"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/under/color/pink)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/jumpsuit_blue
	name = "Blue Jumpsuit"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/under/color/blue)
	time = 5 SECONDS
	create = 1
	category = "Clothing"


/datum/manufacture/jumpsuit_purple
	name = "Purple Jumpsuit"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/under/color/purple)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/jumpsuit_brown
	name = "Brown Jumpsuit"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/under/color/brown)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/jumpsuit_black
	name = "Black Jumpsuit"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/under/color)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/jumpsuit_orange
	name = "Orange Jumpsuit"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/under/color/orange)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/tricolor
	name = "Tricolor Jumpsuit"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/under/misc/tricolor)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/pride_lgbt
	name = "LGBT Pride Jumpsuit"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/under/pride)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/pride_ace
	name = "Asexual Pride Jumpsuit"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/under/pride/ace)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/pride_aro
	name = "Aromantic Pride Jumpsuit"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/under/pride/aro)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/pride_bi
	name = "Bisexual Pride Jumpsuit"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/under/pride/bi)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/pride_inter
	name = "Intersex Pride Jumpsuit"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/under/pride/inter)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/pride_lesb
	name = "Lesbian Pride Jumpsuit"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/under/pride/lesb)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/pride_gay
	name = "Gay Pride Jumpsuit"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/under/pride/gaymasc)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/pride_nb
	name = "Non-binary Pride Jumpsuit"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/under/pride/nb)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/pride_pan
	name = "Pansexual Pride Jumpsuit"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/under/pride/pan)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/pride_poly
	name = "Polysexual Pride Jumpsuit"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/under/pride/poly)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/pride_trans
	name = "Trans Pride Jumpsuit"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/under/pride/trans)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/suit_black
	name = "Fancy Black Suit"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/under/suit/black)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/dress_black
	name = "Fancy Black Dress"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/under/suit/black/dress)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/labcoat
	name = "Labcoat"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/suit/labcoat)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/scrubs_white
	name = "White Scrubs"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/under/scrub)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/scrubs_teal
	name = "Teal Scrubs"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/under/scrub/teal)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/scrubs_maroon
	name = "Maroon Scrubs"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/under/scrub/maroon)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/scrubs_blue
	name = "Navy Scrubs"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/under/scrub/blue)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/scrubs_purple
	name = "Violet Scrubs"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/under/scrub/purple)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/scrubs_orange
	name = "Orange Scrubs"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/under/scrub/orange)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/scrubs_pink
	name = "Hot Pink Scrubs"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/under/scrub/pink)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/medical_backpack
	name = "Medical Backpack"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/storage/backpack/medic)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/patient_gown
	name = "Gown"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/under/patient_gown)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/surgical_mask
	name = "Sterile Mask"
	item_requirements = list(/datum/manufacturing_requirement/fabric 1,
							)
	item_outputs = list(/obj/item/clothing/mask/surgical)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/surgical_shield
	name = "Surgical Face Shield"
	item_requirements = list(/datum/manufacturing_requirement/fabric 1,
							)
	item_outputs = list(/obj/item/clothing/mask/surgical_shield)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/eyepatch
	name = "Medical Eyepatch"
	item_requirements = list(/datum/manufacturing_requirement/fabric 5,
							)
	item_outputs = list(/obj/item/clothing/glasses/eyepatch)
	time = 15 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/blindfold
	name = "Blindfold"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/clothing/glasses/blindfold)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/muzzle
	name = "Muzzle"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							 /datum/manufacturing_requirement/metal = 2,
							)
	item_outputs = list(/obj/item/clothing/mask/muzzle)
	time = 5 SECONDS
	create = 1
	category = "Clothing"

/datum/manufacture/hermes
	name = "Offering to the Fabricator Gods"
	item_requirements = list(/datum/manufacturing_requirement/metal/superdense = 30,
							 /datum/manufacturing_requirement/conductive/high = 30,
							 /datum/manufacturing_requirement/energy/extreme = 6,
							 /datum/manufacturing_requirement/crystal/dense = 1,
							 /datum/manufacturing_requirement/fabric 30,
							 /datum/manufacturing_requirement/insulated = 30,
							)
	item_outputs = list(/obj/item/clothing/shoes/hermes)
	time = 120 //suspense
	create = 3 //because a shoe god has to have acolytes
	category = "Clothing"

/datum/manufacture/towel
	name = "Towel"
	item_requirements = list(/datum/manufacturing_requirement/fabric 8,
							)
	item_outputs = list(/obj/item/cloth/towel/white)
	time = 8 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/handkerchief
	name = "Handkerchief"
	item_requirements = list(/datum/manufacturing_requirement/fabric 4,
							)
	item_outputs = list(/obj/item/cloth/handkerchief/colored/white)
	time = 4 SECONDS
	create = 1
	category = "Resource"

/////// pod construction components

/datum/manufacture/pod/armor_light
	name = "Light Pod Armor"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 30,
							 /datum/manufacturing_requirement/conductive = 20,
							)
	item_outputs = list(/obj/item/podarmor/armor_light)
	time = 20 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/pod/armor_heavy
	name = "Heavy Pod Armor"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 30,
							 /datum/manufacturing_requirement/metal/superdense = 20,
							)
	item_outputs = list(/obj/item/podarmor/armor_heavy)
	time = 30 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/pod/armor_industrial
	name = "Industrial Pod Armor"
	item_requirements = list(/datum/manufacturing_requirement/metal/superdense = 25,
							 /datum/manufacturing_requirement/conductive/high = 10,
							 /datum/manufacturing_requirement/dense = 5,
							)
	item_outputs = list(/obj/item/podarmor/armor_industrial)
	time = 50 SECONDS
	create = 1
	category = "Component"

/datum/manufacture/pod/preassembeled_parts
	name = "Preassembled Pod Frame Kit"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 45,
							 /datum/manufacturing_requirement/conductive = 25,
							 /datum/manufacturing_requirement/crystal = 19,
							)
	item_outputs = list(/obj/item/preassembled_frame_box/pod)
	time = 50 SECONDS
	create = 1
	category = "Component"

ABSTRACT_TYPE(/datum/manufacture/sub)
/datum/manufacture/sub/preassembeled_parts
	name = "Preassembled Minisub Frame Kit"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 23,
							 /datum/manufacturing_requirement/conductive = 12,
							 /datum/manufacturing_requirement/crystal = 9,
							)
	item_outputs = list(/obj/item/preassembled_frame_box/sub)
	time = 25 SECONDS
	create = 1
	category = "Component"

ABSTRACT_TYPE(/datum/manufacture/putt)
/datum/manufacture/putt/preassembeled_parts
	name = "Preassembled MiniPutt Frame Kit"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 23,
							 /datum/manufacturing_requirement/conductive = 12,
							 /datum/manufacturing_requirement/crystal = 9,
							)
	item_outputs = list(/obj/item/preassembled_frame_box/putt)
	time = 25 SECONDS
	create = 1
	category = "Component"

//// pod addons

ABSTRACT_TYPE(/datum/manufacture/pod)

ABSTRACT_TYPE(/datum/manufacture/pod/weapon)

/datum/manufacture/pod/weapon/bad_mining
	name = "Mining Phaser System"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 10,
							 /datum/manufacturing_requirement/conductive = 10,
							 /datum/manufacturing_requirement/crystal = 20,
							)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/bad_mining)
	time = 20 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/pod/weapon/mining
	name = "Plasma Cutter System"
	item_requirements = list(/datum/manufacturing_requirement/energy = 10,
							 /datum/manufacturing_requirement/metal/superdense = 10,
							 /datum/manufacturing_requirement/crystal/dense = 20,
							)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/mining)
	time = 20 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/pod/weapon/mining/drill
	name = "Rock Drilling Rig"
	item_requirements = list(/datum/manufacturing_requirement/energy = 10,
							 /datum/manufacturing_requirement/metal/superdense = 10,
							 /datum/manufacturing_requirement/crystal/dense = 10,
							)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/rockdrills)
	time = 20 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/pod/weapon/ltlaser
	name = "Mk.1.5 Light Phasers"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 15,
							 /datum/manufacturing_requirement/conductive = 15,
							 /datum/manufacturing_requirement/crystal = 15,
							)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/phaser)
	time = 20 SECONDS
	create  = 1
	category = "Tool"

/datum/manufacture/pod/lock
	name = "Pod Locking Mechanism"
	item_requirements = list(/datum/manufacturing_requirement/crystal = 5,
							 /datum/manufacturing_requirement/conductive = 10,
							)
	item_outputs = list(/obj/item/shipcomponent/secondary_system/lock)
	time = 10 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/pod/sps
	name = "Syndicate Purge System"
	item_requirements = list(/datum/manufacturing_requirement/metal = 8,
							 /datum/manufacturing_requirement/conductive = 12,
							 /datum/manufacturing_requirement/crystal = 16,
							)
	item_outputs = list(/obj/item/shipcomponent/mainweapon/syndicate_purge_system)
	time = 90 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/pod/srs
	name = "Syndicate Rewind System"
	item_requirements = list(/datum/manufacturing_requirement/metal = 16,
							 /datum/manufacturing_requirement/conductive = 12,
							 /datum/manufacturing_requirement/crystal = 8,
							)
	item_outputs = list(/obj/item/shipcomponent/secondary_system/syndicate_rewind_system)
	time = 90 SECONDS
	create = 1
	category = "Tool"
//// deployable warp beacon

/datum/manufacture/beaconkit
	name = "Warp Beacon Frame"
	item_names = list("Crystal","Conductive Material","Sturdy Metal")
	item_requirements = list(/datum/manufacturing_requirement/crystal = 10,
							 /datum/manufacturing_requirement/conductive = 10,
							 /datum/manufacturing_requirement/metal/dense = 10,
							)
	item_outputs = list(/obj/beaconkit)
	time = 30 SECONDS
	create = 1
	category = "Machinery"


/******************** HOP *******************/

/datum/manufacture/id_card
	name = "ID card"
	item_requirements = list(/datum/manufacturing_requirement/conductive = 3,
							 /datum/manufacturing_requirement/crystal = 3,
							)
	item_outputs = list(/obj/item/card/id)
	time = 5 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/id_card_gold
	name = "Gold ID card"
	item_requirements = list(/datum/manufacturing_requirement/gold = 5,
							 /datum/manufacturing_requirement/conductive/high = 4,
							 /datum/manufacturing_requirement/crystal = 3,
							)
	item_outputs = list(/obj/item/card/id/gold)
	time = 30 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/implant_access
	name = "Electronic Access Implant (8 Access Charges)"
	item_requirements = list(/datum/manufacturing_requirement/conductive = 3,
							 /datum/manufacturing_requirement/crystal = 3,
							)
	item_outputs = list(/obj/item/implantcase/access)
	time = 20 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/acesscase
	name = "ID Briefcase"
	item_requirements = list(/datum/manufacturing_requirement/conductive = 25,
							 /datum/manufacturing_requirement/crystal = 15,
							 /datum/manufacturing_requirement/metal = 35,
							 /datum/manufacturing_requirement/gold = 2,
							)
	item_outputs = list(/obj/machinery/computer/card/portable)
	time = 75 SECONDS
	create = 1
	category = "Resource"

/datum/manufacture/implant_access_infinite
	name = "Electronic Access Implant (Unlimited Charge)"
	item_requirements = list(/datum/manufacturing_requirement/conductive = 9,
							 /datum/manufacturing_requirement/crystal = 15,
							)
	item_outputs = list(/obj/item/implantcase/access/unlimited)
	time = 60 SECONDS
	create = 1
	category = "Resource"

/******************** QM CRATES *******************/

/datum/manufacture/crate
	name = "Crate"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							)
	item_outputs = list(/obj/storage/crate)
	time = 10 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/packingcrate
	name = "Random Packing Crate"
	item_requirements = list(/datum/manufacturing_requirement/wood = 1,
							)
	item_outputs = list(/obj/storage/crate/packing)
	time = 10 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/wooden
	name = "Wooden Crate"
	item_requirements = list(/datum/manufacturing_requirement/wood = 1,
							)
	item_outputs = list(/obj/storage/crate/wooden)
	time = 10 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/medical
	name = "Medical Crate"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							)
	item_outputs = list(/obj/storage/crate/medical)
	time = 10 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/biohazard
	name = "Biohazard Crate"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							)
	item_outputs = list(/obj/storage/crate/biohazard)
	time = 10 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/classcrate
	name = "Class Crate"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							)
	item_outputs = list(/obj/storage/crate/classcrate)
	time = 10 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/freezer
	name = "Freezer Crate"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							)
	item_outputs = list(/obj/storage/crate/freezer)
	time = 10 SECONDS
	create = 1
	category = "Miscellaneous"
/******************** GUNS *******************/

/datum/manufacture/alastor
	name = "Alastor Pattern Laser Rifle"
	item_requirements = list(/datum/manufacturing_requirement/dense = 1,
							 /datum/manufacturing_requirement/metal/superdense = 10,
							 /datum/manufacturing_requirement/conductive = 20,
							 /datum/manufacturing_requirement/crystal = 20,
							)
	item_outputs = list(/obj/item/gun/energy/alastor)
	time = 30 SECONDS
	create = 1
	category = "Tool"

/************ INTERDICTOR STUFF ************/

/datum/manufacture/interdictor_kit
	name = "Interdictor Frame Kit"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 10,
							)
	item_outputs = list(/obj/item/interdictor_kit)
	time = 10 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/interdictor_board_standard
	name = "Standard Interdictor Mainboard"
	item_requirements = list(/datum/manufacturing_requirement/conductive = 4,
							)
	item_outputs = list(/obj/item/interdictor_board)
	time = 5 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/interdictor_board_nimbus
	name = "Nimbus Interdictor Mainboard"
	item_requirements = list(/datum/manufacturing_requirement/conductive = 4,
							 /datum/manufacturing_requirement/insulated = 2,
							 /datum/manufacturing_requirement/crystal = 2,
							)
	item_outputs = list(/obj/item/interdictor_board/nimbus)
	time = 10 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/interdictor_board_zephyr
	name = "Zephyr Interdictor Mainboard"
	item_requirements = list(/datum/manufacturing_requirement/conductive = 4,
							 /datum/manufacturing_requirement/viscerite = 5,
							)
	item_outputs = list(/obj/item/interdictor_board/zephyr)
	time = 10 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/interdictor_board_devera
	name = "Devera Interdictor Mainboard"
	item_requirements = list(/datum/manufacturing_requirement/conductive = 4,
							 /datum/manufacturing_requirement/crystal = 2,
							 /datum/manufacturing_requirement/syreline = 5,
							)
	item_outputs = list(/obj/item/interdictor_board/devera)
	time = 10 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/interdictor_rod_lambda
	name = "Lambda Phase-Control Rod"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 2,
							 /datum/manufacturing_requirement/conductive = 10,
							 /datum/manufacturing_requirement/crystal = 5,
							 /datum/manufacturing_requirement/insulated = 2,
							)
	item_outputs = list(/obj/item/interdictor_rod)
	time = 12 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/interdictor_rod_sigma
	name = "Sigma Phase-Control Rod"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 2,
							 /datum/manufacturing_requirement/conductive/high = 10,
							 /datum/manufacturing_requirement/insulated = 5,
							 /datum/manufacturing_requirement/energy = 2,
							)
	item_outputs = list(/obj/item/interdictor_rod/sigma)
	time = 15 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/interdictor_rod_epsilon
	name = "Epsilon Phase-Control Rod"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 2,
							 /datum/manufacturing_requirement/electrum = 10,
							 /datum/manufacturing_requirement/dense = 5,
							 /datum/manufacturing_requirement/energy = 2,
							)
	item_outputs = list(/obj/item/interdictor_rod/epsilon)
	time = 20 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/interdictor_rod_phi
	name = "Phi Phase-Control Rod"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 5,
							 /datum/manufacturing_requirement/crystal = 10,
							 /datum/manufacturing_requirement/conductive = 5,
							)
	item_outputs = list(/obj/item/interdictor_rod/phi)
	time = 15 SECONDS
	create = 1
	category = "Machinery"


/************ NADIR RESONATORS ************/

/datum/manufacture/resonator_type_ax
	name = "Type-AX Resonator"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 15,
							 /datum/manufacturing_requirement/conductive/high = 20,
							 /datum/manufacturing_requirement/crystal = 20,
							 /datum/manufacturing_requirement/energy = 5,
							)
	item_outputs = list(/obj/machinery/siphon/resonator)
	time = 30 SECONDS
	create = 1
	category = "Machinery"

/datum/manufacture/resonator_type_sm
	name = "Type-SM Resonator"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 10,
							 /datum/manufacturing_requirement/conductive/high = 20,
							 /datum/manufacturing_requirement/crystal = 10,
							 /datum/manufacturing_requirement/insulated = 10,
							)
	item_outputs = list(/obj/machinery/siphon/resonator/stabilizer)
	time = 30 SECONDS
	create = 1
	category = "Machinery"

/************ NADIR GEAR ************/

/datum/manufacture/nanoloom
	name = "Nanoloom"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 4,
							 /datum/manufacturing_requirement/conductive = 2,
							 /datum/manufacturing_requirement/cobryl = 1,
							 /datum/manufacturing_requirement/fabric 3,
							)
	item_outputs = list(/obj/item/device/nanoloom)
	time = 15 SECONDS
	create = 1
	category = "Tool"

/datum/manufacture/nanoloom_cart
	name = "Nanoloom Cartridge"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 1,
							 /datum/manufacturing_requirement/cobryl = 1,
							 /datum/manufacturing_requirement/fabric 3,
							)
	item_outputs = list(/obj/item/nanoloom_cartridge)
	time = 8 SECONDS
	create = 1
	category = "Tool"

//////////////////////UBER-EXTREME SURVIVAL////////////////////////////////
/datum/manufacture/armor_vest	//
	name = "Armor Vest"
	item_requirements = list(/datum/manufacturing_requirement/metal/superdense = 5,
							)
	item_outputs = list(/obj/item/clothing/suit/armor/vest)
	time = 30 SECONDS
	create = 1
	category = "Weapon"

/datum/manufacture/saa	//
	name = "Colt SAA"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 7,
							)
	item_outputs = list(/obj/item/gun/kinetic/single_action/colt_saa)
	time = 30 SECONDS
	create = 1
	category = "Weapon"
/datum/manufacture/saa_ammo	//
	name = "Colt Ammo"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							)
	item_outputs = list(/obj/item/ammo/bullets/c_45)
	time = 7 SECONDS
	create = 1
	category = "ammo"
/datum/manufacture/clock	//
	name = "Clock 188"
	item_requirements = list(/datum/manufacturing_requirement/metal = 10,
							)
	item_outputs = list(/obj/item/gun/kinetic/clock_188)
	time = 10 SECONDS
	create = 1
	category = "Weapon"
/datum/manufacture/clock_ammo	//
	name = "Clock ammo"
	item_requirements = list(/datum/manufacturing_requirement/metal = 3,
							)
	item_outputs = list(/obj/item/ammo/bullets/nine_mm_NATO)
	time = 7 SECONDS
	create = 1
	category = "ammo"

/datum/manufacture/riot_shotgun	//
	name = "Riot Shotgun"
	item_requirements = list(/datum/manufacturing_requirement/metal = 20,
							)
	item_outputs = list(/obj/item/gun/kinetic/riotgun)
	time = 20 SECONDS
	create = 1
	category = "Weapon"
/datum/manufacture/riot_shotgun_ammo	//
	name = "Rubber Bullet ammo"
	item_requirements = list(/datum/manufacturing_requirement/metal = 10,
							)
	item_outputs = list(/obj/item/ammo/bullets/abg)
	time = 7 SECONDS
	create = 1
	category = "ammo"

/datum/manufacture/riot_launcher	//
	name = "Riot Launcher"
	item_requirements = list(/datum/manufacturing_requirement/metal = 12,
							)
	item_outputs = list(/obj/item/gun/kinetic/riot40mm)
	time = 10 SECONDS
	create = 1
	category = "Weapon"
/datum/manufacture/riot_launcher_ammo_pbr	//
	name = "Launcher PBR Ammo"
	item_requirements = list(/datum/manufacturing_requirement/metal = 2,
							 /datum/manufacturing_requirement/conductive = 4,
							 /datum/manufacturing_requirement/crystal = 1,
							)
	item_outputs = list(/obj/item/ammo/bullets/pbr)
	time = 10 SECONDS
	create = 1
	category = "ammo"
/datum/manufacture/riot_launcher_ammo_flashbang	//
	name = "Launcher Flashbang Box"
	item_requirements = list(/datum/manufacturing_requirement/metal = 2,
							 /datum/manufacturing_requirement/conductive = 3,
							)
	item_outputs = list(/obj/item/storage/box/flashbang_kit)
	time = 10 SECONDS
	create = 1
	category = "ammo"
/datum/manufacture/riot_launcher_ammo_tactical	//
	name = "Launcher Tactical Box"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 5,
							 /datum/manufacturing_requirement/conductive = 5,
							 /datum/manufacturing_requirement/crystal = 3,
							)
	item_outputs = list(/obj/item/storage/box/tactical_kit)
	time = 10 SECONDS
	create = 1
	category = "ammo"

/datum/manufacture/sniper	//
	name = "Sniper"
	item_requirements = list(/datum/manufacturing_requirement/dense = 2,
							 /datum/manufacturing_requirement/metal/superdense = 15,
							 /datum/manufacturing_requirement/conductive = 4,
							 /datum/manufacturing_requirement/crystal = 3,
							)
	item_outputs = list(/obj/item/gun/kinetic/sniper)
	time = 25 SECONDS
	create = 1
	category = "Weapon"
/datum/manufacture/sniper_ammo	//
	name = "Sniper Ammo"
	item_requirements = list(/datum/manufacturing_requirement/metal/superdense = 6,
							)
	item_outputs = list(/obj/item/ammo/bullets/rifle_762_NATO)
	time = 10 SECONDS
	create = 1
	category = "ammo"
/datum/manufacture/tac_shotgun	//
	name = "Tactical Shotgun"
	item_requirements = list(/datum/manufacturing_requirement/metal/superdense = 15,
							 /datum/manufacturing_requirement/conductive = 5,
							)
	item_outputs = list(/obj/item/gun/kinetic/tactical_shotgun)
	time = 20 SECONDS
	create = 1
	category = "Weapon"
/datum/manufacture/tac_shotgun_ammo	//
	name = "Tactical Shotgun Ammo"
	item_requirements = list(/datum/manufacturing_requirement/metal/superdense = 5,
							)
	item_outputs = list(/obj/item/ammo/bullets/buckshot_burst)
	time = 7 SECONDS
	create = 1
	category = "ammo"
/datum/manufacture/gyrojet	//
	name = "Gyrojet"
	item_requirements = list(/datum/manufacturing_requirement/dense = 5,
							 /datum/manufacturing_requirement/metal/superdense = 10,
							 /datum/manufacturing_requirement/conductive/high = 6,
							)
	item_outputs = list(/obj/item/gun/kinetic/gyrojet)
	time = 30 SECONDS
	create = 1
	category = "Weapon"
/datum/manufacture/gyrojet_ammo	//
	name = "Gyrojet Ammo"
	item_requirements = list(/datum/manufacturing_requirement/metal/superdense = 5,
							 /datum/manufacturing_requirement/conductive/high = 2,
							)
	item_outputs = list(/obj/item/ammo/bullets/gyrojet)
	time = 7 SECONDS
	create = 1
	category = "Ammo"
/datum/manufacture/plank	//
	name = "Barricade Planks"
	item_requirements = list(/datum/manufacturing_requirement/wood = 1,
							)
	item_outputs = list(/obj/item/sheet/wood/zwood)
	time = 1 SECOND
	create = 1
	category = "Medicine"
/datum/manufacture/brute_kit	//
	name = "Brute Kit"
	item_requirements = list(/datum/manufacturing_requirement/metal = 2,
							 /datum/manufacturing_requirement/conductive = 2,
							)
	item_outputs = list(/obj/item/storage/firstaid/brute)
	time = 10 SECONDS
	create = 1
	category = "Medicine"
/datum/manufacture/burn_kit	//
	name = "Burn Kit"
	item_requirements = list(/datum/manufacturing_requirement/metal = 2,
							 /datum/manufacturing_requirement/conductive = 2,
							)
	item_outputs = list(/obj/item/storage/firstaid/fire)
	time = 10 SECONDS
	create = 1
	category = "Medicine"
/datum/manufacture/crit_kit //
	name = "Crit Kit"
	item_requirements = list(/datum/manufacturing_requirement/metal = 2,
							 /datum/manufacturing_requirement/conductive = 2,
							)
	item_outputs = list(/obj/item/storage/firstaid/crit)
	time = 9 SECONDS
	create = 1
	category = "Medicine"
/datum/manufacture/empty_kit
	name = "Empty First Aid Kit"
	item_requirements = list(/datum/manufacturing_requirement/metal = 1,
							)
	item_outputs = list(/obj/item/storage/firstaid/regular/empty)
	time = 4 SECONDS
	create = 1
	category = "Medicine"
/datum/manufacture/spacecillin	//
	name = "Spacecillin"
	item_requirements = list(/datum/manufacturing_requirement/metal = 3,
							 /datum/manufacturing_requirement/conductive = 3,
							)
	item_outputs = list(/obj/item/reagent_containers/syringe/antiviral)
	time = 10 SECONDS
	create = 1
	category = "Medicine"
/datum/manufacture/bat	//
	name = "Baseball Bat"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 15,
							)
	item_outputs = list(/obj/item/bat)
	time = 20 SECONDS
	create = 1
	category = "Miscellaneous"
/datum/manufacture/quarterstaff	//
	name = "Quarterstaff"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 10,
							)
	item_outputs = list(/obj/item/quarterstaff)
	time = 10 SECONDS
	create = 1
	category = "Miscellaneous"
/datum/manufacture/cleaver	//
	name = "Cleaver"
	item_requirements = list(/datum/manufacturing_requirement/metal = 20,
							)
	item_outputs = list(/obj/item/kitchen/utensil/knife/cleaver)
	time = 16 SECONDS
	create = 1
	category = "Miscellaneous"
/datum/manufacture/dsaber	//
	name = "D-Saber"
	item_requirements = list(/datum/manufacturing_requirement/metal/dense = 20,
							 /datum/manufacturing_requirement/conductive = 10,
							)
	item_outputs = list(/obj/item/sword/discount)
	time = 20 SECONDS
	create = 1
	category = "Miscellaneous"
/datum/manufacture/fireaxe	//
	name = "Fireaxe"
	item_requirements = list(/datum/manufacturing_requirement/metal/superdense = 20,
							 /datum/manufacturing_requirement/conductive/high = 5,
							)
	item_outputs = list(/obj/item/fireaxe)
	time = 20 SECONDS
	create = 1
	category = "Miscellaneous"
/datum/manufacture/shovel	//
	name = "Shovel"
	item_requirements = list(/datum/manufacturing_requirement/metal/superdense = 25,
							 /datum/manufacturing_requirement/conductive/high = 5,
							)
	item_outputs = list(/obj/item/shovel)	//this is powerful)
	time = 40 SECONDS
	create = 1
	category = "Miscellaneous"

/datum/manufacture/floodlight
	name = "Floodlight"
	item_outputs = list(/obj/item/device/light/floodlight)
	time = 8 SECONDS
	create = 1
	category = "Tool"
