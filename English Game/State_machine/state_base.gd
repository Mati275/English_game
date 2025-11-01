class_name StateBase extends Node

# Referencia al nodo padre
@onready var controlled_node:Node = self.owner

# Referencia a la maquina de estados
var state_machine : StateMachine

# Metodos comunes

# Ejecutado al entrar en el estado
func start():
	pass

# Ejecutado al salir del estado
func end():
	pass


