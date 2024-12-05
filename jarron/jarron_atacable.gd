extends StaticBody2D

class_name Objeto_Atacable

@onready var fire: Sprite2D = $fire
@onready var fire_animation_tree: AnimationTree = $fire/AnimationTree

@onready var jarron: Sprite2D = $Jarron
@onready var animation_tree: AnimationTree = $Jarron/AnimationTree

@onready var glow_fire: Sprite2D = $glow_fire
@onready var glow_jarron: Sprite2D = $glow_jarron
@onready var light: PointLight2D = $PointLight2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D

var fire_is_Growing = true
var jarron_is_Growing = true
var original_Glow_Fire_Scale = 0
var original_Glow_Jarron_Scale = 0


var atacado : bool = false : set = set_Atacado
var esperando_recoleccion = false
var recolectado : bool = false
var objeto_recolector = null
var valor_Recuperacion = .1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	original_Glow_Fire_Scale = glow_fire.scale.x
	original_Glow_Jarron_Scale = glow_fire.scale.x
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if glow_fire and not recolectado:
		fire_is_Growing = glowingeffect(glow_fire, original_Glow_Fire_Scale, 0.02, 1.1, fire_is_Growing)
	if glow_jarron and not atacado:
		jarron_is_Growing = glowingeffect(glow_jarron, original_Glow_Jarron_Scale, 0.003, 1.1, jarron_is_Growing)
	
	if atacado and not esperando_recoleccion:
		handle_Ataque()
	
	if esperando_recoleccion and not recolectado:
		if ray_cast_2d.is_colliding():
			objeto_recolector = ray_cast_2d.get_collider()
			if objeto_recolector.is_in_group("main"):
				objeto_recolector.set_Vida_Recuperada(valor_Recuperacion)
				handle_Recoleccion()


func set_Atacado(status):
	atacado = status
	
func handle_Ataque():
	esperando_recoleccion = true
	animation_tree["parameters/Blend2/blend_amount"] = 1
	$smash.play()
	glow_jarron.queue_free()
	jarron.set("modulate", Color(0.6, 0.65, 0.7, 1.0))
	$CollisionShape2D.disabled = true
	glow_fire.visible = true
	fire.visible = true
	light.visible = true
	fire_animation_tree["parameters/fade_in/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	
func handle_Recoleccion():
	recolectado = true
	$recoleccion.play()
	fire_animation_tree["parameters/fade_out/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	await get_tree().create_timer(0.5).timeout
	fire.queue_free()
	glow_fire.queue_free()
	ray_cast_2d.queue_free()
	light.queue_free()

func set_Recolectado(status):
	atacado = status

func glowingeffect(sprite, origscale, incremento, fact_Max, is_growing):
	var max_scale = origscale * fact_Max
	var min_scale = origscale / fact_Max
	
	if is_growing:
		if sprite.scale.x < max_scale:
			sprite.scale += Vector2(incremento, incremento)
		else:
			is_growing = false
	else:
		if sprite.scale.x > min_scale:
			sprite.scale -= Vector2(incremento, incremento)
		else:
			is_growing = true
	return is_growing
