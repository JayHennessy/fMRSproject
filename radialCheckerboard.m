close all;
clear all;
sca;
Screen('Preference', 'SkipSyncTests', 1);

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers
screens = Screen('Screens');

% Draw to the external screen if avaliable
screenNumber = max(screens);

% Define black and white
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);

% Here we calculate the radial distance from the center of the screen to
% the X and Y edges
xRadius = windowRect(3) / 2;
yRadius = windowRect(4) / 2;

%% this is the crosshair part

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Setup the text type for the window
Screen('TextFont', window, 'Ariel');
Screen('TextSize', window, 36);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Here we set the size of the arms of our fixation cross
fixCrossDimPix = 40;

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
% xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
% yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
xCoords = [-fixCrossDimPix/2 fixCrossDimPix/2 -fixCrossDimPix/2 fixCrossDimPix/2 ];
yCoords = [ fixCrossDimPix/2 -fixCrossDimPix/2 -fixCrossDimPix/2 fixCrossDimPix/2];
allCoords = [xCoords; yCoords];

% Set the line width for our fixation cross
lineWidthPix = 8;


%%

% Screen resolution in Y
screenYpix = windowRect(4);

% Number of white/black circle pairs
rcycles = 7;

% Number of white/black angular segment pairs (integer)
tcycles = 12;

% Now we make our checkerboard pattern
xylim = 2 * pi * rcycles;
[x, y] = meshgrid(-xylim: 2 * xylim / (screenYpix - 1): xylim,...
    -xylim: 2 * xylim / (screenYpix - 1): xylim);
at = atan2(y, x);
checks = ((1 + sign(sin(at * tcycles) + eps)...
    .* sign(sin(sqrt(x.^2 + y.^2)))) / 2) * (white - black) + black;
circle = x.^2 + y.^2 <= xylim^2;
%checks = circle .* checks + grey * ~circle;

[pattern, pattern_inv] = make_circular_checkerboard_pattern;

% Now we make this into a PTB texture
radialCheckerboardTexture  = Screen('MakeTexture', window, checks);

% Draw our texture to the screen
Screen('DrawTexture', window, radialCheckerboardTexture);

% Draw the fixation cross in white, set it to the center of our screen and
% set good quality antialiasing
Screen('DrawLines', window, allCoords,...
    lineWidthPix, [1,0,0], [xCenter yCenter], 2);

% Flip to the screen
Screen('Flip', window);

% Wait for a keypress
KbStrokeWait;

% Clear up and leave the building
sca;
close all;
clear all;