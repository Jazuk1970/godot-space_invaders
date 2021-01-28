extends Node2D

#Constants
const baseElementWidth = 8							#the base element width
const baseElementHeight = 8							#the base element height
const baseElementRows = 3							#the number of rows in a base
const baseElementCols = 4							#the number of columns in a base
const upDir = 0										#Up direction constant
const downDir = 1									#down direction constant

#Preload scenes
var obaseElement = preload("res://Scenes/baseElement.tscn")		#Preload the base element scene

#Variables
var baseStructure = [1,0,10,11,10,0,10,0,10,2,12,0]	#This is the base construction by element type
var Parent = self									#A pointer to this node

#Initialisation
func _ready():
	createBase()									#Create a base

#Normal node processing
func _process(delta):
	if get_child_count() == 0:						#Check if all elements are removed
		queue_free()								#Remove the base

#create a base structure of sub elements
func createBase():
	for rows in range(baseElementRows):				#Loop for the number of rows in a base structure
		for cols in range(baseElementCols):			#Loop for the number of columns in a base structure
			var oNew_baseElement = obaseElement.instance()												#Instance a new base element
			oNew_baseElement.name = "BaseElement_" + str(rows).pad_zeros(2) + str(cols).pad_zeros(2)	#Set the element name in the stree based on its position in the base
			oNew_baseElement.position.x =  (cols * baseElementWidth)									#Set the element x position
			oNew_baseElement.position.y = (rows * baseElementHeight)									#Set the element y position
			oNew_baseElement.elemType = baseStructure[(rows* baseElementCols) + cols]					#Set the element type
			oNew_baseElement.connect("neighbourHit", self, "_on_neighbourHit")							#Connect the elements neighbour hit signal to this base
			oNew_baseElement.connect("destroyBase", self, "_destroy")									#Connect the elements destroy base signal to this base
			Parent.add_child(oNew_baseElement)															#Add the element to this base as a child
			add_to_group("Base")																				#Add this base to the group Base

#This function will destroy this base instance and call the destroy function for all elements within it
func _destroy():
	for baseElement in self.get_children():			#Loop though all sub elements of this base
		baseElement._destroy()						#destroy the sub elements
	queue_free()									#destroy this base

#This function will find the vertical neighbour of the calling element and
#call the external hit function within it to advance the animation state.
func _on_neighbourHit(element,dir):
	var rw = int(element.name.substr(12,2))			#Get the row of the element who has been hit
	var nextElement									#A pointer to the next element
	var nen											#The name of the next element
	if rw > 0 and dir == upDir:						#The neigbbour is above 
		nen = "BaseElement_" + str(rw -1).pad_zeros(2) + element.name.substr(14,2) #Calculate the name of the neighbour element
		if has_node(nen):							#Check if the neighbour exists
			nextElement = get_node(nen)				#Get a pointer to the neighbour element
			nextElement.externalHit()				#Indicate that the neighbour should also be hit
	if rw < baseElementRows and dir == downDir:		#The neighbour is below
		nen = "BaseElement_" + str(rw +1).pad_zeros(2) + element.name.substr(14,2) #Calculate the name of the neighbour element
		if has_node(nen):							#Check if the neighbour exists
			nextElement = get_node(nen)				#Get a pointer to the neighbour element
			nextElement.externalHit()				#Indicate that the neighbour should also be hit
