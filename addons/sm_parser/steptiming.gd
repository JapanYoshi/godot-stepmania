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
	bpms.resize(0)
	bpms_min = INF
	bpms_max = -INF
	stops.resize(0)
	speeds.resize(0)
	delays.resize(0)
	scrolls.resize(0)
	fakes.resize(0)
	warps.resize(0)
	tick_counts.resize(0)
	time_signatures.resize(0)
	labels.resize(0)
	combos.resize(0)
	display_bpm_low = BPM_DEFAULT
	display_bpm_high = BPM_DEFAULT
	chart_imported = false


### Data to store in order to convert between beats and real time.


### Import and store data from text extracted from the SM/SSC file.
func _split_timestamps(text: String, max_split: int = 1) -> Array:
	var arr: Array = Array(text.split(",", false))
	for i in range(len(arr)):
		var split = arr[i].split("=", true, max_split)
		arr[i] = []
		for e in split:
			arr[i].push_back(float(e))
	return arr


func _split_timestamps_text(text: String) -> Array:
	var arr: Array = Array(text.split(",", false))
	for i in range(len(arr)):
		var split = arr[i].split("=", true, 1)
		arr[i] = [float(split[0]), split[1]]
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

# bpms: Array
# stops: Array
# delays: Array
# warps: Array
var bpm_values: PoolRealArray
var bpm_offsets: PoolRealArray

func _combined_timing_change_sorter(a, b):
	if a.time != b.time:
		return a.time < b.time
	var ranking = ["warp", "delay", "stop", "bpm"]
	return ranking.find(a.type) < ranking.find(b.type)

### Prebakes the timing changes, in order to convert between time and beats.
func render():
	if bpms.empty():
		printerr("Tried to prebake timing changes without a valid BPM entry.")
		return
	bpm_offsets = PoolRealArray([offset])
	var combined_timing_change_events: Array = []
	for bpm_change in bpms:
		combined_timing_change_events.push_back({
			type = "bpm",
			time = int(round(bpm_change[0] * 192.0)),
			value = bpm_change[1]
		})
	for stop in stops:
		combined_timing_change_events.push_back({
			type = "stop",
			time = int(round(stop[0] * 192.0)),
			value = stop[1]
		})
	for delay in delays:
		combined_timing_change_events.push_back({
			type = "delay",
			time = int(round(delay[0] * 192.0)),
			value = delay[1]
		})
	for warp in warps:
		combined_timing_change_events.push_back({
			type = "warp",
			time = int(round(warp[0] * 192.0)),
			value = warp[1]
		})
	combined_timing_change_events.sort_custom(self, "_combined_timing_change_sorter")
	#print(combined_timing_change_events)
	var bpm_now: float = 0
	var time_now: float = offset
	while not combined_timing_change_events.empty():
		var this_event = combined_timing_change_events.pop_front()
		var next_event = combined_timing_change_events.front() # doesn't pop, just for reference
		if this_event.type == "bpm":
			bpm_values.push_back(this_event.value)
			bpm_now = this_event.value
		elif this_event.type == "stop":
			bpm_values.push_back(0.0)
			time_now += this_event.value
			bpm_offsets.push_back(time_now)
			bpm_values.push_back(bpm_now)
		elif this_event.type == "delay":
			bpm_values.push_back(0.0)
			time_now += this_event.value
			bpm_offsets.push_back(time_now)
		elif this_event.type == "warp":
			bpm_values.push_back(-INF)
			time_now += this_event.value
			bpm_offsets.push_back(this_event.value)
			bpm_values.push_back(bpm_now)
		if null != next_event:
			var ticks_till_next: float = (next_event.time - this_event.time)
			var time_till_next = ticks_till_next * 0.3125 / bpm_now # 192 ticks per beat, 60 seconds per minute
			bpm_offsets.push_back(
				bpm_offsets[len(bpm_offsets) - 1] + time_till_next
			)
			time_now += time_till_next
	print(bpm_values)
	print(bpm_offsets)
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
