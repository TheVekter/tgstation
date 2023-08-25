#define PICKUP_RESTRICTION_TIME 3 SECONDS // so other players can pickup the ball after someone scores

/datum/crafting_recipe/basketball_hoop
	name = "Basketball Hoop"
	result = /obj/structure/hoop
	reqs = list(/obj/item/stack/sheet/durathread = 5,
				/obj/item/stack/sheet/iron = 1, // the backboard
				/obj/item/stack/rods = 5)
	time = 10 SECONDS
	category = CAT_STRUCTURE

/obj/structure/hoop
	name = "basketball hoop"
	desc = "Boom, shakalaka!"
	icon = 'icons/obj/fluff/basketball_hoop.dmi'
	icon_state = "hoop"
	anchored = TRUE
	density = TRUE
	layer = ABOVE_MOB_LAYER
	//physically offset ourself so we render right as a big icon (I think? that's what's goin on here)
	pixel_y = 16
	pixel_z = -16
	/// Keeps track of the total points scored
	var/total_score = 0
	/// The chance to score a ball into the hoop based on distance
	var/static/list/throw_range_success = list(95, 80, 65, 50, 35, 20)

/obj/structure/hoop/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/simple_rotation, ROTATION_REQUIRE_WRENCH|ROTATION_IGNORE_ANCHORED, AfterRotation = CALLBACK(src, PROC_REF(reset_appearance)))
	update_appearance()
	register_context()

/obj/structure/hoop/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	context[SCREENTIP_CONTEXT_CTRL_LMB] = "Reset score"
	return CONTEXTUAL_SCREENTIP_SET

/obj/structure/hoop/proc/reset_appearance()
	update_appearance()

/obj/structure/hoop/proc/score(obj/item/toy/basketball/ball, mob/living/baller, points)
	// we still play buzzer sound regardless of the object
	playsound(src, 'sound/machines/scanbuzz.ogg', 100, FALSE)

	if(!istype(ball))
		return

	total_score += points
	update_appearance()
	// whoever scored doesn't get to pickup the ball instantly
	COOLDOWN_START(ball, pickup_cooldown, PICKUP_RESTRICTION_TIME)

	ball.pickup_restriction_ckeys |= baller.ckey
	return TRUE

/obj/structure/hoop/update_overlays()
	. = ..()
	cut_overlays()
	var/dir_offset_x = 0
	var/dir_offset_y = 0

	switch(dir)
		if(NORTH)
			dir_offset_y = -32
		if(SOUTH)
			dir_offset_y = 32
		if(EAST)
			dir_offset_x = -32
		if(WEST)
			dir_offset_x = 32

	var/mutable_appearance/scoreboard = mutable_appearance('icons/obj/signs.dmi', "basketball_scorecard")
	scoreboard.pixel_w = dir_offset_x
	scoreboard.pixel_z = dir_offset_y
	SET_PLANE_EXPLICIT(scoreboard, GAME_PLANE, src)
	. += scoreboard

	var/ones = total_score % 10
	var/mutable_appearance/ones_overlay = mutable_appearance('icons/obj/signs.dmi', "days_[ones]", layer + 0.01)
	ones_overlay.pixel_w = 4
	var/mutable_appearance/emissive_ones_overlay  = emissive_appearance('icons/obj/signs.dmi', "days_[ones]", src, alpha = src.alpha)
	emissive_ones_overlay.pixel_w = 4
	scoreboard.add_overlay(ones_overlay)
	scoreboard.add_overlay(emissive_ones_overlay)

	var/tens = (total_score / 10) % 10
	var/mutable_appearance/tens_overlay = mutable_appearance('icons/obj/signs.dmi', "days_[tens]", layer + 0.01)
	tens_overlay.pixel_w = -5

	var/mutable_appearance/emissive_tens_overlay  = emissive_appearance('icons/obj/signs.dmi', "days_[tens]", src, alpha = src.alpha)
	emissive_tens_overlay.pixel_w = -5
	scoreboard.add_overlay(tens_overlay)
	scoreboard.add_overlay(emissive_tens_overlay)

/obj/structure/hoop/attackby(obj/item/ball, mob/living/baller, params)
	if(!baller.can_perform_action(src, NEED_HANDS|FORBID_TELEKINESIS_REACH))
		return // TK users aren't allowed to dunk

	if(!baller.transferItemToLoc(ball, drop_location()))
		return

	var/dunk_dir = get_dir(baller, src)

	var/dunk_pixel_y = dunk_dir & SOUTH ? -16 : 16
	var/dunk_pixel_x = dunk_dir & EAST && 16 || dunk_dir & WEST && -16 || 0

	INVOKE_ASYNC(src, PROC_REF(dunk_animation), baller, dunk_pixel_y, dunk_pixel_x)
	visible_message(span_warning("[baller] dunks [ball] into \the [src]!"))
	baller.add_mood_event("basketball", /datum/mood_event/basketball_dunk)
	score(ball, baller, 2)

	if(istype(ball, /obj/item/toy/basketball))
		baller.adjustStaminaLoss(STAMINA_COST_DUNKING)

/// This bobs the mob in the hoop direction for the dunk animation
/obj/structure/hoop/proc/dunk_animation(mob/living/baller, dunk_pixel_y, dunk_pixel_x)
	animate(baller, pixel_x = dunk_pixel_x, pixel_y = dunk_pixel_y, time = 5, easing = BOUNCE_EASING|EASE_IN|EASE_OUT)
	sleep(0.5 SECONDS)
	animate(baller, pixel_x = 0, pixel_y = 0, time = 3)

/obj/structure/hoop/attack_hand(mob/living/baller, list/modifiers)
	. = ..()
	if(.)
		return

	if(!(baller.pulling && isliving(baller.pulling)))
		return ..()

	var/mob/living/loser = baller.pulling
	if(baller.grab_state < GRAB_AGGRESSIVE)
		to_chat(baller, span_warning("You need a better grip to do that!"))
		return
	loser.forceMove(loc)
	loser.Paralyze(100)
	visible_message(span_danger("[baller] dunks [loser] into \the [src]!"))
	playsound(src, 'sound/machines/scanbuzz.ogg', 100, FALSE)
	baller.adjustStaminaLoss(STAMINA_COST_DUNKING_MOB)
	baller.stop_pulling()

/obj/structure/hoop/CtrlClick(mob/living/user)
	if(!user.can_perform_action(src, NEED_DEXTERITY|FORBID_TELEKINESIS_REACH|NEED_HANDS))
		return

	user.balloon_alert_to_viewers("resetting score...")
	playsound(src, 'sound/machines/locktoggle.ogg', 50, TRUE)
	if(do_after(user, 5 SECONDS, target = src))
		total_score = 0
		update_appearance()
	return ..()

/obj/structure/hoop/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(!isitem(AM))
		return ..()

	var/distance = clamp(throwingdatum.dist_travelled + 1, 1, throw_range_success.len)
	var/score_chance = throw_range_success[distance]
	var/obj/structure/hoop/backboard = throwingdatum.initial_target?.resolve()
	var/click_on_hoop = TRUE
	var/mob/living/thrower = throwingdatum.thrower

	// aim penalty for not clicking directly on the hoop when shooting
	if(!istype(backboard) || backboard != src)
		click_on_hoop = FALSE
		score_chance *= 0.5

	// aim penalty for spinning while shooting
	if(istype(thrower) && thrower.flags_1 & IS_SPINNING_1)
		score_chance *= 0.5

	if(prob(score_chance))
		AM.forceMove(get_turf(src))
		// is it a 3 pointer shot
		var/points = (distance > 2) ? 3 : 2
		thrower.add_mood_event("basketball", /datum/mood_event/basketball_score)
		score(AM, thrower, points)
		visible_message(span_warning("[click_on_hoop ? "Swish!" : ""] [AM] lands in [src]."))
	else
		visible_message(span_danger("[AM] bounces off of [src]'s [click_on_hoop ? "rim" : "backboard"]!"))

// Special hoops for the minigame
/obj/structure/hoop/minigame
	/// This is a list of ckeys for the minigame to prevent scoring on their own hoops
	var/list/team_ckeys = list()

/obj/structure/hoop/minigame/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	return NONE

// No resetting the score for minigame hoops
/obj/structure/hoop/minigame/CtrlClick(mob/living/user)
	return

/obj/structure/hoop/minigame/score(obj/item/toy/basketball/ball, mob/living/baller, points)
	var/is_team_hoop = !(baller.ckey in team_ckeys)
	if(is_team_hoop)
		baller.balloon_alert_to_viewers("cant score own hoop!")
		return

	if(..())
		ball.pickup_restriction_ckeys |= team_ckeys

#undef PICKUP_RESTRICTION_TIME
