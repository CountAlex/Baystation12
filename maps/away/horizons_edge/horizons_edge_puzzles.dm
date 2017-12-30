#define RIDDLE_LINE_VERTICAL 0
#define RIDDLE_LINE_HORIZONTAL 1
#define RIDDLE_LINES_SIZE 4
#define RIDDLE_COLORS_SIZE 7
#define RIDDLE_LINE_CONSOLE "Lines"
#define RIDDLE_TRANSLATION_LATIN_CONSOLE "Latin"
#define RIDDLE_TRANSLATION_GLYPH_CONSOLE "Glyph"
#define RIDDLE_TRANSLATION_SPHYNX_CONSOLE "Sphynx"

//////////////////////////////////////////////////////////////////////////////////////////////////MAIN RIDDLE HANDLER
/obj/effect/horizons_edge/riddles//object that handles riddles solving
	var/solved = 0
	invisibility = 101
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	var/obj/structure/horizons_edge/endgame_button/the_button

/obj/effect/horizons_edge/riddles/Initialize()
	.=..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/horizons_edge/riddles/LateInitialize()
	for (var/obj/effect/horizons_edge/riddles/riddle/R in GLOB.riddles)//connects children riddles with common parent
		R.set_parent(src)
	var/obj/effect/horizons_edge/placeholders/endgame_button/BTN = locate() in GLOB.riddles_placeholders
	the_button = new /obj/structure/horizons_edge/endgame_button(BTN.loc, src)
	GLOB.riddles_placeholders.Remove(BTN)
	qdel(BTN)

/obj/effect/horizons_edge/riddles/proc/riddle_solved()
	solved+=1
	if (solved == GLOB.riddles.len)
		all_riddles_solved()

/obj/effect/horizons_edge/riddles/proc/all_riddles_solved()
	//unlock doors and activate button
	the_button.activate()
	for (var/obj/effect/horizons_edge/placeholders/field_unlock/FU in GLOB.riddles_placeholders)
		var/turf/T = get_turf(FU)
		var/obj/structure/horizons_edge/forcefield/locked/FF_L = locate() in T
		FF_L.unlock()
		GLOB.riddles_placeholders.Remove(FU)
		qdel(FU)

/obj/effect/horizons_edge/riddles/proc/endgame()
	for (var/obj/effect/horizons_edge/placeholders/window_breaker/WB in GLOB.riddles_placeholders)
		var/turf/T = get_turf(WB)
		var/obj/structure/horizons_edge/alien_window/WDW = locate() in T
		WDW.shatter()
		GLOB.riddles_placeholders.Remove(WB)
		qdel(WB)

//////////////////////////////////////////////////////////////////////////////////////////////////BASIC RIDDLE DEFINITION
/obj/effect/horizons_edge/riddles/riddle
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	invisibility = 101
	var/obj/effect/horizons_edge/riddles/parent//for connection with the all riddles processing
	var/riddle_length = 0

/obj/effect/horizons_edge/riddles/riddle/Initialize()
	. = ..()
	GLOB.riddles.Add(src)

/obj/effect/horizons_edge/riddles/riddle/proc/set_parent(var/P)
	parent = P

/obj/effect/horizons_edge/riddles/riddle/proc/report_solved()
	parent.riddle_solved()

//////////////////////////////////////////////////////////////////////////////////////////////////COLORS PUZZLE
/obj/effect/horizons_edge/riddles/riddle/colors //abstract object that handles colors puzzle logic
	var/list/colors = list("red" = "#ff0000", "orange" = "#ff8000", "yellow" = "#ffd11a","green" = "#009900", "blue" = "#1ac6ff", "indigo" = "#0000ff", "purple" = "#7300e6")
	riddle_length = RIDDLE_COLORS_SIZE //7 colors of the rainbow
	var/list/buttons = list()

/obj/effect/horizons_edge/riddles/riddle/colors/Initialize()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/horizons_edge/riddles/riddle/colors/LateInitialize()//spawn buttons to placeholder locations with randomly chosen colors
	var/list/random_order_colors = shuffle(colors)
	var/iter = 1
	for (var/obj/effect/horizons_edge/placeholders/button/PH in GLOB.riddles_placeholders)
		var/obj/structure/horizons_edge/color_button/B = new /obj/structure/horizons_edge/color_button(PH.loc, random_order_colors[iter], random_order_colors[random_order_colors[iter]], src)
		buttons.Add(B)
		iter += 1
		GLOB.riddles_placeholders.Remove(PH)
		qdel(PH)


/obj/effect/horizons_edge/riddles/riddle/colors/proc/button_pushed(var/button_color)
	if (colors[solved+1] == button_color)
		solved+=1
		if (solved == riddle_length)
			report_solved()
		return 1
	else
		reset()
		solved = 0
		return 0

/obj/effect/horizons_edge/riddles/riddle/colors/proc/reset()
	for (var/obj/structure/horizons_edge/color_button/B in buttons)
		B.reset()

//////////////////////////////////////////////////////////////////////////////////////////////////LINES PUZZLE
/obj/effect/horizons_edge/riddles/riddle/lines//abstract object for handling lines puzzle logic
	riddle_length = RIDDLE_LINES_SIZE * RIDDLE_LINES_SIZE//16 elements to be lined
	var/riddle_size = RIDDLE_LINES_SIZE
	var/list/lines[RIDDLE_LINES_SIZE][RIDDLE_LINES_SIZE]
	var/obj/structure/horizons_edge/alien_console/console

/obj/effect/horizons_edge/riddles/riddle/lines/Initialize()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/horizons_edge/riddles/riddle/lines/LateInitialize()
	for (var/obj/effect/horizons_edge/placeholders/line/PH in GLOB.riddles_placeholders)//puts line objects to their locations
		var/L = new /obj/structure/horizons_edge/line(PH.loc)
		var/row = riddle_size - PH.y + src.y//more convenient to view top down also easier for displaying in console. Players with changed angle of view are screwed anyway
		var/column = 1 + PH.x - src.x
		lines[row][column] = L
		GLOB.riddles_placeholders.Remove(PH)
		qdel(PH)

	var/obj/effect/horizons_edge/placeholders/alien_console/line_console/PHC = locate() in GLOB.riddles_placeholders//spawning console
	console = new /obj/structure/horizons_edge/alien_console/line_console(PHC.loc, riddle_size)
	console.set_parent(src)
	GLOB.riddles_placeholders.Remove(PHC)
	qdel(PHC)

	while (is_solved())//so it won't drop solved set
		for (var/iter_rand = 1 to 5)//random but solvable initial set of states
			rotate(rand(1,riddle_size),rand(1,riddle_size))

/obj/effect/horizons_edge/riddles/riddle/lines/proc/is_solved()
	for (var/iter_row = 1 to riddle_size)
		for (var/iter_col = 1 to riddle_size)
			var/obj/structure/horizons_edge/line/L = lines[iter_row][iter_col]
			if (!L.right_state())
				return 0
	return 1

/obj/effect/horizons_edge/riddles/riddle/lines/proc/rotate(var/row, var/column)//rotates lines in cross pattern
	for (var/iter_row = 1 to riddle_size)//rotates all in same column
		var/obj/structure/horizons_edge/line/L = lines[iter_row][column]
		L.change_state()
	for (var/iter_col = 1 to riddle_size)//rotates all except already rotated in same row
		if (iter_col == column)
			continue
		var/obj/structure/horizons_edge/line/L = lines[row][iter_col]
		L.change_state()
	return is_solved()

/obj/effect/horizons_edge/riddles/riddle/lines/proc/get_lines()
	return lines
////////////////////////////////////////////////////////////////////////////////TRANSLATION+SPHYNX PUZZLE
/obj/effect/horizons_edge/riddles/riddle/translation //handles finding solution to translation puzzle
	var/list/latin_alphabet = list("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", \
									"n", "o", "p", "q", "r", "s", "t", "u", "v", "w",  "x", "y", "z")
	var/obj/structure/horizons_edge/alien_console/translation/latin/console_latin
	var/obj/structure/horizons_edge/alien_console/translation/glyph/console_glyph
	var/obj/structure/horizons_edge/alien_console/translation/sphynx/console_sphynx
	var/list/hint_options = list("jackdaws love my big sphinx of quartz", "the five boxing wizards jump quickly", "glib jocks quiz nymph to vex dwarf", \
	"quick brown fox jumps over the lazy dog", "pack my box with five dozen liquor jugs", "how vexingly quick daft zebras jump")
	var/hint_text
	var/list/alien_alphabet = list()
	var/list/questions = list(
		"hydrogen" = "most common element in the universe",
		"yomoma" = "biggest thing in the universe",//delete this after test
		"narsie" = "meanest son of a bitch",//delete this after test
		"father" = "who killed lora palmer",
		"star" = "celestial object in the center of a system")
	var/answer

/obj/effect/horizons_edge/riddles/riddle/translation/Initialize()
	..()
	hint_text = hint_options[rand(1, hint_options.len)]
	answer = questions[rand(1, questions.len)]
	riddle_length = lentext(answer)
	var/list/mixed_alphabet = shuffle(latin_alphabet)
	for (var/alphabet_iter = 1 to 26)
		alien_alphabet.Add(mixed_alphabet.Find(latin_alphabet[alphabet_iter]))

	return INITIALIZE_HINT_LATELOAD

/obj/effect/horizons_edge/riddles/riddle/translation/LateInitialize()
	var/obj/effect/horizons_edge/placeholders/alien_console/latin/PHL = locate() in GLOB.riddles_placeholders
	console_latin = new /obj/structure/horizons_edge/alien_console/translation/latin(PHL.loc, hint_text)
	console_latin.set_parent(src)
	GLOB.riddles_placeholders.Remove(PHL)
	qdel(PHL)

	var/obj/effect/horizons_edge/placeholders/alien_console/glyph/PHG = locate() in GLOB.riddles_placeholders
	console_glyph = new /obj/structure/horizons_edge/alien_console/translation/glyph(PHG.loc, translate_to_glyphs(hint_text))
	console_glyph.set_parent(src)
	GLOB.riddles_placeholders.Remove(PHG)
	qdel(PHG)

	var/obj/effect/horizons_edge/placeholders/alien_console/sphynx/PHS = locate() in GLOB.riddles_placeholders
	console_sphynx = new /obj/structure/horizons_edge/alien_console/translation/sphynx(PHS.loc, translate_to_glyphs(questions[answer]), alien_alphabet)
	console_sphynx.set_parent(src)
	GLOB.riddles_placeholders.Remove(PHS)
	qdel(PHS)


/obj/effect/horizons_edge/riddles/riddle/translation/proc/translate_to_glyphs(var/latin_text)
	var/list/translation = list()//copytext(string, start,end)
	if (!istext(latin_text))
		return translation
	latin_text = lowertext(latin_text)//just in case
	for (var/iter = 1 to lentext(latin_text))
		var/n = latin_alphabet.Find(copytext(latin_text, iter, iter+1))//Copy gets single letter, Find gets number of a letter in the alphabet
		if (n == 0)//if it's not lowercase letter of latin alphabet
			continue
		translation.Add(alien_alphabet.Find(n))//Find gets position of nth letter in glyphs alphabet
	return translation

/obj/effect/horizons_edge/riddles/riddle/translation/proc/translate_to_latin(var/list/glyphs)
	var/translation = ""
	for (var/iter = 1 to glyphs.len)
		var/G = glyphs[iter]
		if (!isnum(G) || G<1 || G>26)
			continue
		translation += latin_alphabet[alien_alphabet[G]]
	return translation

/obj/effect/horizons_edge/riddles/riddle/translation/proc/check_answer(var/list/answer_from_player)
	var/input = translate_to_latin(answer_from_player)
	if (input == answer)
		report_solved()
		return 1
	return 0
