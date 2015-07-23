% Clear the workspace
close all;
clear all;
sca;

%  ** ***** I ADDED THIS WHICH MAKES THE TIMING VERY INACCURATE  ****
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

crosshairTimer = 12;

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber,...
    grey, [], 32, 2, [], [], kPsychNeed32BPCFloat);

% Get the size of the on screen window
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

%% this is the crosshair part

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
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords1 = [xCoords; yCoords];
xCoords = [-fixCrossDimPix fixCrossDimPix -fixCrossDimPix fixCrossDimPix ];
yCoords = [ fixCrossDimPix -fixCrossDimPix -fixCrossDimPix fixCrossDimPix];
allCoords2 = [xCoords; yCoords];

% Set the line width for our fixation cross
lineWidthPix = 8;


%%


% Screen resolution in Y
screenYpix = windowRect(4);

% Number of white/black circle pairs
rcycles = 8;

% Number of white/black angular segment pairs (integer)
tcycles = 12;

% Now we make our checkerboard pattern
xylim = 2 * pi * rcycles;
[x, y] = meshgrid(-xylim: 2 * xylim / (screenXpixels - 1): xylim,...
    -xylim: 2 * xylim / (screenXpixels - 1): xylim);
at = atan2(y, x);
checks = ((1 + sign(sin(at * tcycles) + eps)...
    .* sign(sin(sqrt(x.^2 + y.^2)))) / 2) * (white - black) + black;
circle = x.^2 + y.^2 <= xylim^2;


%checks = circle .* checks + grey * ~circle;  % this line makes the image
% circular

% Now we make this into a PTB texture
radialCheckerboardTexture(1)  = Screen('MakeTexture', window, checks);
radialCheckerboardTexture(2)  = Screen('MakeTexture', window, 1 - checks);

% Time we want to wait before reversing the contrast of the checkerboard
checkFlipTimeSecs = 1/7.85;
checkFlipTimeFrames = round(checkFlipTimeSecs / ifi);
frameCounter = 0;

% Time to wait in frames for a flip
waitframes = 1;

% Texture cue that determines which texture we will show
textureCue = [1 2];

Screen('DrawLines', window, allCoords1,...
    lineWidthPix, [1,0,0], [xCenter yCenter], 2);

% Sync us to the vertical retrace
vbl = Screen('Flip', window);

tic;
count =1;
orient =1;
allCoords = allCoords1;
t_flip(count) = toc;
while ~KbCheck

    % Increment the counter
    frameCounter = frameCounter + 1;

    % Draw our texture to the screen
    Screen('DrawTexture', window, radialCheckerboardTexture(textureCue(1)));
    
     Screen('DrawLines', window, allCoords,...
            lineWidthPix, [1,0,0], [xCenter yCenter], 2);
           
    
    % Flip to the screen
    vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

    % Reverse the texture cue to show the other polarity if the time is up
    if frameCounter == checkFlipTimeFrames
        
        
        if randi(2,1) ==2 && ((toc-t_flip(count))>crosshairTimer)
            if orient == 2
                allCoords = allCoords1;
                count = count+1;
                t_flip(count)= toc;
                orient =1;
            elseif orient ==1
                
                allCoords = allCoords2;
                count = count+1;
                t_flip(count)= toc;
                orient =2;
            end
        end
        
        textureCue = fliplr(textureCue);
        frameCounter = 0;
        
        
    end
   

end

% Clear up and leave the building
sca;
close all;
%clear all;