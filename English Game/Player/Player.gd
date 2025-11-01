class_name Player extends CharacterBody2D


# ***********
# SEÑALES
# ***********
signal change_terrain
signal area_position_changed

signal finish_move # Emitida al acabar de moverse --> Para parar la animación

signal stop_moving

# ***********
# VARIABLES @ONREADY
# ***********
@onready var anim_player = $Anim_player
@onready var spr_player = $Spr_player
@onready var my_timer = $MyTimer
@onready var area_interaction_finder = $Area_interaction_finder
@onready var area_col_detector = $Area_col_detector
@onready var camera = $Camera


#const NARRATOR_DIALOGUE = preload("res://Dialogue/Narrator_dialogue.dialogue")

# ***********
# VARIABLES
# ***********

# VECTORES DEL COLISION_FINDER (DEPENDE DE LA ANIMACION)
var area_right : Vector2 = Vector2(16, -8)
var area_left : Vector2 = Vector2(-16, -8)
var area_up : Vector2 = Vector2(0, -24)
var area_down : Vector2 = Vector2(0, 8)


# PRIMERA ANIMACION MOSTRADA AL SER INSTANCIADO
var first_animation : String

#MOVIMIENTO
var move_right : String = "Move_right"
var move_up : String = "Move_up"
var move_down : String = "Move_down"
var move_left : String = "Move_left"
var direction : Vector2 = Vector2.ZERO

var tween_move : Tween

@export var move_distance: int = 16  # Distancia de movimiento (16 píxeles)
var move_duration : float = 0.35 # Duración del movimiento (0.31 segundos)

var target_position: Vector2 = Vector2.ZERO  # Posición objetivo al moverse

# LIMITE DE UN TERRENO
var limit_up_vector : Vector2 = Vector2.ZERO
var limit_down_vector : Vector2 = Vector2.ZERO


func _ready():
	Global_Var.move_character.connect(check_character_to_move)
	
	#Animacion que se ejecuta al instanciarse
	anim_player.play(first_animation)

func _process(_delta):
	is_in_scene()


func _input(_event):
	interaction()


# ***********
# ANIMACIÓN
# ***********

func animation(vector_direction):
	if vector_direction == Vector2.DOWN:
		anim_player.play("Moving_down")
	elif vector_direction == Vector2.UP:
		anim_player.play("Moving_up")
	elif vector_direction == Vector2.LEFT:
		anim_player.play("Moving_left")
	elif vector_direction == Vector2.RIGHT:
		anim_player.play("Moving_right")


# ***********
# MOVIMIENTO AUTONOMO
# ***********

func can_move() -> bool:
	var can_move: bool
	#Verifica que no se ha salido del mapa
		# Vector_target.x << limit_up_position
		# Vector_target.y >> limit_up_position
			 
		# Vector_target.x >> limit_down_position
		# Vector_target.y <<= limit_down_position --> EN ESTA LE PONGO <=, PORQUE EL JUGADOR TIENE EN LOS PIES EL CENTRO, POR LO TANTO AL CALCULAR LA POSICION ESTA PUEDE SER IGUAL QUE EN LA DEL EJE "Y" DEL DOWN LIMIT
		
		# and target_position.x < limit_up_vector.x and target_position.y > limit_up_vector.y and target_position.x > limit_down_vector.x and target_position.y <= limit_down_vector.y:
	
	#Si la area puede detectar areas
	if area_col_detector.monitoring == true:
		#print(area_col_detector.has_overlapping_areas())
		#Si no tiene alguna colision que impide el movimiento i esta dentro de los limites de los limites --> Se puede mover
		if not area_col_detector.has_overlapping_areas():
			can_move = true
	
		# Lo conrario --> No se puede mover
		else:
			can_move = false
	
	# Si la area no puede detectar areas --> Solo calcula los límites
	#else:
		#if target_position.x < limit_up_vector.x and target_position.y > limit_up_vector.y and target_position.x > limit_down_vector.x and target_position.y <= limit_down_vector.y:
			#can_move = true
	#
		#else:
			#can_move = false
		
	if Global_Var.scene:
		can_move = false
	
	return can_move


# ***********
# MOVIMIENTO CONTROLADO
# ***********

func simple_move(direction : String, counter : int, move_duration : float):
	
	#Transforma el string de la dirección en un vector
	var vector_direction : Vector2
	
	if direction == "RIGHT":
		vector_direction = Vector2.RIGHT
		
	if direction == "LEFT":
		vector_direction = Vector2.LEFT
		
	if direction == "UP":
		vector_direction = Vector2.UP
		
	if direction == "DOWN":
		vector_direction = Vector2.DOWN
	
	if vector_direction != Vector2.ZERO:
		
		#SE ASIGNA LA TARGET POSITION POR PRIMERA VEZ
		target_position = global_position + (vector_direction * move_distance)

		#Hace la animación dependiendo del vector que se mueva
		animation(vector_direction)
		
		#Se mueve con los parametros indicados
		control_move(vector_direction, counter, move_duration)
		
		
#Una vez haciendo todos los "sets" tenemos las variables listas para ser usadas
func control_move(vector_direction : Vector2, counter : int, move_duration : float) -> void:
	#if is_moving == true:
	while counter > 0:
		#MOVER EL PERSONAJE
		var movement = create_tween()
		movement.tween_property(self, "global_position", target_position, move_duration)
		
		await movement.finished
			
			
		if global_position == target_position:
			#Se resta uno al contador
			counter -= 1
			print("se resta uno al counter")
				
			if counter > 0:
				#ANIMACION + ASIGNAR EL TARGET POSITION(las veces que haga falta)
				target_position = global_position + (vector_direction * move_distance)
				animation(vector_direction)
				
			elif counter == 0:
				print("se deja de mover el npc")
				#is_moving = false
				emit_signal("stop_moving")
				#target_position = Vector2.ZERO

func complex_move(direction : Array, counter : Array, move_duration : float):
	#Recorre todos los elementos de "direction" y "counter"
	var index = 0
	for d in direction:
		#Coje el elemento de la array de counter con el mismo index del valor "d" en array de direction
		var count = counter[index]
		simple_move(d, count, move_duration)
		index += 1
		await stop_moving # Espera a que el movimiento se acabe para ejecutar otro movimiento simple

#COMO FUNCIONA? 
# 1) HAY UN MOVIMIENTO SIMPLE QUE PERMITE MOVER AL NPC EN UNA SOLA DIRECCION
# 2) HAY UN MOVIMIENTO COMPLEJO QUE PERMITE MOVER AL NPC EN VARIAS DIRECCIONES, REPITIENDO DETERMINADAS VECES EL MOVIMIENTO SIPLE DEL NPC

# ************
# MOVIMIENTO CONTROLADO POR SEÑAL
# ***********

# Comprobar si es el personaje que se tiene que mover
# PRIMERA EN MAYUSCULA
func check_character_to_move(character : String, direction : Array, counter : Array, move_duration : float):
	if character == "Player":
		complex_move(direction, counter, move_duration)
	else:
		return


# ************
# HACIA DONDE MIRA
# ***********

# CAMBIAR LA DIRECCION CON ESTAS FUNCIONES CAMBIA LA POSICIÓN DE LAS AREAS DEL

func face_to(direction : String):
	match direction:
		"LEFT":
			anim_player.play("left")
		"RIGHT":
			anim_player.play("right")
		"UP":
			anim_player.play("up")
		"DOWN":
			anim_player.play("down")

func face_to_with_vector(direction : Vector2):
	match direction:
		Vector2.LEFT:
			anim_player.play("left")
		Vector2.RIGHT:
			anim_player.play("right")
		Vector2.UP:
			anim_player.play("up")
		Vector2.DOWN:
			anim_player.play("down")

# CAMBIAR LA POSICION DEL COLISION FINDER DEPENDIENDO DE DONDE MIRE EL JUGADOR
func change_area_positon(where_is_facing : Vector2):
	match where_is_facing:
		
		Vector2.LEFT: 
			area_interaction_finder.position = area_left
			area_col_detector.position = area_left
			#emit_signal("area_position_changed")
		
		Vector2.UP: 
			area_interaction_finder.position = area_up
			area_col_detector.position = area_up
			#emit_signal("area_position_changed")

		Vector2.RIGHT: 
			area_interaction_finder.position = area_right
			area_col_detector.position = area_right
			#emit_signal("area_position_changed")

		Vector2.DOWN: 
			area_interaction_finder.position = area_down
			area_col_detector.position = area_down
			#emit_signal("area_position_changed")



# ***********
# CAMBIO DE TERRENO
# ***********

# AL INTERACCIONAR (PULSAR LA E)
func interaction() -> void:
	#SI HAY UNA AREA SOBREPONIENDOSE + NO ESTA EN UNA ESCENA
	if Input.is_action_just_pressed("Interact") and area_interaction_finder.has_overlapping_areas() == true and Global_Var.scene == false:
		var colision_groups = area_interaction_finder.get_overlapping_areas()[0].get_groups()
		#var first_colision_group = colision_groups[0]

		#SI LA AREA ES PARA CAMBIAR LA ESCENA --> Tiene un grupo que se llama "gr_change_terrain"
		if colision_groups.has("gr_change_terrain") == true:
			
			#Si puede ir a varios terrenos
			if colision_groups.size() > 2:
				return
				#Eliminar el grupo de "gr_chage_terrain", ya que godot no determina el orden de los nodos de grupo + pillar el elemento "0" de la array
				#var next_terrain = colision_groups.erase("gr_change_terrain")[0] # TODO una funcion que 
				#Global_Var.emit_signal("change_terrain", next_terrain) # EL PARAMETRO DE LA FUNCION ES LA ESCENA A LA QUE SE VA A DIRIGIR

			#Si solo puede ir a un terreno
			else:
				Global_Var.emit_signal("change_terrain", colision_groups[1], 1, camera.offset, true) # EL PARAMETRO DE LA FUNCION ES LA ESCENA A LA QUE SE VA A DIRIGIR


		elif colision_groups.has("gr_interaction_npc"):
			var npc = area_interaction_finder.get_overlapping_areas()[0].get_parent()
			npc.interaction() #Se pilla el nodo del npc con el que esta interactuando para que este emita un dialogo
			npc.face_to_player(global_position)


# ***********
# JUGADOR EN ESCENA
# ***********
func is_in_scene():
	#Si esta en escena
	if Global_Var.scene == true:
		camera.enabled = false
	
	#Si no esta en una escena
	elif Global_Var.scene == false:
		camera.enabled = true

# ***********
# AREAS
# ***********

func enable_areas( enable : bool = true ):
	if enable:
		area_interaction_finder.monitoring = true
		area_col_detector.monitoring = true
	else:
		area_interaction_finder.monitoring = false
		area_col_detector.monitoring = false


func _on_finish_move():
	# anim_player.stop()
	pass
