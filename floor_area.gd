extends Area3D

func _ready() -> void:
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_exited(body: Node) -> void:
	# Check if the exited body is a projectile
	if body.is_in_group("Projectile"):
		body.queue_free()
