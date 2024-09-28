extends StaticBody2D

class_name Objeto_Atacable
@onready var animation_tree: AnimationTree = $Jarron/AnimationTree
var atacado : bool = false : set = set_Atacado

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if atacado:
		animation_tree["parameters/Blend2/blend_amount"] = 1

func set_Atacado(status):
	atacado = status
