extends Node

#Signals
signal allAliensDestroyed												#Signal when all aliens have been destroyed (new level?)

#Constants
const leftDir: int = 0
const rightDir: int = 1
const AlienTypes = {  "largeAlien":1, "mediumAlien": 2,"smallAlien" : 3}

#Preload scenes
var oAlien = preload("res://Scenes/Alien.tscn")
var oAlienExplosion = preload("res://Scenes/AlienExplosion.tscn")

#Variables
var Parent																#a reference to this node
var FrameUpdateDelay: float = 0.05										#delay between alien<>alien updates
var AlienMoveDelay: float = 0.015										#min delay between alien movements
var CurrentAlienMoveDelay: float = 0.0									#current alien move timer
var CurrentUpdateDelay: float = 0.0										#current "pack" update timer
var CurrentDirection:int												#current movement direction
var CurrentAlien:int													#current alien counter
var Max_Alien_Columns: int = 11										#number of alien columns
var Max_Alien_Rows: int = 5											#number of alien rows
var Alien_Column_Space: int = 15										#space between alien columns (pixels)
var Alien_Row_Space: int = 15											#space between alein rows (pixels)
var AlienArry: Array													#Array to hold alien instances
var AlienAliveArray: Array												#Array to hold alive alien indexes
var sndCnt: int															#Current sound clip counter
var NoOfAliens: int														#Total number of aliens
var AliveAliens: int													#Number of aliens alive (visible)
var sndPlayedThisCycle: bool											#flag to keep track of when the sound has been played per update
var RequestDirChange: bool												#direction change request flag
var MoveInhibit: bool													#movement inhibt flag
var DropRow: bool														#drop row request flag
var AliensInitialised: bool = false										#All aliens have been initialised flag
var MaxAlienBullets: int = 3											#Set the maximum number of alien bullets allowed on screen
var CurrentAlienBullets: int											#Current number of alien bullets
var NextAlienBulletDelay: float											#Next Alien bullet delay time
export var MinAlienBulletDelay: int = 0.7								#Minimum alien bullet delay time
export var MaxAlienBulletDelay: int = 2.8								#Maximum alien bullet delay time
var AlienBulletTypes: Array = [1,2,3]									#Array of alien bullet types in use
var AliensCanShoot: bool = false										#Once an alien reaches a max limit down the screen prevent aliens shooting
var levelOffset: int

#Initialisation
func _ready() -> void:
	CurrentDirection = rightDir											#set the starting direction towards the right
	RequestDirChange = false											#reset the direction change flag
	DropRow = false														#reset the drop a row flag
	MoveInhibit = true													#inhibit alien movement
	AlienArry = []														#Initialise the alien array
	Parent = self														#create a reference to this node as a parent
	
#Normal node processing
func _process(delta) -> void:

	if Globals.gameFreeze or Globals.gameState != Globals.gameStates.In_Play:	#Check if movement should be paused
		$Timer.stop()													#Stop the timer for bullet creation
	else:		
		if !$Timer.time_left > 0:										#Check if the bullet creation timer has elapsed
			$Timer.start(getRand_Range(1,3,1))							#restart a new delay
		CurrentUpdateDelay += delta										#update the current cycle timer
		CurrentAlienMoveDelay += delta									#update the alien/alien move delay timer
		NextAlienBulletDelay += delta									#update the next alien bullet delay timer
		if CurrentAlienMoveDelay >= AlienMoveDelay:						#Check if its time to move the next alien
			if !MoveInhibit:											#Check is movement has been permitted
				if !sndPlayedThisCycle:									#Check if sound has been played on this alien update cycle
					$InvSnd.get_node("InvSnd" + str(sndCnt)).play()		#if not play the current alien sound based on the sound counter
					sndCnt = sndCnt %4									#wrap the sound counter if greater than 4
					sndCnt += 1											#increment the sound counter
					sndPlayedThisCycle = true							#flag that the alien sound has been played this cycle
				moveAliens()											#Call the aliens "move" function
		if CurrentUpdateDelay >= FrameUpdateDelay:						#Check if the current cycle timer has elapsed
			CurrentUpdateDelay = 0										#reset the cycle timer
			MoveInhibit = false											#re-enable alien movements

#Generate the aliens
func Generate_Aliens() -> void:
	var Parent = self													#create a reference to this node as the parent of the aliens
	var Pos = Vector2()													#create a vector to hold the position
	sndCnt = 1															#set the sound count to the 1st clip
	sndPlayedThisCycle = false											#reset the sound played this cycle flag
	CurrentAlien = 0													#set the current alien to the first alien in the array
	MoveInhibit = false													#enable movement cycle
	if Globals.Level < Globals.maxLevel:								#Check what level we are on
		levelOffset = (Globals.Level-1) * (Alien_Row_Space/2)				#If we are on a lower level adjust the alien starting row based on level
	else:
		levelOffset = Globals.maxLevel * (Alien_Row_Space/2)	#If we are above the max starting level use the max starting row
	for rows in range(Max_Alien_Rows,0,-1):								#cycle through all the rows of aliens starting from the bottom
		var AlienType													#variable to hold the current alien type
		match rows:														#match the row numbers to get the correct alien type
			1:
				AlienType = AlienTypes.smallAlien									#Alien type = small alien
			2,3:
				AlienType = AlienTypes.mediumAlien									#Alien type = medium alien
			4,5:
				AlienType = AlienTypes.largeAlien									#Alien type = large alien
		for cols in range(Max_Alien_Columns,0,-1):						#cycle through all the columns of aliens starting from the right
			var oNew_Alien = oAlien.instance()							#create a new alien instance
			oNew_Alien.name = "Alien_" + str(rows) + str(cols)			#set the name of the instance based on the col/row
			oNew_Alien.connect("Hit", self, "_on_AlienHit")				#connect the signals to this instance
			oNew_Alien.connect("ReqDirChange", self, "_on_ReqDirChange")#connect the direction change request to this instance
			oNew_Alien.connect("Landed", get_tree().get_root().get_node("Main"), "_AliensHaveLanded") 	#connect the aliens have landed signal to the main node
			Pos.x = $Alien_Start_Position.position.x + (cols * Alien_Column_Space) 						#calculate the x position for the current alien
			Pos.y = $Alien_Start_Position.position.y + levelOffset + (rows * Alien_Row_Space)			#calculate the y position for the current alien
			oNew_Alien.SetPosition(Pos,AlienType)						#call the set position function in the alien instance and set up its type
			oNew_Alien.visible = true									#set the alien instance visible
			Parent.add_child(oNew_Alien)								#add the alien instance to this node
			AlienArry.append(oNew_Alien)								#add the alien instance into the alien array
			AlienAliveArray.append(AlienArry.size())					#update the alive alien array
	NoOfAliens = AlienArry.size()										#setup the total number of aliens created
	AliveAliens = NoOfAliens											#setup the number of alive aliens
	AliensInitialised = true											#indicate that the aliens have been initilaised

#Move aliens function
func moveAliens() -> void:
	var Alien															#a reference to hold an alien instance node
	if CurrentAlien >= NoOfAliens:										#check if we have processed all aliens
		MoveInhibit = true												#inhibit movement of the aliens until next cycle update
		CurrentAlien = 0												#reset the current alien counter
		DropRow = false													#reset the drop row request
		sndPlayedThisCycle = false										#reset the sound played this cycle flag
		if RequestDirChange:											#check if a direction change has been requested during that last cycle update
			CurrentDirection *= -1										#reverse the direction
			DropRow = true												#request aliens to drop a row on next move
			RequestDirChange = false									#reset the direction change flag
	while CurrentAlien < NoOfAliens and !AlienArry[CurrentAlien].visible:	#cycle through all none visible aliens
		CurrentAlien += 1													#increment the alien counter if not visible
	if CurrentAlien < NoOfAliens:										#check if we are still within the limit of aliens
		Alien = AlienArry[CurrentAlien]									#get a reference to the current alien instance
		Alien.Move(CurrentDirection,DropRow,AliveAliens)				#request the alien to move
		CurrentAlienMoveDelay = 0										#reset the alien<>alien move delay
		CurrentAlien += 1												#increment the current alien counter
	if AliveAliens <= 0:												#check if all the aliens have been destroyed
		emit_signal("allAliensDestroyed")								#indicate all aliens destroyed to reset the level etc.

#Handle an alien being hit	
func _on_AlienHit(Alien) -> void:
	var oNew_AlienExplosion = oAlienExplosion.instance()				#create an alien explosion instance
	oNew_AlienExplosion.position = Alien.position						#set the position of the explosion to that of the alien
	oNew_AlienExplosion.name = Alien.name + "_Explosion"				#set the name of the explosion instance
	Parent.add_child(oNew_AlienExplosion)								#add the explosion instance to this node
	Alien.visible = false												#make the current alien invisible
	Globals.Score += Alien.PointValue									#increment the score
	AliveAliens = AliensAlive()											#update the alive alien count
	
#Handle a direction change request from an alien instance
func _on_ReqDirChange() -> void:
	RequestDirChange = true												#set the direction change flag

#Update the alive alien count
func AliensAlive() -> int: 
	AlienAliveArray = []												#Clear the alien alive array
	AliensCanShoot = true												#indicate that aliens can currently shoot
	if Globals.playerState != Globals.playerStates.Alive:				#Check if the player is alive
		AliensCanShoot = false											#If the player isn't alive aliens can't shoot
	var x = 0															#initialise the alive alien counter
	for i in range(NoOfAliens):											#cycle through all the aliens
		if AlienArry[i].visible:										#check each instance in the array for visibility (alive)
			var alien = AlienArry[i]									#get a reference to he current alien
			AlienAliveArray.append(i)									#add the alien index into the alive array
			x+= 1														#increment the alive alien counter
			if alien.position.y > Globals.AlienYShootLimit:				#Check if the alien is below the Y Shoot limit
				AliensCanShoot = false									#Disable aliens from shooting
	return x															#return the number of alive aliens

#Initialise the aliens / array	
func InitialiseAliens() -> void:
	var currentAlien = 0												#initialise the current alien counter
	var Pos = Vector2()													#create a vector2 to hold position information
	if Globals.Level < Globals.maxLevel:								#Check what level we are on
		levelOffset = (Globals.Level-1) * (Alien_Row_Space/2)				#If we are on a lower level adjust the alien starting row based on level
	else:
		levelOffset = Globals.maxLevel * (Alien_Row_Space/2)				#If we are above the max starting level use the max starting row
	for rows in range(Max_Alien_Rows,0,-1):								#cycle through all the alien rows starting from the bottom
		for cols in range(Max_Alien_Columns,0,-1):						#cycle throuhg all the alien columns starting from the right
			Pos.x = $Alien_Start_Position.position.x + (cols * Alien_Column_Space)					#Calculate the current alien x position
			Pos.y = $Alien_Start_Position.position.y + levelOffset +  (rows * Alien_Row_Space)		#Calculate the current alien y position
			InitialiseAlien(AlienArry[currentAlien],Pos,true)			#initilise the current alien
			currentAlien += 1											#increment the current alien counter
	MoveInhibit = false													#reset the movement inhibit flag
	sndCnt = 1															#re-initialise the sound counter
	AliveAliens = NoOfAliens											#reset the number of alive aliens to the total number of aliens
	AliensInitialised = true											#indicate the aliens have been initialised

#Initialise the specified alien
func InitialiseAlien(Alien,Pos,v) -> void:
	Alien.position = Pos												#set the alien position
	Alien.visible = v													#set the alien visibility
	
#Choose a random number between low and high values (type: 0 = integer, 1 = float)
func getRand_Range(low,high, type):
	var rng = RandomNumberGenerator.new()								#Initialise a random number generator
	rng.randomize()														#randomize the result
	if type == 0:														#Check if an integer is requested
		return rng.randi_range( low, high)								#return a random integer between the two specified values
	else:
		return rng.randf_range( low, high)								#return a random float between the two specified values

#Alien Shoot timer
func _on_Timer_timeout():
	if CurrentAlienBullets < MaxAlienBullets:							#Check if we have capacity to spawn another bullet
		AliensAlive()													#Update the number of alive aliens and if they can shoot
		if AliensCanShoot:												#If aliens can shoot
			var AlienIdx = getRand_Range(0,AlienAliveArray.size()-1,0)	#Get a random live alien index
			var Alien = AlienArry[AlienAliveArray[AlienIdx]]			#Get a reference to the alien
			var AlienBulletIdx = getRand_Range(0, AlienBulletTypes.size()-1,0)	#Get the index of a random bullet type
			var AlienBulletType = AlienBulletTypes[AlienBulletIdx]				#Get the bullet type from the types array
			AlienBulletTypes.remove(AlienBulletIdx)								#Remove the selected type from the range of available types
			Alien.spawnBullet(self,AlienBulletType)								#Request the alien to shoot with the bullet type selected
			CurrentAlienBullets += 1											#Increment the number of alien bullets
	$Timer.start(getRand_Range(MinAlienBulletDelay,MaxAlienBulletDelay,1)) 		#Restart the shoot timer
	

#Remove alien bullet
func _on_RemoveBullet(bullet):
	AlienBulletTypes.append(bullet.BulletType)							#Reinstate the alien bullet type as being available
	CurrentAlienBullets -= 1											#Decrease the number of alien bullets
	clamp(CurrentAlienBullets,0,MaxAlienBullets)						#Make sure the number doesn't go out of range
	bullet.queue_free()													#Destroy the bullet

#Destroy all the aliens	
func DestroyAll() -> void: 
	for i in range(NoOfAliens):											#cycle through all the aliens
		AlienArry[i].visible = false									#check each instance in the array for visibility (alive)

