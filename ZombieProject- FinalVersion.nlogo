globals [ level money lastClick-xcor lastClick-ycor timetonext timed survivorshealth
          shopOpen ammo heavyammo mines blocks medkits useMk
          lastClickShop-xcor lastClickShop-ycor pistolEquipped smgEquipped hmgEquipped
        ]
breed   [ survivors survivor ]
breed   [ projectiles projectile ]
breed   [ crosshairs crosshair ]
breed   [ barriers barrier ]
breed   [ destinations destination ]
breed   [ zombies zombie ]
breed   [ landmines landmine ]

projectiles-own [ target-xcor target-ycor velocity timeleft projtype ]
crosshairs-own  [ gridSetting shopClicking ]
survivors-own   [ target-xcor target-ycor survivorspeed]
zombies-own     [ zhealth ztype zspeed ]
barriers-own    [ bhealth ]



;;; SETUP FUNCTIONS ;;;

to setup
  ca
  reset-ticks

  set-default-shape crosshairs   "x"
  set-default-shape barriers     "tile brick"
  set-default-shape survivors    "person"
  set-default-shape destinations "circle 2"
  set-default-shape zombies      "person"
  set-default-shape landmines    "landmine"
  import-pcolors "grassyterrain.jpg"

  create-ordered-crosshairs 1  ; crosshair turtle
   [
     set color white
     set size 3
     set shopClicking "false"
   ]

  create-survivors 1           ; player turtle
   [
     set size 2
     set survivorshealth 100
     set color ( random 13 * 10 + 15 )
     set survivorspeed .35
   ]

  setupHouse

  set timed false

  set lastClickShop-xcor -20
  set lastClickShop-ycor 20

  set pistolEquipped false
  set smgEquipped false
  set hmgEquipped false
end

to setupHouse
  cro 1                        ; house turtle/stamp
   [
     set shape "house"
     set color brown
     set size 4
     setxy -15 -15
     stamp
     die
   ]
end



;;; GO ;;;

to go
  ifelse health-labels
    [
      ask zombies   [ set label zhealth ]
      ask survivors [ set label survivorshealth ]
    ]
    [
      ask zombies [ set label " " ]
      ask survivors [ set label " " ]
    ]


  ifelse shop? or ( shopOpen = true ) and not any? zombies
    [
      set shopOpen true
      shopWindow
      exitShop
      iconClick
    ]
    [
      ifelse mode = "shoot"
        [ wepType ]
        [
          every 1 / 300
            [
              if mode = "walk"
                [ walkmove ]

              if mode = "blocks"
                [ blockPlace ]

              if mode = "landmines"
                [ minePlace ]
            ]
        ]

      zombiesGo
      surviveHealth
      barrierKeep
      mineDetect
      useMedkit
      survivorShapes
    ]
  tick
end



;;; SHOP FUNCTIONS ;;;

to-report shop?
  report
    (
      ( lastClick-ycor > -17 and lastClick-ycor < -13 ) and
      ( lastClick-xcor > -17 and lastClick-xcor < -13 ) and
      ( count survivors with [ (distancexy -15 -15) < 2 ] > 0 )
    )
end

to shopWindow
  cd
  ask projectiles [ die ]
  ask turtles [ hide-turtle ]
  ask crosshairs [ show-turtle ]
  import-pcolors "metalshelf4.jpg"
  ask patches [ set pcolor ( pcolor - 1 ) ]

  shopExitIcon
  shopPistolIcon    ; row 1
  shopSMGIcon
  shopAmmoIcon1
  shopHMGIcon       ; row 2
  shopAmmoIcon2
  shopLandminesIcon ; row 3
  shopBricksIcon
  shopMedkitIcon

  every 1 / 300
    [
      ask crosshairs
        [
          set shopClicking "true"
          crosshairMove
        ]
    ]

end

to-report shopexit?
  report
    (
      ( lastClick-ycor > -17 and lastClick-ycor < -13 ) and
      ( lastClick-xcor >  -3 and lastClick-xcor <  3 )
    )
end

to exitShop
  if shopexit?
    [
      ask turtles [ show-turtle ]
      ask survivors
        [
          setxy -15 -17
          set target-xcor -15
          set target-ycor -17
        ]
      import-pcolors "grassyterrain.jpg"

      set lastClick-xcor -15
      set lastClick-ycor -17
      set lastClickShop-xcor -20
      set lastClickShop-ycor 20

      ask crosshairs [ set shopClicking "false" ]

      cd
      setupHouse

      set shopOpen false
    ]
end


; BUYING FUNCTIONS

to iconClick
  if (
      ( lastClickShop-ycor > 13 and lastClickShop-ycor < 19 ) and
      ( lastClickShop-xcor > -16 and lastClickShop-xcor < -6 ) and
      ( pistolEquipped = false ) and
      ( money >= 30 )
     )
    [ every 0.3
        [
          set pistolEquipped true
          set money ( money - 30 )
        ]
    ]
  if (
      ( lastClickShop-ycor > 13 and lastClickShop-ycor < 20.5 ) and
      ( lastClickShop-xcor > -3.5 and lastClickShop-xcor < 7 ) and
      ( smgEquipped = false ) and
      ( money >= 60 )
     )
    [ every 0.3
        [
          set smgEquipped true
          set money ( money - 60 )
        ]
    ]
  if (
      ( lastClickShop-ycor > 13 and lastClickShop-ycor < 18 ) and
      ( lastClickShop-xcor > 12 and lastClickShop-xcor <  14 ) and
      ( pistolEquipped = true or smgEquipped = true ) and
      ( money >= 5 )
     )
    [ every 0.3
        [
          set ammo ( ammo + 10 )
          set money ( money - 5 )
        ]
    ]
  if (
      ( lastClickShop-ycor > 2.5 and lastClickShop-ycor < 11.5 ) and
      ( lastClickShop-xcor > -16 and lastClickShop-xcor < 7.5 ) and
      ( hmgEquipped = false ) and
      ( money >= 100 )
     )
    [ every 0.3
        [
          set hmgEquipped true
          set money ( money - 100 )
        ]
    ]
  if (
      ( lastClickShop-ycor > 2.5 and lastClickShop-ycor < 9 ) and
      ( lastClickShop-xcor > 11.5 and lastClickShop-xcor < 14.5 ) and
      ( hmgEquipped = true ) and
      ( money >= 20 )
     )
    [ every 0.3
        [
          set heavyammo ( heavyammo + 50 )
          set money ( money - 20 )
        ]
    ]
  if (
      ( lastClickShop-ycor > -7.5 and lastClickShop-ycor < 1.5 ) and
      ( lastClickShop-xcor > -16.5 and lastClickShop-xcor < -7.5 ) and
      ( money >= 20 )
     )
    [ every 0.3
        [
          set mines ( mines + 1 )
          set money ( money - 20 )
        ]
    ]
  if (
      ( lastClickShop-ycor > -7.5 and lastClickShop-ycor < 1.5 ) and
      ( lastClickShop-xcor > -4.5 and lastClickShop-xcor < 4.5 ) and
      ( money >= 15 )
     )
    [ every 0.3
        [
          set blocks ( blocks + 10 )
          set money ( money - 15 )
        ]
    ]
  if (
      ( lastClickShop-ycor > -7.5 and lastClickShop-ycor < 2 ) and
      ( lastClickShop-xcor > 9 and lastClickShop-xcor < 17 ) and
      ( money >= 25 )
     )
    [ every 0.3
        [
          set medkits ( medkits + 1 )
          set money ( money - 25 )
        ]
    ]

  set lastClickShop-xcor -20
  set lastClickShop-ycor 20
end


; ICONS

to shopExitIcon
  ask patch 0 -15
    [
      sprout 1
        [
          set shape "arrow"
          set size 5.5
          set heading 90
          set color red
          stamp
          die
        ]
    ]
end

to shopPistolIcon
  ask patch -11 16
    [
      sprout 1
        [
          set shape "pistolicon"
          set color 66
          set size 25
          set heading 35
          stamp
          die
        ]
    ]
end

to shopSMGIcon
  ask patch 1 17
    [
      sprout 1
        [
          set shape "smgicon"
          set color 66
          set size 20
          set heading 35
          stamp
          die
        ]
    ]
end

to shopAmmoIcon1
  ask patch 13 16
    [
      sprout 1
        [
          set shape "ammoicon1"
          set color 46
          set size 8
          set heading 0
          stamp
          die
        ]
    ]
end

to shopHMGIcon
  ask patch -5 9
    [
      sprout 1
        [
          set shape "hmgicon"
          set color 66
          set size 24
          set heading 355
          stamp
          die
        ]
    ]
end

to shopAmmoIcon2
  ask patch 13 6
    [
      sprout 1
        [
          set shape "ammoicon2"
          set color 46
          set size 8
          set heading 0
          stamp
          die
        ]
    ]
end

to shopLandminesIcon
  ask patch -12 -3
    [
      sprout 1
        [
          set shape "landmine"
          set color 62
          set size 8
          set heading 234
          stamp
          die
        ]
    ]
end

to shopBricksIcon
  ask patch 0 -3
    [
      sprout 1
        [
          set shape "bricksicon10"
          set color red
          set size 8
          set heading 0
          stamp
          die
        ]
    ]
end

to shopMedkitIcon
  ask patch 13 -3
    [
      sprout 1
        [
          set shape "medkiticon"
          set size 14
          set heading 0
          stamp
          die
        ]
    ]
end



;;; WEAPON FUNCTIONS ;;;

to wepType
  if weapontype = "pistol"
    [ shoot 0.35 ]
  if weapontype = "submachinegun"
    [ shoot 0.15 ]
  if weapontype = "heavymachinegun"
    [ shoot ( 1 / 300 ) ]
  if weapontype = "machete"
  [ shoot .1 ]
end

to shoot [ rate ]
  defaultCrosshair
  if mouse-down?
   [
     every rate
       [
         ask survivors
           [
             if heavyammo > 0 and weapontype = "heavymachinegun" and hmgEquipped = true
             [
             hatch-projectiles 1
               [
                 set size .5
                 set shape "circle"
                 set target-xcor mouse-xcor
                 set target-ycor mouse-ycor
                 set label " "
                 facexy target-xcor target-ycor
                 set velocity 0.5 + ( random 3 * 0.1 )
                 set heavyammo heavyammo - 1
                 set timeleft 100
                 set projtype "heavy"
               ]
             ]
             if ammo > 0 and weapontype = "submachinegun" and smgEquipped = true
             [
               hatch-projectiles 1
               [
                 set size .5
                 set shape "circle"
                 set target-xcor mouse-xcor
                 set target-ycor mouse-ycor
                 set label " "
                 facexy target-xcor target-ycor
                 set velocity .7 + ( random 5 * .05 )
                 set ammo ammo - 1
                 set timeleft 80
                 set projtype "reg"
               ]
             ]
             if ammo > 0 and weapontype = "pistol" and pistolEquipped = true
             [
               hatch-projectiles 1
               [
                 set size .5
                 set shape "circle"
                 set target-xcor mouse-xcor
                 set target-ycor mouse-ycor
                 set label " "
                 facexy target-xcor target-ycor
                 set velocity .7 + ( random 5 * .05 )
                 set ammo ammo - 1
                 set timeleft 80
                 set projtype "reg"
               ]
             ]


             if weapontype = "machete"
             [
               hatch-projectiles 1
               [
                 set size 2
                 set shape "line"
                 set target-xcor mouse-xcor
                 set target-ycor mouse-ycor
                 set label " "
                 facexy target-xcor target-ycor
                 set velocity 1
                 set timeleft 3
                 set projtype "machete"
               ]
           ]
       ]
       ]
   ]
  ask projectiles [ projectileMove ]
  ask crosshairs  [ crosshairMove ]
  ask survivors   [ shootMove ]
end

to projectileMove
  ifelse ( worldEdgeDetect ) or ( any? barriers-here ) or timeleft <= 0
    [ die ]
    [ fd velocity
      set timeleft timeleft - 1 ] ; SET A default speed and base the in-cone around the set speed of projectile
  if any? zombies in-cone 1 90
    [ if projtype = "reg"
      [
      ask zombies in-cone 1 90 [ set zhealth zhealth - 20 ]
      die
      ]
      if projtype = "heavy"
      [
        ask zombies in-cone 1 90 [ set zhealth zhealth - 40 ]
        die
      ]
      if projtype = "machete"
      [ ask zombies in-cone 1 90 [ set zhealth zhealth - 10 ]
        die
      ]
    ]
end

to-report worldEdgeDetect
  report ( xcor > 19  ) or
         ( xcor < -19 ) or
         ( ycor > 19  ) or
         ( ycor < -19 )
end



;;; CROSSHAIR FUNCTIONS ;;;

to crosshairMove
   if mouse-inside?
    [ ifelse gridSetting = "true"
      [ setxy (round mouse-xcor) ( round mouse-ycor) ]
      [ setxy mouse-xcor mouse-ycor ]
    ]
   if mouse-down?
     [
       if shopClicking = "true"
         [
           set lastClickShop-xcor mouse-xcor
           set lastClickShop-ycor mouse-ycor
         ]

       set lastClick-xcor mouse-xcor
       set lastClick-ycor mouse-ycor

     ]
end

to defaultCrosshair
  ask crosshairs
    [
      set gridSetting "false"
      set color white
      set size 3
      set shape "x"
    ]
end



;;; SURVIVOR FUNCTIONS ;;;

to walkMove
  defaultCrosshair

  ask survivors
    [
      ifelse mouse-down?
      [
        set target-xcor mouse-xcor
        set target-ycor mouse-ycor

        ask destinations [ die ]
        hatch-destinations 1
          [
            setxy mouse-xcor mouse-ycor
            set size 1
            set color red
            set label " "
          ]
      ]
      [
        ifelse (
                 not
                   (
                     ( xcor > (target-xcor - 0.18 ) and xcor < (target-xcor + 0.18 ) ) and
                     ( ycor > (target-ycor - 0.18 ) and ycor < (target-ycor + 0.18 ) )
                   )
               )
               and
               ( not ( any? barriers in-radius 1 ) )
         [
           ask destinations [ show-turtle ]
           facexy target-xcor target-ycor
           fd survivorspeed     ; survivor move speed
         ]
         [
           ask destinations [ die ]
         ]
      ]
    ]

  ask projectiles [ projectileMove ]
  ask crosshairs  [ crosshairMove ]
end

to shootMove
    ifelse ( not
            ( ( xcor > (target-xcor - 1 ) and xcor < (target-xcor + 1 ) ) and
              ( ycor > (target-ycor - 1 ) and ycor < (target-ycor + 1 ) )
            )
           )
     [
       facexy target-xcor target-ycor
       fd .1
     ]
     [
       ask destinations [ die ]
     ]
end

to surviveHealth
  every .5
   [
     ask survivors
       [
         if any? zombies-here
           [
             set survivorshealth ( survivorshealth - (20 * count zombies-here ) )
             ask zombies-here with [ ztype = "fast" ] [ bk 3 ]
           ]
         if survivorshealth <= 0 [ die ]
       ]
   ]
end



;;; BARRIER FUNCTIONS ;;;

to blockPlace
 ask destinations [ hide-turtle ]
 ask crosshairs
  [
    barrierCrosshair
    set gridSetting "true"
    if mouse-down? and ( any? survivors in-radius 6 ) and blocks > 0
     [
       setxy mouse-xcor mouse-ycor
       if not ( any? turtles-here with [ breed = barriers or breed = landmines ] or
                any? turtles with [ breed = survivors or breed = zombies ] in-radius 2
              )
        [
          ask patch xcor ycor
           [
             sprout-barriers 1
              [
                set bhealth 40
                set size 1
                set color red
                set blocks blocks - 1
              ]
           ]
        ]
     ]
  ]

 ask projectiles [ projectileMove ]
 ask crosshairs  [ crosshairMove ]
end

to barrierCrosshair
  set shape "tile brick"
  set color red
  set size 1
end

to barrierKeep
  ask barriers
    [
      if any? zombies-here
        [ set bhealth (bhealth - 1 * count zombies-here ) ]
      if bhealth <= 0 [ die ]
      ifelse bhealth = 40
        [ set color red ]
        [
          ifelse bhealth > 30
            [ set color ( red - 1 ) ]
            [
              ifelse bhealth > 20
                [ set color ( red - 2 ) ]
                [ 
                  ifelse bhealth > 10
                    [ set color ( red - 3 ) ]
                    [ set color ( red - 4 ) ]
                ]
            ]
        ]
      
      if any? survivors in-radius 1.5
        [
          ask survivors [ bk .2 ]
        ]
      if any? projectiles-here
        [
          ask projectiles [ die ]
        ]
    ]
end



;;; ZOMBIE FUNCTIONS ;;;

to zombiesGo
  ask zombies
    [
      if any? survivors [ zombieAttack ]
      ifelse heading <= 180
        [ set shape "zombiepersonright" ]
        [ set shape "zombiepersonleft" ]
    ]

  if ( not any? zombies ) and ( timed = false ) and ( level > 0 )
    [
      set timed true
      set timetonext 30
    ]
  if ( level = 0 ) and ( timed = false )
  [
    set timed true
    set timetonext 30
  ]
  if ( timed = true )
    [
      every 1
        [ set timetonext timetonext - 1 ]
    ]

  if ( not any? zombies ) and ( timetonext <= 0 )
    [
      set timed false
      cd
      setuphouse
      spawnZombies
    ]
end

to spawnZombies
  set level ( level + 1 )
  import-pcolors "grassyterrain.jpg"
  setupHouse
  ask survivors
    [
      if survivorshealth < 100
      [ set survivorshealth 100 ]
    ]

  if level = 1
  [ create-zombies 5
    [
      reg-z
      oneside
      set zspeed .15
    ]
  ]
  if level = 2
  [ create-zombies 3
    [
      reg-z
      oneside
      set zspeed .20
    ]
    create-zombies 3
      [
        reg-z
        oneside
        set zspeed .15
      ]
    ]
  if level = 3
  [
    create-zombies 4
    [
      reg-z
      twoside
      set zspeed .2
    ]
    create-zombies 4
    [
      reg-z
      twoside
      set zspeed .15
    ]
  ]
  if level = 4
  [
    create-zombies 8
    [
      reg-z
      threeside
      set zspeed .2
    ]
  ]
  if level >= 5 and level <= 8
   [
     create-zombies 2 * ( level - 2 )
     [
       reg-z
       fourside
       set zspeed .2
     ]
     create-zombies 2
     [
       fast-z
       fourside
       set zspeed .35
     ]
    ]
   if level = 9
   [
     create-zombies 1
     [
       big-z
       setxy max-pxcor ( (random (max-pycor * 2 + 1 )) - max-pycor )
       set zspeed .3
     ]
     create-zombies 1
     [
       big-z
       setxy min-pxcor ((random (max-pycor * 2 + 1 )) - max-pycor)
       set zspeed .3
     ]
   ]
   if level > 9
   [
     create-zombies 8
     [
       fast-z
       fourside
       ifelse .35 + level * .01 < .6
       [ set zspeed .35 + level * .01 ]
       [ set zspeed .6 ]
     ]
     create-zombies level
     [
       reg-z
       fourside
       ifelse level < 15
       [ set zspeed level * .03 ]
       [ set zspeed .45 ]
     ]
     if level > 13
     [ if random 2 = 0
       [ create-zombies 1
         [
           big-z
           fourside
           set zspeed .3
         ]
       ]
     ]
   ]

end

to oneside
  setxy max-pxcor ( (random (max-pycor * 2 + 1 )) - max-pycor )
end

to twoside
  ifelse random 2 = 0
  [ setxy max-pxcor ( (random (max-pycor * 2 + 1 )) - max-pycor ) ]
  [ setxy min-pxcor ( (random (max-pycor * 2 + 1 )) - max-pycor ) ]
end

to threeside
  ifelse random 3 = 0
  [ setxy max-pxcor ( (random (max-pycor * 2  + 1 )) - max-pycor ) ]
  [ ifelse random 2 = 0
    [ setxy min-pxcor ( (random (max-pycor * 2 + 1 ) - max-pycor ) ) ]
    [ setxy (random (max-pycor * 2 + 1 ) - max-pycor ) max-pycor ]
  ]
end

to fourside
  ifelse random 4 = 0
    [ setxy max-pxcor ( (random (max-pycor * 2 + 1 )) - max-pycor ) ]
    [ ifelse random 3 = 0
      [ setxy min-pxcor ( ( random (max-pycor * 2 + 1 ) ) - max-pycor ) ]
      [ ifelse random 2 = 0
        [ setxy ( (random (max-pycor * 2 + 1 )) - max-pycor ) max-pycor ]
        [ setxy ( (random (max-pycor * 2 + 1 )) - max-pycor ) min-pxcor ]
      ]
    ]
end

to reg-z
  set zhealth 100
  set size 2
  set color green
  set ztype "reg"
end

to fast-z
  set zhealth 40
  set size 1
  set color green + 1
  set ztype "fast"
end

to big-z
  set zhealth 2000
  set size 8
  set color green + 2
  set ztype "big"
end

to zombieAttack
  if not any? barriers-here
  [
    face survivor 1
    fd zspeed
    zombieRegister
  ]
end

to zombieRegister
 if any? projectiles-here
 [
    set zhealth zhealth - 20
 ]
 if zhealth <= 0
 [
   set money ( ( money + 2 ) + random 5 )
   die
 ]
end

;;; LANDMINE FUNCTIONS ;;;

to minePlace
  ask destinations [ hide-turtle ]
  ask projectiles  [ projectileMove ]
  ask crosshairs   [ crosshairMove ]

  ask crosshairs
    [
      set shape "landmine"
      set color 62
      set size 1
      set gridSetting "true"

      if mines > 0
        [
          if mouse-down? and ( any? survivors in-radius 6 )
            [
              setxy mouse-xcor mouse-ycor
              if not ( any? turtles-here with [ breed = landmines or breed = barriers] or
                       any? turtles with [ breed = survivors or breed = zombies or breed = landmines ] in-radius 2
                     )
                [
                  ask patch xcor ycor
                    [
                      sprout-landmines 1
                        [
                          set size 1
                          set color 62
                          set heading ( random 360 )
                          set mines ( mines - 1 )
                        ]
                    ]
                ]
            ]
        ]
    ]
end

to useMedkit
  if ( useMk = true ) and ( medkits > 0 )
    [
      set medkits ( medkits - 1 )
      set useMk false
      set survivorshealth ( survivorshealth + 80 )

      if survivorshealth > 100
       [ set survivorshealth 100 ]
    ]
end

to survivorShapes
  ask survivors
    [
      facexy mouse-xcor mouse-ycor

      if mode = "blocks"
        [ set shape "personblock" ]
      if mode = "landmines"
        [ set shape "personmine" ]
      if ( mode = "shoot" ) and ( heading <= 180 )
        [
          if weapontype = "machete"
            [ set shape "personmachete" ]
          if weapontype = "pistol"
            [ set shape "personpistol" ]
          if weapontype = "submachinegun"
            [ set shape "personsmg" ]
          if weapontype = "heavymachinegun"
            [ set shape "personhmg" ]
        ]
      if ( mode = "shoot" ) and ( heading > 180 )
        [
          if weapontype = "machete"
            [ set shape "personmacheteleft" ]
          if weapontype = "pistol"
            [ set shape "personpistolleft" ]
          if weapontype = "submachinegun"
            [ set shape "personsmgleft" ]
          if weapontype = "heavymachinegun"
            [ set shape "personhmgleft" ]
        ]
      if mode = "walk"
       [ set shape "person" ]
    ]
end



;;; LANDMINES ;;;

to mineCrosshair
  set shape "landmine"
  set color 62
  set size 1
  set gridSetting "true"
end

to mineDetect
  ask landmines
    [
      if any? zombies in-radius 1
        [
          mineExplode
        ]
    ]
end

to mineExplode
  set color red
  ask survivors in-radius 2
    [ set survivorshealth ( survivorshealth - 60 ) ]
  ask patches in-radius 2
     [ set pcolor red ]
  ask zombies in-radius 2
    [ set zhealth ( zhealth - 60 ) ]
  die
end
@#$#@#$#@
GRAPHICS-WINDOW
341
10
843
533
20
20
12.0
1
10
1
1
1
0
0
0
1
-20
20
-20
20
1
1
1
ticks
30.0

BUTTON
26
15
81
48
NIL
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
80
15
135
48
go
if any? survivors [ go ]
T
1
T
OBSERVER
NIL
G
NIL
NIL
1

CHOOSER
26
186
136
231
mode
mode
"shoot" "walk" "blocks" "landmines"
3

BUTTON
26
231
81
264
shoot
set mode \"shoot\"
NIL
1
T
OBSERVER
NIL
Q
NIL
NIL
1

BUTTON
81
153
136
186
walk
set mode \"walk\"
NIL
1
T
OBSERVER
NIL
W
NIL
NIL
1

BUTTON
136
153
191
186
blocks
set mode \"blocks\"
NIL
1
T
OBSERVER
NIL
E
NIL
NIL
1

MONITOR
26
53
76
98
level
level
17
1
11

MONITOR
217
53
267
98
$$$$$
money
17
1
11

MONITOR
167
53
217
98
hp
survivorshealth
17
1
11

CHOOSER
26
264
137
309
weapontype
weapontype
"machete" "baseballbat" "pistol" "submachinegun" "heavymachinegun" "shotgun"
0

MONITOR
76
53
167
98
time to next level
timetonext
17
1
11

BUTTON
191
153
246
186
landmines
set mode \"landmines\"
NIL
1
T
OBSERVER
NIL
R
NIL
NIL
1

BUTTON
81
98
136
131
Skip
set timetonext 0\n
NIL
1
T
OBSERVER
NIL
X
NIL
NIL
1

BUTTON
191
231
246
264
SMG
set weapontype \"submachinegun\"\nset mode \"shoot\"
NIL
1
T
OBSERVER
NIL
3
NIL
NIL
1

BUTTON
26
98
81
131
Pause
set timetonext 9999
T
1
T
OBSERVER
NIL
Z
NIL
NIL
1

SWITCH
146
17
236
50
health-labels
health-labels
0
1
-1000

BUTTON
246
231
301
264
HMG
set weapontype \"heavymachinegun\"\nset mode \"shoot\"
NIL
1
T
OBSERVER
NIL
4
NIL
NIL
1

BUTTON
81
231
136
264
Machete
set weapontype \"machete\"\nset mode \"shoot\"
NIL
1
T
OBSERVER
NIL
1
NIL
NIL
1

BUTTON
136
231
191
264
Pistol
set weapontype \"pistol\"\nset mode \"shoot\"
NIL
1
T
OBSERVER
NIL
2
NIL
NIL
1

MONITOR
138
309
247
354
Low-Caliber Ammo
ammo
17
1
11

MONITOR
246
309
301
354
H-C Ammo
heavyammo
17
1
11

MONITOR
191
186
246
231
Landmines
mines
17
1
11

MONITOR
136
186
191
231
Blocks
blocks
17
1
11

MONITOR
246
186
301
231
Medkits
medkits
17
1
11

BUTTON
136
98
191
131
cheat
set survivorshealth 99999\nset money 99999\nset ammo 99999\nset heavyammo 99999\nset mines 99999\nset blocks 99999\nset medkits 99999\nset pistolEquipped true\nset smgEquipped true\nset hmgEquipped true\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
137
264
191
309
Pistol
pistolEquipped
17
1
11

MONITOR
191
264
246
309
SMG
smgEquipped
17
1
11

MONITOR
246
264
301
309
HMG
hmgEquipped
17
1
11

BUTTON
246
153
301
186
Medkit
set useMk true
NIL
1
T
OBSERVER
NIL
T
NIL
NIL
1

TEXTBOX
38
363
211
521
KEYBOARD SHORTCUTS:\n\nQ - Shoot mode\nW - Walk mode\nE - Barrier mode\nR - Landmine mode\nT - Use Medkit\n\nZ - Pause\nX - Skip
11
0.0
1

TEXTBOX
161
391
251
447
1 - Machete\n2 - Pistol\n3 - SMG\n4 - HMG
11
0.0
1

BUTTON
46
562
261
596
Stuyvesant Caffeine Pills ( EAT ME )
ask survivors [ die ]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
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
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

ammoicon1
true
0
Circle -6459832 true false 120 75 60
Rectangle -7500403 true true 120 105 180 240
Rectangle -7500403 true true 120 248 180 257
Polygon -7500403 true true 178 239 176 242 175 245 179 249 158 254 166 217
Polygon -7500403 true true 122 239 124 242 125 245 121 249 142 254 134 217
Rectangle -7500403 true true 134 232 166 252

ammoicon2
true
0
Rectangle -7500403 true true 120 105 180 240
Rectangle -7500403 true true 120 248 180 257
Polygon -7500403 true true 178 239 176 242 175 245 179 249 158 254 166 217
Polygon -7500403 true true 122 239 124 242 125 245 121 249 142 254 134 217
Rectangle -7500403 true true 134 232 166 252
Polygon -6459832 true false 120 105 150 45 180 105
Polygon -6459832 true false 121 105 125 82
Polygon -6459832 true false 180 104 178 89 172 73 161 55 150 45 150 105
Polygon -6459832 true false 120 104 122 89 128 73 139 55 150 45 150 105

arrow
true
0
Polygon -7500403 true true 150 0 60 150 120 150 120 300 180 300 180 150 240 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bricksicon10
false
0
Rectangle -1 true false 0 0 300 300
Rectangle -7500403 true true 15 225 150 285
Rectangle -7500403 true true 165 225 300 285
Rectangle -7500403 true true 75 150 210 210
Rectangle -7500403 true true 0 150 60 210
Rectangle -7500403 true true 225 150 300 210
Rectangle -7500403 true true 165 75 300 135
Rectangle -7500403 true true 15 75 150 135
Rectangle -7500403 true true 0 0 60 60
Rectangle -7500403 true true 225 0 300 60
Rectangle -7500403 true true 75 0 210 60
Polygon -16777216 true false 105 103 85 103 55 222 73 222
Polygon -16777216 true false 56 103 76 103 106 222 88 222
Rectangle -16777216 true false 139 63 161 221
Polygon -16777216 true false 139 63 134 70 126 72 126 78 145 80
Rectangle -16777216 true false 185 63 207 221
Rectangle -16777216 true false 197 63 265 86
Rectangle -16777216 true false 198 198 266 221
Rectangle -16777216 true false 244 63 266 221

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -1 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

eyeball
false
0
Circle -1 true false 22 20 248
Circle -7500403 true true 83 81 122
Circle -16777216 true false 122 120 44

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

hmgicon
true
0
Rectangle -7500403 true true 90 135 195 165
Rectangle -7500403 true true 30 140 105 155
Rectangle -7500403 true true 28 138 78 158
Polygon -7500403 true true 18 138 18 165 19 178 22 193 29 198 32 189 37 180 48 173 65 164 73 153 64 138
Polygon -7500403 true true 105 165 93 214 112 217 132 149
Polygon -7500403 true true 92 165 99 168 102 173 102 181 92 197 88 206 88 212 102 215 121 159
Polygon -7500403 true true 121 182 143 183 151 181 159 163 155 162 149 175 147 179 141 179 120 179
Rectangle -7500403 true true 149 165 193 182
Polygon -7500403 true true 120 165 120 180 135 180 120 180 120 150
Polygon -7500403 true true 127 164 126 174 129 181 119 181
Polygon -7500403 true true 136 163 131 161 131 175 134 179 136 178 134 173 136 162
Polygon -7500403 true true 156 179 158 200 163 223 166 230 198 224 192 204 189 170
Polygon -7500403 true true 144 163 151 172 164 157
Rectangle -7500403 true true 196 140 295 150
Polygon -7500403 true true 193 165 208 161 223 151 191 142
Rectangle -7500403 true true 202 140 254 165
Polygon -7500403 true true 194 136 212 141
Polygon -7500403 true true 193 135 209 139 189 150
Rectangle -7500403 true true 240 160 254 210
Polygon -7500403 true true 263 162 256 167 250 179 245 159
Polygon -7500403 true true 218 165 237 169 243 181 248 161
Polygon -7500403 true true 240 178 236 203 237 208 241 210
Polygon -7500403 true true 252 178 256 203 255 208 251 210
Polygon -7500403 true true 94 137 98 128 101 128 120 135
Polygon -7500403 true true 187 137 185 129 174 130 166 143
Polygon -7500403 true true 255 168 267 159 272 147 248 141
Polygon -7500403 true true 234 136 265 135 272 143 268 143 263 138 241 137
Polygon -7500403 true true 195 136 245 136 250 142 239 138 195 138
Polygon -7500403 true true 219 137 224 145 229 146 224 137
Line -16777216 false 28 187 28 157
Line -16777216 false 28 157 64 157
Line -16777216 false 259 143 259 154
Line -16777216 false 249 143 249 154
Line -16777216 false 239 143 239 154
Line -16777216 false 228 143 228 154
Line -16777216 false 217 143 217 154
Line -16777216 false 157 182 192 182
Line -16777216 false 107 144 178 144
Line -16777216 false 163 191 169 222
Line -16777216 false 172 191 178 220
Line -16777216 false 182 191 187 218
Line -16777216 false 152 165 156 161
Line -16777216 false 156 161 189 161
Circle -16777216 true false 154 175 4
Line -16777216 false 102 186 116 190
Line -16777216 false 203 159 265 160
Line -16777216 false 90 139 90 155
Line -16777216 false 75 140 25 140
Line -16777216 false 245 184 248 184
Line -16777216 false 244 179 248 179

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

landmine
true
0
Circle -7500403 true true 0 0 300
Rectangle -16777216 true false 15 135 285 165
Rectangle -16777216 true false 135 15 165 285
Rectangle -16777216 true false 30 120 270 150
Rectangle -16777216 true false 150 30 180 270
Rectangle -16777216 true false 30 150 270 180
Rectangle -16777216 true false 120 30 150 270
Circle -16777216 true false 90 90 120
Circle -2674135 true false 103 103 92
Circle -16777216 true false 0 120 60
Circle -16777216 true false 240 120 60
Circle -16777216 true false 120 240 60
Circle -16777216 true false 120 0 60
Circle -16777216 false false 30 30 240

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Rectangle -7500403 true true 150 285 165 285
Rectangle -7500403 true true 135 60 165 255

line half
true
0
Line -7500403 true 150 0 150 150

medkiticon
true
0
Circle -2674135 true false 75 60 30
Circle -2674135 true false 195 60 30
Circle -2674135 true false 195 210 30
Circle -2674135 true false 75 210 30
Rectangle -2674135 true false 75 75 225 225
Polygon -16777216 true false 86 61 97 53 110 48 147 45 177 46 199 53 216 62 199 62 189 57 171 50 118 52 95 63
Polygon -2674135 true false 122 78 140 97
Rectangle -1 true false 105 113 194 210
Rectangle -2674135 true false 138 125 161 200
Rectangle -2674135 true false 112 150 187 173
Rectangle -16777216 true false 90 96 210 105
Rectangle -16777216 true false 201 75 210 225
Rectangle -16777216 true false 89 75 98 225
Polygon -16777216 true false 77 116 66 125 60 141 59 169 67 185 78 191 79 182 72 180 67 167 67 151 68 134 77 123
Rectangle -2674135 true false 90 225 210 240
Rectangle -2674135 true false 90 60 210 75
Rectangle -2674135 true false 75 90 90 225
Rectangle -2674135 true false 90 60 210 75

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

personblock
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105
Rectangle -2674135 true false 210 135 270 195

personhmg
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 120 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 180 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 180 90 240 150 225 180 165 105
Polygon -7500403 true true 120 90 225 165 210 195 135 105
Polygon -16777216 true false 210 120 285 120 285 135 270 135 255 135 225 150 210 165 195 180 195 120

personhmgleft
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 120 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 180 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 120 90 60 150 75 180 135 105
Polygon -7500403 true true 180 90 75 165 90 195 165 105
Polygon -16777216 true false 90 120 15 120 15 135 30 135 45 135 75 150 90 165 105 180 105 120

personmachete
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105
Polygon -7500403 true true 225 150 236 131 244 137 235 151
Polygon -7500403 true true 230 131 245 146 249 140 238 129
Polygon -7500403 true true 239 134 281 70 284 74 285 80 284 87 280 101 268 113 257 124 244 137

personmacheteleft
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105
Polygon -7500403 true true 75 150 64 131 56 137 65 151
Polygon -7500403 true true 70 131 55 146 51 140 62 129
Polygon -7500403 true true 61 134 19 70 16 74 15 80 16 87 20 101 32 113 43 124 56 137

personmine
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105
Circle -10899396 true false 41 131 67

personpistol
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 120 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 180 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 180 90 240 150 225 180 165 105
Polygon -7500403 true true 120 90 225 165 210 195 135 105
Polygon -16777216 true false 210 180 225 150 270 150 270 165 240 165 225 180

personpistolleft
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 120 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 180 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 120 90 60 150 75 180 135 105
Polygon -7500403 true true 180 90 75 165 90 195 165 105
Polygon -16777216 true false 90 180 75 150 30 150 30 165 60 165 75 180

personsmg
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 120 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 180 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 180 90 240 150 225 180 165 105
Polygon -7500403 true true 120 90 225 165 210 195 135 105
Polygon -16777216 true false 210 135 285 135 285 150 270 150 255 165 240 165 225 180 210 180 210 135

personsmgleft
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 120 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 180 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 120 90 60 150 75 180 135 105
Polygon -7500403 true true 180 90 75 165 90 195 165 105
Polygon -16777216 true false 90 135 15 135 15 150 30 150 45 165 60 165 75 180 90 180 90 135

pillsicon
true
0
Circle -7500403 true true 180 240 30
Rectangle -7500403 true true 105 240 195 270
Circle -7500403 true true 90 240 30
Rectangle -7500403 true true 105 90 195 120
Rectangle -7500403 true true 105 75 195 105
Circle -7500403 true true 90 90 30
Circle -7500403 true true 180 90 30
Rectangle -1 true false 90 107 210 255
Rectangle -955883 true false 105 60 195 75
Polygon -955883 true false 107 60 102 61 96 63 96 67 96 70 101 75 108 75
Polygon -955883 true false 193 60 198 61 204 63 204 67 204 70 199 75 192 75
Line -16777216 false 105 75 195 75
Line -16777216 false 90 107 210 107
Line -16777216 false 90 255 210 255
Polygon -16777216 true false 124 121 117 122 115 125 117 129 121 134 119 140 112 140 112 144 119 144 123 141 125 134 121 129 120 125 123 125 127 123
Polygon -16777216 true false 131 122 131 125 137 126 137 142 140 142 141 127 145 127 145 122
Polygon -16777216 true false 151 123 151 139 155 142 162 143 164 140 166 125 162 125 162 133 160 138 156 136 154 126
Polygon -16777216 true false 171 123 173 123 176 130 182 123 188 125 179 133 177 144 175 144 175 135
Polygon -16777216 true false 106 157 96 158 95 167 97 175 105 175 108 173 102 172 98 167 100 162 106 160
Polygon -16777216 true false 111 175 114 166 116 158 120 159 125 175 120 175 118 167 116 174 111 174
Polygon -16777216 true false 126 157 126 174 129 175 130 168 136 168 136 165 129 164 130 162 136 162 136 158
Polygon -16777216 true false 140 158 138 175 142 175 144 169 149 170 149 166 145 165 146 160 151 160 151 158
Polygon -16777216 true false 152 158 150 175 159 175 159 172 155 172 156 169 160 169 161 165 157 165 157 162 161 162 161 159
Polygon -16777216 true false 164 159 163 175 167 175 169 160
Polygon -16777216 true false 173 159 178 160 183 169 183 159 188 159 186 180 177 167 175 177 172 177
Polygon -16777216 true false 193 159 191 176 200 176 200 173 196 173 197 170 201 170 202 166 198 166 198 163 202 163 202 160
Polygon -16777216 true false 96 188 95 234 100 233 101 213 115 211 119 206 120 199 121 193 115 188 100 187 96 188
Polygon -1 true false 102 195 102 203 109 204 114 197
Polygon -16777216 true false 121 188 121 192 130 194 128 228 119 227 120 233 141 233 141 228 135 228 135 195 144 195 144 188
Polygon -16777216 true false 147 188 144 233 162 234 162 229 152 228 154 190
Polygon -16777216 true false 164 188 161 233 179 234 179 229 169 228 171 190
Polygon -16777216 true false 207 196 201 192 186 190 184 198 190 207 197 214 197 221 193 228 183 229 183 236 197 233 206 225 204 210 194 203 195 199 206 200

pistolicon
true
0
Rectangle -7500403 true true 123 135 200 150
Polygon -7500403 true true 194 135 211 135 208 150 202 156 150 157 152 145
Polygon -7500403 true true 173 157 125 157 107 157 103 155 105 151 110 149 116 145 122 135
Polygon -7500403 true true 130 154 121 202
Polygon -7500403 true true 112 156 120 160 121 164 120 173 119 182 118 189 116 197 116 202 138 202 141 181 146 153
Polygon -7500403 true true 161 155 159 163 155 167 147 169 139 170 139 174 153 171 161 166 164 154
Polygon -7500403 true true 123 143 114 138 111 141 117 147
Polygon -7500403 true true 150 150 150 165 150 150
Polygon -7500403 true true 135 150 138 155 146 167
Polygon -7500403 true true 143 154 147 166 151 165 150 152
Rectangle -7500403 true true 200 133 204 146
Rectangle -7500403 true true 127 133 131 146
Line -16777216 false 129 137 126 143
Line -16777216 false 134 137 131 143
Line -16777216 false 139 137 136 143
Line -16777216 false 207 148 115 148
Polygon -7500403 true true 121 163 119 174 116 181 114 191 113 198 118 202

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

smgicon
true
0
Rectangle -7500403 true true 105 131 214 165
Rectangle -7500403 true true 130 135 160 225
Polygon -7500403 true true 120 165 135 180
Polygon -7500403 true true 112 164 122 167 126 170 129 177 128 197 127 221 135 224 144 149
Polygon -7500403 true true 130 186 127 221 129 220 146 161
Polygon -7500403 true true 159 181 167 182 179 180 185 174 189 160 186 160 185 167 182 174 175 178 168 179 157 178
Polygon -7500403 true true 163 164 164 169 165 173 166 178 169 176 168 170 168 158
Polygon -7500403 true true 213 138 241 139 239 150 215 150
Rectangle -7500403 true true 132 204 158 228
Polygon -7500403 true true 140 134 137 125 136 123 122 121 100 120 95 123 95 136 96 154 98 172 102 173 100 158 99 138 99 127 104 123 133 125 137 134
Polygon -7500403 true true 112 138 102 137 98 142 98 158 102 157 102 145 109 140
Polygon -7500403 true true 99 158 94 163 93 168 95 170 100 172
Circle -7500403 true true 199 131 34
Rectangle -7500403 true true 217 131 232 146
Polygon -7500403 true true 130 186 124 203 123 213 125 220 131 221
Polygon -7500403 true true 124 218 133 223 138 211
Line -16777216 false 119 132 137 149
Line -16777216 false 137 149 224 149
Polygon -7500403 true true 228 132 225 124 220 124 219 132
Polygon -7500403 true true 203 133 197 129 190 130 184 134
Polygon -7500403 true true 108 132 112 130 116 133
Polygon -7500403 true true 108 134 111 127 116 134
Line -16777216 false 143 136 215 136
Line -16777216 false 143 142 215 142
Line -16777216 false 132 226 158 226

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tile brick
false
0
Rectangle -1 true false 0 0 300 300
Rectangle -7500403 true true 15 225 150 285
Rectangle -7500403 true true 165 225 300 285
Rectangle -7500403 true true 75 150 210 210
Rectangle -7500403 true true 0 150 60 210
Rectangle -7500403 true true 225 150 300 210
Rectangle -7500403 true true 165 75 300 135
Rectangle -7500403 true true 15 75 150 135
Rectangle -7500403 true true 0 0 60 60
Rectangle -7500403 true true 225 0 300 60
Rectangle -7500403 true true 75 0 210 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 120 165 120 135 30 135 30 165
Polygon -7500403 true true 135 30 165 30 165 120 135 120
Polygon -7500403 true true 270 165 270 135 180 135 180 165
Polygon -7500403 true true 135 180 165 180 165 270 135 270

zombiepersonleft
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 120 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 180 90
Rectangle -7500403 true true 135 75 165 94
Polygon -7500403 true true 120 90 45 120 60 135 135 105
Polygon -7500403 true true 180 90 75 135 90 150 180 120
Circle -7500403 true true 162 90 28
Circle -7500403 true true 111 90 24
Circle -16777216 false false 129 34 10
Circle -16777216 false false 153 34 10
Circle -16777216 true false 128 34 11
Circle -16777216 true false 152 34 11
Rectangle -7500403 true true 45 121 51 125
Rectangle -7500403 true true 48 123 55 129
Rectangle -7500403 true true 53 129 59 133
Rectangle -7500403 true true 75 136 81 140
Rectangle -7500403 true true 79 140 85 144
Rectangle -7500403 true true 83 144 89 148

zombiepersonright
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 180 90 180 195 210 285 195 300 165 300 150 225 135 300 105 300 90 285 120 195 120 90
Rectangle -7500403 true true 135 75 165 94
Polygon -7500403 true true 180 90 255 120 240 135 165 105
Polygon -7500403 true true 120 90 225 135 210 150 120 120
Circle -7500403 true true 110 90 28
Circle -7500403 true true 165 90 24
Circle -16777216 false false 161 34 10
Circle -16777216 false false 137 34 10
Circle -16777216 true false 161 34 11
Circle -16777216 true false 137 34 11
Rectangle -7500403 true true 249 121 255 125
Rectangle -7500403 true true 245 123 252 129
Rectangle -7500403 true true 241 129 247 133
Rectangle -7500403 true true 219 136 225 140
Rectangle -7500403 true true 215 140 221 144
Rectangle -7500403 true true 211 144 217 148

@#$#@#$#@
NetLogo 5.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180

@#$#@#$#@
0
@#$#@#$#@
