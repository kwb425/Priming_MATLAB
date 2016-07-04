%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Color Prime Task
%
%%% Requirements:
% Psychtoolbox                                    http://psychtoolbox.org
%
%                                                  Written by Kim, Wiback,
%                                                    2015.10.20, Ver. 1.1.
%                                                    2016.01.11, Ver. 1.2.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%% Clearing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
kill





%% Pre-processing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%
% Stimuli
%%%%%%%%%
fid = fopen('Stimuli.txt', 'r', 'n', 'UTF-8'); % UTF-8 is a global format.
stim = textscan(fid, '%s', 'delimiter', ','); % .csv
stim = stim{1, 1};
fclose(fid);
total_index = regexp(stim, '[a-z]', 'once');

%%% Extracting color indices which are encoded as capital letters
heading_color_index = zeros(length(total_index) / 5, 1);
m = 0;
for n = 1:length(total_index)
    if isempty(total_index{n})
        m = m + 1;
        heading_color_index(m) = n;
    end
end



%%%%%%%%%%%%%%%%%%%%%
% Subject information
%%%%%%%%%%%%%%%%%%%%%
subject_name = input('Subject''s initials: ', 's');
nationality = input('Your nationality (US, UK, KOR only): ', 's');
gender = input('Your sex (Male, Female): ', 's');
out_filename = ['Out_', nationality, '_', gender, '_', subject_name];





%% PsychToolbox Parameters %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%
% System adjustment
%%%%%%%%%%%%%%%%%%%
% For Mac users, this line must be uncommented.
Screen('preference', 'skipsynctests', 2)



%%%%%%%%%%%%%%
% Basic setups
%%%%%%%%%%%%%%

%%% Very basics
[window, screen_size] = Screen('openwindow', 0);
% Screen func works in a manner such that draw -> flip, draw -> flip.
% Flipinterval here is time needed to perform the '->'.
full_flip = Screen('getflipinterval', window);
center_x = screen_size(3) / 2;
center_y = screen_size(4) / 2;
Screen('textfont', window, 'times');
Screen('textsize', window, 72);
timeout = 10;

%%% Getting size of descriptions
bounds = Screen('textbounds', window, 'q');
half_descript_x_size = bounds(3) / 2;
half_descript_y_size = bounds(4) / 2;
bounds = Screen('textbounds', window, 'Choose with ''q ] z /'' keys.');
half_main_1_x_size = bounds(3) / 2;
half_main_1_y_size = bounds(4) / 2;
bounds = Screen('textbounds', window, 'Press any key to proceed.');
half_main_2_x_size = bounds(3) / 2;
half_main_2_y_size = bounds(4) / 2;

%%% Getting size of the stimuli
bounds = Screen('textbounds', window, 'Revobe');
half_stim_x_size = bounds(3) / 2;
half_stim_y_size = bounds(4) / 2;

%%% Getting size of fixation
bounds = Screen('textbounds', window, '+');
half_fix_x_size = bounds(3) / 2;
half_fix_y_size = bounds(4) / 2;

%%% Setting coordinates
up_stim = center_y - 300 - half_stim_y_size;
down_stim = center_y + 300 - half_stim_y_size;
left_stim = center_x - 400 - half_stim_x_size;
right_stim = center_x + 400 - half_stim_x_size;
up_descript = center_y - 300 - half_descript_y_size;
down_descript = center_y + 300 - half_descript_y_size;
left_descript = center_x - 400 - half_descript_x_size;
right_descript = center_x + 400 - half_descript_x_size;
main_1_left = center_x - half_main_1_x_size;
main_1_up = center_y - 50 - half_main_1_y_size;
main_2_left = center_x - half_main_2_x_size;
main_2_up = center_y + 50 - half_main_1_y_size;
fix_x = center_x - half_fix_x_size;
fix_y = center_y - half_fix_y_size;





%% Experiment: ready %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mouse lock
ListenChar(2);
% Mouse hide
HideCursor
% Unification of global keynames of many keyboards
KbName('unifykeynames');





%% Experiment: start %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%
% 3 blocks in 1 test
%%%%%%%%%%%%%%%%%%%%
for test = 1:2
    for blocknumber = 1:3
        
        %%% Showing the descriptions
        Screen('drawtext', window, 'q', left_descript, up_descript, ...
            [0, 0, 0]);
        Screen('drawtext', window, ']', right_descript, up_descript, ...
            [0, 0, 0]);
        Screen('drawtext', window, 'z', left_descript, down_descript, ...
            [0, 0, 0]);
        Screen('drawtext', window, '/', right_descript, down_descript, ...
            [0, 0, 0]);
        Screen('drawtext', window, 'Choose with ''q ] z /'' keys.', ...
            main_1_left, main_1_up, [0, 0, 0]);
        Screen('drawtext', window, 'Press any key to proceed.', ...
            main_2_left, main_2_up, [0, 0, 0]);
        Screen('flip', window);
        % Wating for 'any button-press to proceed'
        KbPressWait(-1)
        
        %%% Breaking
        % In human perspective, we consider 
        % button down -> button up sequence as a single press, thus do not
        % expect the program to run down before we release the button,
        % but computer, rather, simply considers one button down action
        % as a single press, and then just process down the script, which
        % is definitely against our expectation, so we introduce a break.
        pressed_t_f = 1;
        % When the user put his or her finger off the keyboard, proceed.
        while pressed_t_f
            % This will be 1 as lond as the user rest his or her finger
            % upon the keyboard.
            pressed_t_f = KbCheck(-1);
        end
        
        %%% Each stimulus: main
        for typenumber = 1:length(heading_color_index)
            % Random parameters
            color_random = randperm(length(heading_color_index));
            input_random = randperm(4);
            color_or_null = heading_color_index(color_random(typenumber));
            
            %%% Each stimulus: when red
            if stim{color_or_null} == 'R'
                % Fixation
                Screen('drawtext', window, '+', fix_x, fix_y, [0, 0, 0]);
                fix_t = Screen('flip', window);
                % Priming
                Screen('fillrect', window, [255, 0, 0], ...
                    [0, 0, screen_size(3), screen_size(4)]);
                % Showing the fixation for 1 sec
                color_prolong = Screen('flip', window, ...
                    fix_t - full_flip + 0.5);
                % Not like 'filloval', 'drawtext', and other objects,
                % 'fillrect' holds it's setting even if the screen gets
                % flipped many times.
                % Function 'fillrect' also erases all fore-drawn objects.
                % Setting a new default white plain
                Screen('fillrect', window, [255, 255, 255], ...
                    [0, 0, screen_size(3), screen_size(4)]);
                Screen('flip', window, color_prolong - full_flip + 0.01);
                % Preparing stimuli
                Screen('drawtext', window, ...
                    stim{color_or_null + input_random(1)}, ...
                    left_stim, up_stim, [0, 0, 0]);
                Screen('drawtext', window, ...
                    stim{color_or_null + input_random(2)}, ...
                    right_stim, up_stim, [0, 0, 0]);
                Screen('drawtext', window, ...
                    stim{color_or_null + input_random(3)}, ...
                    left_stim, down_stim, [0, 0, 0]);
                Screen('drawtext', window, ...
                    stim{color_or_null + input_random(4)}, ...
                    right_stim, down_stim, [0, 0, 0]);
                
                %%% Each stimulus: when orange
            elseif stim{color_or_null} == 'O'
                % Priming
                Screen('drawtext', window, '+', fix_x, fix_y, [0, 0, 0]);
                fix_t = Screen('flip', window);
                Screen('fillrect', window, [255, 165, 0], ...
                    [0, 0, screen_size(3), screen_size(4)]);
                color_prolong = Screen('flip', window, ...
                    fix_t - full_flip + 0.5);
                Screen('fillrect', window, [255, 255, 255], ...
                    [0, 0, screen_size(3), screen_size(4)]);
                Screen('flip', window, color_prolong - full_flip + 0.01);
                % Preparing stimuli
                Screen('drawtext', window, ...
                    stim{color_or_null + input_random(1)}, ...
                    left_stim, up_stim, [0, 0, 0]);
                Screen('drawtext', window, ...
                    stim{color_or_null + input_random(2)}, ...
                    right_stim, up_stim, [0, 0, 0]);
                Screen('drawtext', window, ...
                    stim{color_or_null + input_random(3)}, ...
                    left_stim, down_stim, [0, 0, 0]);
                Screen('drawtext', window, ...
                    stim{color_or_null + input_random(4)}, ...
                    right_stim, down_stim, [0, 0, 0]);
                
                %%% Each stimulus: when yellow
            elseif stim{color_or_null} == 'Y'
                % Priming
                Screen('drawtext', window, '+', fix_x, fix_y, [0, 0, 0]);
                fix_t = Screen('flip', window);
                Screen('fillrect', window, [255, 255, 0], ...
                    [0, 0, screen_size(3), screen_size(4)]);
                color_prolong = Screen('flip', window, ...
                    fix_t - full_flip + 0.5);
                Screen('fillrect', window, [255, 255, 255], ...
                    [0, 0, screen_size(3), screen_size(4)]);
                Screen('flip', window, color_prolong - full_flip + 0.01);
                % Preparing stimuli
                Screen('drawtext', window, ...
                    stim{color_or_null + input_random(1)}, ...
                    left_stim, up_stim, [0, 0, 0]);
                Screen('drawtext', window, ...
                    stim{color_or_null + input_random(2)}, ...
                    right_stim, up_stim, [0, 0, 0]);
                Screen('drawtext', window, ...
                    stim{color_or_null + input_random(3)}, ...
                    left_stim, down_stim, [0, 0, 0]);
                Screen('drawtext', window, ...
                    stim{color_or_null + input_random(4)}, ...
                    right_stim, down_stim, [0, 0, 0]);
                
                %%% Each stimulus: when green
            elseif stim{color_or_null} == 'G'
                % Priming
                Screen('drawtext', window, '+', fix_x, fix_y, [0, 0, 0]);
                fix_t = Screen('flip', window);
                Screen('fillrect', window, [0, 255, 0], ...
                    [0, 0, screen_size(3), screen_size(4)]);
                color_prolong = Screen('flip', window, ...
                    fix_t - full_flip + 0.5);
                Screen('fillrect', window, [255, 255, 255], ...
                    [0, 0, screen_size(3), screen_size(4)]);
                Screen('flip', window, color_prolong - full_flip + 0.01);
                % Preparing Stimuli
                Screen('drawtext', window, ...
                    stim{color_or_null + input_random(1)}, ...
                    left_stim, up_stim, [0, 0, 0]);
                Screen('drawtext', window, ...
                    stim{color_or_null + input_random(2)}, ...
                    right_stim, up_stim, [0, 0, 0]);
                Screen('drawtext', window, ...
                    stim{color_or_null + input_random(3)}, ...
                    left_stim, down_stim, [0, 0, 0]);
                Screen('drawtext', window, ...
                    stim{color_or_null + input_random(4)}, ...
                    right_stim, down_stim, [0, 0, 0]);
                
                %%% Each stimulus: when blue
            elseif stim{color_or_null} == 'B'
                % Priming
                Screen('drawtext', window, '+', fix_x, fix_y, [0, 0, 0]);
                fix_t = Screen('flip', window);
                Screen('fillrect', window, [0, 0, 255], ...
                    [0, 0, screen_size(3), screen_size(4)]);
                color_prolong = Screen('flip', window, ...
                    fix_t - full_flip + 0.5);
                Screen('fillrect', window, [255, 255, 255], ...
                    [0, 0, screen_size(3), screen_size(4)]);
                Screen('flip', window, color_prolong - full_flip + 0.01);
                % Preparing Stimuli
                Screen('drawtext', window, ...
                    stim{color_or_null + input_random(1)}, ...
                    left_stim, up_stim, [0, 0, 0]);
                Screen('drawtext', window, ...
                    stim{color_or_null + input_random(2)}, ...
                    right_stim, up_stim, [0, 0, 0]);
                Screen('drawtext', window, ...
                    stim{color_or_null + input_random(3)}, ...
                    left_stim, down_stim, [0, 0, 0]);
                Screen('drawtext', window, ...
                    stim{color_or_null + input_random(4)}, ...
                    right_stim, down_stim, [0, 0, 0]);
                
                %%% Each stimulus: when purple
            elseif stim{color_or_null} == 'P'
                % Priming
                Screen('drawtext', window, '+', fix_x, fix_y, [0, 0, 0]);
                fix_t = Screen('flip', window);
                Screen('fillrect', window, [160, 32, 240], ...
                    [0, 0, screen_size(3), screen_size(4)]);
                color_prolong = Screen('flip', window, ...
                    fix_t - full_flip + 0.5);
                Screen('fillrect', window, [255, 255, 255], ...
                    [0, 0, screen_size(3), screen_size(4)]);
                Screen('flip', window, color_prolong - full_flip + 0.01);
                % Preparing Stimuli
                Screen('drawtext', window, ...
                    stim{color_or_null + input_random(1)}, ...
                    left_stim, up_stim, [0, 0, 0]);
                Screen('drawtext', window, ...
                    stim{color_or_null + input_random(2)}, ...
                    right_stim, up_stim, [0, 0, 0]);
                Screen('drawtext', window, ...
                    stim{color_or_null + input_random(3)}, ...
                    left_stim, down_stim, [0, 0, 0]);
                Screen('drawtext', window, ...
                    stim{color_or_null + input_random(4)}, ...
                    right_stim, down_stim, [0, 0, 0]);
                
                %%% Each stimulus: when N (not defined, random color)
            else
                % Priming
                p = randperm(255); % For random rgb (1~256)
                Screen('drawtext', window, '+', fix_x, fix_y, [0, 0, 0]);
                fix_t = Screen('flip', window);
                Screen('fillrect', window, [p(1), p(2), p(3)], ...
                    [0, 0, screen_size(3), screen_size(4)]);
                color_prolong = Screen('flip', window, ...
                    fix_t - full_flip + 0.5);
                Screen('fillrect', window, [255, 255, 255], ...
                    [0, 0, screen_size(3), screen_size(4)]);
                Screen('flip', window, color_prolong - full_flip + 0.01);
                % Preparing Stimuli
                Screen('drawtext', window, ...
                    stim{color_or_null + input_random(1)}, ...
                    left_stim, up_stim, [0, 0, 0]);
                Screen('drawtext', window, ...
                    stim{color_or_null + input_random(2)}, ...
                    right_stim, up_stim, [0, 0, 0]);
                Screen('drawtext', window, ...
                    stim{color_or_null + input_random(3)}, ...
                    left_stim, down_stim, [0, 0, 0]);
                Screen('drawtext', window, ...
                    stim{color_or_null + input_random(4)}, ...
                    right_stim, down_stim, [0, 0, 0]);
            end
            
            
            
            %%%%%%%%%%%%%%%%%%%
            % The user's answer
            %%%%%%%%%%%%%%%%%%%
            
            %%% RT control
            start_time = Screen('flip', window);
            now_time = start_time;
            % Button press or time expiration will break this loop.
            while now_time < start_time + timeout && pressed_t_f == 0
                % Checking for a response
                [pressed_t_f, execute_time, keycode] = KbCheck(-1);
                if pressed_t_f
                    response = KbName(keycode);
                end
                % Reaction time
                now_time = GetSecs;
            end
            % Recording the RT
            response_time = now_time - start_time;
            
            
            
            
            
            %% Experiment: Data Gathering %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            
            
            %%%%%%%%%%%%%%%%%%%%%%%%%
            % Gathering: opening .txt
            %%%%%%%%%%%%%%%%%%%%%%%%%
            if typenumber == 1
                
                %%% Color-ish stimuli, if the user chooses these words
                % more quickly than other types of stimuli, then we have 
                % primacy effect.
                col = {'Revobe', 'Orenze', 'Yewolo', ...
                    'Grween', 'Blquse', 'Puqule'};
                fid = fopen([out_filename, '.txt'], ...
                    'a', ... % Append option
                    'n', 'UTF-8');
                fprintf(fid, '%s,\t\t%s,\t\t\t%s\n', 'Chosen Word', ...
                    'Pure Colorness', ['RT_', num2str(test)]);
            end
            
            
            
            %%%%%%%%%%%%%%%%%%%%
            % Gathering: writing
            %%%%%%%%%%%%%%%%%%%%
            
            %%% When the user pressed q.
            if response(1) == 'q'
                wh = find(strcmp(col, stim{color_or_null + input_random(1)}));
                if isempty(wh)
                    fprintf(fid, '   %s,\t\t\t     %s,\t\t   %s\n', ...
                        stim{color_or_null + input_random(1)}, ...
                        'False', response_time);
                else
                    fprintf(fid, '   %s,\t\t\t     %s,\t\t   %s\n', ...
                        col{wh}, 'True', response_time);
                end
                
                %%% When the user pressed ].
            elseif response(1) == ']'
                wh = find(strcmp(col, stim{color_or_null + input_random(2)}));
                if isempty(wh)
                    fprintf(fid, '   %s,\t\t\t     %s,\t\t   %s\n', ...
                        stim{color_or_null + input_random(2)}, ...
                        'False', response_time);
                else
                    fprintf(fid, '   %s,\t\t\t     %s,\t\t   %s\n', ...
                        col{wh}, 'True', response_time);
                end
                
                %%% When the user pressed z.
            elseif response(1) == 'z'
                wh = find(strcmp(col, stim{color_or_null + input_random(3)}));
                if isempty(wh)
                    fprintf(fid, '   %s,\t\t\t     %s,\t\t   %s\n', ...
                        stim{color_or_null + input_random(3)}, ...
                        'False', response_time);
                else
                    fprintf(fid, '   %s,\t\t\t     %s,\t\t   %s\n', ...
                        col{wh}, 'True', response_time);
                end
                
                %%% When the user pressed /.
            elseif response(1) == '/'
                wh = find(strcmp(col, stim{color_or_null + input_random(4)}));
                if isempty(wh)
                    fprintf(fid, '   %s,\t\t\t     %s,\t\t   %s\n', ...
                        stim{color_or_null + input_random(4)}, ...
                        'False', response_time);
                else
                    fprintf(fid, '   %s,\t\t\t     %s,\t\t   %s\n', ...
                        col{wh}, 'True', response_time);
                end
                
                %%% When the user pressed other buttons.
            else
                fprintf(fid, '  %s,\t\t\t     %s,\t\t   %s\n', ...
                    'Invaild', ...
                    'Nan', response_time);
            end
            
            
            
            
            
            %% Experiment: Wrapping the Round %%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%% Breaking
            while pressed_t_f
                pressed_t_f = KbCheck(-1);
            end
            
            %%% Wiping
            Screen('flip', window);
        end
    end
end





%% Experiment: Finish %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mouse unlock
ListenChar(0);
% Mouse un-hide
ShowCursor
% Terminating Screen function
sca