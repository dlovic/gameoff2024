extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const NUMBER_OF_JUMPS = 2

var jumping = false
var number_of_jumps_left = 2		

@export var coyote_frames: int = 6

var coyote = false
var last_floor = false

func _ready() -> void:
	$CoyoteTimer.wait_time = coyote_frames / 60.0

func _physics_process(delta: float) -> void:
	last_floor = is_on_floor()
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or number_of_jumps_left > 0 or coyote):
		velocity.y = JUMP_VELOCITY
		number_of_jumps_left -= 1
		jumping = true
		
	if is_on_floor():
		number_of_jumps_left = NUMBER_OF_JUMPS;
		jumping = false

	if !is_on_floor() and last_floor and !jumping:
		coyote = true
		$CoyoteTimer.start()

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


func _on_coyote_timer_timeout() -> void:
	coyote = false
