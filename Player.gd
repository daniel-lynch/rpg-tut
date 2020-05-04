extends KinematicBody2D

var canMove : bool = true

var curHp : int = 10
var maxHp : int = 10
var moveSpeed : int = 250
var damage : int = 5
 
var gold : int = 0
 
var curLevel : int = 0
var curXp : int = 0
var xpToNextLevel : int = 50
var xpToLevelIncreaseRate : float = 1.2
 
var interactDist : int = 70
 
var vel = Vector2()
var facingDir = Vector2()

onready var hint = get_parent().get_node("CanvasLayer/InterectHint")
 
onready var rayCast = $RayCast2D
onready var anim = $AnimatedSprite
onready var ui = get_node("/root/MainScene/CanvasLayer/UI")

func _ready ():
 
	ui.update_level_text(curLevel)
	ui.update_health_bar(curHp, maxHp)
	ui.update_xp_bar(curXp, xpToNextLevel)
	ui.update_gold_text(gold)

func _physics_process (delta):
 
	vel = Vector2()
	if canMove:
		# inputs
		if Input.is_action_pressed("move_up"):
			vel.y -= 1
			facingDir = Vector2(0, -1)
		if Input.is_action_pressed("move_down"):
			vel.y += 1
			facingDir = Vector2(0, 1)
		if Input.is_action_pressed("move_left"):
			vel.x -= 1
			facingDir = Vector2(-1, 0)
		if Input.is_action_pressed("move_right"):
			vel.x += 1
			facingDir = Vector2(1, 0)
 
	# normalize the velocity to prevent faster diagonal movement
	vel = vel.normalized()
 
	# move the player
	move_and_slide(vel * moveSpeed, Vector2.ZERO)
	manage_animations()

func manage_animations ():
 
	if vel.x > 0:
		play_animation("MoveRight")
	elif vel.x < 0:
		play_animation("MoveLeft")
	elif vel.y < 0:
		play_animation("MoveUp")
	elif vel.y > 0:
		play_animation("MoveDown")
	elif facingDir.x == 1:
		play_animation("IdleRight")
	elif facingDir.x == -1:
		play_animation("IdleLeft")
	elif facingDir.y == -1:
		play_animation("IdleUp")
	elif facingDir.y == 1:
		play_animation("IdleDown")

func play_animation (anim_name):
 
	if anim.animation != anim_name:
		anim.play(anim_name)

func give_gold (amount):
 
	gold += amount
	ui.update_gold_text(gold)

func give_xp (amount):
 
	curXp += amount
 
	if curXp >= xpToNextLevel:
		level_up()
		
	ui.update_xp_bar(curXp, xpToNextLevel)
 
func level_up ():
 
	var overflowXp = curXp - xpToNextLevel
 
	xpToNextLevel *= xpToLevelIncreaseRate
	curXp = overflowXp
	curLevel += 1
	
	ui.update_level_text(curLevel)
	ui.update_xp_bar(curXp, xpToNextLevel)
	
func take_damage (dmgToTake):
 
	curHp -= dmgToTake
 
	if curHp <= 0:
		die()

	ui.update_health_bar(curHp, maxHp)
 
func die ():
 
	get_tree().reload_current_scene()

func _process (delta):
 
	if Input.is_action_just_pressed("interact"):
		try_interact()
		
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(self.position, (facingDir * interactDist) + self.position, [self])
	if result:
		if result.collider.has_method("on_interact") || result.collider.has_method("talk"):
			if not hint.visible:
				hint.popup()
	else:
		if hint.visible:
			hint.hide()
		#print("Hit: ", result.collider.name)

func try_interact ():
 
	var above = get_parent().get_node("TileMap_Above")

	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(self.position, (facingDir * interactDist) + self.position, [self])
	print(self.name)
	print(above)

	if result:
		print(result.collider)
		if result.collider is KinematicBody2D && result.collider.has_method("take_damage"):
			result.collider.take_damage(damage)
		elif result.collider.has_method("talk"):
			result.collider.talk()
		elif result.collider.has_method("on_interact"):
			result.collider.on_interact(self)
	else:
		print("Not colliding")
