# godot-space_invaders
A space invaders remake in Godot.

This is my first attempt at any game, and also my first attempt at using Godot.
I have attempted to capture the feel of the original invaders including a phased movement system to "emulate" (sort of) the timing of the original in order to move 1 invader at a time.
I have implemented a method for the bases, although wasn't quite sure how to accurately "destruct" a surface when bullets hit it? A work in progress I guess..
A few things are missing:
  Multiplayer - I started to put hooks in for this but decided enough was enough
  Extra lives - Could be easily implemented but where's the challenge getting more lives
 
 I have also introduced a sort of level system where the number of alien bullets increases with the levels.. to be fair i've not checked it too throughly but it seemed to work (or not crash at least).
 
 I'm sure there are many ways to have done this, and I have indeed changed direction a few times within the code..  but i'll see where I can go for the next project :-)
 
 Things I need to get better at (ok.. hold the huge list for now!):
  Having a "Master" scene which loads other scenes for things like the title screen, game screen etc
  Deciding where to put variables and how to link the various scenes together... there's a combination of signals and Global script uses
  UI - I had a fair few problems getting the UI bits in the HUD to actually go where I wanted them, so I need to dig more into the whole Container thing.
  
I'm sure theres many many more.. but this will do for now...

Enjoy the code, rip it apart.. and by all means drop me a message relating to it.. or any improvements/suggestions etc.

Jason.
