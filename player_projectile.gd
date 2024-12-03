extends RigidBody3D

@export var speed = 10.0
@export var lifetime = 3.0
@export var floor_bounds: Vector3 = Vector3(5.0, 0.0, 5.0)  # Half of 10x10x10 floor size

func _ready() -> void:
	# Create a timer that triggers once after the specified lifetime
	var timer = Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true  # Timer should trigger only once
	timer.timeout.connect(self._on_timeout)  # Corrected signal connection
	add_child(timer)
	timer.start()

	# Set the projectile's initial velocity
	linear_velocity = -transform.basis.z * speed

# This function is called when the timer times out (after 3 seconds)
func _on_timeout() -> void:
	print("Despawn due to timeout")
	queue_free()  # Free the projectile after the lifetime

func _process(delta: float) -> void:
	# Check if the projectile is outside the bounds of the floor (10x10)
	var pos = global_transform.origin
	if abs(pos.x) > floor_bounds.x or abs(pos.z) > floor_bounds.z:
		print("Despawn due to boundary")
		queue_free()  # Remove projectile if it exceeds the floor boundaries
