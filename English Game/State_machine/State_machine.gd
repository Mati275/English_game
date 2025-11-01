class_name StateMachine extends Node

# Nodo que vamos a controlar
@onready var controlled_node = self.owner

# Estado por defecto
@export var default_state : StateBase

# Estado en ejecución --> Siempre va a ser un nodo
var current_state : StateBase = null

func _ready():
	call_deferred("_state_default_start") # Llamado para cuando todos los nodos estan listos

func _state_default_start():
	current_state = default_state
	_state_start()

# Funcion que prepara las variables para un nuebo estado y ejecuta su start()
func _state_start() -> void:
	prints("StateMachine", controlled_node, "start state", current_state.name)
	#Configuración del estado
	current_state.controlled_node = controlled_node
	current_state.state_machine = self
	current_state.start()

# Metodo para cambiar de un estado a otro
func change_to( new_state: String ) -> void: 
	if current_state and current_state.has_method("end"): current_state.end()
	
	current_state = get_node(new_state)
	_state_start()

# Metodos que se ejecutan solos

func _process(delta):
	if current_state and current_state.has_method("on_process"):
		current_state.on_process(delta)

func _physics_process(delta):
	if current_state and current_state.has_method("on_physics_process"):
		current_state.on_physics_process(delta)

func _input(event):
	if current_state and current_state.has_method("on_input"):
		current_state.on_input(event)

func _unhandled_input(event):
	if current_state and current_state.has_method("on_unhandled_input"):
		current_state.on_unhandled_input(event)

func _unhandled_key_input(event):
	if current_state and current_state.has_method("on_unhandled_key_input"):
		current_state.on_unhandled_key_input(event)

