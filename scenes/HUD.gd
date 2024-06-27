extends Node

@export var timer : float = 0

var useTimer : bool = false

@onready var preGameCountDownLabel = $PreGame/CountDown

@onready var inGameTimerLabel = $InGame/Timer
@onready var ability1Label = $InGame/Ability1Sprite/Title
@onready var ability2Label = $InGame/Ability2Sprite/Title
@onready var abilityBar = $InGame/AbilityBar

var ability1Cooldown : float = 0
var ability2Cooldown : float = 0

var progress : float = 0
var currentCooldown : float = 0

var abilitiesAvailable : bool = true

var loaded_players = 0

var sound_played = false


@rpc("authority", "call_local", "reliable")
func loaded():
	loaded_players += 1

var countdown = 5

@rpc("authority", "call_local", "reliable")
func start_game():
	var player = Network.get_player_node_by_id(str(multiplayer.get_unique_id())) 
	if str(player.name) == str(multiplayer.get_unique_id()):
		player.alive = true

func _process(delta):
	if not multiplayer.is_server(): 
		return
	if not useTimer and multiplayer.get_peers().size() == loaded_players:
		await get_tree().create_timer(2.0).timeout
		loaded_players = 0
		return
	elif not useTimer:
		if not sound_played:
			Audiocontroller.play_countdown_sfx()
			sound_played = true
		countdown -= delta
		preGameCountDownLabel.text = "0%s" % [int(ceil(countdown))]
		if countdown <= 0:
			useTimer = true
			$PreGame.visible = false
			$InGame.visible = true
			start_game.rpc()
		return
			
	if useTimer:
		timer += delta
		var seconds = int(floor(timer))
		var minutes = floor(seconds / 60)
		seconds = seconds % 60
		seconds = "0%s" % [seconds] if seconds < 10 else str(seconds)
		inGameTimerLabel.text = "%s.%s" % [minutes, seconds] if minutes > 0 else str(seconds)
		
		
	if not abilitiesAvailable:
		progress += delta
		abilityBar.value = progress / currentCooldown * 100
		if progress >= currentCooldown:
			abilityBar.value = 100
			progress = 0
			abilitiesAvailable = true
	
func useAbility(ability : int):
	if not abilitiesAvailable or Network.in_terminal:
		return 
	currentCooldown = ability1Cooldown if ability == 1 else ability2Cooldown
	abilitiesAvailable = false
	abilityBar.value = 0

func set_ability_info(title1 : String, title2 : String, cooldown1 : float, cooldown2 : float):
	ability1Label.text = title1
	ability2Label.text = title2
	ability1Cooldown = cooldown1
	ability2Cooldown = cooldown2
