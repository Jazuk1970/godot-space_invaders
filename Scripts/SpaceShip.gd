extends Node2D
signal removeShip()

# Declare member variables here. Examples:
var Speed = 50
var Directions = {-1: "TravelLeft",1: "TravelRight"}
var Direction: int
var Size = Vector2()
var PointValue: int

# Called when the node enters the scene tree for the first time.
func _ready():
	Size = $Sprite.get_texture().get_size()
	$AnimationPlayer.play(str(Directions[Direction]))
	PointValue = (getRand_Range(1,10,0)*100)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position.x += (Speed * delta) * Direction
	if (position.x < 0 - Size.x and Direction == -1) or (position.x > Globals.Screen_Size.x	+ Size.y and Direction == 1):
		_removeShip(null,false)

func _setDirection(dir,spd):
	Direction = dir
	Speed = spd

func _removeShip(obj,hit):
	emit_signal("removeShip",self,obj,hit)



#Choose a random number between low and high values (type: 0 = integer, 1 = float)
func getRand_Range(low,high, type):
	var rng = RandomNumberGenerator.new()								#Initialise a random number generator
	rng.randomize()														#randomize the result
	if type == 0:														#Check if an integer is requested
		return rng.randi_range( low, high)								#return a random integer between the two specified values
	else:
		return rng.randf_range( low, high)								#return a random float between the two specified values


func _on_SpaceSHip_area_entered(area):
	if area.is_in_group("playerBullet"):					#check if the element has been hit by an alien
		area._removeBullet()								#always remvoe the player bullet
		_removeShip(area,true)
