extends Node2D
#Signals
signal removeBullet(bullet)		#A signal to indicate that this bullet should be removed

#Variables
var Speed = 50					#The current bullet speed
var Speeds = [90,110,135,250]	#The bullet speeds based on bullet type
var Direction = 1				#The current direction of the bullet
var BulletType = 1				#the current bullet type
var BulletTypes = {				#The bullet types
	"alienBulletType1": 0,
	"alienBulletType2": 1,
	"alienBulletType3": 2,
	"playerBullet":3}
var Size = Vector2()			#A place holder for the size of this sprite

#Initialisation
func _ready():
	Size = $Sprite.get_texture().get_size()						#Get the size of this sprite
	Speed = Speeds[BulletType]									#Set the speed based on the bullet type
	$AnimationPlayer.play("alienBulletType" + str(BulletType))	#Set the animation based on the bullet type

#Normal node processing
func _process(delta):
	position.y += (Speed * delta) * Direction					#Update the bullet position
	if (position.y < 0 - Size.y and Direction == -1) or (position.y > Globals.Screen_Size.y	+ Size.y and Direction == 1): #Check if the bullet is out of bounds
		_removeBullet()											#call the remove bullet function

#Set the direction and speed of the bullet
func _setDirection(dir,spd):
	Direction = dir			#Set the direction of the bullet
	Speed = spd				#Set the speed of the bullet

#Remove the bullet
func _removeBullet():
	emit_signal("removeBullet",self)	#Request that this bullet be removed (updates bullet counts etc)

#Handle this bullet hitting an object
func _on_Bullet_area_entered(area):
	if area.is_in_group("playerBullet"):					#check if the bullet has been hit by a players bullet
		match BulletType:
			BulletTypes.alienBulletType1:					#If this is bullet type 1 then the player destroys it
				_removeBullet()
			BulletTypes.alienBulletType2:					#If this is bullet type 2 allow a random chance of being destroyed by the player bullet
				if Globals.getRand_Range(1,10,0) <= 5:				#Check if a random chance between 1 and 10
					_removeBullet()							#remove the alien bullet if the value is less or equal to 5 (50/50)
			BulletTypes.alienBulletType3:					#If this is bullet type 3 allow a random chance of being destroyed by the players bullet
				if Globals.getRand_Range(1,10,0) <= 3:				#Check if a random chance between 1 and 10
					_removeBullet()							#remove the player bullet is the value is less or equal to 3 (70/30)
		area._removeBullet()								#always remvoe the player bullet