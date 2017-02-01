; sliders : initial-number-homen, initial-number-howomen, initial-number-hemen, initial-number-hewomen: meant for initial population size for each of the 4 breeds
; sliders : intial-homan, intial-howoman, initial-heman, intial-hewoman: meant for initial HIV prevalence percent in each of the 4 breeds
; sliders : transprob_HoMen, transprob_HoWomen, transprob_HeMen, transprob_HeWomen: meant for the transmission probabilities ["betas"] for each of the 4 breeds
; sliders : average-commitment: meant for on average how long (in weeks) the couples will stay together
; sliders : average-coupling-tendency: meant for on average how likely the person will form a couple

globals
[
  slider-check-1   ; Temporary variables for slider values, so that if sliders
  slider-check-2   ;   are changed on the fly, the model will notice and
                   ;   change people's tendencies appropriately.
]

; create 4 different breeds
breed [ hemen heman ]     ; Heterosexual men
breed [ homen homan ]     ; Homosexual men
breed [ hewomen hewoman ] ; Heterosexual women
breed [ howomen howoman ] ; Homosexual women

turtles-own
[
  infected?         ; If true, the person is infected
  coupled?          ; If true, the person is in a sexually active couple
  couple-length     ; How long (in weeks) the person has been in a couple
  coupling-tendency ; How likely the person will form a couple
  commitment        ; How long (in weeks) the person will stay in a couple-relationship
  partner           ; The person that is our current partner in a couple
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;                    ;;;;;
;;;;;  SETUP PROCEDURES  ;;;;;
;;;;;                    ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all
  setup-breeds
  reset-ticks
end

to setup-breeds
; heterosexual men - white open square
  set-default-shape hemen "square 2"
  create-hemen initial-number-hemen
  [
    set color white
    set size 0.5
    setxy random-xcor random-ycor
    set infected? (random-float 100 < initial-heman)
    set partner nobody
    set coupled? false
  ]

; homosexual men - yellow solid square
  set-default-shape homen "square"
  create-homen initial-number-homen
  [
    set color yellow
    set size 0.5
    setxy random-xcor random-ycor
    set infected? (random-float 100 < initial-homan)
    set partner nobody
    set coupled? false
  ]

; heterosexual women - white open circle
  set-default-shape hewomen "circle 2"
  create-hewomen initial-number-hewomen
  [
    set color white
    set size 0.5
    setxy random-xcor random-ycor
    set infected? (random-float 100 < initial-hewoman)
    set partner nobody
    set coupled? false
  ]

; homosexual women - yellow solid circle
  set-default-shape howomen "circle"
  create-howomen initial-number-howomen
  [
    set color yellow
    set size 0.5
    setxy random-xcor random-ycor
    set infected? (random-float 100 < initial-howoman)
    set partner nobody
    set coupled? false
  ]

ask turtles
[
  assign-commitment
  assign-color
  assign-coupling-tendency
]
end

to assign-color ; turtle procedure
  if infected?
    [ set color red ]
end

; The following four procedures assign core turtle variables.  They use
;  the helper procedure RANDOM-NEAR so that the turtle variables have an
;  approximately Normal distribution around the average values set by
;  the sliders

to assign-commitment ; turtle procedure
  set commitment random-near average-commitment
end

to assign-coupling-tendency ; turtle procedure
  set coupling-tendency random-near average-coupling-tendency
end

to-report random-near [ center ] ; turtle procedure
  let result 0
  repeat 40
    [ set result (result + random-float center) ]
  report result / 20
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;                 ;;;;;
;;;;;  GO PROCEDURES  ;;;;;
;;;;;                 ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

to go
  check-sliders
  ask turtles
     [ if coupled?
        [ set couple-length couple-length + 1 ] ]
  ask turtles
    [ if not coupled?
        [ move ] ]
  ask turtles
    [ if not coupled? and (random-float 10.0 < coupling-tendency)
        [ couple ] ]
  ask turtles [ uncouple ]
  ask turtles [ infect ]
  ask turtles [ assign-color ]
  if (%infected = 100)
    [ stop ]
  tick
end

; Each tick a check is made to see if sliders have been changed.
; If one has been, the corresponding turtle variable is adjusted.
to check-sliders
  if (slider-check-1 != average-commitment)
    [ ask turtles [ assign-commitment ]
      set slider-check-1 average-commitment ]
  if (slider-check-2 != average-coupling-tendency)
    [ ask turtles [ assign-coupling-tendency ]
      set slider-check-2 average-coupling-tendency ]
end

; People move about at random
to move ; turtle procedure
  rt random-float 360
  fd 1
end

; People have a chance to couple depending on their tendency to have sex and
;  if they meet.  To better show that coupling has occurred, the patches below
;  the couple turn grey (heterosexual) or green (homosexual), respectively.
to couple ; turtle procedure
  let mybreed breed

  if (mybreed = hemen)
  [ let femalePart one-of other turtles-here with [(coupled? = false) and (breed = hewomen) ]
    if femalePart != nobody
    [ set coupled? true
      set partner femalePart
      ask partner [ set coupled? true ]
      ask partner [ set partner myself ]
      ask patch-here [ set pcolor gray - 3 ]
    ]
  ]

  if (mybreed = hewomen)
  [ let malePart one-of other turtles-here with [(coupled? = false) and (breed = hemen) ]
    if malePart != nobody
    [ set coupled? true
      set partner malePart
      ask partner [ set coupled? true ]
      ask partner [ set partner myself ]
      ask patch-here [ set pcolor gray - 3 ]
    ]
  ]

  if (mybreed = homen)
  [ let hoMalePart one-of other turtles-here with [(coupled? = false) and (breed = homen) ]
    if hoMalePart != nobody
    [ set coupled? true
      set partner hoMalePart
      ask partner [ set coupled? true ]
      ask partner [ set partner myself ]
      ask patch-here [ set pcolor green - 3 ]
    ]
  ]

  if (mybreed = howomen)
  [ let hoFemalePart one-of other turtles-here with [(coupled? = false) and (breed = howomen) ]
    if hoFemalePart != nobody
    [ set coupled? true
      set partner hoFemalePart
      ask partner [ set coupled? true ]
      ask partner [ set partner myself ]
      ask patch-here [ set pcolor green - 3 ]
    ]
  ]
end

; If two people are together for longer than either person's commitment variable
;  allows, the couple breaks up
to uncouple ; turtle procedure
  if coupled?
    [ if (couple-length > commitment) or
         ([ couple-length ] of partner) > ([ commitment ] of partner)
        [ ask patch-here [ set pcolor black ]
          set coupled? false
          set couple-length 0
          ask partner [ set couple-length 0 ]
          ask partner [ set partner nobody ]
          ask partner [ set coupled? false ]
          set partner nobody
        ]
    ]
end

; Infection can occur if either person is infected.

to infect ; turtle procedure
  if coupled? and infected? and (breed = hemen)
        [ if random-float 1 < transprob_HeMen
          [ ask partner [ set infected? true ] ]
        ]

  if coupled? and infected? and (breed = homen)
        [ if random-float 1 < transprob_HoMen
          [ ask partner [ set infected? true ] ]
        ]

  if coupled? and infected? and (breed = hewomen)
        [ if random-float 1 < transprob_HeWomen
          [ ask partner [ set infected? true ] ]
        ]

  if coupled? and infected? and (breed = howomen)
        [ if random-float 1 < transprob_HoWomen
          [ ask partner [ set infected? true ] ]
        ]
   end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;                      ;;;;;
;;;;;  MONITOR PROCEDURES  ;;;;;
;;;;;                      ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to-report %infected
  ifelse any? turtles
    [ report ((count turtles with [ infected? ]) / count turtles) * 100 ]
    [ report 0 ]
end

to-report %coupled_hemen
  ifelse any? hemen
    [ report ((count hemen with [ coupled? ]) / initial-number-hemen) * 100 ]
    [ report 0 ]
end

to-report %coupled_homen
  ifelse any? homen
    [ report ((count homen with [ coupled? ]) / initial-number-homen) * 100 ]
    [ report 0 ]
end

to-report %coupled_howomen
  ifelse any? howomen
    [ report ((count howomen with [ coupled? ]) / initial-number-howomen) * 100 ]
    [ report 0 ]
end
@#$#@#$#@
GRAPHICS-WINDOW
288
10
723
466
12
12
17.0
1
10
1
1
1
0
1
1
1
-12
12
-12
12
1
1
1
weeks
30.0

BUTTON
14
12
86
45
Setup
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
101
12
174
45
Go
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
156
154
266
199
% infected
%infected
2
1
11

SLIDER
10
106
279
139
average-commitment
average-commitment
1
200
26
1
1
weeks
HORIZONTAL

SLIDER
8
59
277
92
average-coupling-tendency
average-coupling-tendency
0
10
5
1
1
NIL
HORIZONTAL

PLOT
741
236
1288
563
Prevalence proportion of HIV in the Population by time
Weeks
Prevalence proportion
0.0
260.0
0.0
1.0
false
true
"" ""
PENS
"HIV+ hetero men" 1.0 0 -11221820 true "" "plot (count hemen with [infected?]) / initial-number-hemen"
"HIV+ homo men" 1.0 0 -13345367 true "" "plot (count homen with [infected?]) / initial-number-homen"
"HIV+ hetero women" 1.0 0 -2064490 true "" "plot (count hewomen with [infected?]) / initial-number-hewomen"
"HIV+ homo women" 1.0 0 -817084 true "" "plot (count howomen with [infected?]) / initial-number-howomen"

SLIDER
736
44
908
77
initial-number-hemen
initial-number-hemen
1
100
100
1
1
NIL
HORIZONTAL

SLIDER
737
92
909
125
initial-number-homen
initial-number-homen
1
100
10
1
1
NIL
HORIZONTAL

SLIDER
737
138
910
171
initial-number-hewomen
initial-number-hewomen
1
100
100
1
1
NIL
HORIZONTAL

SLIDER
737
181
910
214
initial-number-howomen
initial-number-howomen
1
100
10
1
1
NIL
HORIZONTAL

TEXTBOX
375
470
645
560
*****  Uninfected population markers *****\nCircle = Woman,\nSquare = Man\n\nYellow Solid = Homosexual,\nWhite Open = Heterosexual
12
123.0
1

SLIDER
1113
44
1285
77
transprob_HeMen
transprob_HeMen
0
1
0.15
.01
1
NIL
HORIZONTAL

SLIDER
1114
91
1286
124
transprob_HoMen
transprob_HoMen
0
1
0.5
.01
1
NIL
HORIZONTAL

SLIDER
1115
138
1287
171
transprob_HeWomen
transprob_HeWomen
0
1
0.3
0.01
1
NIL
HORIZONTAL

SLIDER
1116
185
1288
218
transprob_HoWomen
transprob_HoWomen
0
1
0.1
.01
1
NIL
HORIZONTAL

SLIDER
927
44
1099
77
initial-heman
initial-heman
0
100
5
1
1
NIL
HORIZONTAL

SLIDER
928
91
1100
124
initial-homan
initial-homan
0
100
20
1
1
NIL
HORIZONTAL

SLIDER
931
138
1103
171
initial-hewoman
initial-hewoman
0
100
5
1
1
NIL
HORIZONTAL

SLIDER
931
184
1103
217
initial-howoman
initial-howoman
0
100
1
1
1
NIL
HORIZONTAL

TEXTBOX
763
25
913
43
Initial population size
12
15.0
1

TEXTBOX
947
23
1097
41
% initial prevalence
12
15.0
1

TEXTBOX
1130
25
1280
43
Transmission probabilities
12
15.0
1

MONITOR
10
153
136
198
NIL
%coupled_hemen
2
1
11

MONITOR
11
213
138
258
NIL
%coupled_homen
2
1
11

MONITOR
10
274
138
319
NIL
%coupled_howomen
2
1
11

BUTTON
190
13
260
46
Go
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

@#$#@#$#@
## WHAT IS IT?

REMARK: THIS MODEL IS AN EXTENSION FROM THE AIDS MODEL IN THE NETLOGO MODEL LIBRARY.  ALL CHANGES, IMPLEMENTED HERE, ARE DESCRIBED IN THIS INFO TAB USING CAPITAL LETTERS.  THE ORIGINAL TEXT IS KEPT IN SMALL LETTERS.

-----------------------------------------------------------------------------------------

This model simulates the spread of the human immunodeficiency virus (HIV), via sexual transmission, through a small isolated human population.  It therefore illustrates the effects of certain sexual practices across a population.  As is well known now, HIV is spread in a variety of ways.  This model focuses only on the spread of HIV via sexual contact.  The model examines the emergent effects of sexual behaviour patterns.  The observer controls the population's tendency to practice abstinence, the amount of time an average "couple" in the population will stay together, the population's tendency to use condoms.

## HOW IT WORKS

The model uses "couples" to represent two people engaged in sexual relations.  Individuals wander around the world when they are not in couples.  Upon coming into contact with a suitable partner, there is a chance the two individuals will "couple" together.  When this happens, the two individuals no longer move about, they stand next to each other holding hands as a representation of two people in a sexual relationship.

The presence of the virus in the population is represented by the colours of individuals.  Three colours are used: green individuals are uninfected, blue individuals are infected but their infection is unknown, and red individuals are infected and their infection is known.

TWO COLOURS ARE USED TO DESIGNATE TWO TYPES OF POPULATIONS - WHITE BEING THE UNINFECTED AND RED BEING THE INFECTED.  IN THE ORIGINAL MODEL, THREE COLOURS WERE USED, NAMELY TO DESIGNATE - NOT INFECTED, INFECTED BUT NOT AWARE OF THAT STATUS, AND INFECTED AND AWARE OF THAT STATUS.  THAT MODEL ASSUMED THAT INDIVIDUALS WHEN THEY KNEW THEIR INFECTED STATUS, WOULD NO MORE SPREAD THE DISEASE ANYMORE IN THE SOCIETY BY USE OF CONDOMS, WHEREAS IN THIS MODEL, IT IS ASSUMED THAT ANY INFECTED INDIVIDUAL COULD TRANSMIT THE DISEASE IRRESPECTIVE OF THEIR KNOWLEDGE OF THE INFECTION STATUS.

## HOW TO USE IT

The setup button creates individuals with particular behavioural tendencies according to the values of the interface's sliders (described below).  Once the simulation has been setup, you are now ready to run it, by pushing the go button.  Go starts the simulation and runs it continuously until go is pushed again.  During a simulation initiated by go, adjustments in sliders can affect the behavioural tendencies of the population.

A monitor shows the percent of the population that is infected by HIV.  In this model each time-step is considered one week; the number of weeks that have passed is shown in the toolbar.

Here is a summary of the sliders in the model.  They are explained in more detail below.

- average-coupling-tendency: General likelihood a member of population has sex (0--10).
- average-commitment: How many weeks sexual relationships typically lasts (0--260).

THESE SLIDERS BELOW HAVE NOT BEEN USED IN THIS SETUP, BECAUSE IT IS ASSUMED THAT HIV TRANSMISSION COULD OCCUR IRRESPECTIVE OF THE KNOWLEDGE ABOUT THE INFECTION STATUS IN THE INDIVIDUAL.  HOWEVER, IT IS LIKELY IN A MORE IDEAL SITUATION, THE TRANSMISSION PROBABILITY FROM AN INTERCOURSE WOULD DIFFER PRIOR TO AND AFTER THE KNOWLEDGE OF A SEROPOSITIVE DIAGNOSTIC TEST RESULT IN AN INDIVIDUAL, EXERTED BY CERTAIN BEHAVIOURAL MODIFICATIONS BY THE PARTNER(S) IN COUPLES WITH A LIKELY DECREASE IN COUPLING-TENDENCY AS WELL AS A LIKELY USE OF CONDOMS.  IN THE ORIGINAL SETUP, IT WAS ASSUMED THAT WITH THE KNOWLEDGE OF A KNOWN HIV+ STATUS, THE INDIVIDUAL WOULD USE CONDOMS 100% OF TIME, WHICH TRANSLATES TO EXTREMELY LOW PROBABILITY OF TRANSMISSION.
- initial-people: How many people simulation begins with (50--500).
- average-condom-use: General chance member of population uses a condom. (0--10).
- average-test-frequency: Average frequency member of population will check their HIV status in a 1-year time period (0--2).

THE ORIGINAL SLIDER INITIAL-PEOPLE IS REPLACED HERE BY 4 SLIDERS OF DIFFERENT POPULATIONS (BREEDS) ASSUMED TO HAVE DIFFERENT RISKS AS THEIR OWN CHARACTERISTICS: HOMOSEXUAL MEN, HOMOSEXUAL WOMEN, HETEROSEXUAL MEN AND HETEROSEXUAL WOMEN WITH THE SLIDERS REPRESENSTING THE INITIAL POPULATION IN EACH BREED AS INITIAL-NUMBER-HOMEN (1--10), INITIAL-NUMBER-HOWOMEN (1--10), INITIAL-NUMBER-HEMEN (1--100) AND INITIAL-NUMBER-HEWOMEN (1--100), RESPECTIVELY.

ADDITIONALLY, 4 SLIDERS RESPECTIVELY HAVE BEEN ADDED HERE TO DEFINE AT START THE INITIAL POPULATION PREVALENCE OF INFECTED INDIVIDUALS FOR EACH OF THESE BREEDS (ASSIGNED WITH A RANDOM PROBABILITY): INTIAL-HOMAN (1--10), INITIAL-HOWOMAN (1--10), INITIAL-HEMAN (1--10), INITIAL-HEWOMAN (1--10).

FURTHERMORE, 4 SLIDERS RESPECTIVELY HAVE BEEN ADDED HERE TO ASSIGN 4 DIFFERENT TRANSMISSION PROBABILITIES AGAIN FOR EACH OF THESE BREEDS: TRANSPROB-HOMAN (0--1), TRANSPROB-HOWOMAN (0--1), TRANSPROB-HEMAN (0--1), TRANSPROB-HEWOMAN (0--1).

During the model's setup procedures, all individuals are given "tendencies" according to four additional sliders.  These tendencies are generally assigned in a normal distribution, so that, for instance, if a tendency slider is set at 8, the most common value for that tendency in the population will be 8.  Less frequently, individuals will have values 7 or 9 for that tendency, and even less frequently will individuals have values 6 or 10 (and so on).

The slider average-coupling-tendency (0--10) determines the tendency of the individuals to become involved in couples (as stated earlier, all couples are presumed to be sexually active). When the average-coupling-tendency slider is set at zero, coupling is unlikely, although (because tendencies are assigned in a normal distribution) it is still possible.  Note that when deciding to couple, both individuals involved must be "willing" to do so, so high coupling tendencies in two individuals are actually compounded (i.e., two individuals with a 50% chance of coupling actually only have a 25% of coupling in a given tick).

The slider average-commitment (1--260) determines how long individuals are likely to stay in a couple (in weeks).  Again, the tendencies of both individuals in a relationship are considered; the relationship only lasts as long as is allowed by the tendency of the partner with a shorter commitment tendency.

## THINGS TO NOTICE

Stop the simulation (by pressing the GO button once again), move the average-coupling-tendency slider to 0, push setup, and start the simulation again (with the GO button).  Notice that this time, couples are not forming.  With a low coupling-tendency, individuals do not choose to have sex, which in this model is depicted by the graphical representation of couplehood.  Notice that with these settings, HIV does not typically spread. However, spreading could happen since the population's tendency is set according to a normal distribution and a few people will probably have coupling-tendency values above 0 at this setting.

Again reset the simulation, this time with average-coupling-tendency set back to 10 and average-commitment set to 1.  Notice that while individuals do not stand still next to each other for any noticeable length of time, coupling is nevertheless occurring.  This is indicated by the occasional flash of dark grey behind individuals that are briefly next to one another.  Notice that the spread of HIV is actually faster when relationship-duration is very short compared to when it is very long.

Finally, set initial-population of the breeds to a higher number to notice that couples can form on top of each other.  Watch the simulation until you see individuals by themselves, but standing still and with a grey patch behind them indicating coupling.  Underneath one of its neighbours, is the individual's partner.  This apparent bug in the program is necessary because individuals need to be able to couple fairly freely.  If space constraints prohibited coupling, unwanted emergent behaviour would occur with high population densities.

## THINGS TO TRY

Run a number of experiments with the go button to find out the effects of different variables on the spread of HIV.  Try using good controls in your experiment.  Good controls are when only one variable is changed between trials.  For instance, to find out what effect the average duration of a relationship has, run four experiments with the average-commitment slider set at 1 the first time, 2 the second time, 10 the third time, and 50 the last.  How much does the prevalence of HIV increase in each case?  Does this match your expectations?

Are the effects of some slider variables mediated by the effects of others?  For instance, if lower average-commitment values seem to increase the spread of HIV when all other sliders are set at 0, does the same thing occur if all other sliders are set at 1 or 10, as maximums?  You can run many experiments to test different hypotheses regarding the emergent public health effects associated with individual sexual behaviour.

## EXTENDING THE MODEL

Like all computer simulations of human behaviour, this model has necessarily simplified its subject area substantially.  The model therefore provides numerous opportunities for extension:

The model depicts sexual activity as two people standing next to each other.  This suggests that all couples have sex and that abstinence is only practiced in singlehood.  The model could be changed to reflect a more realistic view of what couples are.  Individuals could be in couples without having sex.  To show sex, then, a new graphical representation would have to be employed.  Perhaps sex could be symbolised by having the patches beneath the couple flash briefly to a different color.

THE ORIGINAL MODEL DOES NOT DISTINGUISH BETWEEN GENDERS AND HOMO-/HETERO-SEXUALITY IN SEXUAL PREFERENCE PATTERNS.  IN THIS MODEL, 4 DIFFERENT BREEDS ARE CREATED BASED ON THIS HYPOTHESIS AND DATA ON THESE RISK GROUPS.  AS SUGGESTED FOR MODEL EXTENSION IN THE ORIGINAL MODEL, THE CURRENT MODEL WAS ABLE TO EXTEND AND TEST THIS FEATURE.  HOWEVER, IN THIS MODEL BISEXUALITY, MULTIPLE PARTNERS, SHARING NEEDLE, BLOOD TRANSFUSION AND VERTICAL TRANSMISSION WERE NOT CONSIDERED.  ALSO, 4 TRANSMISSION PROBABILITIES BY BREED ARE CREATED, WHICH WERE NOT PRESENT IN THE ORIGINAL MODEL.

The model does not distinguish between genders.  This is an obvious over-simplification chosen because making an exclusively heterosexual model was untenable while making one that included a variety of sexual preferences might have distracted from the public health issues which it was designed to explore.  However, extending the model by adding genders would make the model more realistic.

## LIMITATION OF THE CURRENT DESIGN

IN THIS STUDY, THE DESIGN ASSUMES A CLOSED POPULATION.  THIS IS NOT THE CASE IN A REAL-WORLD SCENARIO, WHERE INDIVIDUALS ARE LEAVING THE COHORT (DUE TO DEATH, MIGRATION) AND ARRIVING (DUE TO BIRTH, MIGRATION).  THIS SIMULATION ONLY DEALS WITH SEXUAL TRANSMISSION ROUTE FOR HIV AMONG THE 4 TYPES OF BREEDS, BUT OTHER MODES OF HIV TRANSMISSION ARE NOT INCLUDED HERE.

## NETLOGO FEATURES

Notice that the four procedures that assign the different tendencies generate many small random numbers and add them together.  This produces a normal distribution of tendency values.  A random number between 0 and 100 is as likely to be 1 as it is to be 99. However, the sum of 20 numbers between 0 and 5 is much more likely to be 50 than it is to be 99.

## CREDITS AND REFERENCES

Special thanks to Steve Longenecker for model development.

## HOW TO CITE

If you mention this model in a publication, we ask that you include these citations for the model itself and for the NetLogo software:

* Wilensky, U. (1997).  NetLogo AIDS model. http://ccl.northwestern.edu/netlogo/models/AIDS.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.
* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 1997 Uri Wilensky.
![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the project: CONNECTED MATHEMATICS: MAKING SENSE OF COMPLEX PHENOMENA THROUGH BUILDING OBJECT-BASED PARALLEL MODELS (OBPML).  The project gratefully acknowledges the support of the National Science Foundation (Applications of Advanced Technologies Program) -- grant numbers RED #9552950 and REC #9632612.

This model was converted to NetLogo as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227. Converted from StarLogoT to NetLogo, 2001.
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
NetLogo 5.3.1
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
