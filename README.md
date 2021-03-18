# UT2003-Marky2

Epic's Mark Rein on you screen whenevery you kill three enemies in a row. Isn't that what you've always wanted.

Version 2 includes new characters like the world dumbest fish (Dopefish) and a weird white bunny (aka CliffyB)

Version 3 include Willhaven's broken bagel picture.
Also the configuration has changed, bNoReturn is no longer relevant, instead an option 'Animation' is added, check below

# Installation

Copy the Marky3.u and Marky3.int file to the UT2003 System directory. And install it like any other mutator. The mutator name is: Marky2.MarkyMut Make sure you add this package to the ServerPackages

Note: remove all traces of the previous release

#Configuration

You don't need to configure anything for it to work. However this mutator is higly configurable. Below is the default configuration. You can add more faces if you want Each entry consists out of the following properties:

```
    Face:         the face to show
    Voice:        the voice to playback
    Level:        at what level to react
    Type:         type of event to be triggered at 
                  0: multi kill level (level >= multikill level)
                  1: number of deaths (death % level == 0)
                  2: killing spree level (increase) (0-5)
                  3: number of suicides (suicides % level == 0)
    fFromX, 
    fFromY, 
    fToX, 
    fToY:         percentages where to show the image
    StepSize:     number of stemps to take at the time
    fShowSpeed:   interval between each step
    fWaitTime:    time to show the picture
    fImageScale:  Scale the image to the screen
    Animation:    Animation type:
              		0: move from source to destination and back
            				  source: fFromX, fFromY
                      dest:		fToX, fToY
                  1: only move from source to destination
                      source: fFromX, fFromY
                      dest:		fToX, fToY
                  2: zoom in and out
                      start size: fFromX,	end size: tToX
                      start alpha: fFromY, end alpha fToY
                  3: zoom in only
```

The "Toasty" sound is included in this version, to use it set the voice to:

```
    Sounds'Marky3.ToastySound'
```
