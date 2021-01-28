extends Node

#Preload scenes
var obase = preload("res://Scenes/Base.tscn")	#Preload the base scene

#Variables
var Parent = self								#A reference to this node
var numBases = 4								#The total number of bases
var baseXStart = 16								#The starting X position of the first base
var baseYStart = 215							#The starting Y position of the first base
var baseXSpace = 56								#The X spacing of the bases
var basesCreated = false						#Bases created flag

#Create the bases
func createBases():
	for i in range(numBases):										#Loop through all the bases to create
		var oNew_base = obase.instance()							#Instance a base
		oNew_base.name = "Base_" + str(i)							#Name the base
		oNew_base.position.x =  (baseXStart + (i * baseXSpace))		#Set the base X position
		oNew_base.position.y = (baseYStart)							#Set the base Y position
		oNew_base.add_to_group("Bases")										#Add the base to the Bases group
		Parent.add_child(oNew_base)									#Add the base as a child of this node
	basesCreated = true												#Indicate that the bases have been created

#Re-create the bases
func reCreateBases():
	if !basesCreated:							#Check if the bases have not already been created
		for base in self.get_children():		#First loop through any existing bases
			base._destroy()						#destroy the base
		createBases()							#Create new bases

#Destroy all the bases
func DestroyAll():
		for base in self.get_children():		#Loop through all the bases
			base._destroy()						#destroy the base
