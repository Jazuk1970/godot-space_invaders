extends Area2D

#Signals
signal gameOver											#Indicate that game over is requested
signal neighbourHit										#Indicate that we request the neighbour element to receive damage
signal destroyBase										#Indicate that the whole base should be destroyed

#Constants
const upDir = 0											#An up direction constant
const downDir = 1										#A down direction constant

#Variables
var state 												#used for animation of health
var elemType											#used for animation selection, elements 1->3 normal selection, 11-13 flipped
var elemFrames = 3										#the number of animation frames
var anim												#the acutal animation frame (comprises of base state + anim counter)
var flipped												#used to indicate that this sprite is flipped on the y axis (x-mirrored)
var spr : Sprite 										#a pointer the the sprite node

#Element set-up
func _ready():
	spr = $Sprite										#Get a reference to the sprite node
	state = 0 											#set the base to full health (0 = full 0 + (elemFrames - 1) = destroyed)
	if elemType >= 10:									#If the element type is > 10 this is a flipped element
		flipped = true									#set the flipped flag
		anim = (elemType - 10) * elemFrames				#calculate the current animation frame required from the sprite sheet
	else:
		flipped = false									#clear the flipped flag
		anim = elemType * elemFrames 					#calculate the current animation frame required from the sprite sheet
	setAnim(anim+state)									#set the actual animation frame of the sprite
	spr.flip_h = flipped								#if required flip the sprite
	spr.modulate = Globals.BaseColour

#Element has been hit
func _on_baseElement_area_entered(area):
	if area.is_in_group("alien"):						#check if the element has been hit by an alien
		emit_signal("destroyBase")						#request game over
	else:
		area._removeBullet() 							#remove the bullet
		state += 1 										#advance the animation
		if state < elemFrames:							#check if we have reached the end of the animation for the base element
			setAnim(anim+state)							#set the animation state
		else:
			if area.is_in_group("playerBullet"):		#check if a player bullet has hit the base
				emit_signal("neighbourHit",self,upDir)	#request damage of the element above this one
			else:
				emit_signal("neighbourHit",self,downDir)#request damage of the element below this one
			queue_free() 								#remove this base element

#Set the sprite animation frame
func setAnim(anim):
	spr.set_frame(anim)									#Set the animation frame of the sprite

#Destroy this element of the base
func _destroy():
	queue_free()										#Destroy this element

#Handle a request to damage this base from another element
func externalHit():
		state += 1										#Advance the health state
		if state < elemFrames:							#Check if we are at max damage
			setAnim(anim+state)							#set the animation frame
		else:
			queue_free() 								#remove the base element as max damage has been received
	