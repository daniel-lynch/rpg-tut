extends KinematicBody2D


var dialoguePopup
enum QuestStatus { NOT_STARTED, STARTED, COMPLETED }
var quest_status = QuestStatus.NOT_STARTED
var dialogue_state = 0
var player
var vel

onready var anim = $AnimatedSprite

func _ready():
	dialoguePopup = get_parent().get_node("CanvasLayer/DialoguePopup") 
	player = get_parent().get_node("Player")
	
func _physics_process (delta):
 
	vel = Vector2()

	if quest_status == QuestStatus.COMPLETED:
		goToTown()

func goToTown ():
	player.canMove = false
	var space_state = get_world_2d().direct_space_state
	var result = space_state.intersect_ray(self.position, (Vector2(0,1) * 70) + self.position, [self])
	if result:
		play_animation("MoveRight")
		move_and_slide(Vector2(1,0) * 200)
	result = space_state.intersect_ray(self.position, (Vector2(-1,1) * 70) + self.position, [self])
	if result:
		play_animation("MoveRight")
		move_and_slide(Vector2(1,0) * 200)
		
	if not result:
		if not self.position.y >= 416:
			vel = (Vector2(self.position.x, 416) - self.position).normalized()
			play_animation("MoveDown")
			move_and_slide(vel * 200)
		if self.position.y >= 416 && not self.position.x >= 1120:
			vel = (Vector2(1120, self.position.y) - self.position).normalized()
			move_and_slide(vel * 200)
			play_animation("MoveRight")
		if self.position.y >= 416 && self.position.x >= 1120:
			player.canMove = true
			queue_free()

func play_animation (anim_name):
 
	if anim.animation != anim_name:
		anim.play(anim_name)

func talk(answer=""):
	print("talk")
	# Set dialoguePopup npc to Blue Guy
	dialoguePopup.npc = self
	dialoguePopup.npc_name = "Blue Guy"

	match quest_status:
		QuestStatus.NOT_STARTED:
			match dialogue_state:
				0:
					dialogue_state = 1
					dialoguePopup.dialogue = "Hello adventurer! I am trying to get to Town but there are Red Guys blocking the path! Could you help me out?"
					dialoguePopup.answers = "[A] Sure. [B] Kill them yourself."
					dialoguePopup.open()
				1:
					match answer:
						"A":
							dialogue_state = 2
							dialoguePopup.dialogue = "Thank you! Please becareful!"
							dialoguePopup.answers = "[A] Bye."
							dialoguePopup.open()
						"B":
							dialogue_state = 3
							dialoguePopup.dialogue = "...I'll be here if you change your mind."
							dialoguePopup.answers = "[A] Bye."
							dialoguePopup.open()
				2:
					dialogue_state = 0
					quest_status = QuestStatus.STARTED					
					dialoguePopup.close()
				3:
					dialogue_state = 0
					dialoguePopup.close()

		QuestStatus.STARTED:
			if not get_tree().get_root().find_node("Enemy*",true,false):

				match dialogue_state:
					0:
						dialoguePopup.dialogue = "Hello adventurer! Thanks for killing those Red Guys! Heres some gold!"
						dialoguePopup.answers = "[A] Get out of here before more come."
						dialoguePopup.open()
						player.give_gold(5)
						player.give_xp(100)
						dialogue_state = 1
					1:
						match answer:
							"A":
								dialoguePopup.dialogue = "Can do!"
								dialoguePopup.answers = "[A] Bye"
								dialoguePopup.open()
								dialogue_state = 2
					2:
						quest_status = QuestStatus.COMPLETED
						dialoguePopup.close()
			else:
				match dialogue_state:
					0:
						dialoguePopup.dialogue = "Adventurer there are still Red Guys Alive!"
						dialoguePopup.answers = "[A] Bye."
						dialoguePopup.open()
						dialogue_state = 1
					1:
						dialogue_state = 0
						dialoguePopup.close()
