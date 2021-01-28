extends Node2D

#Initialisation
func _ready():
	$Particles2D.set_emitting(true)	#Enable the partical emitter
	$Explosion.play()				#play the explosion animation

#Normal node processing
func _process(delta):
	if !$Particles2D.emitting and !$Explosion.playing:	#Check if the animation has finished playing
		queue_free()	#remove the explosion