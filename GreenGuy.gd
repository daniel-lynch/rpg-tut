extends KinematicBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var direction
var vel
onready var anim = $AnimatedSprite

# Called when the node enters the scene tree for the first time.
func _ready():
	print(self.position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process (delta):

	if self.position <= Vector2(472,32):
		direction = "right"

	if self.position >= Vector2(744,32):
		direction = "left"

	if direction == "right" && self.position < Vector2(744,32):
		vel = (Vector2(744,32) - self.position).normalized()
		move_and_slide(vel * 150)
	if direction == "left" && self.position > Vector2(472,32):
		vel = (Vector2(472,32) - self.position).normalized()
		move_and_slide(vel * 150)

	manage_animations()

func manage_animations ():
 
	if vel.x > 0:
		play_animation("MoveRight")
	elif vel.x < 0:
		play_animation("MoveLeft")

func play_animation (anim_name):
 
	if anim.animation != anim_name:
		anim.play(anim_name)
