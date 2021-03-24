extends Area2D

#Signals
signal Hit(obj)				#Signal when the player has been hit

#Constants
const cPlayerBullet = 1		#Player bullet constant

#Preload scenes
var oBullet = preload("res://Scenes/PlayerBullet.tscn")	#Prelaod the player bullet scene

#Variables
var Move_Speed = 100						#Player move speed
var Screen_Size								#Screen size reference
var Player_Size								#Player size reference
var OK_To_Shoot								#Ok to shoot flag
var ShootDirection = -1						#Shoot direction
var BulletSpeed = 250						#Player bullet speed
var PlayerBullets							#Number of player bullets
var PlayerMaxBullets = 1					#Maximum number of player bullets
var pressed = {}							#Keys pressed array
var startPos:Vector2 = Vector2(112,242)		#Player starting position

#Initialisation
func _ready():
	Screen_Size = get_viewport_rect().size			#Get the size of the screen
	Player_Size = $Sprite.get_texture().get_size()	#Get the size of the player sprite
	PlayerBullets = 0								#reset the number of player bullets
	OK_To_Shoot = true								#Allow the player to shoot
	$Shoot_Delay.stop()								#Stop the inter-shot delay timer
	$Sprite.modulate = Globals.PlayerColour			#Set the player colour
	position = startPos								#Set the player position
	
#Normal node processing
func _process(delta):
	if !Globals.gameFreeze:							#Check that the game isn't frozen
		var Velocity = Vector2() 					# The player's movement vector.
		if Input.is_action_pressed("ui_right"):		#Check for move right
			Velocity.x += 1							#Set the velocity for movement to the right
		if Input.is_action_pressed("ui_left"):		#Check for move left
			Velocity.x -= 1							#Set the velocity for movement to the left
		if is_action_just_pressed("ui_select") and (PlayerBullets<PlayerMaxBullets) and OK_To_Shoot: #Check if fire pressed, max bullets not reached and ok to shoot
			OK_To_Shoot = false						#Set not ok to shoot
			_spawnBullet()							#Spawn a new bullet
			$Shoot_Delay.start()					#Start the intershot delay timer
			$Shoot.play()							#Play the shoot sound
		if Velocity.length() > 0:					#Check if the player is moving
			Velocity = Velocity.normalized() * Move_Speed	#Calculate the movement based on speed
		_updatePosition(Velocity * delta)			#Update the player position based on time elapsed

#Update the player position
func _updatePosition(movement):
	position += movement							#Update the position
	position.x = (clamp(position.x, 0 + (Player_Size.x/2), Globals.Screen_Size.x -(Player_Size.x/2))) 	#Clamp the x position to the limits of the screen
	position.y = (clamp(position.y, 0, Globals.Screen_Size.y))											#Clamo the y position to the limits of the screen

#Intershot delay timer
func _on_Shoot_Delay_timeout():
	OK_To_Shoot = true								#Allow the player to shoot once again
	$Shoot_Delay.stop()								#Stop the intershot delay timer

#Spawn a new bullet
func _spawnBullet():
	var Parent = get_parent()						#Get a reference to the parent of this node
	var oNewBullet = oBullet.instance()				#Create a new bullet instance
	oNewBullet.position.x = position.x 				#Set the buller x position to that of the player
	oNewBullet.position.y = position.y - (Player_Size.y/2)	#Set the bullet Y position to that of the player
	oNewBullet._setDirection(ShootDirection,BulletSpeed)	#Set the bullet speed and direction
	oNewBullet.BulletType = cPlayerBullet			#Set the bullet type to that of the player
	oNewBullet.connect("removeBullet", self, "_on_removeBullet")	#Connect the remove bullet signal to this node
	oNewBullet.add_to_group("playerBullet")			#Add the bullet to the play bullet group
	Parent.add_child(oNewBullet)					#Add the bullet as a child of this node's parent
	PlayerBullets += 1								#Increment the number of bullets existing

#Remove bullet function
func _on_removeBullet(bullet):
	if PlayerBullets > 0 and bullet != null: 		#If the number of bullets > 0 and this bullet exists still
		PlayerBullets -= 1							#decrement the number of bullets existing
		bullet.queue_free()							#remove the bulllet

#Handle the player being hit
func _on_Player_area_entered(area):
	if (area.is_in_group("alienBullet") or area.is_in_group("alien")):	#Check if an alien or alien bullet has hit the player
		emit_signal("Hit",self)											#Signal the player has been hit
		for ab in get_tree().get_nodes_in_group("alienBullet"):			#Loop through all alien bullets
			ab._removeBullet()											#Remove the bullet
		get_tree().get_root().get_node("Main/Aliens").AliensCanShoot = false	#Disable the aliens ability to shoot

#This function will check if an action has previously been pressed, if not return true. This prevents continuous firing
func is_action_just_pressed(action):
	if Input.is_action_pressed(action):							#Check if the specific key is pressed
		if not pressed.has(action) or not pressed[action]:		#If the key has not been previously pressed
			pressed[action] = true								#Register the keypress in an array for future checking
			return true											#Return true, this is the first time the key is pressed
	else:
		pressed[action] = false									#The key is no longer pressed, remove the keypress from the array
	return false												#Return false, the key has not been pressed

