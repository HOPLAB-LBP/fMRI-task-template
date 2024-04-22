function macInitializePTB(keyboardID)
%   This function is exactly similar to initializePTB except it solves 
%   a problem present on mac systems which has to do with detecting keyboard 
%   input.
% 
% MACINITIATEPTB - Initializes the experiment environment on a mac.
%   This function performs the necessary setup steps to initialize the
%   experiment environment. It closes any open Psychtoolbox screens,
%   unifies key names across different operating systems, creates a
%   keyboard event queue, starts recording keyboard events, and initializes
%   the random number generator with a random seed.
% 
%   Author
%   Tim Maniquet [22/3/24]

try
    % Close any open Psychtoolbox screens
    Screen('CloseAll');
    
    % Unify key names across different operating systems
    % We don't run this command in the mac mode
    % KbName('UnifyKeyNames');
    
    % Create a queue for keyboard events
    KbQueueCreate(keyboardID);
    
    % Start recording keyboard events
    KbQueueStart(keyboardID);
    
    % Initialize the random number generator with a random seed
    rng('shuffle');
    
    % Display a message indicating that the experiment environment is ready
    disp('Experiment environment initialized.');
catch ME
    % If an error occurs, display the error message
    disp('And error occurred while initializing PTB:');
    disp(ME.message);
end

end