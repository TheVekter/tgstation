/datum/lazy_template/virtual_domain/janitor_work_test
	name = "Janitorial Work: Test"
	desc = "Cremwmeber causing janitorial issues? Teach them how to clean up."
	help_text = "Test domain for janitorial work."
	key = "janitor_work_test"
	map_name = "janitor_work_test"
	bitrunning_network = BITRUNNER_DOMAIN_SECURITY
	forced_outfit = /datum/outfit/job/prisoner/janitor

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

/datum/outfit/job/prisoner/janitor
	name = "Janitor (Prisoner)"
	uniform = /obj/item/clothing/under/rank/prisoner
	head = /obj/item/clothing/head/soft/purple
	belt = /obj/item/storage/belt/janitor
	ears = null
	shoes = /obj/item/clothing/shoes/galoshes
	skillchips = null
	backpack_contents = null

/datum/lazy_template/virtual_domain/customer_push_test
	name = "Tourist Assistance: Test"
	desc = "Crewmember being rude to our guests? Teach them how to help their fellow tourist."
	help_text = "Test domain for Tourist Assistance."
	key = "customer_push_test"
	map_name = "customer_push_test"
	bitrunning_network = BITRUNNER_DOMAIN_SECURITY
	forced_outfit = /datum/outfit/job/prisoner/waiter

/datum/lazy_template/virtual_domain/customer_push_test/setup_domain(list/created_atoms)
	for(var/obj/effect/landmark/bitrunning/bitrunner_spawn/spawner in created_atoms)
		custom_spawns += spawner

/datum/outfit/job/prisoner/waiter
	name = "Waiter (Prisoner)"
	neck = /obj/item/clothing/neck/bowtie
	suit = /obj/item/clothing/suit/apron
	uniform = /obj/item/clothing/under/rank/prisoner
	head = /obj/item/clothing/head/collectable/chef
	ears = null
	shoes = /obj/item/clothing/shoes/laceup
	skillchips = null
	backpack_contents = null

/datum/lazy_template/virtual_domain/teleporter_maze_test
	name = "Teleporter Maze Mapping: Test"
	desc = "Crewmember making it hard to get around the station? Teach them how to respect easily navigatable areas."
	help_text = "Test domain for Teleporter Maze."
	key = "teleporter_maze_test"
	map_name = "teleporter_maze_test"
	bitrunning_network = BITRUNNER_DOMAIN_SECURITY
	forced_outfit = /datum/outfit/job/prisoner/scientist

/datum/lazy_template/virtual_domain/teleporter_maze_test/setup_domain(list/created_atoms)
	for(var/obj/effect/landmark/bitrunning/bitrunner_spawn/spawner in created_atoms)
		custom_spawns += spawner

/datum/outfit/job/prisoner/scientist
	name = "Scientist (Prisoner)"
	neck = /obj/item/clothing/neck/tie/horrible
	suit = /obj/item/clothing/suit/toggle/labcoat/science
	uniform = /obj/item/clothing/under/rank/prisoner
	head = null
	glasses = /obj/item/clothing/glasses/science
	ears = null
	shoes = /obj/item/clothing/shoes/sneakers/purple
	skillchips = null
	backpack_contents = null
