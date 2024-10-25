extends CharacterBody2D

# Logica Elementos
@onready var anim_tree: AnimationTree
@onready var anim_treeR: AnimationTree = $guerrero_2/AnimationTree
@onready var anim_treeL: AnimationTree = $guerrero_2L/AnimationTree
@onready var spear: RayCast2D = $RayCast2D

# Logica Animaciones
enum {
	IDLE, IDLE_DEF, #IDLES
	RUN, ANIM_UP, ANIM_DOWN, #MOVEMENTS
	}
var current_animation = IDLE
var CROUCHED : bool = false 

#Logica Fisicas
var SPEED : float = 300.0
var JUMP_VELOCITY : float = -400.0

# Logica Ataques
var objeto_Atacado = null

#Logica Vida
var vida : float = 10.0
var ultimo_Ataque_Left = true
enum {
	vivo, moribundo, muerto
}
var current_Live_State = vivo


func _ready() -> void:
	anim_tree = anim_treeR

func _process(_delta):
	Animation_Handler()
	Dead_Handler()



func _physics_process(delta: float) -> void:
	#gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

	#salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and not CROUCHED:
		anim_tree["parameters/JUMP/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		await get_tree().create_timer(0.5).timeout
		velocity.y = JUMP_VELOCITY

	#ataque
	if Input.is_action_just_pressed("atack"):
		if is_on_floor():
			anim_tree["parameters/ATACK/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		else:
			anim_tree["parameters/ATTACK2/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

		if spear.is_colliding():
			objeto_Atacado = spear.get_collider()
			if objeto_Atacado.is_in_group("Atacable"):
				objeto_Atacado.set_Atacado(true)

	#defensa
	if Input.is_action_just_pressed("defend") and not CROUCHED:
		anim_tree["parameters/DEFENSE/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

	#desplazamento
	var direction := Input.get_axis("left", "right")

	# crouch
	if Input.is_action_just_pressed("crouch"):
		anim_tree["parameters/CROUCH/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	if Input.is_action_pressed("crouch"):
		CROUCHED = true
		SPEED = 150
	if Input.is_action_just_released("crouch"):
		CROUCHED = false
		SPEED = 300

	# dash
	if Input.is_action_just_pressed("dash"):
		anim_tree["parameters/DASH/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
	
	if direction != 0 and current_Live_State != muerto:
		velocity.x = direction * SPEED
		if direction < 0:
			anim_tree = anim_treeL
			$guerrero_2L.visible = true
			$guerrero_2.visible = false
			$RayCast2D.target_position.x = -51
		else:
			anim_tree = anim_treeR
			$guerrero_2L.visible = false
			$guerrero_2.visible = true
			$RayCast2D.target_position.x = 51
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	#suelo
	if is_on_floor():
		if velocity.x != 0:
			current_animation = RUN
		else:
			current_animation = IDLE
			if Input.is_action_pressed("defend") and not CROUCHED:
				current_animation = IDLE_DEF
	#aire
	else:
		if velocity.y>0:
			current_animation = ANIM_DOWN
		else:
			current_animation = ANIM_UP
		if direction == 0:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()

func Animation_Handler():
	if current_Live_State == vivo:
		match current_animation:
			IDLE:
				if CROUCHED == false:
					anim_tree["parameters/IDLE_DEF/blend_amount"] = 0
					anim_tree["parameters/CROUCH_IDLE/blend_amount"] = 0
					anim_tree["parameters/RUN/blend_amount"] = 0
					anim_tree["parameters/CROUCH_MOVE/blend_amount"] = 0
					anim_tree["parameters/AIR_UP/blend_amount"] = 0
					anim_tree["parameters/AIR_DOWN/blend_amount"] = 0
				else:
					anim_tree["parameters/IDLE_DEF/blend_amount"] = 0
					anim_tree["parameters/CROUCH_IDLE/blend_amount"] = 1
					anim_tree["parameters/RUN/blend_amount"] = 0
					anim_tree["parameters/CROUCH_MOVE/blend_amount"] = 0
					anim_tree["parameters/AIR_UP/blend_amount"] = 0
					anim_tree["parameters/AIR_DOWN/blend_amount"] = 0
			IDLE_DEF:
				anim_tree["parameters/IDLE_DEF/blend_amount"] = 1
				anim_tree["parameters/CROUCH_IDLE/blend_amount"] = 0
				anim_tree["parameters/RUN/blend_amount"] = 0
				anim_tree["parameters/CROUCH_MOVE/blend_amount"] = 0
				anim_tree["parameters/AIR_UP/blend_amount"] = 0
				anim_tree["parameters/AIR_DOWN/blend_amount"] = 0
			RUN:
				if CROUCHED == false:
					anim_tree["parameters/IDLE_DEF/blend_amount"] = 0
					anim_tree["parameters/CROUCH_IDLE/blend_amount"] = 0
					anim_tree["parameters/RUN/blend_amount"] = 1
					anim_tree["parameters/CROUCH_MOVE/blend_amount"] = 0
					anim_tree["parameters/AIR_UP/blend_amount"] = 0
					anim_tree["parameters/AIR_DOWN/blend_amount"] = 0
				else:
					anim_tree["parameters/IDLE_DEF/blend_amount"] = 0
					anim_tree["parameters/CROUCH_IDLE/blend_amount"] = 0
					anim_tree["parameters/RUN/blend_amount"] = 0
					anim_tree["parameters/CROUCH_MOVE/blend_amount"] = 1
					anim_tree["parameters/AIR_UP/blend_amount"] = 0
					anim_tree["parameters/AIR_DOWN/blend_amount"] = 0
			ANIM_UP:
				anim_tree["parameters/IDLE_DEF/blend_amount"] = 0
				anim_tree["parameters/CROUCH_IDLE/blend_amount"] = 0
				anim_tree["parameters/RUN/blend_amount"] = 0
				anim_tree["parameters/CROUCH_MOVE/blend_amount"] = 0
				anim_tree["parameters/AIR_UP/blend_amount"] = 1
				anim_tree["parameters/AIR_DOWN/blend_amount"] = 0
			ANIM_DOWN:
				anim_tree["parameters/IDLE_DEF/blend_amount"] = 0
				anim_tree["parameters/CROUCH_IDLE/blend_amount"] = 0
				anim_tree["parameters/RUN/blend_amount"] = 0
				anim_tree["parameters/CROUCH_MOVE/blend_amount"] = 0
				anim_tree["parameters/AIR_UP/blend_amount"] = 0
				anim_tree["parameters/AIR_DOWN/blend_amount"] = 1

func Dead_Handler():
	if vida > 5.0:
		current_Live_State = vivo
	elif 0 < vida and vida <= 5.0:
		current_Live_State = moribundo
	elif vida <= 0.0:
		current_Live_State = muerto
		SPEED = 0
		JUMP_VELOCITY = 0
		if ultimo_Ataque_Left:
			anim_tree["parameters/DEAD/blend_amount"] = -1
		else:
			anim_tree["parameters/DEAD/blend_amount"] = 1
