# Zombie Final Netlogo Project - Intro CS 1 w/ Mr. Konstantinovich

# Features and Directions and Shop Prices

## Directions:

0. Check out our video
1. Click **Setup**
2. Click **Go**
3. Use QWER for different modes, and in shoot mode you must also click 1/2/3/4 for different weapons ( you may need to click outside the black window first )
4. If your mode is **Shoot** or **Walk**, point the crosshair/mouse cursor at where you want to shoot/walk to and click.
5. If your mode is **Blocks** or **Landmines**, point the brick-shaped crosshair at where you want to place a new barrier.
6. Kill zombies and don't get killed.

## Features:

* Check out our video that shows you how to actually play this game
* Shoot bullets to crosshair's position
* Different items in the shop, buy them.
* Exit shop using arrow
* Shooting is random and works when you hold your mouse down

## Shop prices:
Pistol - 30
SMG - 60
Heavy MG - 100
Ammo - (for Pistol / SMG only ) 5 $ for 10
Heavyammo - (for HMG only ) $20 for 50
Mines - 20
Medkit - 25
10 Bricks - 15


# Development Log

## 1/11/16

#### Cesar:
* Added cursor-shaped turtle that follows user's mouse movements
* Added shop window background
* Added house-shaped turtle/stamp that detects mouse clicks on it

#### Datian:
* Added breeds
* Put everything into observer context
* Organized everything into one setup and one go function
* Added monitors/buttons

## 1/12/16
#### Cesar:
* worked on in class

#### Datian:
* worked on in class ( created survivor, created a laser gun )

#### Known bugs:
* Couldn't have different modes (button didn't function)

## 1/13/16

#### Cesar:
* Added basic barrier functions

#### Datian:
* Upon shooting, the projectiles don't get stuck at the edge of the world
* Simplified buttons, fixed modes bug

## 1/14/16

#### Cesar:
* Decreased world size to 41x41
* Barriers can be placed
* When in barrier mode, the crosshair will turn into a barrier turtle
* The barriers can only be placed on individual patches, reason for decreasing world size
* Added randomness to projectile speed

#### Datian:
* Made modes work ( walk / blocks / shoot ) with each other

#### Known Bugs:
* Walking and shooting doesn't work

## 1/15/16

#### Cesar:
* Shop only works if you're near it
* Added a circle-shaped turtle that spawns at the crosshair's location when in walk mode, and shows the destination

#### Datian:
* fixed walking and shooting ( added shootwalk )

#### Known Bugs:
* Pauses for a second when player changes direction when walking
* Shop only opens if you are within the range when clicking on it, meaning player may need to click twice

## 1/17/16

#### Cesar:
* Added primitive zombie functions

#### Datian:
* Implemented zombies + levels

## 1/18/16

#### Cesar:
* Relocated "every" functions inside go functions

#### Datian:
* Health + survivorshealth + damage from zombies and bullets
* Monitors added
* Created gun the heavymachinegun

#### Known Bugs:
* Level / Zombies continuously spawn

## 1/19/16

#### Cesar:
* Shows where player will be moved
* Fixed shop bug where player has to click on shop twice

#### Datian:
* Fixed the level bug
* Ability to place barriers only in radius, but not on top of the user
* Merged our code

## 1/20/16

#### Cesar:
* Relocated "every" commands inside the go function again
* Added weapon functions that call "shoot" and give it rates of fire
* Added pistol and rifle weapons
* Shoot function now has variable "rate", which is used in the "every" function
* Added ability to place landmines, similar to placing barriers
* Added landmine turtle shape

#### Datian:
* Blocks deflect projectiles and zombies eat through blocks
* Shooting while walking or placing bricks while walking makes your speed slower
* Made different mode buttons ( QWER )
* Set default shapes for all
* Included skip button, where you don't have to wait after every round.

#### Known Bugs:
* Many bullets can hit a zombie and deal 0 damage, especially noticeable during low rates of fire
* All bullets will die when one hits a barrier

## 1/21/16

#### Cesar:
* Combined my code with Datian's
* Combined walkerino and walk, shootie and shoot, etc. functions
* Fixed bug where crosshair did not move according to patches in barrier/landmine mode
* Updated landmine turtle shape
* Added ability for landmines to detect zombies in-radius, which then deals damage to surrounding turtles
* Added "defaultCrosshair" function to neat-ify code
* Added more gun types ( lightmachinegun, heavymachinegun )
* Made landmine turtle shape prettier


#### Datian:
* Timed and timetonext
* pen marks disappear each level
* Fixed bug where all projectiles would die if one of them touched barrier
* Fast zombie + speed and # spawned scaled towards level
* Bullets have their own velocity that does not change vs speed cont. changing
* All bullets now do as they function, hitting zombies in a cone bullets dying immediately after
* Created properties for each bullet ( shape, size, target-xcor velocity )
* Velocity makes each bullet a set speed, rather than a random slope every go.
* Added target-xcor and target-ycor so that the bullets don't follow the mouse


#### Known Bugs:
* If landmine detects all turtles, player is not able to place landmines
* When landmines run mineExplode, they die too quickly for an animation or color change to be visible
* If a barrier is placed too close to survivor, the survivor will get pushed away
* Survivor cannot fit in tight spaces between barriers
* Survivor's behavior around barriers is sticky


## 1/22/16

#### Cesar:
* Worked on barrier functions
* Barriers can no longer be placed in the immediate vicinity of any turtles, meaning barriers will not push the survivor anymore
* Landmines can no longer be placed directly next to another landmine
* Edited some numbers in various functions

#### Datian:
* Person is slower after pressing walk, and then shooting ( shooting while walking)
* Blocks are solid, nobody can go through them ( they are commanded back )
* Projectiles die when they reach a block.
* Blocks can be destroyed by zombies ( They essentially eat the block )

## 1/23/16

#### Cesar:
* Fixed bug where projectiles and destinations were showing labels
* Edited numbers in the walkmove function
* Improved shop window background
* Added pistol turtle shape

#### Datian:
* Created machete shape
* Created different zombie modes ( normal, fast, exploding, huge )
* Added machete ( shoots out projectiles at a very fast speed )
* Added video / tutorial of how game works

#### Known Bugs:
* Destinations are still placed in the shop
* Crosshair goes under the weapon turtles in the shop

## 1/24/16

#### Cesar:
* Fixed bug where crosshair goes under the icons in shop
* Edited shop window background to include space for exit arrow
* Fixed bug where exit arrow wouldn't work when it is not the first thing to be clicked on in the shop window
* Added turtle shapes for pistol, smg, hmg, ammo, medkit, pills, landmines, barriers, zombies, and variations of survivors
* Added fading animation for barriers breaking
* Added items to shop window
* Made items clickable/buyable
* Survivor shape will face left/right when it is holding a weapon

#### Datian:
* Oneside/twoside/threeside/fourside, zombies spawn in an entirely different way
* Levels scale after level 9, up to then it is customized for when you start with a
katana and slowly buy items on shop, editing speed of zombies, size and speed of projectiles(basically balancing the game )
* Implemented ammo, modified # zombies killed into $$$$$, made landmines / barriers
monitors work.
* Added code for shop to work, fixed bug where you could only use anything if you had
enough ammo
* Implemented code for buying things in the shop ( you can only buy if you have money )
In addition, you can only buy ammo if you already have the gun, and global variables
such as hmgtrue and pistoltrue to prevent user from buying gun twice
* Guns have to be bought in the shop
* Added projectile functions projtype and timeleft, allows you to change
the range of a gun and projtype allows you to use the same ammo for 2 different guns
* Gameplay tutorial ( To help players grasp a feel of game )
* Reworked features and directions, also added shop prices
* Added caffeine pills ;)
