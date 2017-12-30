//////////////////////////////////////////////////////////////////////////////////////////////////LIGHTS
/obj/structure/horizons_edge/brazier
	name = "floating brazier"
	desc = "A floating brazier. It's floating on three small thursters and emitting deep blue light from cold blue flame."
	icon_state = "brazier"
	icon = 'maps/away/horizons_edge/horizons_edge_sprites.dmi'
	anchored = 0
	density = 1
	light_range = 7
	light_power = 5
	light_color = "#4000ff"

/*/obj/structure/horizons_edge/brazier/New()
	..()
	set_light(light_range, light_power, light_color)*/

/obj/structure/horizons_edge/wall_light
	name = "weird wall light"
	desc = "A wall light. It's emitting cold blue light from cone looking like it's made from glass."
	icon_state = "wall_light"
	icon = 'maps/away/horizons_edge/horizons_edge_sprites.dmi'
	anchored = 1
	light_range = 4
	light_power = 3
	light_color = "#4000ff"

/*/obj/structure/horizons_edge/wall_light/New()
	..()
	set_light(light_range, light_power, light_color)
*/
//////////////////////////////////////////////////////////////////////////////////////////////////ENDGAME BUTTON
obj/structure/horizons_edge/endgame_button
	name = "button pedestal"
	desc = "An unusual pedestal with big button on top of it."
	icon = 'maps/away/horizons_edge/horizons_edge_alt_sprites.dmi'
	icon_state = "pedestal_button_0"
	density = 1
	anchored = 1
	light_range = 2
	light_power = 10
	light_color = "#00dd00"
	var/state = "inactive"
	var/obj/effect/horizons_edge/riddles/riddle/parent

obj/structure/horizons_edge/endgame_button/Initialize(var/loc, var/P)
	. = ..()
	parent = P
//	set_light(1.5, 10, "#00dd00")

obj/structure/horizons_edge/endgame_button/proc/activate()
	state = "active"
	update_icon()
	set_light(2, 10, "#00dd00")

obj/structure/horizons_edge/endgame_button/update_icon()
	if (state == "active")
		icon_state = "pedestal_button_1"

obj/structure/horizons_edge/endgame_button/attack_hand(mob/user as mob)
	if (state == "pushed")
		to_chat(user, "<span class='notice'>Button is already pressed by somebody.</span>")
		return
	if (state == "inactive" || state == "activated")
		to_chat(user, "<span class='notice'>You push the button but nothing happens.</span>")
		return
	state = "pushed"
	if (!do_after(user, 50, src))
		set_light(2, 10, "#00dd00")
		state = "active"
		return
	visible_message("<span class='notice'>You feel like floor is slightly shaking under your feet.</span>")
	set_light(2, 10, "#fffb00")
	if (!do_after(user, 50, src))
		set_light(2, 10, "#00dd00")
		state = "active"
		return
	set_light(3, 10, "ff0000")
	visible_message("<span class='warning'>You definitely feel everything around is shaking.</span>")
	if (!do_after(user, 50, src))
		set_light(2, 10, "#00dd00")
		state = "active"
		return
	//point of no return
	visible_message("<span class='warning'>You hear roaring sound from somewhere below. It may be too late to run already.</span>")

	state = "activated"
	set_light(0.0)
	parent.endgame()

//////////////////////////////////////////////////////////////////////////////////////////////////CONSOLES
obj/structure/horizons_edge/alien_console
	name = "unusual console"
	anchored = 1
	density = 1
	icon = 'maps/away/horizons_edge/horizons_edge_sprites.dmi'
	icon_state = "alien_console"
	light_range = 2
	light_power = 2
	light_color = "#7199bf"
	var/console_type
	var/obj/effect/horizons_edge/riddles/riddle/parent
	var/solved = 0


/*obj/structure/horizons_edge/alien_console/Initialize()
	. = ..()
	set_light(2,2, "#7199bf")*/

obj/structure/horizons_edge/alien_console/proc/set_parent(var/new_parent)
	parent = new_parent

obj/structure/horizons_edge/alien_console/attack_hand(mob/user as mob)
	ui_interact(user)

obj/structure/horizons_edge/alien_console/proc/set_solved()//to display post-solved state
	solved = 1
/////////////////////////////////////////////////////
/////////////////////////////////////////////////////
/////////////////////////////////////////////////////Lines console
obj/structure/horizons_edge/alien_console/line_console
	desc = "A weird console floating above the round platform. Screen displays set of 16 symbols."
	console_type = RIDDLE_LINE_CONSOLE
	var/size = 4
	icon_state = "alien_console_lines"

/obj/structure/horizons_edge/alien_console/line_console/Initialize(var/loc, var/r_size)
	. = ..()
	size = r_size

obj/structure/horizons_edge/alien_console/line_console/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	user.set_machine(src)
	var/list/data = list()
	data["console_type"] = console_type
	data["solved"] = solved
	var/obj/effect/horizons_edge/riddles/riddle/lines/P = parent
	var/list/lines = P.get_lines()
	var/list/states = list()
	for (var/iter_row = 1 to size)
		var/list/columns = list()
		for (var/iter_col = 1 to size)
			var/obj/structure/horizons_edge/line/L = lines[iter_row][iter_col]
			var/state = 0
			if (L.right_state())
				state = 1
			columns.Add(list(list("state" = state)))
		states.Add(list(list("columns" = columns)))
	data["states"] = states
	ui = GLOB.nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "alien_console.tmpl", "unusual console", 390, 300)
		ui.set_initial_data(data)
		ui.open()

obj/structure/horizons_edge/alien_console/line_console/Topic(href, href_list)
	if(..())
		return 1
	if (href_list["action"])
		var/row = text2num(href_list["row"])+1
		var/column = text2num(href_list["column"])+1
		if (row<1 || row> size || column<1 || column>size)
			return 1
		var/obj/effect/horizons_edge/riddles/riddle/lines/LP = parent
		LP.rotate(row, column)
		if (LP.is_solved())
			solved = 1
			LP.report_solved()
		return 1
/////////////////////////////////////////////////////
/////////////////////////////////////////////////////Latin hint console
/obj/structure/horizons_edge/alien_console/translation/latin
	desc = "A weird console floating above the round platform. When you approach unrecognisable symbols on the screen imperceptibly morph into latin letters."
	console_type = RIDDLE_TRANSLATION_LATIN_CONSOLE
	var/hint_text = ""

/obj/structure/horizons_edge/alien_console/translation/latin/Initialize(var/loc, var/hint)
	. = ..()
	hint_text = hint

/obj/structure/horizons_edge/alien_console/translation/latin/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	user.set_machine(src)
	var/list/data = list()
	data["console_type"] = console_type
	data["hint_text"] = hint_text
	ui = GLOB.nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "alien_console.tmpl", "unusual console", 390, 60)
		ui.set_initial_data(data)
		ui.open()

/////////////////////////////////////////////////////
/////////////////////////////////////////////////////Glyph hint console
/obj/structure/horizons_edge/alien_console/translation/glyph
	desc = "A weird console floating above the round platform. Screen displays constant set of unknown symbols."
	console_type = RIDDLE_TRANSLATION_GLYPH_CONSOLE
	var/list/hint_glyphs = list()

/obj/structure/horizons_edge/alien_console/translation/glyph/Initialize(var/loc, var/list/hint)
	. = ..()
	hint_glyphs = hint

/obj/structure/horizons_edge/alien_console/translation/glyph/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	user.set_machine(src)
	var/list/data = list()
	data["console_type"] = console_type
	data["hint_glyphs"] = hint_glyphs
	ui = GLOB.nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "alien_console.tmpl", "unusual console", 390, 250)
		ui.set_initial_data(data)
		ui.open()
/////////////////////////////////////////////////////
/////////////////////////////////////////////////////Sphynx (questioning) console
/obj/structure/horizons_edge/alien_console/translation/sphynx
	desc = "A weird console floating above the round platform. Screen displays interactive set of unknown symbols."
	console_type = RIDDLE_TRANSLATION_SPHYNX_CONSOLE
	icon_state = "alien_console_sphynx"
	var/list/question_glyphs = list()
	var/list/input_glyphs = list()
	var/list/alien_glyphs_order = list()
	var/list/player_input = list()//for displaying
	//var/list/processed_input = list()//procesed to current glyphs order

/obj/structure/horizons_edge/alien_console/translation/sphynx/Initialize(var/loc, var/list/question/, var/list/alien_alphabet)
	. = ..()
	question_glyphs = question
	alien_glyphs_order = alien_alphabet

/obj/structure/horizons_edge/alien_console/translation/sphynx/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)
	user.set_machine(src)
	var/list/data = list()
	data["console_type"] = console_type
	data["question_glyphs"] = question_glyphs
	data["icon_links"] = alien_glyphs_order//helps generate proper length list for NanoUI
	data["player_input"] = player_input
	data["solved"] = solved
	ui = GLOB.nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "alien_console.tmpl", "unusual console", 400, 530)
		ui.set_initial_data(data)
		ui.open()

/obj/structure/horizons_edge/alien_console/translation/sphynx/Topic(href, href_list)
	if(..())
		return 1

	if(href_list["letter"])
		var/letter = text2num(href_list["letter"])
		if (letter<1 || letter>26)
			return 1
		player_input.Add(letter)
		//processed_input.Add(alien_glyphs_order.Find(letter))
		return 1
	if(href_list["wipe"])
		player_input = list()
		//processed_input = list()
		return 1
	if(href_list["enter"])
		var/obj/effect/horizons_edge/riddles/riddle/translation/P = parent
		if (P.check_answer(player_input))
			solved = 1
		else
			player_input = list()
		return 1
//////////////////////////////////////////////////////////////////////////////////////////////////BUTTON PEDESTAL
obj/structure/horizons_edge/color_button
	name = "weird stand"
	anchored = 1
	density = 1
	icon = 'maps/away/horizons_edge/horizons_edge_sprites.dmi'
	icon_state = "button"
	var/bright_low_range = 1.5
	var/bright_high_range = 2
	var/bright_low_power = 2
	var/bright_high_power = 4
	var/obj/effect/horizons_edge/riddles/riddle/colors/parent
	var/button_color

obj/structure/horizons_edge/color_button/Initialize(var/location, var/btn_color, var/lgt_color, var/P)
	. = ..()
	src.button_color = btn_color
	src.light_color = lgt_color
	src.parent = P
	desc = "You see unusually looking console stand with big dark button on the top. Small frame filled with [src.button_color] color is floating above it."
	var/image/O = image(src.icon, "button_screen")
	O.color = light_color
	src.overlays += O
	set_light(bright_low_range, bright_low_power, light_color)

obj/structure/horizons_edge/color_button/attack_hand(var/mob/user)
	visible_message("[user] pushes button on \the [src].")
	if (parent.button_pushed(src.button_color))
		set_light(bright_high_range, bright_high_power, light_color)
		visible_message("Button pedestal lights up.")

obj/structure/horizons_edge/color_button/proc/reset(var/mob/user)
	set_light(bright_low_range, bright_low_power, light_color)

////////////////////////////////////////////////////////////////////////////////LINE OBJECT
obj/structure/horizons_edge/line
	name = "unusual glowing line"
	anchored = 1
	density = 1
	icon = 'maps/away/horizons_edge/horizons_edge_sprites.dmi'
	icon_state = "line_h"
	var/state = RIDDLE_LINE_HORIZONTAL

obj/structure/horizons_edge/line/update_icon()
	if (state == RIDDLE_LINE_VERTICAL)
		icon_state = "line_v"
		set_light(1.5, 3, "#dd0000")
	else
		icon_state = "line_h"
		set_light(1.5, 3, "#00dd00")

obj/structure/horizons_edge/line/proc/change_state()
	if (state == RIDDLE_LINE_VERTICAL)
		state = RIDDLE_LINE_HORIZONTAL
	else
		state = RIDDLE_LINE_VERTICAL
	update_icon()

obj/structure/horizons_edge/line/proc/right_state()
	if (state == RIDDLE_LINE_HORIZONTAL)
		return 1
	return 0

//////////////////////////////////////////////////////////////////////////////////////////////////FORCE-FIELD "DOOR"
obj/structure/horizons_edge/forcefield
	name = "glowing field"
	desc = "A glowing field blocking entire passage with little extremties at the corners that appear to be emitters."
	icon = 'maps/away/horizons_edge/horizons_edge_sprites.dmi'
	icon_state = "field_closed"
	anchored = 1
	density = 1
	var/state = "closed"
	var/locked = 0
	var/last_time_used = 0
	atmos_canpass = CANPASS_DENSITY

obj/structure/horizons_edge/forcefield/Initialize()
	. = ..()
	set_light(1.5, 2, "#74bcff")

obj/structure/horizons_edge/forcefield/attack_hand(mob/user as mob)
	change_state()

obj/structure/horizons_edge/forcefield/proc/change_state()
	if ((last_time_used+15) > world.time)
		return
	if (state == "closed")
		flick("field_opening", src)
		state = "open"
		set_density(0)
		visible_message("\The [src] is retracting to sides opening human-sized passage.")
	else
		flick("field_closing", src)
		state = "closed"
		set_density(1)
		visible_message("\The [src] is closing passage.")
	playsound(src.loc, 'sound/effects/phasein.ogg', 100, 1)
	update_icon()
	last_time_used = world.time

obj/structure/horizons_edge/forcefield/update_icon()
	if (locked)
		icon_state = "field_locked"
		return
	if (state == "closed")
		icon_state = "field_closed"
	else
		icon_state = "field_open"

obj/structure/horizons_edge/forcefield/locked
	locked = 1
	icon_state = "field_locked"

obj/structure/horizons_edge/forcefield/locked/proc/unlock()
	locked = 0
	update_icon()

obj/structure/horizons_edge/forcefield/locked/change_state()
	if (locked)
		visible_message("\The [src] doesn't react.")
		return
	..()

//////////////////////////////////////////////////////////////////////////////////////////////////PROPS AND DECORATIONS
/obj/structure/horizons_edge/props
	anchored = 1
	density = 1
	icon = 'maps/away/horizons_edge/horizons_edge_sprites.dmi'

/obj/structure/horizons_edge/props/holo
	name = "hologpaphic projector"
	desc = "A hologrpahic projector displaying star system of blue giant and two planets."
	icon_state = "alien_holo_alt"
	density = 0
	anchored = 0
	light_range = 3
	light_power = 5
	light_color= "#eeeeee"

/obj/structure/horizons_edge/props/pump
	name = "pump-like machinery"
	desc = "An apparent piece of machinery resembling some sort of industrial pump with two big double pistons on top."
	icon_state = "alien_pump"

/obj/structure/horizons_edge/props/spiral//credits dor sprite: Ursur
	name = "double spiral statue"
	desc = "A statue in shape of double spiral. Fist-sized crystal is hanging in the canter of it, blinking."//credits for sprite: Ursur
	icon_state = "spiral"

//////////////////////////////////////////////////////////////////////////////////////////////////CONTAINER WITH ALIEN CONTENT
/obj/structure/horizons_edge/props/container
	name = "diamond-shaped container"
	desc = "A huge diamond.shaped object with transparent upper part. "
	icon_state = "container_closed"
	anchored = 0
	var/state = "closed"
	var/item_inside
	var/last_iteraction_time = 0
	var/list/posible_items = list(
		/obj/item/weapon/cell/slime,
		/obj/item/stack/material/diamond,
		/obj/item/stack/material/uranium,
		/obj/item/stack/material/phoron,
		/obj/item/weapon/ectoplasm,
		/obj/item/weapon/material/horizons_edge/chakram,
		/obj/item/horizons_edge/cloth,
		/obj/item/horizons_edge/wand,
		/obj/item/weapon/material/horizons_edge/dagger)
	var/being_used = 0

/obj/structure/horizons_edge/props/container/Initialize()
	. = ..()
	var/I = pick(posible_items)
	item_inside = new I

/obj/structure/horizons_edge/props/container/attack_hand(mob/user as mob)
	if ((last_iteraction_time + 15 > world.time) || being_used)//no spam, no side interruption
		return
	being_used = 1
	if (state == "closed")
		state = "open"
		flick("container_opening", src)
		playsound(src, 'sound/effects/stonedoor_openclose.ogg', 75, 1)
	else if (item_inside)
		to_chat(user, "<span class='notice'>You reach inside \the [src].</span>")
		if (!do_after(user, 50, src))
			to_chat(user, "<span class='notice'>You pull your arm back before grabing anything inside \the [src].</span>")
		else
			user.put_in_hands(item_inside)
			item_inside = null
	else
		state = "closed"
		flick("container_closing", src)
		playsound(src, 'sound/effects/stonedoor_openclose.ogg', 75, 1)
	being_used = 0
	update_icon()
	last_iteraction_time = world.time

/obj/structure/horizons_edge/props/container/update_icon()
	if (state == "closed")
		icon_state = "container_closed"
	else
		icon_state = "container_open"

/obj/structure/horizons_edge/props/container/attackby(var/obj/item/I, var/mob/user)
	if (state == "closed")
		to_chat(user, "<span class='notice'>Your attempts to apply [I] to \the [src] are futile.</span>")
		return
	if (I.w_class > ITEM_SIZE_NORMAL)
		to_chat(user, "<span class='notice'>You can't fit [I] inside \the [src].</span>")
		return
	if (item_inside)
		to_chat(user, "<span class='notice'>There's already something inside \the [src].</span>")
		return
	if (!being_used)
		being_used = 1
		to_chat(user, "<span class='notice'>You start fitting [I] inside \the [src].</span>")
		if (!do_after(user, 30, src))
			to_chat(user, "<span class='notice'>You stop fitting [I] inside \the [src] and pull [I] back outside.</span>")
			being_used = 0
			return
		to_chat(user, "<span class='notice'>[I] is inside \the [src] now.</span>")
		user.remove_from_mob(I)
		I.forceMove(src)
		item_inside = I
		state = "closed"
		flick("container_closing", src)
		playsound(src, 'sound/effects/stonedoor_openclose.ogg', 75, 1)
		update_icon()
		being_used = 0

/obj/structure/horizons_edge/props/container/examine(mob/user)
	..(user)
	if (src.Adjacent(user))
		if (item_inside )
			to_chat(usr, "You see [item_inside] inside \the [src].")
		else
			to_chat(usr, "Apparently \the [src] is empty.")
/////////////////////////
/////////////////////////ALIEN ITEMS
/////////////////////////Have limited use and some potential for destructive analysis
/obj/item/weapon/material/horizons_edge/chakram
	name = "shining disc"
	desc = "A shining disc with shard edges. Inner side of the edge is shining with a pink light."
	icon = 'maps/away/horizons_edge/horizons_edge_sprites.dmi'
	icon_state = "alien_chakram"
	item_icons = list(slot_l_hand_str = 'maps/away/horizons_edge/horizons_edge_items_sprites_lh.dmi', slot_r_hand_str = 'maps/away/horizons_edge/horizons_edge_items_sprites_rh.dmi')
	light_range = 1.5
	light_power = 2
	light_color = "#4000ff"
	throw_speed = 5
	throw_range = 10
	sharp = 1
	edge =  1
	unbreakable = 1
	default_material = "diamond"
	applies_material_colour = 0
	w_class = ITEM_SIZE_SMALL
	origin_tech = list(TECH_MATERIAL = 3, TECH_COMBAT = 3)

/obj/item/horizons_edge/cloth
	name = "strip of fabric"
	desc = "A strip of fabric. It looks absolutely smooth and unstretchable."
	icon = 'maps/away/horizons_edge/horizons_edge_sprites.dmi'
	icon_state = "alien_cloth"
	item_icons = list(slot_l_hand_str = 'maps/away/horizons_edge/horizons_edge_items_sprites_lh.dmi', slot_r_hand_str = 'maps/away/horizons_edge/horizons_edge_items_sprites_rh.dmi')
	origin_tech = list(TECH_MATERIAL = 5)
	w_class = ITEM_SIZE_SMALL

/obj/item/horizons_edge/wand
	name = "small wand"
	desc = "A small wand with sphere on top. Sphere has button on it."
	icon = 'maps/away/horizons_edge/horizons_edge_sprites.dmi'
	icon_state = "alien_wand"
	item_icons = list(slot_l_hand_str = 'maps/away/horizons_edge/horizons_edge_items_sprites_lh.dmi', slot_r_hand_str = 'maps/away/horizons_edge/horizons_edge_items_sprites_rh.dmi')
	w_class = ITEM_SIZE_SMALL
	origin_tech = list(TECH_MATERIAL = 2, TECH_BLUESPACE = 2)
	var/last_activation_time = 0

/obj/item/horizons_edge/wand/attack_self(mob/user)
	if (last_activation_time + 50 > world.time)//5 seconds cooldown
		to_chat(user, "<span class='notice'>[src] doesn't react to pushing button.</span>")
		return
	last_activation_time = world.time
	to_chat(user, "<span class='notice'>You push the button on [src].</span>")
	random_action(user)

/obj/item/horizons_edge/wand/proc/random_action(mob/user)
	var/action = rand(1,6)
	switch(action)
		if(1)//drops few sparks around
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(2, 1, src)
			s.start()
		if (2)//rainbow lights cycle. Might hint colors puzzle
			visible_message("Small wand lights up with few different colors.")
			set_light(1.5, 2, "#ff0000")
			sleep(5)
			set_light(1.5, 2, "#ff8000")
			sleep(5)
			set_light(1.5, 2, "#ffd11a")
			sleep(5)
			set_light(1.5, 2, "#009900")
			sleep(5)
			set_light(1.5, 2, "#1ac6ff")
			sleep(5)
			set_light(1.5, 2, "#0000ff")
			sleep(5)
			set_light(1.5, 2, "#7300e6")
			sleep(5)
			set_light(1.5, 2, "#4000ff")
		if (3)
			playsound(src.loc, 'sound/effects/beam.ogg', 100, 1)
			if (ishuman(user))
				var/mob/living/carbon/H = user
				to_chat(user, "<span class='notice'>You feel tickling inside your head.</span>")
				H.adjust_hallucination(rand(100, 600), rand(10, 40))//weak to moderate hallucinations for 10-60 seconds
		if (4)
			to_chat(user, "<span class='notice'>\The [src] suddenly slips from your fingers.</span>")
			user.drop_item()
		if (5)
			to_chat(user, "<span class='notice'>\The [src] vibrates but nothing else happens.</span>")
		if (6)
			to_chat(user, "<span class='notice'>You push the button but nothing happens.</span>")

/obj/item/weapon/material/horizons_edge/dagger
	name = "glowing dagger"
	icon = 'maps/away/horizons_edge/horizons_edge_sprites.dmi'
	icon_state = "alien_dagger"
	item_icons = list(slot_l_hand_str = 'maps/away/horizons_edge/horizons_edge_items_sprites_lh.dmi', slot_r_hand_str = 'maps/away/horizons_edge/horizons_edge_items_sprites_rh.dmi')
	desc = "A small glowing dagger. You feel you have too many fingers that are too short to hold it properly."
	sharp = 1
	edge = 1
	unbreakable = 1
	origin_tech = list(TECH_MATERIAL = 4, TECH_COMBAT = 1)
	force_divisor = 0.5
	w_class = ITEM_SIZE_NORMAL
	light_range = 1.5
	light_power = 2
	light_color = "#0c01ba"
	default_material = "diamond"

//////////////////////////////////////////////////////////////////////////////////////////////////COOLING SARCOPHAGUS
/obj/structure/horizons_edge/props/sarcophagus
	name = "standing container"
	desc = "Standing container similar to some medical pods woth unusual shapes and weird extremeties"
	icon = 'maps/away/horizons_edge/horizons_edge_sprites.dmi'
	icon_state = "sarcophagus"
	density = 1
	anchored = 1
	var/mob/living/carbon/human/mob_inside = null

/obj/structure/horizons_edge/props/sarcophagus/update_icon()
	if (mob_inside)
		icon_state = "sarcophagus_locked"
	else
		icon_state = "sarcophagus"

/obj/structure/horizons_edge/props/sarcophagus/attack_hand(var/mob/user)
	if(!isclient(user) || isobserver(user) || isghost(user))
		return
	if (mob_inside)
		visible_message("<span class='notice'>[user] starts to climb into \the [src].</span>")
		if (!ishuman(user))
			visible_message("<span class='warning'>\The [src]'s extremities push [user] away!</span>")
			return
		if (!do_after(user, 50, src))
			visible_message("<span class='notice'>[user] stands back from \the [src].</span>")
		if(mob_inside)//no partying inside
			to_chat(user, "<span class='warning'>\The [src] is locked.</span>")
			return
		visible_message("<span class='notice'>[user] climbs into \the [src]. </span>")
		visible_message("<span class='warning'>\The [src] suddenly locks up! away!</span>")
		mob_inside = user
		//start processing
		START_PROCESSING(SSobj, src)
	else
		if (user != mob_inside)//someone's assisitng
			visible_message("<span class='notice'>[user] starts to pulling aside extremeties locking \the [src].</span>")
			if (!do_after(user, 100, src))
				visible_message("<span class='notice'>[user] lets go \the [src]'s extremeties.</span>")
				return
			visible_message("<span class='notice'>[user] pulls \the [src]'s extremeties away unlocking it, and [mob_inside] drops onto floor like an empty sack!</span>")

		else//breaking out
			to_chat(mob_inside, "<span class='warning'>You start banging and pushing insides of the sarcophagus!</span>")//maybe add some sounds?
			if (!do_after(user, 150, src))//gotta take longer
				to_chat(mob_inside, "<span class='notice'>You stop banging and pushing insides of the sarcophagus!</span>")
				return
			visible_message("<span class='warning'>[user] breaks out from \the [src]!</span>")
		var/turf/T = get_turf(user)
		mob_inside.forceMove(T)
		mob_inside = null
		//stop processing
		STOP_PROCESSING(SSobj, src)
	update_icon()

/obj/structure/horizons_edge/props/sarcophagus/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/structure/horizons_edge/props/sarcophagus/Process()
	if (!mob_inside)
		STOP_PROCESSING(SSobj, src)
		return

	if(mob_inside.vessel.get_reagent_amount(/datum/reagent/blood) < 1)//player sucked dry, unlikely case
		STOP_PROCESSING(SSobj, src)
		return

	to_chat(mob_inside, "<span class='warning'>You feel like your blood is being sucked away and something cold replaces it!</span>")
	mob_inside.remove_blood(1)
	mob_inside.reagents.add_reagent("Frost Oil", 0.1)