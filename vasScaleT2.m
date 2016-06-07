function [finalRating,reactionTime,response] = vasScaleT2(window,windowRect,durRating,defaultRating,backgroundColor,StartY,keys)

%% key settings
KbName('UnifyKeyNames');
lessKey =  keys.left; % yellow button
moreKey =  keys.right; % red button
confirmKey =  keys.confirm;  % green button
escapeKey = keys.esc;

if isempty(window); error('Please provide window pointer for likertScale!'); end
if isempty(windowRect); error('Please provide window rect for likertScale!'); end
if isempty(durRating); error('Duration length of rating has to be specified!'); end

%% Default values
nRatingSteps = 101;
scaleWidth = 700; 
textSize = 20; 
lineWidth = 6;
scaleColor = [255 255 255]; 
activeColor = [255 0 0]; 

if isempty(defaultRating); defaultRating = round(nRatingSteps/2); end
if isempty(backgroundColor); backgroundColor = 0; end

% if length(ratingLabels) ~= nRatingSteps
%     error('Rating steps and label numbers do not match')
% end

%% Calculate rects
activeAddon_width = 1.5;
activeAddon_height = 20;
[xCenter, yCenter] = RectCenter(windowRect);
yCenter = StartY;
axesRect = [xCenter - scaleWidth/2; yCenter - lineWidth/2; xCenter + scaleWidth/2; yCenter + lineWidth/2];
lowLabelRect = [axesRect(1),yCenter-20,axesRect(1)+6,yCenter+20];
highLabelRect = [axesRect(3)-6,yCenter-20,axesRect(3),yCenter+20];
ticPositions = linspace(xCenter - scaleWidth/2,xCenter + scaleWidth/2-lineWidth,nRatingSteps);
% ticRects = [ticPositions;ones(1,nRatingSteps)*yCenter;ticPositions + lineWidth;ones(1,nRatingSteps)*yCenter+tickHeight];
activeTicRects = [ticPositions-activeAddon_width;ones(1,nRatingSteps)*yCenter-activeAddon_height;ticPositions + lineWidth+activeAddon_width;ones(1,nRatingSteps)*yCenter+activeAddon_height];
% keyboard


Screen('TextSize',window,textSize);
Screen('TextColor',window,[255 255 255]);
Screen('TextFont', window, 'Arial');
currentRating = defaultRating;
finalRating = currentRating;
reactionTime = 0;
response = 0;
first_flip  = 1;
startTime = GetSecs;
numberOfSecondsRemaining = durRating;
nrbuttonpresses = 0;


%%%%%%%%%%%%%%%%%%%%%%% loop while there is time %%%%%%%%%%%%%%%%%%%%%
% tic; % control if timing is as long as durRating
while numberOfSecondsRemaining  > 0
    Screen('FillRect',window,backgroundColor);
    Screen('FillRect',window,scaleColor,axesRect);   
    Screen('FillRect',window,scaleColor,lowLabelRect);
    Screen('FillRect',window,scaleColor,highLabelRect);
    Screen('FillRect',window,activeColor,activeTicRects(:,currentRating));
   
    DrawFormattedText(window, 'Bitte bewerten Sie die Schmerzhaftigkeit', 'center',yCenter-100, scaleColor);
    DrawFormattedText(window, ' VOR dem Sternchen', 'center',yCenter-70, scaleColor);
    
    Screen('DrawText',window,'kein',axesRect(1)-17,yCenter+25,scaleColor);
    Screen('DrawText',window,'Schmerz',axesRect(1)-40,yCenter+45,scaleColor);
    
    Screen('DrawText',window,'unerträglicher',axesRect(3)-55,yCenter+25,scaleColor);
    Screen('DrawText',window,'Schmerz',axesRect(3)-40,yCenter+45,scaleColor);
    
    
    
    % Remove this line if a continuous key press should result in a continuous change of the scale
    %     while KbCheck; end
    
    if response == 0
        
        % set time 0 (for reaction time)
        if first_flip   == 1
            secs0       = Screen('Flip', window); % output Flip -> starttime rating
            first_flip  = 0;
            % after 1st flip -> just flips without setting secs0 to null
        else
            Screen('Flip', window);
        end
        
        [ keyIsDown, secs, keyCode ] = KbCheck; % this checks the keyboard very, very briefly.
        if keyIsDown % only if a key was pressed we check which key it was
            response = 0; % predefine variable for confirmation button 'space'
            nrbuttonpresses = nrbuttonpresses + 1;
            if keyCode(moreKey) % if it was the key we named key1 at the top then...
                currentRating = currentRating + 1;
                finalRating = currentRating;
                response = 0;
                if currentRating > nRatingSteps
                    currentRating = nRatingSteps;
                end
            elseif keyCode(lessKey)
                currentRating = currentRating - 1;
                finalRating = currentRating;
                response = 0;                 
                if currentRating < 1
                    currentRating = 1;
                end
            elseif keyCode(escapeKey)
                reactionTime = 99; % to differentiate between ESCAPE and timeout in logfile
                VASoff = GetSecs-StartExp;
                disp('***********');
                disp('Abgebrochen');
                disp('***********');
                break;
            elseif keyCode(confirmKey)
                finalRating = currentRating-1;
                disp(['VAS Rating: ' num2str(finalRating)]);              
                response = 1;
                reactionTime = secs - secs0;
                break;
            end
        end
    end
    
    numberOfSecondsElapsed   = (GetSecs - startTime);
    numberOfSecondsRemaining = durRating - numberOfSecondsElapsed;
    
end
if nrbuttonpresses ~= 0 && response == 0
        finalRating = currentRating - 1;
        reactionTime = durRating;
        disp(['VAS Rating: ' num2str(finalRating)]);
        warning(sprintf('\n***********\n***********\nNo Confirmation!!!\n***********\n***********\n'));
elseif nrbuttonpresses == 0
        finalRating = NaN;
        reactionTime = durRating;
        disp(['VAS Rating: ' num2str(finalRating)]);
        warning(sprintf('\n***********\n***********\nNo Response!\nPlease check participant!!!\n***********\n***********\n'));
end
% toc



