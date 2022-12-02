extends Node
class_name StepSong, "icon_stepsong.svg"

var song_imported: bool = false

### List of (known) tags that this won't work with:
#KEYSOUNDS - because I don't know how the hell it works
#ATTACKS - because nobody's recreating modcharts in Godot using these attacks

export var sm_version: String = ""
export var title: String = ""
export var title_translit: String = ""
export var subtitle: String = ""
export var subtitle_translit: String = ""
export var artist: String = ""
export var artist_translit: String = ""
export var genre: String = ""
export var credit: String = ""
export var music: String = ""
export var banner: String = ""
export var background: String = ""
export var cd_title: String = ""
export var sample_start: float = 0.0
export var sample_length: float = 0.0
export var selectable: bool = true
export var origin: String = ""
export var preview_vid: String = ""
export var jacket: String = ""
export var cd_image: String = ""
export var disc_image: String = ""
export var lyrics_path: String = ""
export var bg_changes: String = ""
export var fg_changes: String = ""
export var charts: Array = []

var song_timing: StepTiming = StepTiming.new()

func reset():
	sm_version = ""
	title = ""
	title_translit = ""
	subtitle = ""
	subtitle_translit = ""
	artist = ""
	artist_translit = ""
	genre = ""
	credit = ""
	music = ""
	banner = ""
	background = ""
	cd_title = ""
	sample_start = 0.0
	sample_length = 0.0
	selectable = true
	origin = ""
	preview_vid = ""
	jacket = ""
	cd_image = ""
	disc_image = ""
	lyrics_path = ""
	bg_changes = ""
	fg_changes = ""
	charts = []
	song_timing.reset()
	song_imported = false


### Import the SM or SSC file of the song.
### Pass the file name TO THE SM OR SSC FILE, not to the folder.
func import_song(filename: String) -> int:
	var file = File.new()
	if !file.file_exists(filename):
		return ERR_FILE_NOT_FOUND
	if song_imported:
		reset()
	file.open(filename, File.READ)
	var line_number = 0
	var last_line_number = 0
	var current_chart = -1
	while !file.eof_reached():
		line_number += 1
		var line: String = file.get_line()
		line.strip_edges()
		if line.empty() or line.begins_with("//"):
			last_line_number = line_number;
			continue;
		# split the line by the first colon character
		var line_split = line.split(":", true, 1)
		if len(line_split) == 1:
			line_split.append("")
		# remove the semicolon at the end, if it ends with one
		while !line_split[1].ends_with(";"):
			line_number += 1
			var next_line = file.get_line()
			line_split[1] += "\n" + next_line
		line_split[1] = line_split[1].trim_suffix(";")
#		print(line_number, " ", line_split[0], ":", line_split[1])
		match line_split[0]:
			# text content
			"#VERSION":          sm_version          = line_split[1]
			"#TITLE":            title               = line_split[1]
			"#SUBTITLE":         subtitle            = line_split[1]
			"#ARTIST":           artist              = line_split[1]
			"#TITLETRANSLIT":    title_translit      = line_split[1]
			"#SUBTITLETRANSLIT": subtitle_translit   = line_split[1]
			"#ARTISTTRANSLIT":   artist_translit     = line_split[1]
			"#GENRE":            genre               = line_split[1]
			"#CREDIT":           credit              = line_split[1]
			"#MUSIC":            music               = line_split[1]
			"#BANNER":           banner              = line_split[1]
			"#BACKGROUND":       background          = line_split[1]
			"#CDTITLE":          cd_title            = line_split[1]
			"#ORIGIN":           origin              = line_split[1]
			"#PREVIEWVID":       preview_vid         = line_split[1]
			"#JACKET":           jacket              = line_split[1]
			"#CDIMAGE":          cd_image            = line_split[1]
			"#DISCIMAGE":        disc_image          = line_split[1]
			"#LYRICSPATH":       lyrics_path         = line_split[1]
			# don't bother parsing, just leave it alone
			"#BGCHANGES":        bg_changes          = line_split[1]
			"#FGCHANGES":        fg_changes          = line_split[1]
			# needs a bit of work
			"#SELECTABLE":       selectable          = (line_split[1] == "YES")
			"#SAMPLESTART":      sample_start        = float(line_split[1])
			"#SAMPLELENGTH":     sample_length       = float(line_split[1])
			# song or chart timing
			"#OFFSET":
				if current_chart == -1:
					song_timing.offset = float(line_split[1])
				else:
					charts[current_chart].timing = float(line_split[1])
			"#BPMS":
				if current_chart == -1:
					song_timing          .import_bpms(line_split[1])
				else:
					charts[current_chart].import_bpms(line_split[1])
			"#STOPS":
				if current_chart == -1:
					song_timing          .import_stops(line_split[1])
				else:
					charts[current_chart].import_stops(line_split[1])
			"#DELAYS":
				if current_chart == -1:
					song_timing          .import_delays(line_split[1])
				else:
					charts[current_chart].import_delays(line_split[1])
			"#SPEEDS":
				if current_chart == -1:
					song_timing          .import_speeds(line_split[1])
				else:
					charts[current_chart].import_speeds(line_split[1])
			"#SCROLLS":
				if current_chart == -1:
					song_timing          .import_scrolls(line_split[1])
				else:
					charts[current_chart].import_scrolls(line_split[1])
			"#WARPS":
				if current_chart == -1:
					song_timing          .import_warps(line_split[1])
				else:
					charts[current_chart].import_warps(line_split[1])
			"#FAKES":
				if current_chart == -1:
					song_timing          .import_fakes(line_split[1])
				else:
					charts[current_chart].import_fakes(line_split[1])
			"#TICKCOUNTS":
				if current_chart == -1:
					song_timing          .import_tick_counts(line_split[1])
				else:
					charts[current_chart].import_tick_counts(line_split[1])
			"#TIMESIGNATURES":
				if current_chart == -1:
					song_timing          .import_time_signatures(line_split[1])
				else:
					charts[current_chart].import_time_signatures(line_split[1])
			"#LABELS":
				if current_chart == -1:
					song_timing          .import_labels(line_split[1])
				else:
					charts[current_chart].import_labels(line_split[1])
			"#COMBOS":
				if current_chart == -1:
					song_timing          .import_combos(line_split[1])
				else:
					charts[current_chart].import_combos(line_split[1])
			"#DISPLAYBPM":
				if current_chart == -1:
					song_timing          .import_display_bpm(line_split[1])
				else:
					charts[current_chart].import_display_bpm(line_split[1])
			# new note data
			"#NOTEDATA":
				current_chart += 1
				charts.push_back(StepChart.new())
			# data that belongs to a chart
			"#STEPSTYPE":   charts[current_chart].steps_type  = line_split[1]
			"#DESCRIPTION": charts[current_chart].description = line_split[1]
			"#CHARTNAME":   charts[current_chart].chart_name  = line_split[1]
			"#CHARTSTYLE":  charts[current_chart].chart_style = line_split[1]
			"#DIFFICULTY":  charts[current_chart].parse_difficulty(line_split[1])
			"#METER":       charts[current_chart].meter       = int(line_split[1])
			"#RADARVALUES": charts[current_chart].parse_radar_values(line_split[1])
			"#CREDIT":      charts[current_chart].credit      = line_split[1]
			"#NOTES":       charts[current_chart].parse_notes(line_split[1])
			# fallback
			_:
				printerr(
					"StepSong.import_song(): At line %d:" % (last_line_number + 1),
					"Skipping unrecognized or unimplemented Stepmania file section \"%s\"." % line_split[0]
				)
	last_line_number = line_number;
	file.close()
	return OK
