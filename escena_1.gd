extends Node2D

func _ready() -> void:
	var main_char = $main_char  # Reference to the main character node
	assign_personaje_to_enemies(main_char)

func assign_personaje_to_enemies(personaje: Node) -> void:
	var enemigos = $Enemigos  # Reference to the "enemigos" node
	for enemy in enemigos.get_children():
		if enemy.has_method("set_personaje"):  # Ensure the child has the method
			enemy.set_personaje(personaje)

func _process(_delta: float) -> void:
	pass
