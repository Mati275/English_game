extends StateBase

var move_right : String = "Move_right"
var move_up : String = "Move_up"
var move_down : String = "Move_down"
var move_left : String = "Move_left"


var player : Player

func start():
	player = controlled_node
	
	move()
	#player.change_area_positon(player.direction)
	## VER Y PROBARLO CON LOS FRAMES UNA VEZ ACABADO EL MENU DE SETTINGS
	#await get_tree().create_timer( 60 / Engine.get_frames_per_second() ).timeout

	


func move():
	#player.change_area_positon(player.direction)
	#await get_tree().create_timer( 60 / Engine.get_frames_per_second() ).timeout
	
	player.animation(player.direction)
	player.enable_areas( false ) # Al iniciar el movimiento se desactivan las areas
	
	# Si hay un tween activado lo elimina
	if player.tween_move:
		player.tween_move.kill()
	
	# Calcula la posición target
	var target_position = player.global_position + ( player.move_distance * player.direction ) 
	
	# Crea un tween y hace mover al jugador
	player.tween_move = create_tween()
	player.tween_move.tween_property(player, "global_position", target_position, player.move_duration).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	await player.tween_move.finished # Espera al acabar el movimiento

	player.enable_areas( true ) # Al acabar el movimiento activar las areas
	player.emit_signal("finish_move") # Emite una señal para cortar la animación
	
	# Si se sigue pulsando alguna tecla de moverse
	if get_key_move_pressed():
		# Redireccionar la dirección
		
		if Input.is_action_pressed(move_up):
			player.direction = Vector2(0, -1)
			
		elif Input.is_action_pressed(move_down):
			player.direction = Vector2(0, 1)
				
		elif Input.is_action_pressed(move_left):
			player.direction = Vector2(-1, 0)
				
		elif Input.is_action_pressed(move_right):
			player.direction = Vector2(1, 0)
		
		# Redireccionar las areas
		player.change_area_positon(player.direction) # Cambiar la posición de la area
		await get_tree().create_timer( 5 / Engine.get_frames_per_second() ).timeout # Esperar un tiempo
		
		if player.can_move(): # Si el jugador tiene el permiso de moverse se mueve
			move()
		
		else: # Si no tiene el permiso de moverse, solo gira hacia una dirección y se queda "idle" 
			player.face_to_with_vector(player.direction)
			state_machine.change_to("PlayerStateIdle") # Cambia de estado a quieto

	else:
		state_machine.change_to("PlayerStateIdle") # Cambia de estado a quieto
	#else:
		#player.face_to_with_vector(player.direction)
		#state_machine.change_to("PlayerStateIdle") # Cambia de estado a quieto
		
# Obtiene true si una tecla de movimiento esta pulsada sino, false
func get_key_move_pressed():
	var key_move_pressed : bool 
	
	if Input.is_action_pressed(move_up) or Input.is_action_pressed(move_down) or Input.is_action_pressed(move_left) or Input.is_action_pressed(move_right):
		key_move_pressed = true
		
	else:
		key_move_pressed = false
	return key_move_pressed
