extends CharacterBody2D
@onready var anim_tree: AnimationTree = $guerrera3/AnimationTree
#@onready var #anim_tree2: AnimationTree = $guerrera3_left/AnimationTree
@onready var sprite: Sprite2D = $guerrera3
@onready var sprite2: Sprite2D = $guerrera3_left
const SPEED = 300.0
const JUMP_VELOCITY = -400.0


@onready var spear: RayCast2D = $RayCast2D
var objeto_Atacado = null


func _physics_process(delta: float) -> void:
	#gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

	#salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		anim_tree["parameters/JUMPING/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		#anim_tree2["parameters/JUMPING/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		await get_tree().create_timer(0.5).timeout
		velocity.y = JUMP_VELOCITY

	#ataque
	if Input.is_action_just_pressed("atack"):
		anim_tree["parameters/ATACKING/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		#anim_tree2["parameters/ATACKING/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		if spear.is_colliding():
			objeto_Atacado = spear.get_collider()
			if objeto_Atacado.is_in_group("Atacable"):
				objeto_Atacado.set_Atacado(true)
	#defensa
	if Input.is_action_just_pressed("defend"):
		anim_tree["parameters/DEFENDING/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		#anim_tree2["parameters/DEFENDING/request"] = AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE

	#desplazamento
	var direction := Input.get_axis("left", "right")
	
	if direction != 0:
		velocity.x = direction * SPEED
		if direction < 0:
			$guerrera3_left.visible = true
			$guerrera3.visible = false
			$RayCast2D.target_position.x = -51
		else:
			$guerrera3_left.visible = false
			$guerrera3.visible = true
			$RayCast2D.target_position.x = 51
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	#suelo
	if is_on_floor():
		anim_tree["parameters/AIR_UP/blend_amount"] = 0
		#anim_tree2["parameters/AIR_UP/blend_amount"] = 0
		anim_tree["parameters/AIR_DOWN/blend_amount"] = 0
		#anim_tree2["parameters/AIR_DOWN/blend_amount"] = 0
		anim_tree["parameters/IDLE_DEF/blend_amount"] = 0
		#anim_tree2["parameters/IDLE_DEF/blend_amount"] = 0
		anim_tree["parameters/RUNING/blend_amount"] = 0
		#anim_tree2["parameters/RUNING/blend_amount"] = 0
		if velocity.x != 0:
			anim_tree["parameters/RUNING/blend_amount"] = 1
			#anim_tree2["parameters/RUNING/blend_amount"] = 1
		else:
			anim_tree["parameters/RUNING/blend_amount"] = 0
			#anim_tree2["parameters/RUNING/blend_amount"] = 0
			if Input.is_action_pressed("defend"):
				anim_tree["parameters/IDLE_DEF/blend_amount"] = 1
				#anim_tree2["parameters/IDLE_DEF/blend_amount"] = 1
			else:
				anim_tree["parameters/IDLE_DEF/blend_amount"] = 0
				#anim_tree2["parameters/IDLE_DEF/blend_amount"] = 0
	#aire
	else:
		anim_tree["parameters/IDLE_DEF/blend_amount"] = 0
		#anim_tree2["parameters/IDLE_DEF/blend_amount"] = 0
		anim_tree["parameters/RUNING/blend_amount"] = 0
		#anim_tree2["parameters/RUNING/blend_amount"] = 0
		if velocity.y>0:
			anim_tree["parameters/AIR_UP/blend_amount"] = 0
			#anim_tree2["parameters/AIR_UP/blend_amount"] = 0
			anim_tree["parameters/AIR_DOWN/blend_amount"] = 1
			#anim_tree2["parameters/AIR_DOWN/blend_amount"] = 1
		else:
			anim_tree["parameters/AIR_UP/blend_amount"] = 1
			#anim_tree2["parameters/AIR_UP/blend_amount"] = 1
			anim_tree["parameters/AIR_DOWN/blend_amount"] = 0
			#anim_tree2["parameters/AIR_DOWN/blend_amount"] = 0
		if direction == 0:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()
