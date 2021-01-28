extends Area2D
#Signals
signal Hit(obj)					#Indicate that this alien has been hit
signal ReqDirChange				#Request a global direction change for the alien group
signal Landed					#Indicate that the aliens have landed

#Preload scenes
var oBullet = preload("res://Scenes/AlienBullet.tscn")	#Preload the bullet scene for this alien to instance

#Variables
var Size = Vector2()									#A place holder for the size of this alien sprite
var OK_To_Shoot											#Indicate this alien is ok to shoot
var ShootDirection = 1									#A direction indicator for the alien bullet (possible changes in direction)
var BulletSpeed = 125									#The bullet speed (when instanced)
var AlienType											#This aliens "type"
var PointValue = 10										#This aliens point value
var XMoveStep = 1										#This aliens x movement increment
var YMoveStep = 8										#This aliens y movement increment
var AnimBase											#This aliens base animation frame
var AlienMinX											#This aliens minimum x position on screen before a direction change
var AlienMaxX											#This aliens maximum x position on screen before a direction change
var Points = [10,20,30]									#The point values for each alien type

#Initialisation
func _ready():
	AlienMinX = Globals.Screen_Size.x * 0.05 			# 5% of screen width	
	AlienMaxX = Globals.Screen_Size.x * 0.95 			# 95% of screen width
	Size = $AnimatedSprite.frames.get_frame("default",0).get_size()	#Get the size of this aliens sprite
	PointValue = Points[AlienType-1]					#allocate this aliens point value
	add_to_group("alien")								#add this alien to the group "alien"

#Set the position of the alien on screen
func SetPosition(pos,type):
	position = pos										#Set the position of the alien
	AlienType = type									#Set the type of the alien
	SetAnim(AlienType)									#set-up the animation frames of the alien based on type

#Move the alien
func Move(dir,drop,noofaliens):
	if noofaliens <=5:									#If the total number of aliens is less than 5 increase the movement rate
		position.x += (XMoveStep * (5-noofaliens)+1)  * dir #move the alien in the current position (speed adjusted)
	else:
		position.x += XMoveStep  * dir					#move the alien in the current direction (normal speed)

	if position.x <= AlienMinX or position.x >= AlienMaxX: 	#Check if the alien has reached a screen limit
		emit_signal("ReqDirChange")							#request the group to change direction
	if drop:												#check if the alien has been requested to drop a row
		position.y += YMoveStep								#move the alien down
		if position.y > Globals.LandedYPos:					#Check if the alien has landed
			emit_signal("Landed")							#indicate to the main function that aliens have landed
	SetAnim(AlienType)										#update the animation frame

#Set the animation frame for the alien
func SetAnim(type):
	AnimBase = $AnimatedSprite.get_frame()					#Get the current animation frame
	if AnimBase & 1:										#check if this is the second frame of animation
		$AnimatedSprite.set_frame((type -1)*2)				#set the animation frame to the first frame for this type of alien
	else:	
		$AnimatedSprite.set_frame(((type -1)*2)+1)			#set the animation frame to the second frame for this type of alien

#Handle the alien being hit
func _on_Alien_area_entered(area):
	if area.is_in_group("playerBullet") and visible:		#If the alien is visible and hit by the players bullet
		emit_signal("Hit",self)								#Indicate this alien has been hit
		area._removeBullet()								#remove the players bullet
		
#Spawn an alien bullet
func spawnBullet(parent,AlienBulletType) -> void:
	var oNewBullet = oBullet.instance()						#Instance a new alien bullet
	oNewBullet.position.x = position.x + 1					#Set the position to that of this alien
	oNewBullet.position.y = position.y - (Size.y/2)			#Set the position to that of this alien
	oNewBullet._setDirection(ShootDirection,BulletSpeed)	#Set the direction and speed of travel for the bullet
	oNewBullet.BulletType = AlienBulletType					#Set the bullet type to an alien bullet
	oNewBullet.connect("removeBullet", parent, "_on_RemoveBullet")	#connect the remove bullet signal
	oNewBullet.add_to_group("alienBullet")					#Add the bullet to the alienBullet group
	parent.add_child(oNewBullet)							#Add the bullet to the parent node of this alien