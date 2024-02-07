extends Control

func _ready():
	var song: StepSong = StepSong.new()
	add_child(song)
	song.import_song("res://test/Dat Disco Swindle/Dat Disco Swindle.ssc")
	song.charts[2].timing.render()
