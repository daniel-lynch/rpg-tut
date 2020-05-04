extends Navigation2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	print(get_simple_path(PoolVector2Array(Vector2(2,2)), PoolVector2Array(vector2(4,4))))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
