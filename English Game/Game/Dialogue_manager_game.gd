extends Node

const DIALOGUE_NARRATOR = preload("res://Dialogue/Dialogue_narrator.dialogue")


func _ready():
	DialogueManager.show_dialogue_balloon(DIALOGUE_NARRATOR, "start")
