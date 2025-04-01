# fMRI task template

This is a template script for running a task in the fMRI scanner. It is designed to be modular, lightweight and easy to adapt to your needs. Your main tool is `fMRI_task.m`, which is designed to play one run of experimental task at a time.

The structure & most of the ideas for this repo come from work by [@costantinoai](https://github.com/costantinoai) and [@laura](https://www.hoplab.be/people/#LauraVH). It was adapted by [@TimManiquet](https://github.com/TimManiquet).


**Repository structure**
```
.
├── data
│   └── sub-01
│       └── ...
├── fMRI_task.m
├── README.md
├── src
│   ├── list_of_stimuli.tsv
│   ├── parameters.txt
│   ├── readme_files
│   └── stimuli
│       └── your images here ...
└── utils
    ├── adjustFixationDuration.m
    ├── configScreenCol.m
    ├── convertVisualUnits.m
    ├── createLogFile.m
    ├── dateTimeStr.m
    ├── detectKeyboard.m
    ├── determineButtonMapping.m
    ├── displayFixation.m
    ├── displayInstructions.m
    ├── displayTrial.m
    ├── initializePTB.m
    ├── loadImages.m
    ├── logEvent.m
    ├── logKeyPress.m
    ├── macInitializePTB.m
    ├── macLogKeyPress.m
    ├── makeTrialList.m
    ├── parseParameterFile.m
    ├── resizeStim.m
    ├── saveAndClose.m
    ├── setupScreen.m
    └── zeroFill.m
```


### Requirements

Make sure the following exist in your root directory:

 - A `utils` folder containing utility functions.
 - A `src` folder containing all your stimuli in `src/stimuli`.
 - A `parameters.txt` file in the `src` directory, containing your experimental parameters.
 - A `list_of_stimuli.tsv` file in the `src` directory, containing a list of your trial stimuli & other relevant variables.

Before starting your experiment, make sure you set the flags `debugMode`, `macMode` and `fmriMode`. These will determine a number of things:

- `debugMode` should be turned on if you are still developing. It will make your experiment run in a window instead of full screen, and will prevent data from being saved. Switching it off will make the cursor disappear for the time of the experiment, have it run in full screen, and save all result and log all the data.
- `macMode` should be turned on if you are developing on a mac. Its purpose is to make the logging of key presses work reliably on mac systems. 
- `fmriMode` will have the fMRI screen properties, response & trigger buttons, and response instruction values used. Switching it off will turn these parameters to their PC values.

About the `macMode`: note that Psychtoolbox is not optimised for Mac systems, and surely isn't maintained anymore on macOS in newest versions (as of early 2025). Remember to always try out your script on a Windows machine, or best on the fMRI computer itself, before scanning. The `macMode` flag will have the following effects:
  - **Keyboard detection**: `detectKeyboard` will be ran to find which keyboard will be sending input during the task and return a _keyboardID_. This is which is crucial as PTB and mac don't see to agree on how to decide on that.
  - **key presses**: `macLogKeyPress` will be used instead of `logKeyPress`, which is exactly similar except it logs input based on the ID of the detected keyboard.
  - **Psychtoolbox initialisation**: `macInitializePTB` will be ran instead of `initializePTB`, which will avoid executing `KbName('UnifyKeyNames');` and create & start a queue for the given keyboard ID rather than a general queue.


### Parameters

Most of your experiment parameters will be read externally from the `parameters.txt` file. When you conceive your own task, use this document as a checklist for the elements you need to set. Here is a detailled description of all the parameters you will find in `parameters.txt` and what they do.


| Parameter name | Default value | Description |
| :-------------- | :-----------: | :---------- |
| `stimDur`  | `1` | Stimulus presentation time (in seconds). |
| `fixDur`  | `1` | Duration of each post-stimulus fixation (in seconds). |
| `prePost` | `10` | Duration of the pre- and post-run fixation periods (in seconds).|
| `taskName` | *'myexp'* | Name of your experiment, useful to identify it in output files. Try to use a single, meaningful word (*expertisetask*, *localiser*, *maintask*, ...). |
| `resize` | `true` | Resize flag, determines whether your stimuli get resized or not. |
| `resizeMode` | _'visualUnits'_ | If the resize flag is `true`, determines how to resize the images. Two possible values: _visualUnits_ and _pixelSize_ (see [Trial list](#trial-list)). |
| `outWidth` | `8` | If the resize flag is `true`, the width of your resized stimuli (in pixels or degrees of visual angle, depending on your `resizeMode`. Either one of `outWidth` or `outHeight` has to exist if the `resize` flag is `true`.|
| `outHeight` | `8` | If the resize flag is `true`, the height of your resized stimuli. |
| `numRuns` | `2` | Total number of runs in the experiment. |
| `stimListFile` | *'list_of_stimuli.tsv'* | Name of the file that contains a _partial_ or _full_ list of the experiment trials (see [Trial list](#trial-list)).|
| `numRepetitions` | `2` | How many times to repeat the trials listed in the `stimListFile`. Set to 1 if it contains a full trial list (see [How to write your list of stimuli](#how-to-write-your-list-of-stimuli)). |
| `stimRandomization` | _'run'_ | How to randomize the stimuli in your trial list. Comment out if you don't need any randomisation. Other possible values are 'run' and 'all' (see [Trial randomization](#trial-randomization)). |
| `fixSize` | `.6` | Size of your fixation element (in degrees of visual angle).|
| `fixType` | _'round'_ | Type of fixation element you wish to use (see `displayFixation.m`). Possible values include 'round' and 'cross'.|
| `textSize` | `30` | Size of your text on screen. |
| `textFont` | _'Helvetica'_ | Font of your text on screen. |
| `instructionsText1`, `instructionsText2`, ... | *'On each trial..'* | Line-by-line elements of instruction to give at the beginning of each run. |
| `triggerWaitText` | *'Experiment loading ...'* | Message to display while the script waits for a trigger to begin the task. |
| `scrDistMRI` | `630` | Distance to the screen in the MRI scanner (in mm). |
| `scrWidthMRI` | `340` | Width of the screen in the MRI scanner (in mm). |
| `scrDistPC` | `520` | Estimated distance to the PC screen in debug mode (in mm).  |
| `scrWidthPC` | `510` | Estimated width of the PC screen in debug mode (in mm).|
| `respKeyMRI1`, `respKeyMRI2` | `3`, `4` | Key codes of the response buttons at the scanner (2-button right & red response box).|
| `triggerKeyMRI` | `5` | Key code of the MRI trigger.|
| `respInstMRI1`, `respInstMRI2` | _'left/green'_, _'right/red'_ | Names to display for each key in the instructions at the scanner.|
| `respKeyPC1`, `respKeyPC2` | _'f'_, _'j'_ | Keyboard response keys in debug mode (will also be used in the instructions). |
| `triggerKeyPC` | _'t'_ | Mock trigger keyboard key to use in debug mode.|
| `escapeKey` | _'ESCAPE'_ | Keyboard key to use to abort the experiment.|



### Trial list

The trials of your task will be executed based on the **parameters** and **list of stimuli** file that you input. Upon execution, a list of trials is created that contains all the information about the trials to be played in the experiment. 


#### How to write your list of stimuli

Write your list of stimuli in a file called `list_of_stimuli.tsv`, to be placed in the `src` folder. This file should contain _at least_ one column with header name `stimuli`. All other columns are optional, and will be read as extra information and stored in the list of trials output file (see below for an example, with two extra variables `animacy` and `setting`).

```
stimuli     animacy     setting
image1.png  animate     outside
image2.png  inanimate   inside
image3.png  inanimate   outside
image4.png  animate     outside
image5.png  animate     inside
```

Note that the `list_of_stimuli.tsv` is taken as a base to create the output `data/sub-xx/sub-xx_trial-list.tsv`, which merges the input list of stimuli with the output participant responses and any other variables created during the task. As such, make sure you don't enter column names in the `list_of_stimuli.tsv` that will interfere with the writing of these new variables (see below for a breakdown of the columns that will be created). 

A special case is that of **`run`**: in the absence of it, a `run` column will be created based on the input parameters. However, if you do include a `run` column in your `list_of_stimuli.tsv` file, it will be considered correct and used as it is in the `trial_list`.


Your list of trials will be built from the list of stimuli provided in the `stimuli` column of your `list_of_stimuli.tsv` file. Here is how the script will proceed:

1. Based on the length of your stimuli column and the number of repetitions (`numRepetitions`), a total number of trials is calculated (stimuli list length * number of repetitions). The list of stimuli is duplicated to match this length.
2. Based on the number of runs, each entry in the list of stimuli gets assigned a run number, considering evenly long runs and starting from 1.

There are two possible ways of writing this list:

- Provide a **full stimuli list**, with one line for each trial of *the whole* experiment, and set the number of repetitions to 1. This is the way to go if you want to control exactly the whole sequence of action.
- Provide a **partial stimuli list**, with one line for each trial of *one/several run(s)* of the experiment, but not for the whole experiment. In this case, set the number of repetitions to >1. This is the way to go if you are repeating the same set of stimuli several times across the experiment.

![trial_list](./src/readme_files/trial_list.png)

The resulting trial list gets enhanced of several extra variables (trial number, etc.). Each time the script is executed, the trials corresponding to the run are extracted into the `runTrials` structure, which is then saved as `yyyy-mm-dd-hh-mm_sub-xx_run-xx_task-taskname.mat` in the results directory (`in.resDir`).

Here are the variables that will be created in the `trialList` structure, on top of `stimuli` and any extra variable you have entered in your `list_of_stimuli.tsv`:

- `run` 
- `trialNb` 
- `butMap` 
- `respKey..` 
- `respInst..` 
- `subNum..` 
- `idealStimOnset` 
- `response`

These variables will also end up in the `runTrials` structure, which constitutes the behavioural output that is saved eventually as a `.mat` file.

#### Monitoring accuracy

You might wish to monitor the accuracy of your participants online, to have an idea of how the task is going or to give feedback. This can be achieved by playing with extra variables in your `list_of_stimuli.tsv` file. These variables will automatically be indexed in your trial list and can hence be accessed during/right after trial presentation. The script contains a section showing how to use such variables for accuracy monitoring (see the `%% monitoring accuracy` section, l.290).

#### Trial randomization

You can ask the script to randomize your trials by playing with the `stimRandomization` parameter.

- Comment out the `stimRandomization` parameter in your parameters file if you don't need any randomization from your list of stimuli.
- Set the `stimRandomization` parameter to _'run'_ to randomize your trials within each run.
- Set the `stimRandomization` parameter to _'all'_ to randomize your trials across all runs.

![trial_randomization](./src/readme_files/trial_randomization.png)

#### Fixation trials

You can introduce fixation events in your task by replacing image file names in your list of stimuli by the word _fixation_. The script will read those differently and show a fixation instead of showing a stimulus for these trials.

![fixation_trials](./src/readme_files/fixation_trials.png)

#### Button randomisation & instructions

This task template takes two response buttons, which can be determined using the `respKey` parameters. A random assignment is made for the first run. The order of buttons is then switched across runs. Make sure the repsonse instructions you write in the `respInst` parameters match the order of the response button parameters. These will be used to render correct instructions at the beginning of each run.

![button_mapping](./src/readme_files/button_mapping.png)

The instructions you write line by line in the parameters will be pasted together in a single paragraph. Add as many instruction lines as you need (`instructionsText4`, `instructionsText5`, ...). Make sure to have two **place holders** in your instructions, denoted with parentheses `()`. These will be replaced by the response instructions you gave, and alternated in between runs.

![instructions](./src/readme_files/instructions.png)

### Output

Upon completion and given the `debugMode` flag is off, your `data` folder should look like this:

````
.
├── sub-01
│   ├── YYYY-MM-DD-hh-mm_sub-01_run-01_task-myexp_log.tsv
│   ├── YYYY-MM-DD-hh-mm_sub-01_run-01_task-myexp.mat
│   ├── YYYY-MM-DD-hh-mm_sub-01_run-02_task-myexp_log.tsv
│   ├── YYYY-MM-DD-hh-mm_sub-01_run-02_task-myexp.mat
│   └── ... other runs here
└── sub-02
    └── ...
````

In this output are the following files:

- **log files** are created for each run (i.e. each time you run the script). They contain information about every event in the script, including screen flips, key presses, errors, etc. They are meant to keep track of everything, and to be easily turned into event files later on. By default, they are named *time tag*-*subject number*-*run number*-*experiment name*-*log***.tsv**.
- **`.mat` files** are created for each run and contain every variable created by MatLab during the run, including the `params` and `in` structures, the `runImMat` structure which ontains the images themselves, and the `runTrials` strcuture which contains all the trial-by-trial behavioural output of the task. By default, they are named *time tag*-*subject number*-*run number*-*experiment name***.mat**.

### Timing

An important aspect of this template is that it pays attention to the **timing of events**. Firstly, through a comprehensive **logging**, the script aims at keeping close track of the timing of things. Secondly, during the task itself, event durations are **adapted** so that the run follows the ideal onset of events as closely as possible (see figure below). Here is how things unfold:

1. When started, the script will create a list of **ideal onsets** for all the trials to happen. These ideal onsets are zero-aligned, i.e. the ideal onset of the pre-fixation is `0.0`s, the ideal onset of the first image presentation is `0.0` + `params.prePost` (i.e. `10.0` with default values), the idea onset of the first fixation cross is `0.0 + params.prePost + params.fixDur`, etc.
2. As soon as logging begins, a time stamp is created to record the *script start* (stored in `in.scriptStart`).
3. Once the starting trigger is received from the scanner, the pre-run fixation begins, and the `runStart` time stamp is taken to mark the beginning of the actual task.
4. From `runStart`, the `idealOnset` is re-calculated for each successive event. For instance, if `runStart` is `15.3` (i.e. 15.3 seconds elapsed before the task actually began), then the ideal stimulus onset of the first image presentation will become `0.0 + params.prePost + 15.3`.
5. For each trial, a time stamp if taken when the stimulus is _actually_ shown on the screen, which it records as its `actualOnset`. The script will then calculate a delta between the re-calculated *ideal* and the *actual* onset of the stimulus presentation, and adjust the duration of the subsequent fixation cross duration to compensate. For instance, if a stimulus has an `actualOnset` of `25.56` but an `idealOnset` of `25.55`, the subsequent fixation cross will stay on screen for `params.fixDur - 0.01`. This adjustment is done by the `adjustFixationDuration` function.

This procedure is reflected in the log files, which contain a `EXP_ONSET` and a `ACTUAL_ONSET` column, containing the `idealOnset` and the `actualOnset` values, respectively. The `DELTA` column shows the difference between the two. It's worth noting that the onsets logged in these columns are *aligned to the start of the script* (`in.scriptStart`). This is useful from a logging perspective, as it allows to keep track of _all events_, including instruction display, pre-fixation, etc. However, this is not the format expected by BIDS. According to BIDS convention, onset values must be aligned to the start of the run (`runStart`), i.e. when the recording starts. To be able to use log files as event files, it is essential then to re-align the `ACTUAL_ONSET` column to create the final `onset` column. 

![timing_adjustment_logic](./src/readme_files/timing_adjustment_logic.png)

### response keys

talk here about the way we bring the keys to be logged, from parameters, to parse param, to log key pres
mention that response keys are stored in the params structure at the start of the run

### Trouble shooting notes

This section lists the most often encountered bugs and their solution.

| Problem | Resolution |
| :------ | :--------- |
| **Screen Setup** | If you get an error from the `screen setup` section, it might be a problem with the system frame rate and the frame rate detected by PTB. Perhaps you are using an external monitor? If so, try disconnecting the external monitor, or set `SkipSyncTests` to 1 (ATTENTION: DON`T DO THIS IF YOU ARE RUNNING THE REAL EXPERIMENT! ONLY FOR DEBUG PURPOSES). |
| **Trigger Wait** | There is a known bug currently (as of the 21st of March 2024) where the MRI scanner sends two triggers before beginning. As a result, two keys presses are logged in the trigger wait section, with the start of each run actually taking place after the **second** trigger.|
| **Keyboard silent** | Did your script crash, and now you cannot write anything in Matlab anymore? Maybe your keyboard is still silent. You need to enable input listening again by running `ListenChar(0)`. Find a way to run that segment, for instance by finding it in `saveAndClose`, highlighting and evaluating it.|

