/obj/effect/horizons_edge/engravings //credits for engravings sprites: 5crownik007
	icon = 'horizons_edge_engravings_sprites.dmi'
	name = "engraving"
	plane = ABOVE_TURF_PLANE
	layer = DECAL_LAYER

/obj/effect/horizons_edge/engravings/star
	icon_state = "star_engraving"

/obj/effect/horizons_edge/engravings/contained
	icon_state = "contained_engraving"

/obj/effect/horizons_edge/engravings/uncontained
	icon_state = "uncontained_engraving"

/obj/effect/horizons_edge/engravings/fading
	icon_state = "fading_engraving"

/obj/effect/horizons_edge/engravings/part_of_big/Initialize(var/loc, var/image_to_use)
	. = ..()
	icon_state = image_to_use

/obj/effect/horizons_edge/engravings/big/Initialize()//generates big engraving
	. = ..()
	var/size = 4
	for (var/y_pos = 0 to size-1)
		for (var/x_pos = 0 to size-1)
			var/turf/T = locate(src.x + x_pos, src.y + y_pos, src.z)
			new /obj/effect/horizons_edge/engravings/part_of_big(T, "big_engraving [x_pos],[y_pos]")
