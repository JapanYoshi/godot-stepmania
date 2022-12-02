### The timing data attached to every Stepmania file, and optionally some charts individually if the file format is .ssc.

extends Object
class_name StepTiming, "icon_steptiming.svg"

const TICKS_PER_BEAT = 48

var chart_imported: bool = false

const BPM_DEFAULT: float = -1.0
const BPM_SECRET: float = -2.0
### Imported data from Stepmania chart.
var offset: float = 0.0
var bpms: Array = []
var bpms_min: float = INF
var bpms_max: float = -INF
var stops: Array = []
export var delays: Array = []
export var warps: Array = []
export var time_signatures: Array = []
export var tick_counts: Array = []
export var combos: Array = []
export var speeds: Array = [] # PIU stretch/shrink effect
export var scrolls: Array = []
export var fakes: Array = []
export var labels: Array = []
export var display_bpm_low: float = BPM_DEFAULT
export var display_bpm_high: float = BPM_DEFAULT

func reset():
	offset = 0.0
	bpms.clear()
	bpms_min = INF
	bpms_max = -INF
	stops.clear()
	speeds.clear()
	delays.clear()
	scrolls.clear()
	fakes.clear()
	warps.clear()
	tick_counts.clear()
	time_signatures.clear()
	labels.clear()
	combos.clear()
	display_bpm_low = BPM_DEFAULT
	display_bpm_high = BPM_DEFAULT
	chart_imported = false


### Data to store in order to convert between beats and real time.


### Import and store data from text extracted from the SM/SSC file.
func _split_timestamps(text: String, max_split: int = 1) -> Array:
	var arr = text.split(",")
	for line in arr:
		var split = line.split("=", true, max_split)
		line = []
		for e in split:
			line.push_back(float(e))
	return arr


func _split_timestamps_text(text: String) -> Array:
	var arr = text.split(",")
	for line in arr:
		var split = line.split("=", true, 1)
		line = [float(split[0]), split[1]]
	return arr


func import_bpms(text: String):
	bpms = _split_timestamps(text)


func import_stops(text: String):
	stops = _split_timestamps(text)


func import_delays(text: String):
	delays = _split_timestamps(text)


func import_speeds(text: String):
	speeds = _split_timestamps(text, 4)


func import_scrolls(text: String):
	scrolls = _split_timestamps(text)


func import_fakes(text: String):
	fakes = _split_timestamps(text)


func import_warps(text: String):
	warps = _split_timestamps(text)


func import_tick_counts(text: String):
	tick_counts = _split_timestamps(text)


func import_time_signatures(text: String):
	speeds = _split_timestamps(text, 2)


func import_labels(text: String):
	speeds = _split_timestamps_text(text)


func import_combos(text: String):
	speeds = _split_timestamps(text)


func import_display_bpm(text: String):
	if text == "*":
		display_bpm_low = BPM_SECRET
		display_bpm_high = BPM_SECRET
		return
	var split = text.split(":");
	display_bpm_low = float(split[0])
	if len(split) == 1:
		display_bpm_high = display_bpm_low
	else:
		display_bpm_high = float(split[1])


### Returns an array of two floats: the minimum and maximum display BPM.
func get_display_bpms() -> Array:
	if display_bpm_low == BPM_SECRET:
		return [NAN, NAN]
	if display_bpm_low == BPM_DEFAULT:
		return [bpms_min, bpms_max]
	return [display_bpm_low, display_bpm_high]

### Prebakes the timing changes, in order to convert between time and beats.
func render():
	return;


### Converts beats to real time. There are 48 ticks per beat (192th note precision). Time returns in microseconds.
func tick_to_time_us(beat: int, tick: int) -> int:
	return 0; # todo


### Converts real time to beats. There are 48 ticks per beat (192th note precision). Time must be in microseconds.
func time_us_to_tick(time_us: int) -> int:
	return 0; # todo


func _get_current_scroll_speed(time_us: int) -> float:
	return 1.0; # todo


func _get_current_stretch(time_us: int) -> float:
	return 1.0; # todo


### Takes in real time and the target time, and returns how many "beats" ahead it should APPEAR.
### Returns a FLOAT!
func get_beat_distance(now_us: int, time_us: int) -> float:
	return 0.0; # todo
