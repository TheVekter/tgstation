/datum/lazy_template/virtual_domain/janitor_work_test
	name = "Janitorial Work: Test"
	desc = "Cremwmeber causing janitorial issues? Teach them how to clean up."
	help_text = "Test domain for janitorial work."
	key = "janitor_work_test"
	map_name = "janitor_work_test"
	bitrunning_network = BITRUNNER_DOMAIN_SECURITY
	forced_outfit = /datum/outfit/job/janitor/prisoner

/datum/lazy_template/virtual_domain/janitor_work_test/setup_domain(list/created_atoms)
	for(var/obj/effect/landmark/bitrunning/bitrunner_spawn/spawner in created_atoms)
		custom_spawns += spawner

	for(var/obj/item/gun/ballistic/ballistic_gun in created_atoms)
		ballistic_gun.magazine.empty_magazine()

	for(var/obj/item/gun/energy/energy_gun in created_atoms)
		energy_gun.cell.charge = 0
		energy_gun.update_icon()

	for(var/obj/item/ammo_casing/casing in created_atoms)
		casing.loaded_projectile = null
		casing.update_icon_state()

/datum/outfit/job/janitor/prisoner
	name = "Janitor (Prisoner)"
	uniform = /obj/item/clothing/under/rank/prisoner
	head = /obj/item/clothing/head/soft/purple
	belt = /obj/item/storage/belt/janitor
	ears = null
	shoes = /obj/item/clothing/shoes/galoshes
	skillchips = null
	backpack_contents = null
