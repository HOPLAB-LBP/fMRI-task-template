function initializePTB()
% INITIATEPTB Initializes the experiment environment.
% 
%   This function performs the necessary setup steps to initialize the
%   experiment environment. It closes any open Psychtoolbox screens,
%   unifies key names across different operating systems, creates a
%   keyboard event queue, starts recording keyboard events, and initializes
%   the random number generator with a random seed.
% 
%   Author
%   Andrea Costantino [9/6/23]

try
    % Close any open Psychtoolbox screens
    Screen('CloseAll');
    
    % Unify key names across different operating systems
    KbName('UnifyKeyNames');
    
    % Create a queue for keyboard events
    KbQueueCreate;
    
    % Start recording keyboard events
    KbQueueStart;
    
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