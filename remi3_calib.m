function [p] = remi3_calib(subject)

if nargin == 0
    subject = 1;
end

fprintf(['Sub' num2str(subject)]);

temp_range = input('pain threshold (ll, l, n, h):  ','s');
if strcmp(temp_range,'ll')==1
    PainTemp = repmat([42 43 44 41 42.5 43.5 44.5 41 42 43] - 1,1,1);
elseif strcmp(temp_range,'l')==1
    PainTemp = repmat([42 43 44 41 NaN NaN 42.5 43.5 44.5 NaN 41 NaN 42 43 NaN NaN] ,1,1);
elseif strcmp(temp_range,'n')==1
    PainTemp = repmat([42 43 44 41 42.5 43.5 44.5 41 42 43] + 1,1,1);
elseif strcmp(temp_range,'h')==1
    PainTemp = repmat([42 43 44 41 42.5 43.5 44.5 41 42 43] + 2,1,1);
else
    error('check pain threshold input');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%% Put in your experiment choices here
debug       = 1;                                                           % Use this function to have a transparent screen                                                   % If on, waits for pulses and useses BrainVision Recorder marking BEFORE it marks CED. Otherwise, it only uses CED marking and sets BVR to 0
p_slave_on  = 0;                                                           % If on, waits for pulse from master and starts presentation at the same time.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 Initialize Experiment Environment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ListenChar(2);                                                             % Disable pressed keys to printed out
commandwindow;
%clear everything without using 'clear all'
clear mex global functions

%%%%%%%%%%%%%%%%%%%%%%%%%%% Load the GETSECS mex files so call them at
%%%%%%%%%%%%%%%%%%%%%%%%%%% least oncec
GetSecs;
WaitSecs(0.001);

SetParameters;

if strcmp(p.hostname,'triostim1')
    debug = 0;
end

SetPTB;


%%%%%%%%%%%%%%%%%%%%%%%%%%% Initialize all variables
nTrial                          = 0;
itiDuration                     = [];
CueDuration                     = [];
TimeCrossOn                     = [];
TimeCueOn                       = [];
TimeHeatOn                      = [];
TimeBlankOn                     = [];
p_stim_white                    = p.stim.white;
p_stim_red                      = p.stim.red;
p_stim_backgr                   = p.stim.backgr;
p_stim_sizeCross                = p.stim.sizeCross;
p_stim_widthCross               = p.stim.widthCross;
p_monitor_nx                    = p.monitor.Xaxis; % pixel x-axis
p_monitor_ny                    = p.monitor.Yaxis; % pixel y-axis
p_com_lpt_CEDaddress            = p.com.lpt.CEDaddress;
p_com_lpt_CEDduration           = p.com.lpt.CEDduration;
p_com_lpt_HeatOnset             = p.com.lpt.HeatOnset;
p_presentation_itiDuration      = p.presentation.itiDuration;
p_presentation_CueDuration      = p.presentation.CueDuration;
p_presentation_stimDuration     = p.presentation.stimDuration;
p_presentation_blankDuration    = p.presentation.blankDuration;
p_presentation_scaleDuration    = p.presentation.scaleDuration;
p_keys_nextStep                 = p.keys.nextStep;
p_ptb_w                         = p.ptb.w;
p_ptb_midpoint                  = p.ptb.midpoint;
p_ptb_midpoint_y                = p.ptb.midpoint(2);
p_ptb_rect                      = p.ptb.rect;
p_ptb_startY                    = p.ptb.startY;
p_text_linespace                = p.text.linespace;
p_ptb_lineheight                = p.ptb.lineheight;

% save again the parameter file
save(p.path.save ,'p');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%                  Run Experiment
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

putLog(GetSecs, 'Experiment Start');

% Show Instructions;
ShowInstruction;

% Actual stimulus presentation
runExperiment;

% Show SessionEnd
ShowEndSessionText;

cleanup;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%               End of Experiment
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% Set all parameters relevant for the whole experiment and the specific subject
    function SetParameters
        p.slave                        = p_slave_on;
        p.subinfo.subID                = subject;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%% create log structure
        p.log.mriExpStartTime          = 0;                                % Initialize as zero
        p.log.events                   = {{},{},{},{}}; % event count, real time, experiment duration, event string
        p.log.ratings                  = []; % event count, real time, experiment duration, event string
        p.log.eventCount               = 0;
        p.log.ratingEventCount         = 0;
        p.log.onratingEventCount       = 0;
        p.log.moodEventCount           = 0;
        p.log.scaleDefaultVAS          = [];
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%% relative paths to stim and experiments
        [~, hostname] = system('hostname');
        p.hostname                     = deblank(hostname);
        p.hostaddress = java.net.InetAddress.getLocalHost ;
        p.hostIPaddress = char( p.hostaddress.getHostAddress);
        if strcmp(p.hostname,'triostim1')
            p.path.experiment          = 'C:\USER\tinnermann\Paradigma\';
            p.monitor.Xaxis                = 1024; % stim PC resolution
            p.monitor.Yaxis                = 768; % stim PC resolution
        else
            p.path.experiment        = 'C:\Users\tinnermann\Documents\remi3\Paradigma\';
            p.monitor.Xaxis                = 1920; % stim PC resolution
            p.monitor.Yaxis                = 1200; % stim PC resolution
        end
        %
        p.subID                        = sprintf('sub%02d',subject);
        p.timestamp                    = datestr(now,30);
        
        p.path.subject                 = [p.path.experiment 'logs/' p.subID '_calib_' p.timestamp '/'];
        
        p.path.save                    = [p.path.subject  p.subID];
        %create folder hierarchy
        mkdir(p.path.subject);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%% font size, background gray level, monitor settings
        p.text.fontname                = 'Arial';
        p.text.fontsize                = 20; %30; %18;
        p.text.linespace               = 10;
        p.stim.white                   = [255 255 255];
        p.stim.red                     = [255 0 0];
        p.stim.backgr                  = [50 50 50];
        p.stim.widthCross              = 3;
        p.stim.sizeCross               = 20;
        p.MoodRating                   = [];
        p.Rating                       = [];
        
        if strcmp(p.hostname,'triostim1') % curdes button box single diamond (HID NAR 12345)
            p.keys.confirm             = KbName('3#'); % green button
            p.keys.right               = KbName('4$'); % red button
            p.keys.left                = KbName('2@'); % yellow button
            p.keys.esc                 = KbName('esc');
            p.keys.nextStep            = KbName('space');
            p.keys.trigger             = KbName('5%');
        else
            %All settings for laptop computer.
            KbName('UnifyKeyNames');
            p.keys.confirm             = KbName('Return');
            p.keys.right               = KbName('RightArrow');
            p.keys.left                = KbName('LeftArrow');
            p.keys.esc                 = KbName('Escape');
            p.keys.nextStep            = KbName('space');
            p.keys.trigger             = KbName('5');
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%% Parallel port settings
        if strcmp(p.hostname,'triostim1') % Heat trigger for thermode
            p.com.lpt.HeatOnset        = 4;
        else
            p.com.lpt.HeatOnset        = 255;
        end
        p.com.lpt.CEDaddress           = 888;
        p.com.lpt.CEDduration          = 0.005;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%% Stimulus sequence and startle timings
        p.presentation.stimDuration     = 17;
        p.presentation.blankDuration    = 0.3;
        iti                             = [8 8 9 9 10 10 11 11 12 12];
        p.presentation.tTrial           = 10;  %number of trials
        p.presentation.itiDuration      = iti(randperm(length(iti)));
        p.presentation.CueDuration      = 4;
        p.presentation.scaleDuration    = 12;
        p.presentation.scaleBackColor   = p.stim.backgr;
        p.temps                         = PainTemp;
        
        clearvars trialLists
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%% Save the parameters for this subject
        save(p.path.save ,'p');
    end

%% Set Up the PTB with parameters and initialize drivers
    function SetPTB
        screens                     =  Screen('Screens');                  % Find the number of the screen to be opened
        p.ptb.screenNumber          =  max(screens);                       % The maximum is the second monitor
        if debug
            commandwindow;
            PsychDebugWindowConfiguration;                                 % Make everything transparent for debugging purposes.
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%% Default parameters
        Screen('Preference', 'SkipSyncTests', 1);
        Screen('Preference', 'DefaultFontSize', p.text.fontsize);
        Screen('Preference', 'DefaultFontName', p.text.fontname);
        %Screen('Preference', 'TextAntiAliasing',2);                       % Enable textantialiasing high quality
        Screen('Preference', 'VisualDebuglevel', 0);                       % 0 disable all visual alerts
        %Screen('Preference', 'SkipSyncTests', 0);
        %Screen('Preference', 'SuppressAllWarnings', 0);
        if debug == 0;
            HideCursor(p.ptb.screenNumber);                                   % Hide the cursor
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%% Open a graphics window using PTB
        p.ptb.w                     = Screen('OpenWindow', p.ptb.screenNumber, p.stim.backgr);
        %         Screen('TextStyle', p.ptb.w, 1);                                 % Make Text Bold
        Screen('Flip',p.ptb.w);                                            % Make the bg
        p.ptb.slack                 = Screen('GetFlipInterval',p.ptb.w)./2;
        %         [p.ptb.width, p.ptb.height] = Screen('WindowSize', p.ptb.screenNumber);
        p.ptb.rect                  = [0 0 p.monitor.Xaxis p.monitor.Yaxis];
        p.ptb.width                 = p.monitor.Xaxis;
        p.ptb.height                = p.monitor.Yaxis;
        p.ptb.midpoint              = [p.ptb.width./2 p.ptb.height./2];   % Find the mid position on the screen.
        
        p.ptb.startY                = p.monitor.Yaxis/4;
        p.ptb.lineheight = p.text.fontsize + p.text.linespace;
        
        p.ptb.whiteFix1 = [p.ptb.midpoint(1)-p.stim.sizeCross p.ptb.startY-p.stim.widthCross p.ptb.midpoint(1)+p.stim.sizeCross p.ptb.startY+p.stim.widthCross];
        p.ptb.whiteFix2 = [p.ptb.midpoint(1)-p.stim.widthCross p.ptb.startY-p.stim.sizeCross p.ptb.midpoint(1)+p.stim.widthCross p.ptb.startY+p.stim.sizeCross];
        %         p.ptb.imrect                = [ p.ptb.midpoint(1)-p.stim.width/2 p.ptb.midpoint(2)-p.stim.height/2 p.stim.width p.stim.height];
        
        p.ptb.priorityLevel=MaxPriority('GetSecs','KbCheck','KbWait');
        Priority(MaxPriority(p.ptb.w));
        p.ptb.device        = [];
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%% Parallel port communication.
        config_io;
        outp(p.com.lpt.CEDaddress,0);
        
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       Functions collection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Start the actual experiment
    function runExperiment
        for nTrial  = 1:p.presentation.tTrial;                             % Enter the presentation loop
            itiDuration     = p_presentation_itiDuration(nTrial);
            CueDuration     = p_presentation_CueDuration;
            
            if nTrial == 1                                                 % Turn on the fixation cross for the first trial. These have to be done before the main for loop.
                Screen('FillRect', p_ptb_w, p_stim_white, p.ptb.whiteFix1);
                Screen('FillRect', p_ptb_w, p_stim_white, p.ptb.whiteFix2);
                TimeCrossOn = Screen('Flip',p_ptb_w);                      % gets timing of event for putLog
                putLog(TimeCrossOn, 'FirstITIOnset');                      % Log the cross onset...
                fprintf('=================\n=================\nFirst ITI, waiting for 5 seconds\n=================\n=================\n');
                while GetSecs < TimeCrossOn + 5 end
            end
            
            p.log.scaleDefaultVAS1(nTrial,1) = randi([20,81]);
            
            Trial(itiDuration);
            
        end
        
        while 1
            [keyIsDown, End, keyCode] = KbCheck;      % Start waiting 1/2 TR before JitterOnset for next pulse (this avoids collecting Pulses before).
            if keyIsDown
                if keyCode(p_keys_nextStep);
                    break;
                end
            end
        end
        
        putLog(GetSecs, 'ExpEnd');
    end

%% Present affective Picture
    function Trial(itiDuration) %Trial(stimID,stimName,stimStrlOnset,itiDuration,itiStrlOnset,jitter)
        
        %cue
        Screen('FillRect', p_ptb_w, p_stim_red, p.ptb.whiteFix1);
        Screen('FillRect', p_ptb_w, p_stim_red, p.ptb.whiteFix2);
        TimeCueOn = Screen('Flip',p_ptb_w);
        putLog(TimeCueOn, 'CueOnset');
        fprintf('Cue on\n');
        while GetSecs < TimeCueOn + CueDuration end
        
        %Pain
        Screen('FillRect', p_ptb_w, p_stim_red, p.ptb.whiteFix1); % no treatment condition
        Screen('FillRect', p_ptb_w, p_stim_red, p.ptb.whiteFix2);
        TimeHeatOn = Screen('Flip',p_ptb_w);
        putLog(TimeHeatOn, 'HeatOnset');
        putMark(p_com_lpt_HeatOnset);
        fprintf('Heat on\n');
        while GetSecs < TimeHeatOn + p_presentation_stimDuration end % = WaitSecs(p_presentation_stimDuration);
        
        %blank screen
        TimeBlankOn = Screen('Flip',p_ptb_w);
        while GetSecs < TimeBlankOn + p_presentation_blankDuration end % = WaitSecs(p_presentation_blankDuration);
        putLog(TimeBlankOn, 'BlankOnset');
        
        %VAS
        putLog(GetSecs, 'VASOnset');
        fprintf('VAS on\n');
        
        [p.rating.finalRating,p.rating.reactionTime,p.rating.response] = vasScale(p_ptb_w,p.ptb.rect,...
            p_presentation_scaleDuration,p.log.scaleDefaultVAS1(nTrial,1),p_stim_backgr,p_ptb_startY,p.keys); %
        putRatingLog(nTrial);
        p.Rating(nTrial) = p.rating.finalRating;
        
        %ITI
        Screen('FillRect', p_ptb_w, p_stim_white, p.ptb.whiteFix1);
        Screen('FillRect', p_ptb_w, p_stim_white, p.ptb.whiteFix2);
        TimeCrossOn = Screen('Flip',p_ptb_w);
        putLog(TimeCrossOn, 'ITIOnset');
        fprintf(['ITI duration: ' num2str(itiDuration) '\n']);
        while GetSecs < (TimeCrossOn + itiDuration) end
        
        save(p.path.save ,'p');
    end

%% Instruction Text
    function ShowInstruction
        
        p_monitor_ny = p.monitor.Yaxis/8;
        [p_monitor_nx, p_monitor_ny, textbounds]=DrawFormattedText(p_ptb_w, 'Wir beginnen nun mit der Kalibrierung.', 'center', p_monitor_ny, p_stim_white);
        [p_monitor_nx, p_monitor_ny, textbounds]=DrawFormattedText(p_ptb_w, '', 'center', p_monitor_ny+p_ptb_lineheight, p_stim_white);
        
        introTextTime = Screen('Flip',p_ptb_w);
        putLog(introTextTime,'IntroTextOn');
        WaitSecs(1);
        
        while 1
            [keyIsDown, ~, keyCode] = KbCheck();      % Start waiting 1/2 TR before JitterOnset for next pulse (this avoids collecting Pulses before).
            if keyIsDown
                if find(keyCode) == p_keys_nextStep;
                    break;
                end
            end
        end
        
        StartWaitTime = Screen('Flip',p_ptb_w);
        putLog(StartWaitTime, 'WaitForExpStartOnset');
        
    end

%% End session Text
    function ShowEndSessionText
        
        [p_monitor_nx, p_monitor_ny, textbounds]=DrawFormattedText(p_ptb_w, 'Ende der Kalibrierung.', 'center', p.ptb.start, p_stim_white);
        [p_monitor_nx, p_monitor_ny, textbounds]=DrawFormattedText(p_ptb_w, 'Es geht gleich weiter!', 'center', p_monitor_ny+p_ptb_lineheight, p_stim_white);
        [p_monitor_nx, p_monitor_ny, textbounds]=DrawFormattedText(p_ptb_w, 'Bitte weiterhin ganz ruhig liegen bleiben!', 'center', p_monitor_ny+p_ptb_lineheight, p_stim_white);
        
        
        endTextTime = Screen('Flip',p_ptb_w);
        putLog(endTextTime,'EndTextOn');
        
        WaitSecs(1);
        
        while 1
            [keyIsDown, ~, keyCode] = KbCheck();      % Start waiting 1/2 TR before JitterOnset for next pulse (this avoids collecting Pulses before).
            if keyIsDown
                if find(keyCode) == p_keys_nextStep;
                    break;
                end
            end
        end
    end


%% Set Marker for CED and BrainVision Recorder
    function putMark(port)
        % Send pulse to CED for SCR, thermode, digitimer
        %       [handle, errmsg] = IOPort('OpenSerialport',num2str(port));
        outp(p_com_lpt_CEDaddress,port);
        WaitSecs(p_com_lpt_CEDduration);
        outp(p_com_lpt_CEDaddress,0);
        %         IOPort('CloseAll');
    end

%% Log all events
    function putLog(ptb_time, event_info)
        p.log.eventCount                    = p.log.eventCount + 1;
        p.log.events(p.log.eventCount,1)    = {p.log.eventCount};
        p.log.events(p.log.eventCount,2)    = {ptb_time};
        p.log.events(p.log.eventCount,3)    = {ptb_time-p.log.mriExpStartTime};
        p.log.events(p.log.eventCount,4)    = {event_info};
    end
    function putRatingLog(currentTrial)
        p.log.ratingEventCount                      = p.log.ratingEventCount + 1;
        p.log.ratings(p.log.rating1EventCount,1)    = currentTrial;
        p.log.ratings(p.log.rating1EventCount,2)    = p.rating.finalRating;
        p.log.ratings(p.log.rating1EventCount,3)    = p.rating.response;
        p.log.ratings(p.log.rating1EventCount,4)    = p.rating.reactionTime;
    end
%% After experiment is over clean everything and close drivers
    function cleanup
        sca;                                                               % Close window:
        commandwindow;
        ListenChar(0);                                                     % Use keys again
        %KbQueueRelease(p_ptb_device);
        save(p.path.save ,'p');
        if run == 4
            diary off;
        end
    end

end





