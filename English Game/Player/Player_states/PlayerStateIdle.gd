extends StateBase
@onready var my_timer = $"../../MyTimer"


#MOVIMIENTO
var move_right : String = "Move_right"
var move_up : String = "Move_up"
var move_down : String = "Move_down"
var move_left : String = "Move_left"


var player : Player

func start():
	player = controlled_node

func on_unhandled_key_input(event):
	if Input.is_action_pressed(move_up):
		player.direction = Vector2(0, -1)
		check_move()
		
	elif Input.is_action_pressed(move_down):
		player.direction = Vector2(0, 1)
		check_move()
			
	elif Input.is_action_pressed(move_left):
		player.direction = Vector2(-1, 0)
		check_move()
		
	elif Input.is_action_pressed(move_right):
		player.direction = Vector2(1, 0)
		check_move()

func check_move():
	player.change_area_positon(player.direction)
	await get_tree().create_timer( 5 / Engine.get_frames_per_second() ).timeout
	
	if player.can_move(): # Si el jugador tiene el permiso de moverse, cambia el estado
		state_machine.change_to("PlayerStateMoving")
	else: 
		player.face_to_with_vector(player.direction)
