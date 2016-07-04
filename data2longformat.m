%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Data Management (making long format)
% 
%                                                  Written by Kim, Wiback,
%                                                     2015.10.20 Ver. 1.1.
%                                                     2016.06.11 Ver. 1.2.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%% Searching & Reading %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = data2longformat



%%%%%%%%%%%%
% Parameters
%%%%%%%%%%%%
temp_path = dir(pwd);
reading_index = 0;
nation = 0;
gend = 0;
pre_allocating = 0;



%%%%%%%%%%%%%%%%%%%%%%%%%
% Preallocating for speed
%%%%%%%%%%%%%%%%%%%%%%%%%
for n = 1:length(temp_path)
    if strfind(temp_path(n).name, 'Out')
        pre_allocating = pre_allocating + 1;
    end
end
nationality(pre_allocating) = {[]};
subject(pre_allocating) = {[]};
necessary(pre_allocating) = {[]};
gender(pre_allocating) = {[]};



%%%%%%%%%
% Reading
%%%%%%%%%
for n = 1:length(temp_path)
    if ~isempty(regexp(temp_path(n).name, '^Out\w*.txt$', 'once'));
        
        %%% Extracting nationality (synchronizing with contents data)
        nation = nation + 1;
        if ~isempty(cell2mat(regexp(temp_path(n).name, 'KOR', 'match')))
            nationality{nation} = regexp(temp_path(n).name, ...
                'KOR', 'match');
        elseif ~isempty(cell2mat(regexp(temp_path(n).name, 'US', 'match')))
            nationality{nation} = regexp(temp_path(n).name, ...
                'US', 'match');
        elseif ~isempty(cell2mat(regexp(temp_path(n).name, 'UK', 'match')))
            nationality{nation} = regexp(temp_path(n).name, ...
                'UK', 'match');
        end
        
        %%% Extracting gender (synchronizing with contents data)
        gend = gend + 1;
        if ~isempty(cell2mat(regexp(temp_path(n).name, 'Male', 'match')))
            gender{gend} = regexp(temp_path(n).name, ...
                'Male', 'match');
        elseif ~isempty(cell2mat(regexp(temp_path(n).name, ...
                'Female', 'match')))
            gender{gend} = regexp(temp_path(n).name, ...
                'Female', 'match');
        end
        reading_index = reading_index + 1;
        fid = fopen(temp_path(n).name, 'r', 'n', 'UTF-8');
        subject{reading_index} = textscan(fid, '%s', 'delimiter', ',');
        fclose(fid);
    end
end





%% Reading & Modifying %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Five indices: 
%                 m (main loop), i (inner loop), newc (index for new cell),
%                 rt_index (index for figuring out RT boundary)
%                 bound_index (RT changing boundary)
newc = 0;
rt_index = 1;
bound_index = zeros(length(subject{1, 1}{1, 1}), 1);
for m = 1:length(subject)
    for i = 1:length(subject{1, m}{1, 1})
        index_chosen = isempty(cell2mat(regexp(subject{1, m}{1, 1}(i), ...
            'Chosen Word', 'once')));
        index_pure = isempty(cell2mat(regexp(subject{1, m}{1, 1}(i), ...
            'Pure Colorness', 'once')));
        index_rt = isempty(cell2mat(regexp(subject{1, m}{1, 1}(i), ...
            'RT', 'once')));
        
        %%% Getting RT_%d changing point
        if strfind(subject{1, m}{1, 1}{i}, sprintf('RT_%d', rt_index))
            newc = newc + 1;
            bound_index(rt_index) = newc;
            rt_index = rt_index + 1;
            necessary{m}{newc} = 'RT Bound';
        end
        
        %%% Extracting contents (excluding column names)
        if sum([index_chosen, index_pure, index_rt]) == 3
            newc = newc + 1;
            necessary{m}{newc} = subject{1, m}{1, 1}(i);
            if i == length(subject{1, m}{1, 1})
                newc = 0;
                rt_index = 1;
            end
        end
    end
end





%% Rewriting (.csv is always desirable.) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%
% Parameters
%%%%%%%%%%%%
new_index_chosen = 1;
new_index_pure = 2;
new_index_rt = 3;
test_index = 0;



%%%%%%%%%
% Writing
%%%%%%%%%
fid = fopen('Statistics.txt', 'w', 'n', 'UTF-8');

%%% Column names
fprintf(fid, '%s,%s,%s,%s,%s,%s,%s,%s,%s\n', ...
    'Subject', 'Test Number', 'Chosen Word', 'Pure Colorness', 'RT', ...
    'Gender', 'Nationality', 'English Scores', 'Lived Years');

%%% Main appending loop
for n = 1:length(necessary)
    fid = fopen('Statistics.txt', 'a', 'n', 'UTF-8');
    % Sub contents filling loop
    for m = 1:length(necessary{n})
        % RT Bound (character) to Test Bound (numeric)
        if  strcmp(necessary{1, n}{new_index_chosen}, 'RT Bound')
            test_index = test_index + 1;
            new_index_chosen = new_index_chosen + 1;
            new_index_pure = new_index_pure + 1;
            new_index_rt = new_index_rt + 1;
        end
        fprintf(fid, '%d,%d,%s,%s,%d,%s,%s,%d, %d\n', ...
            n, test_index, ...
            ... % One more deep down indexing then RT Bound
            necessary{1, n}{new_index_chosen}{1}, ...
            necessary{1, n}{new_index_pure}{1}, ...
            str2double(necessary{1, n}{new_index_rt}{1}), ...
            cell2mat(gender{n}), ...
            cell2mat(nationality{n}), ...
            ... % English scores
            eng_scores(n, gender, nationality), ...
            ... % Lived years
            lived_years(n, gender, nationality));
        new_index_chosen = new_index_chosen + 3;
        new_index_pure = new_index_pure + 3;
        new_index_rt = new_index_rt + 3;
        if new_index_chosen > length(necessary{n})
            break
        end
    end
    new_index_chosen = 1;
    new_index_pure = 2;
    new_index_rt = 3;
    test_index = 0;
end
fclose(fid);
end





%% Data Twisting Functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%
% English score generator
%%%%%%%%%%%%%%%%%%%%%%%%%
function [varargout] = eng_scores(varargin)
n = varargin{1};
gender = varargin{2};
nationality = varargin{3};
if strcmp(cell2mat(gender{n}), 'Male') && ...
        strcmp(cell2mat(nationality{n}), 'KOR')
    varargout{1} = randi([20, 40]);
elseif  strcmp(cell2mat(gender{n}), 'Female') && ...
        strcmp(cell2mat(nationality{n}), 'KOR')
    varargout{1} = randi([40, 60]);
elseif  strcmp(cell2mat(gender{n}), 'Male') && ...
        strcmp(cell2mat(nationality{n}), 'US')
    varargout{1} = randi([60, 80]);
elseif  strcmp(cell2mat(gender{n}), 'Female') && ...
        strcmp(cell2mat(nationality{n}), 'US')
    varargout{1} = randi([80, 100]);
else
    varargout{1} = randi(100);
end
end



%%%%%%%%%%%%%%%
% Age generator
%%%%%%%%%%%%%%%
function [varargout] = lived_years(varargin)
n = varargin{1};
gender = varargin{2};
nationality = varargin{3};
if strcmp(cell2mat(gender{n}), 'Male') && ...
        strcmp(cell2mat(nationality{n}), 'KOR')
    varargout{1} = randi([0, 10]);
elseif  strcmp(cell2mat(gender{n}), 'Female') && ...
        strcmp(cell2mat(nationality{n}), 'KOR')
    varargout{1} = randi([10, 20]);
elseif  strcmp(cell2mat(gender{n}), 'Male') && ...
        strcmp(cell2mat(nationality{n}), 'US')
    varargout{1} = randi([30, 40]);
elseif  strcmp(cell2mat(gender{n}), 'Female') && ...
        strcmp(cell2mat(nationality{n}), 'US')
    varargout{1} = randi([40, 50]);
else
    varargout{1} = randi(100);
end
end