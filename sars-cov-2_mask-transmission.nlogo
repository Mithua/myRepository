;; observer SLIDERS
;; initial-people - initial total population of the world
;; initial-number-masks - inital population of masked people
;; initial-infected-prop - initial number of infected population
;; transmit-prob-mask-mask - transmission probability {partner-agent} from infected to non-infected depending on who wears mask
;; transmit-prob-nomask-mask - transmission probability {partner-agent} from infected to non-infected depending on who wears mask
;; transmit-prob-mask-nomask - transmission probability {partner-agent} from infected to non-infected depending on who wears mask
;; transmit-prob-nomask-nomask - transmission probability {partner-agent} from infected to non-infected depending on who wears mask

globals [
  slider-check-1     ;; Temporary variables for slider values, so that if sliders
  slider-check-2     ;;   are changed on the fly, the model will notice and
                     ;;   change people's tendencies appropriately.
]

breed [ masks mask ]
breed [ nomasks nomask ]

turtles-own [
  infected?          ;; If true, the person is infected.
  close-proximity?   ;; If true, the person is in close proximity (assumed to be <2 mt).
  close-duration     ;; How long the person HAS BEEN in close proximity (hours).
  partner            ;; The person that is to our current partner in close proximity.

  ;; the next 2 values are controlled by SLIDERS
  hours-proximity    ;; How long the person LIKELY to stay in close proximity.
  proximity-tendency ;; How likely the person is to engage in close proximity.
                     ;;   Akin to a lockdown (y/n) scenario if population's proximity-tendency is low/high.
]

;;; SETUP PROCEDURES
;;;
to setup
  clear-all
  setup-globals
  setup-breeds
  reset-ticks
end

to setup-globals
  set slider-check-1 average-hours-proximity
  set slider-check-2 average-proximity-tendency
end

;; Triangle ('mask') and face neutral ('sans mask') breeds
;;   and, some of both are infected.  Also, assign colours to people with the ASSIGN-COLOUR routine.
to setup-breeds
  ;; masked - triangle
  set-default-shape masks "triangle"
  create-masks initial-number-masks
  [
    set size 3
    setxy random-xcor random-ycor
    set partner nobody
    set close-proximity? false
    set infected? (who < initial-number-masks * initial-infected-prop)
    assign-hours-proximity
    assign-proximity-tendency
    assign-colour
  ]

  ;; non-masked - face neutral
  set-default-shape nomasks "face neutral"
  create-nomasks initial-people - initial-number-masks
  [
    set size 2
    setxy random-xcor random-ycor
    set partner nobody
    set close-proximity? false
    set infected? (who < (initial-people - initial-number-masks) * initial-infected-prop)
    assign-hours-proximity
    assign-proximity-tendency
    assign-colour
  ]
end

;; People are displayed in 2 different colours depending on infection status:
;;   green not infected
;;   red infected
to assign-colour ;; turtle procedure
  ifelse infected?
  [ set color red ]
  [ set color green ]
end

to assign-hours-proximity ;; turtle procedure
  set hours-proximity random-near average-hours-proximity
end

to assign-proximity-tendency ;; turtle procedure
  set proximity-tendency random-near average-proximity-tendency
end

to-report random-near [centre] ;; turtle {helper} procedure
  let result 0
  repeat 40
    [ set result (result + random-float centre) ]
  report result / 20
end

;;; GO PROCEDURES
;;;
to go
  if all? turtles [ infected? ] ;; or ticks > 90
  [ stop ]
  check-sliders
  ask turtles
  [ if not close-proximity?
    [ move ] ]
  ask turtles
  [ if not close-proximity? and (random-float 10 < proximity-tendency)
    [ closeup ] ]
  ask turtles
  [ if close-proximity?
    [ set close-duration close-duration + 0.5 ] ]
  ask turtles [ infect ]
  ask turtles [ assign-colour ]
  ask turtles [ unclose ]
  tick
end

;; Each tick a check is made to see if sliders have been changed.
;;   if one has been, the corresponding turtle variable is adjusted
to check-sliders
  if (slider-check-1 != average-hours-proximity)
  [ ask turtles [ assign-hours-proximity ]
    set slider-check-1 average-hours-proximity ]
  if (slider-check-2 != average-proximity-tendency)
  [ ask turtles [ assign-proximity-tendency ]
    set slider-check-2 average-proximity-tendency ]
end

;; People move about at random.
to move ;; turtle procedure
  right random-float 360
  forward 1
end

;; People have a chance to close up depending on their tendency, if they meet.
;; To better show that close-proximity has occurred, the patches below
;;   the close up turns grey.
to closeup ;; turtle procedure
  let tmpPart one-of other turtles-here
  if tmpPart != nobody
  [ set close-proximity? true
    set partner tmpPart
    ask partner [ set close-proximity? true ]
    ask partner [ set partner myself ]
    ;; ask patch-here [ set pcolor gray - 3 ]
  ]
end

;; If two peoples are close for longer than either person's hours-proximity variable
;;   allows, the close up ends.
to unclose ;; turtle procedure
  if close-proximity?
  [ if (close-duration > hours-proximity) or ([ close-duration ] of partner) > ([ hours-proximity ] of partner)
    [ ;; ask patch-here [ set pcolor black ]
      set close-proximity? false
      set close-duration 0
      ask partner [ set close-duration 0 ]
      ask partner [ set partner nobody ]
      ask partner [ set close-proximity? false ]
      set partner nobody
    ]
  ]
end

to infect ;; turtle procedure
  let infectMaskPart one-of other turtles-here with [ close-proximity? and infected? and breed = masks ]
  if infectMaskPart != nobody
  [ set partner infectMaskPart ]
  if close-proximity? and not infected? and breed = masks and random-float 1 < transmit-prob-mask-mask
  [ set infected? true ]

  let infectNoMaskPart one-of other turtles-here with [ close-proximity? and infected? and breed = nomasks ]
  if infectNoMaskPart != nobody
  [ set partner infectNoMaskPart ]
  if close-proximity? and not infected? and breed = masks and random-float 1 < transmit-prob-nomask-mask
  [ set infected? true ]

  let noInfectMaskPart one-of other turtles-here with [ close-proximity? and not infected? and breed = masks ]
  if noInfectMaskPart != nobody
  [ set partner noInfectMaskPart ]
  if close-proximity? and infected? and breed = nomasks and random-float 1 < transmit-prob-mask-nomask
  [ ask partner [set infected? true ] ]

  let noInfectNoMaskPart one-of other turtles-here with [ close-proximity? and not infected? and breed = nomasks ]
  if noInfectNoMaskPart != nobody
  [ set partner noInfectNoMaskPart ]
  if close-proximity? and infected? and breed = nomasks and random-float 1 < transmit-prob-nomask-nomask
  [ ask partner [set infected? true ] ]
end

;;; MONITOR PROCEDURES
;;;
to-report %infected
  ifelse any? turtles
  [ report (count turtles with [ infected? ] / count turtles) * 100 ]
  [ report 0 ]
end
@#$#@#$#@
GRAPHICS-WINDOW
285
11
732
459
-1
-1
5.42
1
10
1
1
1
0
1
1
1
-40
40
-40
40
1
1
1
Ticks
30.0

BUTTON
10
55
93
88
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
104
55
187
88
go
go
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
598
465
732
510
% infected
%infected
2
1
11

SLIDER
9
12
278
45
initial-people
initial-people
50
500
300.0
1
1
NIL
HORIZONTAL

SLIDER
10
99
280
132
average-hours-proximity
average-hours-proximity
0
12
1.0
1
1
hour(s)
HORIZONTAL

PLOT
743
10
1416
248
Incidence of Infections
Ticks
Proportion
0.0
200.0
0.0
1.0
true
true
"" ""
PENS
"Masks+infected" 1.0 0 -13345367 true "" "plot (count masks with [ infected? ]) / initial-people"
"Nomasks+infected" 1.0 0 -2674135 true "" "plot (count nomasks with [ infected? ]) / initial-people"

SLIDER
10
145
280
178
average-proximity-tendency
average-proximity-tendency
0
10
5.0
1
1
NIL
HORIZONTAL

BUTTON
197
55
280
88
go
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
11
234
280
267
transmit-prob-mask-mask
transmit-prob-mask-mask
0
1
0.1
0.1
1
NIL
HORIZONTAL

SLIDER
11
282
280
315
transmit-prob-nomask-mask
transmit-prob-nomask-mask
0
1
0.5
0.1
1
NIL
HORIZONTAL

SLIDER
10
188
280
221
initial-number-masks
initial-number-masks
0
75
50.0
1
1
NIL
HORIZONTAL

SLIDER
11
328
280
361
transmit-prob-mask-nomask
transmit-prob-mask-nomask
0
1
0.2
0.1
1
NIL
HORIZONTAL

SLIDER
12
376
278
409
transmit-prob-nomask-nomask
transmit-prob-nomask-nomask
0
1
0.9
0.1
1
NIL
HORIZONTAL

SLIDER
12
427
278
460
initial-infected-prop
initial-infected-prop
0
1
0.5
0.05
1
NIL
HORIZONTAL

PLOT
744
256
1415
520
Hazard Ratio (Infection Rate Ratio)
Ticks
HR
0.0
200.0
2.0
7.0
true
true
"" ""
PENS
"Nomasks-to-masks" 1.0 0 -6459832 true "" "plot ((count nomasks with [ infected? ]) / initial-people) / ((count masks with [ infected? ]) / initial-people)"

@#$#@#$#@
## WHAT IS IT?

This model simulates the spread of the SARS-CoV-2, via human to human transmission, in a small isolated population.  It illustrates the utility of masks in the population.  It is not intended to measure the recovery rate from Coronavirus, as seen in SIRD / SEIRD models.

As it is understood that COVID-19 is spread from human to human through forceful explusion by coughing of virus-laden aerosols by an infected individual.  The aerosols can directly enter the susceptible individual if within 2 metres of distance from the infected or the aerosols that can keep the virus alive on objects that a susceptile individual may touch and later the virus can enter her/his body through nose, mouth and eyes among the major portals of entry, or through gestures as hugging, handshaking, close proximity, health-care delivery, etc. that can transmit the virus from the infected to the susceptible.  COVID-19 can remain alive for different lengths of time periods on different materials, but this model does not try to highlight this property of the virus.  Neither this model tries to capture the transmission of COVID-19 by indirect method by contact exposure of contaminated surfaces by the susceptible and then entry of virus into the individual.  Rather the goal of this model is to examine the infection rate among susceptible individuals, which will potentially change with time, by the use or not of masks that is putatively thought to influence the spread of the disease in the community and closed-space arenas like hospitals, public transport and places of public gatherings like markets.

The model examines the emergent effects of four scenarios of mask use.  The user controls the the amount of time two (or more) individuals will stay in close proximity as that can influence the spread.

Regular identification of individuals infected by the virus could have significant public health impacts.

## HOW IT WORKS

The model uses "close-up" to represent two people engaged close proximity like hugging, handshaking, health-care delivery, etc.  If an individual stays 1 hour in close proximity, that assumes 1/24 probability of disease transmission to someone theoretically lives 24 hours in close proximity.  In the same way, someone staying 2 hours in close proximity will have 1/12 probability of disease transmission and so on.  This is irrespective of mask use, which is in influencer of the transmission rate among agents.

The presence of the mask in the population is represented by symbols of the agents. Two colours are used to denote if the agent is infect or susceptible: green individuals are uninfected, and red individuals are infected.  In reality, after some time, it happens that infected individuals will be removed from the population at-risk by either death or recovery.  But this model will not explore that feature currently.

## HOW TO USE IT

The SETUP button creates individuals with particular behavioural tendencies according to the values of the interface's sliders (described below).  Once the simulation has been setup, you are now ready to run it, by pushing the GO button.  GO starts the simulation and runs it continuously until GO is pushed again.  During a simulation initiated by GO, adjustments in sliders can affect the behavioral tendencies of the population.

A monitor shows the % of the population that is infected by COVID-19.  In this model, each time-step is considered one day; the number of days that have passed is shown in the toolbar.

Here is a summary of the sliders in the model.  They are explained in more detail below:

- INITIAL-PEOPLE: How many people simulation begins with (100--500).
- AVERAGE-HOURS-PROXIMITY: How many hours proximity typically lasts (0--12).
- AVERAGE-PROXIMITY-TENDENCY: General chance a member of population to use a mask (0--10).

The total number of individuals in the simulation is controlled by the slider INITIAL-PEOPLE (initialised to vary between 100--500), which must be set before SETUP is pushed.

During the model's setup procedures, all individuals are given a RANDOM-NEAR tendency around AVERAGE-PROXIMITY-TENDENCY.  These tendencies are generally assigned in a normal distribution, so that, for instance, if a tendency slider is set at 8, the most common value for that tendency in the population will be 8.  Less frequently, individuals will have values 7 or 9 for that tendency, and even less frequently will individuals have values 6 or 10 (and so on).  Decreasing this to low values like 1 or 2 will result in a condition akin to flattening the curve by a stricter lockdown situation or imposing restrictions on individual movements.  In a complete lockdown scenario, the infections will not increase.

The slider AVERAGE-HOURS-PROXIMITY (0--12) determines how long individuals are likely to stay in close-up situation (hours).  Again, the tendencies of both individuals to stay in a close distance are considered; the proximity duration only lasts as long as is allowed by the tendency of the neighbour with a shorter commitment tendency.

INITIAL-NUMBER-MASKS (0--75) assigns masked individuals at the beginning of the simulation.  It is kept from no use to 1/4th of the default population size of 300 in the current model.

INITIAL-INFECTED-PROP (0--1) is the proportion of initially infected population, which is @33%.

TRANSMIT-PROB-MASK-MASK, TRANSMIT-PROB-NOMASK-MASK, TRANSMIT-PROB-MASK-NOMASK, TRANSMIT-PROB-NOMASK-NOMASK represents the different transmission probabilities (0--1) between the partner and the agent, respectively.

## THINGS TO NOTICE

Set the INITIAL-PEOPLE slider to 300, and AVERAGE-PROXIMITY-TENDENCY to 5.  Push SETUP and then push GO.  These close-ups represent proximity tendency between the two individuals.

Finally, set INITIAL-PEOPLE to 500 to notice that proximities can form on top of each other.  Watch the simulation until you see individuals by themselves, but standing still and with a gray patch behind them indicating proximity.  Underneath one of its neighbours, is the individuals partner.  This apparent bug in the program is necessary because individuals need to be able to couple fairly freely.  If space constraints prohibited coupling, unwanted emergent behaviour would occur with high population densities.

## THINGS TO TRY

Run a number of experiments with the GO button to find out the effects of different variables on the spread of Coronavirus.  Try using good controls in your experiment.  Good controls are when only one variable is changed between trials.  For instance, to find out what effect the average hours of a proximity has, run four experiments with the AVERAGE-PROXIMITY-TENDENCY slider set at 0 the first time, 1 the second time, 2 the third time, and 10 the last.  How much does the prevalence of COVID-19 increase in each case?  Does this match your expectations of flattening the curve aking to a lockdown scenario with low values of this slider?

## EXTENDING THE MODEL

Like all computer simulations of human behaviours, this model has necessarily simplified its subject area substantially.  The model therefore provides numerous opportunities for extension:

The model depicts transmission potential as two people standing next to each other.  This suggests that all proximities have risk of spread, and that lockdown is only practiced in singlehood.  The model could be changed to reflect a more realistic view of what proximities are.  Individuals could be in proximities without spreading.  To show transmission then, a new graphical representation would have to be employed.  Perhaps transmission could be symbolised by having the patches beneath the couple flash briefly to a different colour.

The model does not distinguish between genders.  This is an obvious over-simplification chosen.  However, extending the model by adding genders would make the model more realistic.

The model assumes that individuals who are infected / tested positive do not necessarily use mask.  This portrayal of human behaviour is clearly not entirely realistic, but it does create interesting emergent behaviour that has genuine relevance to certain public health debate.  However, an interesting extension of the model would be to change individuals' reactions to knowledge of Coronavirus tested status.

The model does not assume that mask use is always 100% effective even if both individuals in proximity have mask.  In fact, responsible mask use is actually slightly less than ideal protection from the transmission of Coronavirus, which is thought to be the best using PPE or complete locked down scenario.  A line code is added to the INFECT procedure to check for a slight random chance that a particular episode of mask-use is not effective.

Finally, certain significant changes can easily be made in the model by simply changing the value of certain global variables in the procedure SETUP-GLOBALS.

## NETLOGO FEATURES

Notice that the four procedures that assign the different tendencies generate many small random numbers and add them together.  This produces a normal distribution of tendency values.  A random number between 0 and 100 is as likely to be 1 as it is to be 99.  However, the sum of 20 numbers between 0 and 5 is much more likely to be 50 than it is to be 99.

Notice that the global variables SLIDER-CHECK-1, and so on are assigned with the values of the various sliders so that the model can check the sliders against the variables while the model is running.  Every time-step, a slider's value is checked against a global variable that holds the value of what the slider's value was the time-step before.  If the slider's current value is different than the global variable, NetLogo knows to call procedures that adjust the population's tendencies.  Otherwise, those adjustment procedures are not called.

## REFERENCES AND EXTENSION OF THE SOURCE MODEL

Wilensky, U. (1997).  NetLogo AIDS model.

## COPYRIGHT, LICENSE AND CITATION

Copyright April 2020, Soutrik Banerjee.

It is an extension / adaptation of the NetLogo library original AIDS model by Uri Wilensky.
http://ccl.northwestern.edu/netlogo/models/AIDS.  Centre for Connected Learning and Computer-Based Modelling, Northwestern University, Evanston, USA.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

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
Circle -16777216 true false 30 30 240

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

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

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

person lefty
false
0
Circle -7500403 true true 170 5 80
Polygon -7500403 true true 165 90 180 195 150 285 165 300 195 300 210 225 225 300 255 300 270 285 240 195 255 90
Rectangle -7500403 true true 187 79 232 94
Polygon -7500403 true true 255 90 300 150 285 180 225 105
Polygon -7500403 true true 165 90 120 150 135 180 195 105

person righty
false
0
Circle -7500403 true true 50 5 80
Polygon -7500403 true true 45 90 60 195 30 285 45 300 75 300 90 225 105 300 135 300 150 285 120 195 135 90
Rectangle -7500403 true true 67 79 112 94
Polygon -7500403 true true 135 90 180 150 165 180 105 105
Polygon -7500403 true true 45 90 0 150 15 180 75 105

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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="1" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>count hemen</metric>
    <metric>count hewomen</metric>
    <metric>count homen</metric>
    <metric>count howomen</metric>
    <enumeratedValueSet variable="initial-number-howomen">
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-number-homen">
      <value value="10"/>
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-number-hewomen">
      <value value="50"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="initial-number-hemen">
      <value value="50"/>
      <value value="100"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
