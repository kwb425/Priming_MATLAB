%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clear everything including any hidden handles.
%
%%% INPUT:
%%% None
%
%%% OUTPUT:
%%% None
%
%                                                  Written by Kim, Wiback,
%                                                     2016.04.14. Ver 1.1.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function kill





%% Killing Everything %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%
% Searching figures
%%%%%%%%%%%%%%%%%%%
% Saving whether or not display is showing all the hidden handles
handles_hidden_or_not = get(0,'showhiddenhandles');
% Tell the display to show all the hidden handles.
set(0, 'showhiddenhandles', 'on')
% Find all objects (including root).
objects = findobj(0);
% Among all the objects, get the handles only.
handles = objects((ishandle(objects)));
% Among all the handles, get the figures (which we have to kill) only.
handles = handles(strcmp('figure', get(handles,'type')));



%%%%%%%%%%
% Clearing
%%%%%%%%%%

%%% When the handles are not found, just clear variables and command line.
if isempty(handles)
    % Tell the display to get back to it's default setting.
    set(0,'ShowHiddenHandles', handles_hidden_or_not);
    % Clearing the variables and command line
    evalin('base', 'clear'); clc

%%% When the handles are found, kill them.
else
    delete(handles)
    % Tell the display to get back to it's default setting.
    set(0,'ShowHiddenHandles', handles_hidden_or_not);
    % Clearing the variables and command line
    evalin('base', 'clear'); clc
end