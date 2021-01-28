extends Node2D

#Signals
signal removeBullet(bullet)		#Signal when the bullet should be removed from the pool

#Variables
var Speed						#The speed of the bullet
var Direction = 1				#The direction of the bullet
var BulletType = 1				#The type of the bullet
var Size = Vector2()			#The size of the bullet sprite

#Initialisation
func _ready():
	Size = $Sprite.get_texture().get_size()		#Set the size of the bullet sprite

#Normal node processing
func _process(delta):
	position.y += (Speed * delta) * Direction	#Update the position of the bullet
	if (position.y < 0 - Size.y and Direction == -1) or (position.y > Globals.Screen_Size.y	+ Size.y and Direction == 1):	#Check if the bullet is off screen
		_removeBullet()							#Remove the bullet

#Set the bullet direction
func _setDirection(dir,spd):
	Direction = dir				#Set the bullet direction
	Speed = spd					#Set the bullet speed

#Remove the bullet from the pool
func _removeBullet():
	emit_signal("removeBullet",self)	#Signal that the bullet should be removed from the pool

