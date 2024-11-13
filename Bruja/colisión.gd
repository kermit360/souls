extends CharacterBody2D

@onready var anim_tree: AnimationTree = $bruja/AnimationTree

const SPEED = 80.0
var personaje = null
var distancia = 0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else :
		velocity = position.direction_to(personaje.position)*SPEED
	if position.distance_to(personaje.position)< 300:
		anim_tree["parameters/walk/blend_amount"]= 1
		move_and_slide()
	
func _ready() -> void:
	personaje=  get_parent().get_node("main_char")
	
#func _process(delta: float) -> void:
#	if 

func _on_area_entered(area):
	if area.is_in_group("main"):
		anim_tree ["parameters/Blend2/blend_amount"]= 1
