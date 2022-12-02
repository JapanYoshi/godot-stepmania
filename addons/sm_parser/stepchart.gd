extends Object
class_name StepChart, "icon_stepchart.svg"

var chart_imported: bool = false

const TICKS_PER_MEASURE: int = 192

const NOTES = {
	NONE = "0",
	NOTE = "1",
	HOLD_HEAD = "2",
	HOLD_TAIL = "3",
	MILE = "M",
	LIFT = "L",
}

### [
###   0: Lane,
###   1: Note type,
###   2: Time (ticks),
### ]
var notes: Array = []
var timing: StepTiming = StepTiming.new()

# Textual content from SM/SSC.
var steps_type: String = ""
var description: String = ""
var chart_name: String = ""
var chart_style: String = ""
var meter: int = 0
var radar_values: Array = []
var credit: String = ""

# Enums.
var difficulty: int = -1

# Inferred from parsing.
var lane_count: int = 0


### Difficulty text is just an enum.
func parse_difficulty(text: String):
	match text:
		"Beginner":  difficulty = 0
		"Easy":      difficulty = 1
		"Medium":    difficulty = 2
		"Hard":      difficulty = 3
		"Challenge": difficulty = 4
		"Edit":      difficulty = 5
		_:           difficulty = -1


### Radar values are used inconsistently by different Stepmania themes, so they aren't very indicative of anything. I'm going to parse it as a list of floats regardless.
func parse_radar_values(text: String):
	radar_values = text.split_floats(",")


func parse_notes(text: String):
	var lane_count_unset: bool = true
	var this_measure = []
	var lines_in_measure: int = 0
	var measure_count: int = 0
	for line in text.split("\n", false):
#		print(line)
		if line == ",":
			# finish up measure
			for n in this_measure:
				notes.push_back([
					n[0],
					n[1],
					measure_count * TICKS_PER_MEASURE + n[2] * TICKS_PER_MEASURE / lines_in_measure,
				])
			this_measure.clear()
			measure_count += 1
			lines_in_measure = 0
		else:
			if lane_count_unset:
				lane_count = len(line)
				lane_count_unset = false
			for i in range(lane_count):
				if line[i] == NOTES.NONE: continue
				this_measure.push_back(
					[
						i,
						line[i],
						lines_in_measure,
					]
				)
			lines_in_measure += 1
	chart_imported = true
