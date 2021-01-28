extends Node2D

#Initialisation
func _ready():
	$Particles2D.set_emitting(true)		#Start the particles emitting
	$Explosion.play()					#Play the explostion animation

#Normal node processing
func _process(delta):
	if !$Particles2D.emitting:	#Check if the particles are not emitting
		queue_free()			#remove the explosion