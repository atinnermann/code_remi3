function [conRating,conTime,response] = onlineScale(window,windowRect,durRating,backgroundColor,StartY,keys,starTime)

%% key settings
KbName('UnifyKeyNames');
lessKey =  keys.left; % yellow button
moreKey =  keys.right; % red button
escapeKey = keys.nextStep;

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
defaultRating = 1;
if isempty(backgroundColor); backgroundColor = 0; end
if isempty(starTime); starTime = 0; end

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
midLabelRect = [xCenter-3,yCenter-20,xCenter+3,yCenter+20];
midlLabelRect = [xCenter-3-scaleWidth/4,yCenter-20,xCenter+3-scaleWidth/4,yCenter+20];
midhLabelRect = [xCenter-3+ scaleWidth/4,yCenter-20,xCenter+3+scaleWidth/4,yCenter+20];
ticPositions = linspace(xCenter - scaleWidth/2,xCenter + scaleWidth/2-lineWidth,nRatingSteps);
activeTicRects = [ticPositions-activeAddon_width;ones(1,nRatingSteps)*yCenter-activeAddon_height;ticPositions + lineWidth+activeAddon_width;ones(1,nRatingSteps)*yCenter+activeAddon_height];

Screen('TextSize',window,textSize);
Screen('TextColor',window,[255 255 255]);
Screen('TextFont', window, 'Arial');
currentRating = defaultRating;
finalRating = currentRating;
response = 0;

numberOfSecondsRemaining = durRating;
conRating = 0;
conTime = 0;


%%%%%%%%%%%%%%%%%%%%%%% loop while there is time %%%%%%%%%%%%%%%%%%%%%
% tic; % control if timing is as long as durRating

startTime = GetSecs;
while numberOfSecondsRemaining  > 0
   
    Screen('FillRect',window,backgroundColor); 
    Screen('FillRect',window,activeColor,[activeTicRects(1,1)+3 activeTicRects(2,1)+ 5 activeTicRects(3,currentRating)-3 activeTicRects(4,1)-5]);   
    Screen('FillRect',window,scaleColor,lowLabelRect);   
    Screen('FillRect',window,scaleColor,highLabelRect);    
    Screen('FillRect',window,scaleColor,midLabelRect); 
    Screen('FillRect',window,scaleColor,midlLabelRect);  
    Screen('FillRect',window,scaleColor,midhLabelRect);
  
%     DrawFormattedText(window, 'Bitte bewerten Sie die Schmerzhaftigkeit', 'center',yCenter-100, scaleColor);  
%     DrawFormattedText(window, 'des Hitzereizes', 'center',yCenter-70, scaleColor);   
    
    Screen('DrawText',window,'kein',axesRect(1)-17,yCenter+25,scaleColor);
    Screen('DrawText',window,'Schmerz',axesRect(1)-40,yCenter+45,scaleColor);
      
    Screen('DrawText',window,'unerträglicher',axesRect(3)-55,yCenter+25,scaleColor); 
    Screen('DrawText',window,'Schmerz',axesRect(3)-40,yCenter+45,scaleColor);
    
    if (numberOfSecondsRemaining <= (durRating - (durRating/2.5) + 0.01)) && (numberOfSecondsRemaining >= (durRating - (durRating/2.5)- starTime - 0.01))
%         disp(GetSecs-startTime);
        Screen('TextSize',window,70);
        Screen('DrawText',window,'*',xCenter-12,yCenter-70,scaleColor);       
    end
    Screen('Flip', window);
    Screen('TextSize',window,textSize);
        
    [keyIsDown,secs,keyCode] = KbCheck; % this checks the keyboard very, very briefly.
        
        if keyIsDown % only if a key was pressed we check which key it was
            response = 1;          
            if keyCode(moreKey) % if it was the key we named key1 at the top then...
                currentRating = currentRating + 1;
                if currentRating > nRatingSteps
                    currentRating = nRatingSteps;
                end  
                finalRating = currentRating - 1;
                conRating(end+1) = finalRating;
                conTime(end+1) = GetSecs - startTime; 
            elseif keyCode(lessKey)
                currentRating = currentRating - 1;                
                if currentRating < 1
                    currentRating = 1;
                end
                finalRating = currentRating - 1;
                conRating(end+1) = finalRating;
                conTime(end+1) = GetSecs - startTime;
%             elseif keyCode(escapeKey)
%                 disp(['Middle Pain: ' num2str(GetSecs - startTime)]);
            end
        end
      
        conRating(end+1) = finalRating;         
        conTime(end+1) = GetSecs - startTime;
   
        numberOfSecondsElapsed   = (GetSecs - startTime);
        numberOfSecondsRemaining = durRating - numberOfSecondsElapsed;
       
%     if ((GetSecs - loopTime + lt) <= 0.055 && (GetSecs - loopTime + lt) >= 0.045) && log == 0
%         conRating2(end+1) = finalRating;
%         conTime2(end+1) = GetSecs - startTime;
%         log = 1;
%         loopTime = GetSecs;
%         disp(GetSecs - loopTime + lt);
%     end
    
end
% figure;plot(conTime,conRating);

