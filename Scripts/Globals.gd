extends Node

#Constants
const gameStates = {							#The game states possible
	"Title": 1,
	"Init_Game": 10,
	"Init_Aliens": 11,
	"Init_Bases": 12, 
	"Init_Player": 13,
	"Init_SpaceShip": 14, 
	"In_Play":20,
	"Game_Over":50, 
	"Unknown":-1}
const playerStates = {							#The player states possible
	"Alive":1, 
	"Dead":2, 
	"Dying":3}		

#Variables
var Score:int = 0 setget updateScore			#Player Score
var HiScore:int = 0 setget updateHiScore 		#Hi-Score (not retentive from reboot)
var Lives:int  = 0 setget updateLives			#Player lives left
var Level:int = 0 setget updateLevel			#Level of play (just determines starting row of aliens)
var LandedYPos:int = 230						#The level on screen at which aliens have been deemed to have landed
var AlienYShootLimit:int  =200					#The level on screen at which aliens can no longer shoot
var maxLevel = 15								#The highest level at which aliens can be drawn down the screen
var Screen_Size:Vector2 = Vector2()				#Screen size holder
var OSScreen_Size:Vector2 = Vector2()			#OS screen size holder
var CurrentAlien:int							#The alien currently being processed
var LiveAliens:int  = 0							#The number of "alive"/visible aliens
var NoOfAliens:int = 0							#The total number of aliens
var BaseColour = Color8(0,190,0)				#The colour for the bases
var PlayerColour = Color8(0,190,0)				#The colour for the player
var HUD:Node									#A pointer to the HUD
var gameFreeze: bool							#A flag to indicate that the game should be frozen/paused
var gameState = gameStates.Unknown				#The game state (current)
var playerState = playerStates.Dead				#The player state (current)
var BonusPoints:int = 100						#The bonus points for clearing a round of aliens

#Update the level function
func updateLevel(val):							#Update the level value in the HUD
	if !HUD:									#get a reference to the hud if we've not already
		 HUD = get_node("/root/Main/HUD")		#keep the reference
	Level = val									#update the level
	HUD.updateLevel(1,Level)					#call the HUD with the update

#Update the score function
func updateScore(val):							#Update the score value in the HUD
	if !HUD:									#get a reference to the hud if we've not already
		 HUD = get_node("/root/Main/HUD")		#keep the reference
	Score = val									#update the score
	HUD.updateScore(1,Score)					#call the HUD with the update
	if Score > HiScore:							#check if we have a new hi-score
		updateHiScore(Score)					#update the hi-score value

#Update the lives function
func updateLives(val):							#Update the player lives in the hud
	if !HUD:									#get a reference to the hud if we've not already
		 HUD = get_node("/root/Main/HUD")		#keep the reference
	Lives = val									#update the lives count
	HUD.updateLives(1,Lives)					#call the HUD with the update

#Update the hi-score function
func updateHiScore(val):						#Update the hi-score in the hud
	if !HUD:									#get a reference to the hud if we've not already
		 HUD = get_node("/root/Main/HUD")		#keep the reference
	HiScore = val								#update the hi-score
	HUD.updateScore(0,HiScore)					#call the HUD with the update
	
#Choose a random number between low and high values (type: 0 = integer, 1 = float)
func getRand_Range(low,high, type):
	var rng = RandomNumberGenerator.new()		#Initialise a random number generator
	rng.randomize()								#randomize the result
	if type == 0:								#Check if an integer is requested
		return rng.randi_range( low, high)		#return a random integer between the two specified values
	else:
		return rng.randf_range( low, high)		#return a random float between the two specified values
