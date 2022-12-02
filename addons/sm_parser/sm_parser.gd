tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("StepTiming", "Object", load("steptiming.gd"), load("icon_steptiming.svg"))
	add_custom_type("StepChart", "Object", load("stepchart.gd"), load("icon_stepchart.svg"))
	add_custom_type("StepSong", "Node", load("stepsong.gd"), load("icon_stepsong.svg"))

func _exit_tree():
	remove_custom_type("StepSong")
	remove_custom_type("StepChart")
	remove_custom_type("StepTiming")
