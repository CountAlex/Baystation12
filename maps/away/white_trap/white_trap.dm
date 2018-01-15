#include "white_trap_areas.dm"

/obj/effect/overmap/sector/white_trap
	name = "cold expolanet"
	desc = "Sensors detect presence of artificial structures on a surface."
	icon_state = "globe"
	known = 0

/obj/effect/overmap/sector/white_trap/New(nloc, max_x, max_y)
	name = "[generate_planet_name()], \a [name]"
	..()

/datum/map_template/ruin/away_site/white_trap
	name = "Arctic Base"
	id = "awaysite_white_trap"
	description = "The crashlanding site of the SEV Icarus."
	suffixes = list("white_trap/white_trap-1.dmm", "white_trap/white_trap-2.dmm")
	cost = 2

/turf/unsimulated/white_trap/snow
	name = "ankle-deep snow"
	desc = "Some snow covering frozed dirt."
	initial_gas = list("oxygen" = MOLES_O2STANDARD, "nitrogen" = MOLES_N2STANDARD)
	temperature = T0C -15
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"

/turf/unsimulated/white_trap/snow/Entered(var/atom/movable/A)
	if (!istype(A) || !ismob(A))
		return
	var/image/I = image('maps/away/white_trap/white_trap_sprites.dmi',"footprints")//the pattern could use some love
	I.dir = A.dir//somehow doesn't properly set dir for overlay, A.last_move doesn't help too. Investigate later
	I.pixel_x += rand(-5, 5)
	I.pixel_y += rand(-5, 5)
	overlays += I

/obj/effect/white_trap/snow_tracks//used to generate tracks on snow for story-making purposes. Feel free to use any other way
	name = "footprints"
	icon = 'maps/away/white_trap/white_trap_sprites.dmi'
	icon_state = "footprints"

/obj/structure/white_trap/railway
	name = "rails"
	desc = "Piece of obsolete technology used for moving trains. Not quite as good as your favorite monorail maglevs. You might even deconstruct them to salvage some materials."
	icon = 'maps/away/white_trap/white_trap_sprites.dmi'
	icon_state = "railway"
	anchored = 1
	var/spikes = 8
	var/busy = 0

/obj/structure/white_trap/railway/examine()
	..()
	if (spikes)
		var/isare = "are"
		if (spikes == 1)
			isare = "is"
		to_chat(usr, "<span class='notice'>[spikes] of the spikes [isare] still nalied down.</span>")
	else
		to_chat(usr, "<span class='notice'>All spikes are removed. Now you can cut off rails.</span>")

/obj/structure/white_trap/railway/attackby(obj/item/W as obj, mob/user as mob)
	if (busy)
		to_chat(usr, "<span class='notice'>Someone is breaking \the [src] already.</span>")
		return
	if(isCrowbar(W))
		if (spikes)
			busy = 1
			visible_message("[user] starts to pry out spike from \the [src].")
			if (!do_after(src,50,user))
				visible_message("[user] stops prying out spike from \the [src].")
				busy = 0
				return
			spikes -= 1
			busy = 0
			visible_message("[user] pulls out spike from \the [src].")
			to_chat(usr, "<span class='notice'>Now you can cut off the rails from their base.</span>")
		else
			to_chat(usr, "<span class='notice'>All spikes are already removed.</span>")
	if(isWelder(W))
		if (spikes)
			to_chat(usr, "<span class='notice'>Remove spikes from \the [src] first!</span>")
			return
		busy = 1
		var/obj/item/weapon/weldingtool/WT = W
		if(!WT.remove_fuel(0, user))
			to_chat(user, "<span class='warning'>\The [src] must be on to complete this task.</span>")
			return
		playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)
		if(!do_after(src, 100, user))
			busy = 0
			return
		visible_message("<span class='warning'>[user] cuts rails from their base.</span>")
		//spawn 4 boards and 2 rods
		new /obj/item/stack/material/wood(src)
		new /obj/item/stack/material/wood(src)
		new /obj/item/stack/material/wood(src)
		new /obj/item/stack/material/wood(src)
		new /obj/item/stack/rods(src.loc)
		new /obj/item/stack/rods(src.loc)
		qdel(src)

/obj/structure/white_trap/railway/railway_end
	icon_state = "railway_end"

/obj/structure/white_trap/satellite_dish
	name = "satellite_dish"
	desc = "Huge satellite dish on a tripod for close cosmos communication."
	icon = 'maps/away/white_trap/white_trap_sprites.dmi'
	icon_state = "s_dish"
	anchored = 0
	density = 1

/obj/effect/decal/white_trap/platform_edge
	name = "platform edge"
	icon = 'maps/away/white_trap/white_trap_sprites.dmi'
	icon_state = "platform_edge"

/obj/machinery/power/emitter/anchored/white_trap/mining_laser
	name = "mining laser"
	icon = 'maps/away/white_trap/white_trap_sprites.dmi'
	id = "TajMiningLaser"

/obj/effect/decal/cleanable/blood/white_trap/tajaran_blood
	basecolor = "#862a51"

/decl/hierarchy/outfit/corpse/white_trap
	name = "Dead Tajara basic outfit"
	uniform = /obj/item/clothing/under/color/grey
	shoes = /obj/item/clothing/shoes/workboots/toeless
	glasses = /obj/item/clothing/glasses/tajblind

/obj/effect/landmark/corpse/white_trap
	name = "dead tajara"
	corpse_outfit = /decl/hierarchy/outfit/corpse/white_trap
	species = SPECIES_TAJARA

/decl/hierarchy/outfit/corpse/white_trap/engineer
	name = "dead tajaran engineer outfit"
	uniform = /obj/item/clothing/under/color/grey
	belt = /obj/item/weapon/storage/belt/utility
	head = /obj/item/clothing/head/orangebandana

/obj/effect/landmark/corpse/white_trap/engineer
	corpse_outfit = /decl/hierarchy/outfit/corpse/white_trap/engineer

/decl/hierarchy/outfit/corpse/white_trap/miner
	name = "dead tajaran miner outfit"
	uniform = /obj/item/clothing/under/rank/miner
	suit = /obj/item/clothing/suit/storage/hooded/wintercoat/miner
	belt = /obj/item/weapon/storage/belt/utility
	head = /obj/item/clothing/head/soft/purple
	back = /obj/item/weapon/storage/backpack

/obj/effect/landmark/corpse/white_trap/miner
	corpse_outfit = /decl/hierarchy/outfit/corpse/white_trap/miner

/decl/hierarchy/outfit/corpse/white_trap/cook
	name = "dead tajaran cook outfit"
	uniform = /obj/item/clothing/under/rank/chef
	suit = /obj/item/clothing/suit/chef/classic
	head = /obj/item/clothing/head/chefhat

/obj/effect/landmark/corpse/white_trap/cook
	corpse_outfit = /decl/hierarchy/outfit/corpse/white_trap/cook

/decl/hierarchy/outfit/corpse/white_trap/guard
	name = "dead tajaran guard outfit"
	uniform = /obj/item/clothing/under/color/red
	suit = /obj/item/clothing/suit/armor/bulletproof/vest
	head = /obj/item/clothing/head/helmet/ballistic
	belt = /obj/item/weapon/melee/baton

/obj/effect/landmark/corpse/white_trap/guard
	corpse_outfit = /decl/hierarchy/outfit/corpse/white_trap/guard

/decl/hierarchy/outfit/corpse/white_trap/offduty1
	name = "dead tajaran off duty #1 outfit"
	uniform = /obj/item/clothing/under/color/blue
	head = /obj/item/clothing/head/tajaran/scarf

/obj/effect/landmark/corpse/white_trap/offduty1
	corpse_outfit = /decl/hierarchy/outfit/corpse/white_trap/offduty1

/decl/hierarchy/outfit/corpse/white_trap/offduty2
	name = "dead tajaran off duty #2 outfit"
	uniform = /obj/item/clothing/under/color/green
	head = /obj/item/clothing/head/beaverhat

/obj/effect/landmark/corpse/white_trap/offduty2
	corpse_outfit = /decl/hierarchy/outfit/corpse/white_trap/offduty2

/obj/item/weapon/paper/white_trap/ore_inventory
	name = "Ore Inventory"
	info = "<b><center><u><large>J’Tale Facility Ore Inventory</large></b></center></u><br>\
			<br>\
			<b>Local Time: </b>17:46<br>\
			<b>Shipment Number:</b>013<br>\
			<br>\
			<b>Ores in this shipment:</b><br>\
			<small>Leave blank or write 0 if none</small><br>\
			<br>\
			Iron Ore: 121 kg.<br>\
			<br>\
			Sand: 47 kg.<br>\
			<br>\
			Native Gold: 74 kg.<br>\
			<br>\
			Native Silver: 46 kg.<br>\
			<br>\
			Galena: 63 kg.<br>\
			<br>\
			Platinum: 14 kg.<br>\
			<br>\
			Diamonds: 0.4 kg.<br>\
			<br>\
			miscellaneous: 1748 kg of useable rock.<br>\
			<br>\
			<b>Facility overseer signature:</b> <i>Farqarakah Mi'jri.</i>"

/obj/item/weapon/paper/white_trap/incident_report
	name = " Incident Report"
	info = "<b><center><u><large>J’Tale Facility Incident Report</large></b></center></u><br>\
			<br>\
			The miners have reported of small bits of rocks seemingly moving on their own and apparently being alive. A psychologist has been requested for the facility. Below is a transcript of the conversation with mr. <b>\[REDACTED\]</b>.<br>\
			<i>”We were mining, shot the mining laser when the rocks suddenly came out of the walls around where we mined. Just.. They walked around! Stood up and just began to walk around on their own! <b>\[REDACTED\]</b> started the laser and just shot whatever it was until only dust was left!”</i><br>\
			Facility overseer <i>F. Mi’jri.</i>"

/obj/item/weapon/paper/white_trap/security_report
	name = " Security Report"
	info = "<b><center><u><large>J’Tale Facility High Security Report</large></b></center></u><br><br>\
			It appears mr. <b>\[REDACTED\]</b] spoke the truth along with the other miners. Several creatures of stone walked around the warehouse this morning. We captured the creatures and have shipped them off for research purpose. We are hereby sending an official request for a detachment of armed forces to be stationed at our facility until we can determine what the creatures are.\
			Facility overseer <i]F. Mi’jri.</i]"
