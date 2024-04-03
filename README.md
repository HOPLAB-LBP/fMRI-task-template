# fMRI task template

This is a template script for running a task in the fMRI scanner. It is designed to be modular, lightweight and easy to adapt to your needs.

## Requirements

Make sure the following exist in your your root directory:

 - A `utils` folder containing utility functions.
 - A `src` folder containing all your stimuli in `src/stimuli`.
 - A `parameters.txt` file in the `src` directory, containing your experimental parameters.
 - A `list_of_stimuli.tsv` file in the `src` directory, containing a list of your trial stimuli & other relevant variables.

## Parameters

Most of your experiment parameters will be read externally from the `parameters.txt` file. When you conceive your own task, use this document as a checklist for the elements you need to set. Here is a detailled description of all the parameters you will find in `parameters.txt` and what they do.


| Parameter name | Default value | Description |
| :-------------- | :-----------: | :---------- |
| `stimDur`  | `1` | Stimulus presentation time (in seconds). |
| `fixDur`  | `1` | Duration of each post-stimulus fixation (in seconds). |
| `prePost` | `10` | Duration of the pre- and post-run fixation periods (in seconds).|
| `taskName` | *'my_exp'* | Name of your experiment, useful to identify it in output files. |
| `resize` | `true` | Resize flag, determines whether your stimuli get resized or not. |
| `resizeMode` | _'visualUnits'_ | If the resize flag is `true`, determines how to resize the images. Two possible values: _visualUnits_ and _pixelSize_ (see [Trial list](#trial-list)). |
| `outWidth` | `8` | If the resize flag is `true`, the width of your resized stimuli (in pixels or degrees of visual angle, depending on your `resizeMode`. Either one of `outWidth` or `outHeight` has to exist if the `resize` flag is `true`.|
| `outHeight` | `8` | If the resize flag is `true`, the height of your resized stimuli. |
| `numRuns` | `2` | Total number of runs in the experiment. |
| `stimListFile` | *'list_of_stimuli.tsv'* | Name of the file that contains a _partial_ or _full_ list of the experiment trials (see [Trial list](#trial-list)).|
| `numRepetitions` | `2` | How many times to repeat the trials listed in the `stimListFile`. Set to 1 if it contains a full trial list (see [How to write your list of stimuli](#how-to-write-your-list-of-stimuli)). |
| `stimRandomization` | _'run'_ | How to randomize the stimuli in your trial list. Comment out if you don't need any randomisation. Other possible values are 'run' and 'all'. |
| `fixSize` | .`6` | Size of your fixation element (in degrees of visual angle).|
| `fixType` | _'round'_ | Type of fixation element you wish to use (see `displayFixation.m`). Possible values include 'round' and 'cross'.|
| `textSize` | `30` | Size of your text on screen. |
| `textFont` | _'Helvetica'_ | Font of your text on screen. |
| `instructionsText1`, `instructionsText2`, ... | *'On each trial..'* | Line-by-line elements of instruction to give at the beginning of each run. |
| `triggerWaitText` | *'Experiment loading ...'* | Message to display while the script waits for a trigger to begin the task. |
| `scrDistMRI` | `630` | Distance to the screen in the MRI scanner (in mm). |
| `scrWidthMRI` | `340` | Width of the screen in the MRI scanner (in mm). |
| `scrDistPC` | `520` | Estimated distance to the PC screen in debug mode (in mm).  |
| `scrWidthPC` | `510` | Estimated width of the PC screen in debug mode (in mm).|
| `respKeyMRI1`, `respKeyMRI2` | `51`, `52` | Key codes of the response buttons at the scanner (2-button right & red response box).|
| `triggerKeyMRI` | `53` | Key code of the MRI trigger.|
| `respInstMRI1`, `respInstMRI2` | _'left/green'_, _'right/red'_ | Names to display for each key in the instructions at the scanner.|
| `respKeyPC1`, `respKeyPC2` | _'q'_, _'w'_ | Keyboard response keys in debug mode (will also be used in the instructions). |
| `triggerKeyPC` | _'a'_ | Mock trigger keyboard key to use in debug mode.|
| `escapeKey` | _'ESCAPE'_ | Keyboard key to use to abort the experiment.|



## Trial list

The trials of your task will be executed based on the **parameters** and **list of stimuli** file that you input. Upon execution, a list of trials is created that contains all the information about the trials to be played in the experiment. 

This section explains how the trial list is made in the script, along with the randomisation, import of images, etc.

### How to write your list of stimuli

Write your list of stimuli in a file called `list_of_stimuli.tsv`, to be placed in the `src` folder. This file should contain _at least_ one column with header name `stimuli`. All other columns are optional, will be read as extra information and stored in the list of trials output file (see below for an example, with two extra variables `category` and `setting`).

```
stimuli	                        category	setting
./src/stimuli/animal_sheep.jpg	animal	    outside
./src/stimuli/animal_zebra.jpg	animal	    outside
./src/stimuli/food_banana.jpg	food	    inside
./src/stimuli/food_cake.jpg	    food	    inside
./src/stimuli/food_pizza.jpg	food	    inside
./src/stimuli/object_camera.jpg	objects	    inside
./src/stimuli/object_phone.jpg	objects	    inside
```

Your list of trials will be build from the list of stimuli provided in the `stimuli` column of your `list_of_stimuli.tsv` file. Here is how the script will proceed:

1. Based on the length of your stimuli column and the number of repetitions (`numRepetitions`), a total number of trials is calculated (stimuli list length * number of repetitions).
2. Based on the number of runs 

 There are two possible ways of writing this list:

1. Provide a **full stimuli list**

in the trial loop

any other column will be read as an extra variable in the trial list structure

![trial_list](./src/readme_files/trial_list.png)

### Here, explanations about the randomisation.

![trial_randomization](./src/readme_files/trial_randomization.png)

### Here explanations about fixation trials

fixation events: explain how writing 'fixation' instead of an image file name will make a fixation trial

![fixation_trials](./src/readme_files/fixation_trials.png)


## General script design

Here an explanation of what the script does. 
- Mention that it is meant to be played once for each run. 
- Mention that the user has to input the run number each time.
- Mention that the trial list is created once for the current participant, then sampled from for each run.

## Output

Here I describe all the output that users will find in the data folder.





## Trouble shooting notes

This section lists the most often encountered bugs and their solution

### Screen Setup
If you get an error from the `screen setup` section, it might be a problem with the system frame rate and the frame rate detected by PTB. Perhaps you are using an external monitor? If so, try disconnecting the external monitor, or set `SkipSyncTests` to 1 (ATTENTION: DON`T DO THIS IF YOU ARE RUNNING THE REAL EXPERIMENT! ONLY FOR DEBUG PURPOSES).

### Trigger Wait
There is a known bug currently (as of the 21st of March 2024) where the MRI scanner sends two triggers before beginning. As a result, two keys presses are logged in the trigger wait section, with the start of each run actually taking place after the **second** trigger.
