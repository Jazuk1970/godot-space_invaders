extends Node2D

#Signals
signal playerReset			#Signal when the player should be reset

#Initialisation
func _ready():
	$Particles2D.set_emitting(true)		#Start the particles emitting
	$Explosion.play()					#Play the explostion animation

#Normal node processing
func _process(delta):
	if !$Particles2D.emitting and !$Explosion.playing:	#Check if the particles are not emitting and the animation has stopped
		emit_signal("playerReset",self)					#Signal that the player should now be reset
		queue_free()									#remove the explosion
