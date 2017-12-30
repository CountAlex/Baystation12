#include "horizons_edge_areas.dm"
#include "horizons_edge.dmm"
#include "horizons_edge_puzzles.dm"
#include "horizons_edge_engravings.dm"
#include "horizons_edge_structures.dm"
#include "horizons_edge_traps_and_messages.dm"
//throw_at(atom/target, range, speed, thrower)
//set_light(l_range, l_power, l_color)
//command_announcement.Announce("Warning, gravitational anomaly detected forming within vessel range! Recalibrating systems, adjusting gravity generators to compensate. Reorienting Gravitational pull to direct “Forward” of the Torch. Reorienting Torch to point away. Engines engaging on full. Projected time to Point of No Return: five minutes. Please set a course to leave the gravity well of the anomaly before this time..", "Gravitational Anomaly")

/datum/map_template/ruin/away_site/horizons_edge
 	name = "Horizon's Edge"
 	id = "awaysite_horizons_edge"
 	description = "Alein structure in space"
 	suffixes = list("horizons_edge/horizons_edge.dmm")
 	cost = 1

/obj/effect/overmap/sector/horizons_edge
	name = "unknown srtucture"
	desc = "Sensors detect artificial structure. Avaliable patterns and recogniition algorithms fail to process recieved data."
	icon_state = "object"
	known = 0

	generic_waypoints = list(
		"nav_horizons_edge_1",
		"nav_horizons_edge_2",
		"nav_horizons_edge_antag"
	)

/obj/effect/shuttle_landmark/horizons_edge/nav1
	name = "Unknown structure Navpoint #1"
	landmark_tag = "nav_horizons_edge_1"

/obj/effect/shuttle_landmark/horizons_edge/nav2
	name = "Unknown structure Navpoint #2"
	landmark_tag = "nav_horizons_edge_2"

/obj/effect/shuttle_landmark/horizons_edge/nav3
	name = "Unknown structure Navpoint #3"
	landmark_tag = "nav_horizons_edge_3"

/obj/effect/shuttle_landmark/horizons_edge/nav4
	name = "Unknown structure Navpoint #4"
	landmark_tag = "nav_horizons_edge_antag"

//////////////////////////////////////////////////////////////////////////////////////////////////WALLS/FLOORS/ETC
/turf/unsimulated/wall/horizons_edge/alien_wall
	name = "strange wall"
	icon = 'maps/away/horizons_edge/horizons_edge_sprites.dmi'
	icon_state = "alien_wall0"
	desc = "A wall from a material you can't define. It doesn't react to any of your actions"
	var/sprite_name = "alien_wall"

/obj/structure/horizons_edge/alien_window
	name = "strange transparent wall"
	icon = 'maps/away/horizons_edge/horizons_edge_sprites.dmi'
	icon_state = "alien_window"
	desc = "A window from a material you can't define. It doesn't react to any of your actions"
	opacity = 0
	density = 1
	anchored = 1
	var/shard = /obj/item/weapon/material/shard/phoron

/obj/structure/horizons_edge/alien_window/proc/shatter()
	set_density(0)
	icon_state = "alien_window_shattered"
	new shard(loc)
	new shard(loc)
	new shard(loc)
	playsound(src.loc, 'sound/effects/Glassbr1.ogg', 100, 1)

/turf/unsimulated/wall/horizons_edge/alien_wall/Initialize()
	. = ..()
	var/dirs = 0
	for(var/turf/unsimulated/wall/horizons_edge/alien_wall/W in orange(src, 1))
		var/dir = get_dir(src, W)
		if (dir == NORTH)
			dirs+=1
		if (dir == SOUTH)
			dirs+=2
		if (dir == EAST)
			dirs+=4
		if (dir == WEST)
			dirs+=8
	icon_state = "[sprite_name][dirs]"

/turf/unsimulated/floor/horizons_edge/alien_floor
	name = "strange floor"
	icon = 'maps/away/horizons_edge/horizons_edge_sprites.dmi'
	icon_state = "alien_floor"
	desc = "This is a floor with four small stands in the corner. When you try to to touch it something invisible stops you five cantimeters from the surface."

/turf/simulated/floor/horizons_edge/rocky_floor
	name = "rocky floor"
	desc = "Rough stone surface."
	icon = 'maps/away/horizons_edge/horizons_edge_sprites.dmi'
	icon_state = "rocky_floor"
	initial_gas = null

/turf/unsimulated/wall/horizons_edge/alien_wall/alt
	sprite_name = "awall"
	icon = 'maps/away/horizons_edge/horizons_edge_alt_sprites.dmi'//credits for sprite: 5crownik007
	icon_state = "awall0"

/turf/unsimulated/floor/horizons_edge/alien_floor/alt
	icon = 'maps/away/horizons_edge/horizons_edge_alt_sprites.dmi'//credits for sprite: 5crownik007
	icon_state = "a_floor"
	desc = "An unusual floor."
	initial_gas = null

/turf/unsimulated/floor/horizons_edge/alien_floor/alt_dark
	icon = 'maps/away/horizons_edge/horizons_edge_alt_sprites.dmi'//credits for sprite: 5crownik007
	icon_state = "a_plating"
	desc = "An unusual floor."
	initial_gas = null

//////////////////////////////////////////////////////////////////////////////////////////////////PLACEHOLDERS
/obj/effect/horizons_edge/placeholders
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x3"
	invisibility = 101

/obj/effect/horizons_edge/placeholders/Initialize(var/location)
	. = ..()
	GLOB.riddles_placeholders.Add(src)

/obj/effect/horizons_edge/placeholders/button//for colors puzzle

/obj/effect/horizons_edge/placeholders/line//for initialization. Must have 16 of them planted in 4x4 pattern with riddle object in left bottom corner (as, minimal x,y)
/obj/effect/horizons_edge/placeholders/alien_console/line_console//for control console

/obj/effect/horizons_edge/placeholders/alien_console/latin//these three are for translation puzzle
/obj/effect/horizons_edge/placeholders/alien_console/glyph
/obj/effect/horizons_edge/placeholders/alien_console/sphynx

/obj/effect/horizons_edge/placeholders/trap
/obj/effect/horizons_edge/placeholders/window_breaker//breaks alien window when endgave event is started so explorers can grab artifacts
/obj/effect/horizons_edge/placeholders/field_unlock

/obj/effect/horizons_edge/placeholders/endgame_button
