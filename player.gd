extends CharacterBody3D

# Movement variables
@export var movement_speed:float = 5.0
@export var rotation_speed:float = 2.0
@export var gravity:float = 9.8
@export var jump_force:float = 5.0
@export var player_projectile_speed:float = 10.0

# Jump variables
var jump_count: int = 0

# Projectile firing variables
@export var fire_point: Vector3 = Vector3(0, 1.5, -1)  # Position offset for spawning projectiles
@export var projectile_scene: PackedScene = preload("res://player_projectile.tscn")
@export var fire_rate: float = 1.0  # Interval (seconds) between firing projectiles

# Timer node for firing projectiles
@onready var fire_timer: Timer = Timer.new()

func _ready():
	# Set up the Timer node for firing projectiles
	fire_timer.wait_time = fire_rate
	fire_timer.one_shot = false
	fire_timer.autostart = true
	fire_timer.start()
	add_child(fire_timer)
	fire_timer.connect("timeout", Callable(self, "_fire_projectile"))

func _physics_process(delta: float) -> void:
	handle_movement(delta)

func handle_movement(delta: float) -> void:
	# Movement logic
	var direction: Vector3 = Vector3.ZERO
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("move_back"):
		direction += transform.basis.z
	if Input.is_action_pressed("strafe_left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("strafe_right"):
		direction += transform.basis.x

	if direction != Vector3.ZERO:
		direction = direction.normalized() * movement_speed

	velocity.x = direction.x
	velocity.z = direction.z
	move_and_slide()

	# Rotation logic
	if Input.is_action_pressed("turn_left"):
		rotate_y(-rotation_speed * delta)
	if Input.is_action_pressed("turn_right"):
		rotate_y(rotation_speed * delta)
		
	# Jumping
	if is_on_floor():
		velocity.y = 0.0
		jump_count = 0
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_force
			jump_count = 1
	else:
		velocity.y -= gravity * delta
		if Input.is_action_just_pressed("jump") and jump_count == 1:
			velocity.y = jump_force
			jump_count = 2

# Function to fire a projectile
func _fire_projectile():
	print("Firing projectile")
	var projectile = projectile_scene.instantiate() as RigidBody3D
	projectile.global_transform.origin = global_transform.origin + global_transform.basis * fire_point
	projectile.global_transform = global_transform
	var forward_direction = -global_transform.basis.z
	projectile.linear_velocity = forward_direction * player_projectile_speed
	projectile.linear_damp = 0  # Disable drag to keep speed constant
	projectile.gravity_scale = 0  # Disable gravity on the projectile
	get_parent().add_child(projectile)
	
	# Add a timer to the projectile to despawn it after 3 seconds
	var timer = Timer.new()
	timer.wait_time = 3.0  # 3 seconds
	timer.one_shot = true  # The timer should trigger only once
	timer.timeout.connect(Callable(projectile, "queue_free"))  # When the timer times out, the projectile will despawn
	projectile.add_child(timer)
	timer.start()
