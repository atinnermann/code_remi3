function [finalRating,reactionTime,response,VASon,VASoff] = moodScale(window,windowRect,durRating,defaultRating,backgroundColor,StartY,keys)

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
nRatingSteps = 7;
scaleWidth = 700; 
textSize = 20; 
lineWidth = 6;
scaleColor = [255 255 255]; 
activeColor = [255 0 0]; 
ticTextGap = 8;
tickHeight = 20;
ratingLabels = {'-3','-2','-1','0','1','2','3'};
if isempty(defaultRating); defaultRating = round(nRatingSteps/2); end
if isempty(backgroundColor); backgroundColor = 0; end


%% Calculate rects
activeAddon_width = 0.6;
activeAddon_height = 20;
[xCenter, yCenter] = RectCenter(windowRect);
yCenter = StartY;
axesRect = [xCenter - scaleWidth/2; yCenter - lineWidth/2; xCenter + scaleWidth/2; yCenter + lineWidth/2];

% for j = 1:nRatingSteps
%     Label(j,:) = round([axesRect(1)+((j-1)*scaleWidth/(nRatingSteps-1)),yCenter-20,axesRect(1)+((j-1)*scaleWidth/(nRatingSteps-1))+6,yCenter+20]);
% end
ticPositions = linspace(xCenter - scaleWidth/2,xCenter + scaleWidth/2-lineWidth,nRatingSteps);
activeTicRects = [ticPositions-activeAddon_width;ones(1,nRatingSteps)*yCenter-activeAddon_height;ticPositions + lineWidth+activeAddon_width;ones(1,nRatingSteps)*yCenter+activeAddon_height];
ticRects = [ticPositions;ones(1,nRatingSteps)*yCenter;ticPositions + lineWidth;ones(1,nRatingSteps)*yCenter+tickHeight];

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
    loopTime = GetSecs;
    Screen('FillRect',window,backgroundColor);
    Screen('FillRect',window,scaleColor,axesRect);  

    Screen('FillRect',window,scaleColor,activeTicRects) 
        for j = 1:nRatingSteps
            textRect = Screen('TextBounds',window,ratingLabels{j});
            Screen('DrawText',window,ratingLabels{j},round(ticRects(1,j)-textRect(3)/2)+2,ticRects(4,j) + ticTextGap,scaleColor);
        end
    Screen('FillRect',window,scaleColor,activeTicRects)
    Screen('FillRect',window,activeColor,activeTicRects(:,currentRating));
   
    DrawFormattedText(window, 'Wie fühlen Sie sich gerade?', 'center',yCenter-100, scaleColor);
    
    Screen('DrawText',window,'sehr',axesRect(1)-17,yCenter+50,scaleColor);
    Screen('DrawText',window,'schlecht',axesRect(1)-30,yCenter+70,scaleColor);
  
    Screen('DrawText',window,'sehr',axesRect(3)-25,yCenter+50,scaleColor);
    Screen('DrawText',window,'gut',axesRect(3)-20,yCenter+70,scaleColor);
    
 
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
%                 disp(num2str(currentRating));
                if currentRating > nRatingSteps
                    currentRating = nRatingSteps;
                end
            elseif keyCode(lessKey)
                currentRating = currentRating - 1;
                finalRating = currentRating;
                response = 0;
%                 disp(num2str(currentRating));
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
                finalRating = currentRating-4;
                disp(['Mood Rating: ' num2str(finalRating)]);
                if finalRating < 0
                    warning(sprintf('\n***********\n***********\nParticipant does not feel good!\nPlease check participant!!!\n***********\n***********\n'));
                end
                response = 1;
                reactionTime = secs - secs0;
                
                
                Screen('FillRect', window, backgroundColor, windowRect);           
                Screen('Flip', window);
%                 flip_confKey = GetSecs; VASoff = GetSecs-StartExp;
%                 numberOfSecondsRemaining_sharp = durRating-(flip_confKey-startTime);
%                 WaitSecs(numberOfSecondsRemaining_sharp);
                break;
            end
            WaitSecs(0.15);
        end
    end
    
    numberOfSecondsElapsed   = (GetSecs - startTime);
    numberOfSecondsRemaining = durRating - numberOfSecondsElapsed;
    
%     if (GetSecs - loopTime) < 0.3
%         disp(GetSecs - loopTime);
%         WaitSecs(0.3 - loopTime);             
%     end
end
if nrbuttonpresses ~= 0 && response == 0
        finalRating = currentRating - 1;
        reactionTime = durRating;
        disp(['Mood Rating: ' num2str(finalRating)]);
        warning(sprintf('\n***********\n***********\nNo Confirmation!!!\n***********\n***********\n'));
elseif nrbuttonpresses == 0
        finalRating = NaN;
        reactionTime = durRating;
        disp(['Mood Rating: ' num2str(finalRating)]);
        warning(sprintf('\n***********\n***********\nNo Response!\nPlease check participant!!!\n***********\n***********\n'));
end

% toc



