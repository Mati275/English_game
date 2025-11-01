extends Node

@onready var color_rect = $ColorRect

var tween_fade_effect : Tween 

func fade_in( time : float ):
	if tween_fade_effect:
		tween_fade_effect.kill()
	
	tween_fade_effect = create_tween()
	await tween_fade_effect.tween_property(color_rect, "modulate", Color(0, 0, 0, 0), time).finished
	
	tween_fade_effect.kill()


func fade_out( time : float ):
	if tween_fade_effect:
		tween_fade_effect.kill()
	
	tween_fade_effect = create_tween()
	await tween_fade_effect.tween_property(color_rect, "modulate", Color(0, 0, 0, 1), time).finished
	
	tween_fade_effect.kill()

func fade_in_out( time : float ):
	if tween_fade_effect:
		tween_fade_effect.kill()
	
	tween_fade_effect = create_tween()
	print("hola")
	await tween_fade_effect.tween_property(color_rect, "modulate", Color(0, 0, 0, 1), time).finished
	tween_fade_effect.kill()
	
	tween_fade_effect = create_tween()
	await tween_fade_effect.tween_property(color_rect, "modulate", Color(0, 0, 0, 0), time).finished
	tween_fade_effect.kill()
