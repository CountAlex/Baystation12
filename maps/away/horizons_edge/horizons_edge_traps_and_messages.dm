////////////////////////////////////////////////////////////////////////////////TRAPS AND TRIGGERS
/obj/effect/step_trigger/horizons_edge/Crossed(H as mob)
	..()
	if(!H)
		return
	if(!isclient(H) || isobserver(H) || isghost(H))
		return
	Trigger(H)

/obj/effect/step_trigger/horizons_edge/message///makes spooky message upon entering the temple
	var/list/visited_by = list()//only one message for every visitor
	var/message = ""

/obj/effect/step_trigger/horizons_edge/message/Trigger(mob/M as mob)
	if(M.client)
		if (!visited_by.Find(M))
			to_chat(M, "<span class='info'>[message]</span>")
			visited_by.Add(M)

/obj/effect/step_trigger/horizons_edge/message/entrance//makes spooky message upon entering the temple
	message = "You feel like slow wind is pushing you back. Anxiety fills you as you walk past the doors into the darkness."

/obj/effect/step_trigger/horizons_edge/message/colors
	message = "You see seven pedestals glowing with faint lights of different colors. It appears there are buttons on each of them."

/obj/effect/step_trigger/horizons_edge/message/cistern
	message = "You see big empty room. The air feels damp and the floor is partially covered with water."

/obj/effect/step_trigger/horizons_edge/message/lines
	message = "You see pedestal with a screen and wide transparent part of a wall. Behind it set of weird lines are floating. Lines emit faint red and green glow."

/obj/effect/step_trigger/horizons_edge/message/activation_chamber
	message = "You see pedestal with a button. You feel like you should decide if you really want to push it after all your efforts."


/obj/effect/step_trigger/horizons_edge/trap_spawner //spawns random traps


/obj/effect/step_trigger/horizons_edge/trap
	var/activated = 0

/obj/effect/step_trigger/horizons_edge/trap/Initialize(var/location)
	. = ..()
	//return INITIALIZE_HINT_LATELOAD
	var/image/O = image('maps/away/horizons_edge/horizons_edge_sprites.dmi', "trap_hint")
	var/turf/T = get_turf(src)
	T.overlays += O

/*/obj/effect/step_trigger/horizons_edge/trap/LateInitialize()//adds hint overlay
	var/image/O = image('maps/away/horizons_edge/horizons_edge_sprites.dmi', "trap_hint")
	var/turf/T = locate(src.x, src.y, src.z)
	T.overlays += O*/

/obj/effect/step_trigger/horizons_edge/trap/Trigger(mob/user as mob)
	if(!activated)
		to_chat(user, "<span class='info'>You hear quiet click from below.</span>")

/obj/effect/step_trigger/horizons_edge/trap/flashplate/Trigger(mob/user as mob)
	..()
	if (!activated)
		var/eye_safety = 0
		if(iscarbon(user))
			var/mob/living/carbon/human/H = user
			eye_safety = H.eyecheck()
			if(eye_safety < FLASH_PROTECTION_MODERATE)
				H.flash_eyes()
				H.Stun(2)
				H.Weaken(5)
		playsound(src.loc, 'sound/effects/bang.ogg', 50, 1, 0)
		activated = 1//it activates anyway
		spawn(100)
			activated = 0

/obj/effect/step_trigger/horizons_edge/trap/projectile
	var/projectile_type

/obj/effect/step_trigger/horizons_edge/trap/projectile/Trigger(mob/user as mob)
	..()
	if (!activated)
		var/turf/T = get_random_place()
		var/atom/movable/ST = new projectile_type(T)
		ST.throw_at(user, 3, 3)
		activated = 1
		playsound(src.loc, 'sound/effects/bang.ogg', 50, 1, 0)

/obj/effect/step_trigger/horizons_edge/trap/projectile/proc/get_random_place()
	var/turf/throw_location
	var/dense = 1
	while(dense)
		throw_location = get_random_turf_in_range(src,4, 1)
		if (!throw_location.density)
			dense = 0
	return throw_location

/obj/effect/step_trigger/horizons_edge/trap/projectile/laser
	projectile_type = /obj/item/projectile/beam

/obj/effect/step_trigger/horizons_edge/trap/projectile/laser/Trigger(mob/user as mob)
	..()
	if (!activated)
		if (prob(50))
			return
		var/turf/T = get_random_place()
		var/def_zone = get_exposed_defense_zone(user)
		var/obj/item/projectile/P = new projectile_type(T)
		P.launch(user, def_zone)
		playsound(src.loc, 'sound/weapons/Laser.ogg', 50, 1, 0)
		activated = 1

//VV they can break your bones but won't fry you
/obj/effect/step_trigger/horizons_edge/trap/projectile/stick
	projectile_type = /obj/item/weapon/material/stick

/obj/effect/step_trigger/horizons_edge/trap/projectile/stone
	projectile_type = /obj/item/weapon/ore/slag

/obj/effect/step_trigger/horizons_edge/trap/projectile/shard
	projectile_type = /obj/item/weapon/material/shard

/obj/effect/horizons_edge/trap_spawner //randomly spawns traps at placeholder locations
	var/traps_list = list(
		/obj/effect/step_trigger/horizons_edge/trap/flashplate,
		/obj/effect/step_trigger/horizons_edge/trap/projectile/laser,
		/obj/effect/step_trigger/horizons_edge/trap/projectile/stick,
		/obj/effect/step_trigger/horizons_edge/trap/projectile/stone,
		/obj/effect/step_trigger/horizons_edge/trap/projectile/shard)

/obj/effect/horizons_edge/trap_spawner/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/horizons_edge/trap_spawner/LateInitialize()
	for (var/obj/effect/horizons_edge/placeholders/trap/TP in GLOB.riddles_placeholders)

		if (prob(80))
			var/new_trap_path = pick(traps_list)
			new new_trap_path(TP.loc)
		GLOB.riddles_placeholders.Remove(TP)
		qdel(TP)
