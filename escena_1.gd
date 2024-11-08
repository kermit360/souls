extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var enmigos= get_node("Enemigos")
	for enemigo in enemigos.get_children():
		if enemigo is enemigo_atacable :
			enemigo.connect("recibir_ataque", Callable(enemigo,"reducir_vida"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
