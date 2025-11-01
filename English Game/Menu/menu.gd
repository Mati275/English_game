extends Control

const GAME = "res://Game/Game.tscn"








# *******************
# CONEXIÓN DE BOTONES
# *******************

func _on_but_play_toggled(toggled_on):
	get_tree().change_scene_to_file( GAME )
	print("hola")


func _on_but_settings_toggled(toggled_on):
	pass # Replace with function body.


func _on_but_exit_toggled(toggled_on):
	get_tree().quit()
