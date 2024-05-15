
/datum/unit_test/manufacturer_blueprint_generations

/datum/unit_test/manufacturer_blueprint_generations/Run()
	var/starting_runtimes = runtime_count
	//var/obj/machinery/manufacturer/M = new /obj/machinery/manufacturer/
	for (var/blueprint_type in concrete_typesof(/datum/manufacture))
		var/datum/manufacture/B = new blueprint_type
		qdel(B)

	var/obj/item/electronics/scanner/syndicate/scanner = new /obj/item/electronics/scanner/syndicate
	for (var/obj/O as anything in concrete_typesof(/obj/))
		var/scan_result = SEND_SIGNAL(A, COMSIG_ATOM_ANALYZE, parent_item, user)
		if (scan_result != MECHANICS_ANALYSIS_INCOMPATIBLE)
			

	var/caused_runtimes = runtime_count - starting_runtimes
	if (caused_runtimes)
		Fail("Spawning manufacturer blueprints caused [caused_runtimes] runtime\s")
