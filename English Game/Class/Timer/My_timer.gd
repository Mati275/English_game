extends Node2D
class_name MyTimer

signal timeout
signal started
signal tick

@export var seconds : float
var time_left : float
@export var loop : bool 
var is_running : bool 
var counter : int

func _ready():
	is_running = false

func start():
	time_left = seconds
	is_running = true
	emit_signal("started")
	set_process(true)
	
func stop():
	is_running = false
	set_process(false)

func restart():
	stop()
	start()

func _process(delta):
	
	if not is_running:
		return
	
	time_left -= delta
	emit_signal("tick")
	
	if time_left <= 0:
		emit_signal("timeout")
		if loop == true:
			time_left = seconds
		else:
			print("El timer se ha detenido")
			
			stop()
