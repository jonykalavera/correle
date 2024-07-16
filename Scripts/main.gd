extends Node2D

var character_start_position: Vector2i
var camera_start_position:  Vector2i
var game_running = false;
var speed: float
var screen_size: Vector2
const START_SPEED: float = 10.0
const MAX_SPEED: int = 25
const SPEED_MODIFIER = 30;
var score = 0
var high_score = score

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_window().size
	character_start_position = $Character.position
	camera_start_position = $Camera2D.position
	new_game()

func new_game():
	score = 0
	speed = START_SPEED
	$Character.position = character_start_position
	$Character.velocity = Vector2i(0, 0)
	$Camera2D.position = camera_start_position
	$Ground.position = Vector2i(0, 0)
	$HUD.get_node("StartLabel").show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_running:
		score = round(($Character.position.x - character_start_position.x) / screen_size.x)
		speed = (START_SPEED + score) * SPEED_MODIFIER
		high_score = max(score, high_score)
		$Character.speed = speed
		show_score()
		$Camera2D.position.x = $Character.position.x + (camera_start_position.x-character_start_position.x) 
		$Soundtrack.start()
		
		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x
		elif $Camera2D.position.x - $Ground.position.x < screen_size.x * 0.5:
			$Ground.position.x -= screen_size.x
	elif Input.is_anything_pressed():
		game_running = true
		$HUD.get_node("StartLabel").hide()
		
func show_score():
	$HUD.get_node("ScoreLabel").text = "Distance: " + str(score)
	$HUD.get_node("HighScoreLabel").text = "High Score: " + str(high_score)
	
