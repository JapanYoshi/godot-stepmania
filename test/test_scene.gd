extends Control

func _ready():
	var chart: StepSong = StepSong.new()
	add_child(chart)
	chart.import_song("res://test/Goin' Under/Goin' Under.ssc")
