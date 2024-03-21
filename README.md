# fMRI-task

This is a template script for running a task in the fMRI scanner. It is designed to be modular, lightweight and easy to adapt to your needs.

## Requirements

 - `utils`and `src` directories
 - `parameters.txt` file in the `src` directory


## Trouble shooting

If you get an error from the `screen setup` section, it might be a problem with the system frame rate and the frame rate detected by PTB. Perhaps you are using an external monitor? If so, try disconnecting the external monitor, or set `SkipSyncTests` to 1 (ATTENTION: DON`T DO THIS IF YOU ARE RUNNING THE REAL EXPERIMENT! ONLY FOR DEBUG PURPOSES).

