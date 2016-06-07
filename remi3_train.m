function [p] = remi3_train(subject)

if nargin == 0
    subject = 1;
end

fprintf(['Sub' num2str(subject) '\n']);

temp_range = input('pain threshold (ll, l, n, h, hh):  ','s');
% if strcmp(temp_range,'ll')==1
%     PainTemp = [41 42 43 44 40 42.5 43.5 44.5 45.5 42 43 44 45 42 43 44] - 2;
%     RealTemp = [42 43 44 45 41 42.5 44 43.5 42 44.5 45.5 41 42 43 44 44 45 42 42.5 43 44 43 ] - 2;
if strcmp(temp_range,'ll')==1
    PainTemp = [42 43 44 45 41 42.5 43.5 44.5 45.5 42 43 44 45 42 43 44] - 1;
    RealTemp = [42 43 44 45 41 42.5 44 43.5 42 44.5 45.5 41 42 43 44 44 45 42 42.5 43 44 43] - 1;
elseif strcmp(temp_range,'l')==1
    PainTemp = [42 43 44 45 41 42.5 43.5 44.5 45.5 42 43 44 45 42 43 44];
    RealTemp = [42 43 44 45 41 42.5 44 43.5 42 44.5 45.5 41 42 43 44 44 45 42 42.5 43 44 43];
elseif strcmp(temp_range,'n')==1
    PainTemp = [42 43 44 45 41 42.5 43.5 44.5 45.5 42 43 44 45 42 43 44] + 1;
    RealTemp = [42 43 44 45 41 42.5 44 43.5 42 44.5 45.5 41 42 43 44 44 45 42 42.5 43 44 43] + 1;
elseif strcmp(temp_range,'h')==1
    PainTemp = [42 43 44 45 41 42.5 43.5 44.5 45.5 42 43 44 45 42 43 44] + 2;
    RealTemp = [42 43 44 45 41 42.5 44 43.5 42 44.5 45.5 41 42 43 44 44 45 42 42.5 43 44 43] + 2;
else
    error('check pain threshold input');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%% Put in your experiment choices here
debug       = 1;                                                           % Use this function to have a transparent screen
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
stimName                        = [];
itiDuration                     = [];
CueDuration                     = [];
TimeCrossOn                     = [];
TimeCueOn                       = [];
TimeHeatOn                      = [];
TimeStarOn                      = [];
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
p_presentation_TrialList        = p.trialList ;
p_presentation_CueDuration      = p.presentation.CueDuration;
p_presentation_stimDuration     = p.presentation.stimDuration;
p_presentation_blankDuration    = p.presentation.blankDuration;
p_presentation_scaleDuration    = p.presentation.scaleDuration;
p_presentation_itiDuration      = p.presentation.iti;
p_keys_trigger                  = p.keys.trigger;
p_keys_nextStep                 = p.keys.nextStep;
p_keys_confirm                  = p.keys.confirm;
p_ptb_w                         = p.ptb.w;
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
        p.log.ratings1                 = []; % event count, real time, experiment duration, event string
        p.log.ratings2                 = [];
        p.log.eventCount               = 0;
        p.log.ratingEventCount         = 0;
        p.log.rating1EventCount        = 0;
        p.log.rating2EventCount        = 0;
        p.log.onratingEventCount       = 0;
        p.log.moodEventCount           = 0;
        p.log.scaleDefaultVAS          = 0;
        p.log.scaleDefaultVAS1         = [];
        p.log.scaleDefaultVAS2         = [];
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%% relative paths to stim and experiments
        [~, hostname] = system('hostname');
        p.hostname                     = deblank(hostname);
        p.hostaddress = java.net.InetAddress.getLocalHost ;
        p.hostIPaddress = char( p.hostaddress.getHostAddress);
        if strcmp(p.hostname,'triostim1')
            p.path.experiment          = 'C:\USER\tinnermann\remi3\Paradigma';
            p.monitor.Xaxis                = 1024; % stim PC resolution
            p.monitor.Yaxis                = 768; % stim PC resolution
        else
            p.path.experiment        = 'C:\Users\tinnermann\Documents\remi3\Paradigma_von_MRT\';
            p.monitor.Xaxis                = 1920; % stim PC resolution
            p.monitor.Yaxis                = 1200; % stim PC resolution
        end
        %
        p.subID                        = sprintf('sub%02d',subject);
        p.timestamp                    = datestr(now,30);
        
        p.path.subject                 = [p.path.experiment '/logs/' p.subID '/'];
        
        p.path.save                    = [p.path.subject  p.subID '_train'];
        %create folder hierarchy
        mkdir(p.path.subject);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%% font size, background gray level, monitor settings
        p.text.fontname                = 'Arial';
        p.text.fontsize                = 20; %30; %18;
        p.text.linespace               = 10;
        p.stim.white                   = [255 255 255];
        p.stim.red                     = [255 0 0];
        p.stim.backgr                  = [70 70 70];
        p.stim.widthCross              = 3;
        p.stim.sizeCross               = 20;
        p.MoodRating                   = [];
        p.Rating                       = [];
        p.Rating1                      = [];
        p.Rating2                      = [];
        
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
        if strcmp(p.hostname,'triostim1')
            p.com.lpt.HeatOnset        = 4;  % Heat trigger for thermode 
        else
            p.com.lpt.HeatOnset        = 255;  
        end
        p.com.lpt.CEDaddress           = 888;
        p.com.lpt.CEDduration          = 0.005;
             
        %%%%%%%%%%%%%%%%%%%%%%%%%%% Stimulus sequence and startle timings
        p.presentation.stimDuration     = 17;
        p.presentation.blankDuration    = 0.5;
        iti                             = [6 6 6 6.5 6.5 7 7 7.5 7.5 8 8 8.5 8.5 9 9 9];
        p.presentation.iti              = iti(randperm(length(iti)));
        p.trialList                     = [1 1 1 1 1 2 2 1 2 1 2 1 1 2 1 2];
        p.realTrialList                 = [1 1 1 1 1 2 3 2 3 1 2 3 1 2 3 1 1 2 3 1 2 3];
        p.presentation.tTrial           = length(p.trialList);  %number of trials
        p.presentation.CueDuration      = 4;
        p.presentation.scaleDuration    = 8;
        p.presentation.scaleBackColor   = p.stim.backgr;
        p.presentation.StarOn           = 0.6;
        p.temps                         = PainTemp;
        p.realtemps                     = RealTemp;
        
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
        for nTrial  = 1:p.presentation.tTrial; % Enter the presentation loop
            stimName        = p_presentation_TrialList(nTrial);
            CueDuration     = p_presentation_CueDuration;
            itiDuration     = p_presentation_itiDuration(nTrial);
            
            if nTrial == 1
                ShowInstruction_vas
            elseif nTrial == 5
                ShowInstruction_star
            elseif nTrial == 9
                ShowInstruction_on
            elseif nTrial == 13
                ShowInstruction_all
            end
            fprintf('%d of %d,  Stim: %d, CueDuration: %d, itiDuration: %d \n',nTrial,p.presentation.tTrial, stimName(1), CueDuration, itiDuration);
            
            p.log.scaleDefaultVAS(nTrial,1) = randi([30,71]);
            p.log.scaleDefaultVAS1(nTrial,1) = randi([30,71]);
            p.log.scaleDefaultVAS2(nTrial,1) = randi([30,71]);
            p.log.scaleDefaultMood(nTrial,1) = randi([2,6]);
            
            if find(nTrial == 1:4)
                Trial(itiDuration);
            elseif find(nTrial == 5:8)
                Trial_star(itiDuration);
            elseif find(nTrial == 9:12)
                Trial_on(itiDuration);
            elseif find(nTrial == 13:16)
                Trial_all(itiDuration);
            end
        end
        
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
%%
    function Trial_star(itiDuration) %Trial(stimID,stimName,stimStrlOnset,itiDuration,itiStrlOnset,jitter)
        
        %cue
        Screen('FillRect', p_ptb_w, p_stim_red, p.ptb.whiteFix1);
        Screen('FillRect', p_ptb_w, p_stim_red, p.ptb.whiteFix2);
        TimeCueOn = Screen('Flip',p_ptb_w);
        putLog(TimeCueOn, 'CueOnset');
        fprintf('Cue on\n');
        while GetSecs < TimeCueOn + CueDuration end
        
        % Pain
        Screen('FillRect', p_ptb_w, p_stim_red, p.ptb.whiteFix1); % no treatment condition
        Screen('FillRect', p_ptb_w, p_stim_red, p.ptb.whiteFix2);
        TimeHeatOn = Screen('Flip',p_ptb_w);
        putMark(p_com_lpt_HeatOnset);
        putLog(TimeHeatOn, 'HeatOnset');
        fprintf('Heat on\n');
        while GetSecs < TimeHeatOn + (p_presentation_stimDuration/2.5) end % = WaitSecs(p_presentation_stimDuration);
        %Show star for rating
        Screen('TextSize',p_ptb_w,p.text.fontsize+40);
        Screen('FillRect', p_ptb_w, p_stim_red, p.ptb.whiteFix1); % no treatment condition
        Screen('FillRect', p_ptb_w, p_stim_red, p.ptb.whiteFix2);
        Screen('DrawText', p_ptb_w,'*',p.ptb.midpoint(1)-12,p.ptb.startY-60,p_stim_white);
        TimeStarOn = Screen('Flip',p_ptb_w);
        putLog(TimeStarOn, 'StarOnset');
        fprintf('Star on\n');
        
        while GetSecs < TimeStarOn + p.presentation.StarOn end % = WaitSecs(p_presentation_stimDuration);
        
        Screen('FillRect', p_ptb_w, p_stim_red, p.ptb.whiteFix1); % no treatment condition
        Screen('FillRect', p_ptb_w, p_stim_red, p.ptb.whiteFix2);
        TimeHeatOn = Screen('Flip',p_ptb_w);
        
        while GetSecs < TimeStarOn + (p_presentation_stimDuration - (p_presentation_stimDuration/2.5)) end
        
        %blank screen
        TimeBlankOn = Screen('Flip',p_ptb_w);
        while GetSecs < TimeBlankOn + p_presentation_blankDuration end % = WaitSecs(p_presentation_blankDuration);
        putLog(TimeBlankOn, 'BlankOnset');
        
        %VAS T2
        putLog(GetSecs, 'VAS1Onset');
        fprintf('VAS_T2 on\n');
        
        [p.rating1.finalRating,p.rating1.reactionTime,p.rating1.response] = vasScaleT2(p_ptb_w,p.ptb.rect,...
            p_presentation_scaleDuration,p.log.scaleDefaultVAS1(nTrial,1),p_stim_backgr,p_ptb_startY,p.keys); %
        putRating1Log(nTrial);
        p.Rating1(nTrial) = p.rating1.finalRating;
        
        %blank screen
        TimeBlankOn = Screen('Flip',p_ptb_w);
        putLog(TimeBlankOn, 'BlankOnset');
        while GetSecs < TimeBlankOn + p_presentation_blankDuration end % = WaitSecs(p_presentation_blankDuration);
        
        %VAS T3
        putLog(GetSecs, 'VAS2Onset');
        fprintf('VAS_T3 on\n');
        
        [p.rating2.finalRating,p.rating2.reactionTime,p.rating2.response] = vasScaleT3(p_ptb_w,p.ptb.rect,...
            p_presentation_scaleDuration-2,p.log.scaleDefaultVAS2(nTrial,1),p_stim_backgr,p_ptb_startY,p.keys,p.rating1.finalRating); %
        putRating2Log(nTrial);
        p.Rating2(nTrial) = p.rating2.finalRating;
        
        Screen('FillRect', p_ptb_w, p_stim_white, p.ptb.whiteFix1);
        Screen('FillRect', p_ptb_w, p_stim_white, p.ptb.whiteFix2);
        TimeCrossOn = Screen('Flip',p_ptb_w);
        putLog(TimeCrossOn, 'ITIOnset');
        fprintf(['ITI duration: ' num2str(itiDuration) '\n']);
        while GetSecs < (TimeCrossOn + itiDuration) end
        
        save(p.path.save ,'p');
    end
%%
    function Trial_on(itiDuration) %Trial(stimID,stimName,stimStrlOnset,itiDuration,itiStrlOnset,jitter)
        
        %Cue
        Screen('FillRect', p_ptb_w, p_stim_red, p.ptb.whiteFix1);
        Screen('FillRect', p_ptb_w, p_stim_red, p.ptb.whiteFix2);
        TimeCueOn = Screen('Flip',p_ptb_w);
        putLog(TimeCueOn, 'CueOnset');
        fprintf('Cue on\n');
        while GetSecs < TimeCueOn + CueDuration end
        
        %Pain
        TimeHeatOn = GetSecs;
        putMark(p_com_lpt_HeatOnset);
        putLog(TimeHeatOn, 'HeatOnset');
        fprintf('Heat on\n');
        [p.onrating.conRating,p.onrating.conTime,p.onrating.response] = onlineScale(p_ptb_w,p.ptb.rect,...
            p_presentation_stimDuration,p_stim_backgr,p_ptb_startY,p.keys,0); %
        putOnRatingLog(nTrial);
        figure;plot(p.onrating.conRating);
        
        %blank screen
        TimeBlankOn = Screen('Flip',p_ptb_w);
        while GetSecs < TimeBlankOn + p_presentation_blankDuration end % = WaitSecs(p_presentation_blankDuration);
        putLog(TimeBlankOn, 'BlankOnset');
        
        Screen('FillRect', p_ptb_w, p_stim_white, p.ptb.whiteFix1);
        Screen('FillRect', p_ptb_w, p_stim_white, p.ptb.whiteFix2);
        TimeCrossOn = Screen('Flip',p_ptb_w);
        putLog(TimeCrossOn, 'ITIOnset');
        fprintf(['ITI duration: ' num2str(itiDuration) '\n']);
        while GetSecs < (TimeCrossOn + itiDuration) end
        
        save(p.path.save ,'p');
    end
%%
    function Trial_all(itiDuration) %Trial(stimID,stimName,stimStrlOnset,itiDuration,itiStrlOnset,jitter)
        
        %cue
        if nTrial == 13 || nTrial == 16
            DrawFormattedText(p_ptb_w, 'Im nächsten Durchgang bewerten Sie bitte', 'center',p_ptb_startY-100, p_stim_white);
            DrawFormattedText(p_ptb_w, 'die Schmerzhaftigkeit WÄHREND des Hitzereizes!', 'center',p_ptb_startY-70, p_stim_white);
        end
        Screen('FillRect', p_ptb_w, p_stim_red, p.ptb.whiteFix1);
        Screen('FillRect', p_ptb_w, p_stim_red, p.ptb.whiteFix2);
        TimeCueOn = Screen('Flip',p_ptb_w);
        putLog(TimeCueOn, 'CueOnset');
        p.reactionTime(nTrial) = getRT(p_presentation_CueDuration,TimeCueOn);  % check reaction time during cue
        if nTrial > 1
            if isnan(p.reactionTime(end)) && isnan(p.reactionTime(end-1))
                warning(sprintf('\n***********\n***********\nNo RT for 2 Trials!\nPlease check participant!!!\n***********\n***********\n'));
            end
        end
        
        %Pain
        if nTrial == 13 || nTrial == 16
            TimeHeatOn = GetSecs;
            putMark(p_com_lpt_HeatOnset);
            putLog(TimeHeatOn, 'HeatOnset');
            fprintf('Heat on\n');
            [p.onrating.conRating,p.onrating.conTime,p.onrating.response] = onlineScale(p_ptb_w,p.ptb.rect,...
                p_presentation_stimDuration,p_stim_backgr,p_ptb_startY,p.keys,p.presentation.StarOn); %
            putOnRatingLog(nTrial);
            figure;plot(p.onrating.conRating);
            
        else % only showing cross during pain
            Screen('FillRect', p_ptb_w, p_stim_red, p.ptb.whiteFix1); % no treatment condition
            Screen('FillRect', p_ptb_w, p_stim_red, p.ptb.whiteFix2);
            TimeHeatOn = Screen('Flip',p_ptb_w);
            putMark(p_com_lpt_HeatOnset);
            putLog(TimeHeatOn, 'HeatOnset');
            fprintf('Heat on\n');
            while GetSecs < TimeHeatOn + (p_presentation_stimDuration/2.5) end % = WaitSecs(p_presentation_stimDuration);
            %Show star for rating
            Screen('TextSize',p_ptb_w,p.text.fontsize+40);
            Screen('FillRect', p_ptb_w, p_stim_red, p.ptb.whiteFix1); % no treatment condition
            Screen('FillRect', p_ptb_w, p_stim_red, p.ptb.whiteFix2);
            Screen('DrawText', p_ptb_w,'*',p.ptb.midpoint(1)-12,p.ptb.startY-60,p_stim_white);
            TimeStarOn = Screen('Flip',p_ptb_w);
            putLog(TimeStarOn, 'StarOnset');
            fprintf('Star on\n');
            
            
            
            
            while GetSecs < TimeStarOn + p.presentation.StarOn end % = WaitSecs(p_presentation_stimDuration);
            
            Screen('FillRect', p_ptb_w, p_stim_red, p.ptb.whiteFix1); % no treatment condition
            Screen('FillRect', p_ptb_w, p_stim_red, p.ptb.whiteFix2);
            TimeHeatOn = Screen('Flip',p_ptb_w);
            
            while GetSecs < TimeStarOn + (p_presentation_stimDuration - (p_presentation_stimDuration/2.5)) end
            
        end
        
        %blank screen
        TimeBlankOn = Screen('Flip',p_ptb_w);
        while GetSecs < TimeBlankOn + p_presentation_blankDuration end % = WaitSecs(p_presentation_blankDuration);
        putLog(TimeBlankOn, 'BlankOnset');
        
        %VAS T2
        putLog(GetSecs, 'VAS1Onset');
        fprintf('VAS_T2 on\n');
        
        [p.rating1.finalRating,p.rating1.reactionTime,p.rating1.response] = vasScaleT2(p_ptb_w,p.ptb.rect,...
            p_presentation_scaleDuration,p.log.scaleDefaultVAS1(nTrial,1),p_stim_backgr,p_ptb_startY,p.keys); %
        putRating1Log(nTrial);
        p.Rating1(nTrial) = p.rating1.finalRating;
        
        %blank screen
        TimeBlankOn = Screen('Flip',p_ptb_w);
        putLog(TimeBlankOn, 'BlankOnset');
        while GetSecs < TimeBlankOn + p_presentation_blankDuration end % = WaitSecs(p_presentation_blankDuration);
        
        %VAS T3
        putLog(GetSecs, 'VAS2Onset');
        fprintf('VAS_T3 on\n');
        
        [p.rating2.finalRating,p.rating2.reactionTime,p.rating2.response] = vasScaleT3(p_ptb_w,p.ptb.rect,...
            p_presentation_scaleDuration-2,p.log.scaleDefaultVAS2(nTrial,1),p_stim_backgr,p_ptb_startY,p.keys,p.rating1.finalRating); %
        putRating2Log(nTrial);
        p.Rating2(nTrial) = p.rating2.finalRating;
        
        %blank screen
        TimeBlankOn = Screen('Flip',p_ptb_w);
        while GetSecs < TimeBlankOn + p_presentation_blankDuration end % = WaitSecs(p_presentation_blankDuration);
        putLog(TimeBlankOn, 'BlankOnset');
        
        %Mood
        putLog(GetSecs, 'MoodOnset');
        fprintf('Mood on\n');
        
        [p.mood.finalRating,p.mood.reactionTime,p.mood.response] = moodScale(p_ptb_w,p.ptb.rect,...
            p_presentation_scaleDuration-4,p.log.scaleDefaultMood(nTrial,1),p_stim_backgr,p_ptb_startY,p.keys); %p.log.scaleDefaultVAS(nTrial,1)
        putMoodLog(nTrial);
        p.MoodRating(nTrial) = p.mood.finalRating;
        if nTrial > 1
            if p.MoodRating(end)+2 <= p.MoodRating(end-1)
                warning(sprintf('\n***********\n***********\nParticipant rated 2 points less!\nPlease check participant!!!\n***********\n***********\n'));
            end
        end
        
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
        [p_monitor_nx, p_monitor_ny, textbounds]=DrawFormattedText(p_ptb_w, 'Nun beginnt das Training.', 'center', p_monitor_ny, p_stim_white);
        [p_monitor_nx, p_monitor_ny, textbounds]=DrawFormattedText(p_ptb_w, 'Bitte lesen Sie sich die Instruktion vor jedem Block sorgfältig durch!', 'center', p_monitor_ny+p_ptb_lineheight, p_stim_white);
        introTextTime = Screen('Flip',p_ptb_w);
        putLog(introTextTime,'IntroTextOn');
        WaitSecs(1);
        
        while 1
            [keyIsDown, ~, keyCode] = KbCheck();      % Start waiting 1/2 TR before JitterOnset for next pulse (this avoids collecting Pulses before).
            if keyIsDown
                if find(keyCode) == p_keys_confirm;
                    break;
                end
            end
        end
        
        StartWaitTime = Screen('Flip',p_ptb_w);
        putLog(StartWaitTime, 'WaitForExpStartOnset');
        
    end
%% Instruction Text
    function ShowInstruction_vas
        
        p_monitor_ny = p.monitor.Yaxis/8;
        [p_monitor_nx, p_monitor_ny, textbounds]=DrawFormattedText(p_ptb_w, 'Nach jedem Hitzereiz erscheint nun eine Skala.', 'center', p_monitor_ny, p_stim_white);
        [p_monitor_nx, p_monitor_ny, textbounds]=DrawFormattedText(p_ptb_w, 'Bitte bewerten Sie die Schmerzhaftigkeit des Hitzereizes mit dem roten Cursor.', 'center', p_monitor_ny+p_ptb_lineheight, p_stim_white);
        [p_monitor_nx, p_monitor_ny, textbounds]=DrawFormattedText(p_ptb_w, 'Mit dem Zeigefinger bewegt sich der Cursor nach links, mit dem Ringfinger', 'center', p_monitor_ny+p_ptb_lineheight, p_stim_white);
        [p_monitor_nx, p_monitor_ny, textbounds]=DrawFormattedText(p_ptb_w, 'nach rechts und mit dem Mittelfinger bestätigen Sie Ihre Auswahl.', 'center', p_monitor_ny+p_ptb_lineheight, p_stim_white);
        introTextTime = Screen('Flip',p_ptb_w);
        putLog(introTextTime,'IntroTextOn');
        WaitSecs(1);
        
        while 1
            [keyIsDown, ~, keyCode] = KbCheck();      % Start waiting 1/2 TR before JitterOnset for next pulse (this avoids collecting Pulses before).
            if keyIsDown
                if find(keyCode) == p_keys_confirm;
                    break;
                end
            end
        end
        
        StartWaitTime = Screen('Flip',p_ptb_w);
        putLog(StartWaitTime, 'WaitForConfirm');
        
    end
%% Instruction Text
    function ShowInstruction_star
        p_monitor_ny = p.monitor.Yaxis/8;
        [p_monitor_nx, p_monitor_ny, textbounds]=DrawFormattedText(p_ptb_w, 'Während des Hitzereizes wird nun ein Sternchen eingeblendet.', 'center', p_monitor_ny, p_stim_white);
        [p_monitor_nx, p_monitor_ny, textbounds]=DrawFormattedText(p_ptb_w, 'Bitte bewerten Sie anschließend auf 2 aufeinanderfoldenden Skalen,', 'center', p_monitor_ny+p_ptb_lineheight, p_stim_white);
        [p_monitor_nx, p_monitor_ny, textbounds]=DrawFormattedText(p_ptb_w, 'wie schmerzhaft der Reiz in den 5 Sekunden VOR dem Erscheinen des Sternchens und wie schmerzhaft der Reiz', 'center', p_monitor_ny+p_ptb_lineheight, p_stim_white);
        [p_monitor_nx, p_monitor_ny, textbounds]=DrawFormattedText(p_ptb_w, 'in den 5 Sekunden NACH dem Erscheinen des Sternchens war.', 'center', p_monitor_ny+p_ptb_lineheight, p_stim_white);
        introTextTime = Screen('Flip',p_ptb_w);
        putLog(introTextTime,'IntroTextOn');
        WaitSecs(1);
        
        while 1
            [keyIsDown, ~, keyCode] = KbCheck();      % Start waiting 1/2 TR before JitterOnset for next pulse (this avoids collecting Pulses before).
            if keyIsDown
                if find(keyCode) == p_keys_confirm;
                    break;
                end
            end
        end
        
        StartWaitTime = Screen('Flip',p_ptb_w);
        putLog(StartWaitTime, 'WaitForConfirm');
        
    end
%% Instruction Text
    function ShowInstruction_on
        p_monitor_ny = p.monitor.Yaxis/8;
        [p_monitor_nx, p_monitor_ny, textbounds]=DrawFormattedText(p_ptb_w, 'Nun erscheint eine Bewertungsskala während des Hitzereizes.', 'center', p_monitor_ny, p_stim_white);
        [p_monitor_nx, p_monitor_ny, textbounds]=DrawFormattedText(p_ptb_w, 'Bitte bewerten Sie über die gesamte Dauer des Hitzereizes den Schmerz', 'center', p_monitor_ny+p_ptb_lineheight, p_stim_white);
        [p_monitor_nx, p_monitor_ny, textbounds]=DrawFormattedText(p_ptb_w, 'indem Sie den Balken nach rechts oder links bewegen und machen Sie so', 'center', p_monitor_ny+p_ptb_lineheight, p_stim_white);
        [p_monitor_nx, p_monitor_ny, textbounds]=DrawFormattedText(p_ptb_w, 'Änderungen in Ihrem Schmerzempfinden deutlich.', 'center', p_monitor_ny+p_ptb_lineheight, p_stim_white);

        introTextTime = Screen('Flip',p_ptb_w);
        putLog(introTextTime,'IntroTextOn');
        WaitSecs(1);
        
        while 1
            [keyIsDown, ~, keyCode] = KbCheck();      % Start waiting 1/2 TR before JitterOnset for next pulse (this avoids collecting Pulses before).
            if keyIsDown
                if find(keyCode) == p_keys_confirm;
                    break;
                end
            end
        end
        
        StartWaitTime = Screen('Flip',p_ptb_w);
        putLog(StartWaitTime, 'WaitForConfirm');
        
    end
%% Instruction Text
    function ShowInstruction_all
        
        p_monitor_ny = p.monitor.Yaxis/8;
        [p_monitor_nx, p_monitor_ny, textbounds]=DrawFormattedText(p_ptb_w, 'Bitte bewerten Sie nun wieder den Schmerz vor und nach dem Sternchen.', 'center', p_monitor_ny, p_stim_white);
        [p_monitor_nx, p_monitor_ny, textbounds]=DrawFormattedText(p_ptb_w, 'In einigen Durchgängen kann nun zusätzlich noch die Skala während des Reizes', 'center', p_monitor_ny+p_ptb_lineheight, p_stim_white);
        [p_monitor_nx, p_monitor_ny, textbounds]=DrawFormattedText(p_ptb_w, 'erscheinen. Zusätzlich werden Sie noch nach Ihrem Befinden befragt.', 'center', p_monitor_ny+p_ptb_lineheight, p_stim_white);
        [p_monitor_nx, p_monitor_ny, textbounds]=DrawFormattedText(p_ptb_w, 'Außerdem drücken Sie nun bitte so schnell wie möglich die mittlere Taste', 'center', p_monitor_ny+p_ptb_lineheight, p_stim_white);
        [p_monitor_nx, p_monitor_ny, textbounds]=DrawFormattedText(p_ptb_w, 'wenn das Kreuz rot wird.', 'center', p_monitor_ny+p_ptb_lineheight, p_stim_white);

        introTextTime = Screen('Flip',p_ptb_w);
        putLog(introTextTime,'IntroTextOn');
        WaitSecs(1);
        
        while 1
            [keyIsDown, ~, keyCode] = KbCheck();      % Start waiting 1/2 TR before JitterOnset for next pulse (this avoids collecting Pulses before).
            if keyIsDown
                if find(keyCode) == p_keys_confirm;
                    break;
                end
            end
        end
        
        StartWaitTime = Screen('Flip',p_ptb_w);
        putLog(StartWaitTime, 'WaitForConfirm');
        
    end
%% End session Text
    function ShowEndSessionText
%         Screen('TextSize',p_ptb_w,p.text.fontsize);
        
        [p_monitor_nx, p_monitor_ny, textbounds]=DrawFormattedText(p_ptb_w, 'Ende des Trainings.', 'center', p.ptb.startY, p_stim_white);
        [p_monitor_nx, p_monitor_ny, textbounds]=DrawFormattedText(p_ptb_w, 'Bitte bleiben Sie weiterhin ruhig liegen!', 'center', p_monitor_ny+p_ptb_lineheight, p_stim_white);
        %             [p_monitor_nx, p_monitor_ny, textbounds]=DrawFormattedText(p_ptb_w, 'Bitte bleiben Sie weiterhin ruhig liegen!', 'center', p_monitor_ny+p_ptb_lineheight, p_stim_white);
        
        
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
%% get reaction time
    function reactionTime = getRT(durCue,startTime)
        response = 0;
        numberOfSecondsRemaining = durCue;
        while numberOfSecondsRemaining  > 0
            
            if response == 0
                
                [ keyIsDown, secs, keyCode ] = KbCheck; % this checks the keyboard very, very briefly.
                if keyIsDown % only if a key was pressed we check which key it was
                    response = 0; % predefine variable for confirmation button 'space'
                    if keyCode(p.keys.confirm)
                        response = 1;
                        reactionTime = secs - startTime;
                        disp(['Reaction Time: ' num2str(reactionTime)]);
                        flip_confKey = GetSecs;
                        SecondsRemaining = durCue-(flip_confKey-startTime);
                        WaitSecs(SecondsRemaining);
                        break;
                    end
                end
            end
            numberOfSecondsElapsed   = (GetSecs - startTime);
            numberOfSecondsRemaining = durCue - numberOfSecondsElapsed;
        end
        
        if  response == 0
            warning(sprintf('\n***********\n***********\nNo Response!\nPlease check participant!!!\n***********\n***********\n'));
            reactionTime = NaN;
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
        p.log.ratings(p.log.ratingEventCount,1)    = currentTrial;
        p.log.ratings(p.log.ratingEventCount,2)    = p.rating.finalRating;
        p.log.ratings(p.log.ratingEventCount,3)    = p.rating.response;
        p.log.ratings(p.log.ratingEventCount,4)    = p.rating.reactionTime;
    end
    function putOnRatingLog(currentTrial)
        p.log.onratingEventCount                       = p.log.onratingEventCount + 1;
        p.log.onratings.conTrial(p.log.onratingEventCount,1)   = {currentTrial};
        p.log.onratings.conRating(:,p.log.onratingEventCount)  = {p.onrating.conRating};
        p.log.onratings.conTime(:,p.log.onratingEventCount)    = {p.onrating.conTime};
        p.log.onratings.conRes(p.log.onratingEventCount,1)     = {p.onrating.response};
    end
    function putRating1Log(currentTrial)
        p.log.rating1EventCount                      = p.log.rating1EventCount + 1;
        p.log.ratings1(p.log.rating1EventCount,1)    = currentTrial;
        p.log.ratings1(p.log.rating1EventCount,2)    = p.rating1.finalRating;
        p.log.ratings1(p.log.rating1EventCount,3)    = p.rating1.response;
        p.log.ratings1(p.log.rating1EventCount,4)    = p.rating1.reactionTime;
    end
    function putRating2Log(currentTrial)
        p.log.rating2EventCount                      = p.log.rating2EventCount + 1;
        p.log.ratings2(p.log.rating2EventCount,1)    = currentTrial;
        p.log.ratings2(p.log.rating2EventCount,2)    = p.rating2.finalRating;
        p.log.ratings2(p.log.rating2EventCount,3)    = p.rating2.response;
        p.log.ratings2(p.log.rating2EventCount,4)    = p.rating2.reactionTime;
    end
    function putMoodLog(currentTrial)
        p.log.moodEventCount                    = p.log.moodEventCount + 1;
        p.log.mood(p.log.moodEventCount,1)    = currentTrial;
        p.log.mood(p.log.moodEventCount,2)    = p.mood.finalRating;
        p.log.mood(p.log.moodEventCount,3)    = p.mood.response;
        p.log.mood(p.log.moodEventCount,4)    = p.mood.reactionTime;
    end
%% After experiment is over clean everything and close drivers
    function cleanup
        sca;                                                               % Close window:
        commandwindow;
        ListenChar(0);                                                     % Use keys again
        %KbQueueRelease(p_ptb_device);
        save(p.path.save ,'p');     
        diary off;      
    end

end





