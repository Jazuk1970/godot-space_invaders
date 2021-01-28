# Space Invaders Remake By J. Prew
# Written for my first attempt at either a) a game of any sort, and b) my first go with GODOT
# Project Date: 2020/12/15
# V1.0

extends Node

#Preload scenes
var oExplosion = preload("res://Scenes/PlayerExplosion.tscn")				#Preload the player explosion scene
var oSpaceShip = preload("res://Scenes/SpaceShip.tscn")						#Preload the spaceship scene
var oSpaceShipExplosion = preload("res://Scenes/SpaceShipExplosion.tscn")	#Preload the spaceship explosion scene
var oPlayer = preload("res://Scenes/Player.tscn")							#Preload the player scene

#Variables
var Player: Node						#A reference to the player
var MinSpaceShipDelay: float = 10		#The minimum delay before a new space ship is generated
var MaxSpaceShipDelay: float = 25		#The maximum delay before a new space ship is generated
var SpaceShipYPosition: int = 24		#The Y position of the spaceship when generated

#Initialisation
func _ready():
	Globals.Screen_Size = Vector2(get_viewport().size.x,get_viewport().size.y) 	#Get the screen size
	Globals.OSScreen_Size = OS.get_screen_size()								#Get the OS screen size
	OS.set_window_position(Globals.OSScreen_Size*0.5 - Globals.Screen_Size*0.5)	#Set the window position
	Globals.gameState = Globals.gameStates.Title								#Set the starting game state to show the title
	Globals.HUD = $HUD															#Create a reference to the HUD

#Normal node processing
func _process(delta):
	if Input.is_key_pressed(KEY_ESCAPE):							#Check if the escape key has been pressed
		get_tree().quit()											#If so quit the game
	match Globals.gameState:										#Evaluate the game state
		Globals.gameStates.Title:									#Game state = Title Screen
			$Aliens.DestroyAll()									#Destroy all aliens
			$Bases.DestroyAll()										#Destroy all bases
			Globals.HUD.showTitle(true)								#Show the title page on the HUD
			
			if Input.is_key_pressed(KEY_ENTER):						#Check if the ENTER key has been pressed
				Globals.HUD.showTitle(false)						#Hide the title page on the HUD
				Globals.gameState = Globals.gameStates.Init_Game	#Set the game state to initialise game
				
		Globals.gameStates.Init_Game: 								#Game state = Initialise Game
			_init_game()											#Call initialise function
			Globals.gameState = Globals.gameStates.Init_Bases		#Set the game state to initialise bases
			
		Globals.gameStates.Init_Aliens:								#Game state = Initialise Aliens
			$Aliens.AliensInitialised = false						#Clear the aliens initialised flag
			$Bases.basesCreated = false								#Clear the bases created flag
			$Aliens.InitialiseAliens()								#Initialise the aliens
			$SpaceShipTimer.start(getRand_Range(MinSpaceShipDelay,MaxSpaceShipDelay,1)) #Start the alien spaceship timer 
			Globals.gameState = Globals.gameStates.Init_Bases		#Set the game state to initialise bases

		Globals.gameStates.Init_Bases:								#Game state = Initialise bases
			$Bases.createBases()									#Create the bases
			if !self.has_node("Player"):							#Check if a player doesn't exsit
				Globals.gameState = Globals.gameStates.Init_Player	#Set the game state to initialise player
			else:
				Globals.gameState = Globals.gameStates.Init_SpaceShip	#Set the game state to initialise spaceship
				
		Globals.gameStates.Init_Player:								#Game state = Initialise player
			Player = oPlayer.instance()								#Create a new player instance
			Player.name = "Player"									#Name the player
			Player.connect("Hit", self,"_on_playerHit")				#Connect the play hit signal to this node
			Player.add_to_group("player")							#Add the player to the player group
			self.add_child(Player)									#Add the player to this node
			Globals.HUD.showMessage("Get Ready",2)					#Show a get ready message on the hud
			Globals.playerState = Globals.playerStates.Alive		#Set the players state to alive
			Globals.gameState = Globals.gameStates.Init_SpaceShip	#Set the game state to initilaise spaceship
			
		Globals.gameStates.Init_SpaceShip:							#Game state = Initialise spaceship
			if !Globals.gameFreeze:									#Check if the game isn't frozen
				$SpaceShipTimer.start(getRand_Range(MinSpaceShipDelay,MaxSpaceShipDelay,1)) #Start the alien spaceship timer 
				Globals.gameState = Globals.gameStates.In_Play		#Set the game state to in play

		Globals.gameStates.Game_Over:								#Game state = Game over
			if !Globals.gameFreeze:									#Check if the game isn't frozen
				Globals.gameState = Globals.gameStates.Title		#Set the game state to Title screen

#Initialise game function
func _init_game():
	Globals.Lives = 2							#Set the players lives
	Globals.Level = 1							#Set the starting level
	Globals.Score = 0							#Clear the score
	Globals.HiScore = 10000						#Set a starting hi-score value
	$Aliens.MaxAlienBullets = 3					#Set the starting number of alien bullets
	$Aliens.Generate_Aliens()					#Generate the aliens
	if !$Aliens.get_signal_connection_list("allAliensDestroyed"):	#If the all aliens destroyed is not currently connected
		$Aliens.connect("allAliensDestroyed", self, "_on_allAliensDestroyed")	#Connect the all aliens destroyed signal to this node
	$Aliens.AliensInitialised = false			#Clear the aliens initialised flag
	$Bases.basesCreated = false					#Clear the bases created flag

#Initialise aliens function
func _init_Aliens():
	$Aliens.AliensInitialised = false			#Clear the aliens initialised flag
	$Bases.basesCreated = false					#Clear the bases created flag
	$Aliens.InitialiseAliens()					#Initialise the aliens
	$SpaceShipTimer.start(getRand_Range(MinSpaceShipDelay,MaxSpaceShipDelay,1)) #Start the alien spaceship timer 

#All aliens destroyed function
func _on_allAliensDestroyed():
	if Globals.gameState == Globals.gameStates.In_Play:		#Check that the game is playing
		Globals.Score += Globals.BonusPoints				#Add bonus points for killing a wave of aliens
		Globals.Level += 1									#Increment the level
		$Aliens.MaxAlienBullets = clamp((int(Globals.Level / 5)+3),3,10)	#Add another alien bullet for each 10 levels
		Globals.gameState = Globals.gameStates.Init_Aliens	#Set the game state to initialise aliens
		Globals.HUD.showMessage("Wave Clear, Get Ready!",2)	#Show a get ready message on the hud

#Aliens have landed function
func _AliensHaveLanded():
	if Globals.gameState == Globals.gameStates.In_Play:		#Check that the game is playing
		Globals.HUD.showMessage("Aliens Have Landed, Game Over!",10)	#Show a game over message
		Globals.gameState = Globals.gameStates.Game_Over				#Set the game state to game over
		Globals.playerState = Globals.playerStates.Dead					#Set the player state to dead

#Player has been hit funcion
func _on_playerHit(player):
	if Globals.gameState == Globals.gameStates.In_Play:		#Check that the game is playing
		var playerBullets = get_tree().get_nodes_in_group("playerBullet")	#Get a reference to any player bullets
		for b in playerBullets:								#Loop through the bullets
			b.queue_free()									#Remove the bullet
		var oNew_PlayerExplosion = oExplosion.instance()	#create an explosion instance
		oNew_PlayerExplosion.position = player.position		#set the position of the explosion to that of the player
		oNew_PlayerExplosion.name = player.name + "_Explosion"				#Name the explostion node
		oNew_PlayerExplosion.connect("playerReset",self,"_on_playerReset")	#connect the player reset signal to this node
		self.add_child(oNew_PlayerExplosion)								#add the explosion instance to this node
		player.queue_free()									#remove the player node
		Globals.playerState = Globals.playerStates.Dying	#Set the player state to dying

#Player reset function (called from a player explosion)
func _on_playerReset(explosion):
		if Globals.Lives > 0:									#Check if the player has lives left
			Globals.Lives -=1									#decrement the number of lives left
			Globals.gameState = Globals.gameStates.Init_Player	#Set the game state to initialise player
		else:
			Globals.Lives -=1									#decrement the number of lives left
			Globals.HUD.showMessage("Game Over",10)				#Show a game over message on the hud
			Globals.gameState = Globals.gameStates.Game_Over	#Set the game state to game over
			Globals.playerState = Globals.playerStates.Dead		#Set the player state to dead
				
#Choose a random number between low and high values (type: 0 = integer, 1 = float)
func getRand_Range(low,high, type):
	var rng = RandomNumberGenerator.new()			#Initialise a random number generator
	rng.randomize()									#randomize the result
	if type == 0:									#Check if an integer is requested
		return rng.randi_range( low, high)			#return a random integer between the two specified values
	else:
		return rng.randf_range( low, high)			#return a random float between the two specified values

#Spawn a space ship function
func spawnSpaceShip(dir):
	if $Aliens.AliveAliens > 5:						#Check there are at least 6 aliens alive
		var oNew_SpaceShip = oSpaceShip.instance()	#Create a new spaceship instance
		if dir == -1:								#Check the direction request
			oNew_SpaceShip.position = Vector2(Globals.Screen_Size.x + 16, SpaceShipYPosition)	#Set the starting position of the spaceship off screen to the right
		else:
			oNew_SpaceShip.position = Vector2(0 - 16, SpaceShipYPosition) 						#Set the starting position of the spaceship off screen to the left
		oNew_SpaceShip.Direction = dir				#Set the spaceship direction
		oNew_SpaceShip.name = "SpaceShip"			#Name the spaceship instance
		oNew_SpaceShip.connect("removeShip",self,"_on_SpaceShipRemove")							#Connect remove ship signal to this node
		self.add_child(oNew_SpaceShip)				#Add the spaceship to be child of this node

#Remove spaceship function		
func _on_SpaceShipRemove(ship: Node, bulletObj: Node, hit: bool):
	if hit:									#Check if the ship was hit
		Globals.Score += ship.PointValue	#Increment the score by the spaceship point value
		bulletObj._removeBullet()			#Remove the bullet
		var oNew_SpaceShipExplosion = oSpaceShipExplosion.instance()			#Create an spaceship explosion instance
		oNew_SpaceShipExplosion.position = ship.position						#Set the position of the explosion to that of the spaceship
		oNew_SpaceShipExplosion.name = ship.name + "_Explosion"					#Name the explosion instance
		self.add_child(oNew_SpaceShipExplosion)									#Add the explosion instance to this node
	ship.queue_free()						#Remove the spaceship
	$SpaceShipTimer.start(getRand_Range(MinSpaceShipDelay,MaxSpaceShipDelay,1)) #Start the alien spaceship timer 
	
	#Spaceship timer
func _on_SpaceShipTimer_timeout():
	var rnd = getRand_Range(-1,1,0)		#Get a random number between -1 and 1
	if rnd != 0:						#Check the number is not 0
		spawnSpaceShip(rnd)				#Spawn a new space ship
	else:
		$SpaceShipTimer.start(getRand_Range(MinSpaceShipDelay,MaxSpaceShipDelay,1)) #Start the alien spaceship timer 
