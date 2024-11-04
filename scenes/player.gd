extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const NUMBER_OF_JUMPS = 2
var number_of_jumps_left = 2		

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	

	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or number_of_jumps_left > 0):
		velocity.y = JUMP_VELOCITY
		number_of_jumps_left -= 1
		
	if is_on_floor():
		number_of_jumps_left = NUMBER_OF_JUMPS;

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	#TODO: this is naive
	var bgMap = get_node("Level/Map2");
	
	if bgMap != null:
		bgMap.position = -0.1 * position

	move_and_slide()
