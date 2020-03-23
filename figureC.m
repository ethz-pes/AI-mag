% Filename: figureC.m
%
% Created by Seth Wood
% 12 Feb 2013
%
% Description: This file is a custom figure for Matlab. It includes a
% custom data cursor which creates delta data tips.
%
% Questions, please contact seth_wood@raytheon.com
%% Custom Figure
function outHdl = figureC(inHdl,callerName,dataTipStyleDelta)
    if nargin < 3
        dataTipStyleDelta = 1;%0=normal cursors, 1=delta cursors
    end
    if nargin < 2
        callerName = 'SomeCallerName';%Attaches a name to the figure so the calling function/program can know that it created the figure
    end
    if nargin < 1
        inHdl = NaN;%Handle to a figure that already exists
    end
    
    if ishandle(inHdl)
        figure(inHdl);%If this handle esists and is valid then simply make it the current figure and return
        outHdl = inHdl;
        return;
    end
    
    if isscalar(inHdl) && mod(inHdl,1) == 0
        outHdl = figure(inHdl);
    else
        outHdl = figure;
    end
    
    %create a userdata variable which will be used to make the delta cursors and store important figure info
    udata.prgmName = callerName;
    udata.dataTipStyleDelta = dataTipStyleDelta;
    set(outHdl,'UserData',udata);
    
    %Set the data cursor to update via a custom function
    dcm_obj = datacursormode(outHdl);%Get the data cursor mode object of the figure
    set(dcm_obj,'UpdateFcn',@deltaCursorUpdateFcn);
end
%% Delta Cursor 
function output_txt = deltaCursorUpdateFcn(obj,event_obj)
    %Input Variables
    % The input variables are provided by the system
    % obj - un-used
    % event_obj - contains the information for the position of the current datatip cursor
    
    %Output Variables
    % output_txt - cell array of strings which wil be displayed in the current datatip cursor
    
    deltaOn = 0;%Default cursor mode
    refExist = 0;%Default Reference
    output_txt = {};
    
    hfig = gcf;%Get the current figure
    udata = get(hfig,'UserData');
    
    cm = datacursormode(hfig);
    hdc = cm.CurrentDataCursor;%Current Cursor handle
    hdcs = cm.DataCursors;%All curor handles for this figure
    
    %If no reference data cursor exists then set the current cursor as the referce
    if ~isfield(udata,'hdcRef')
        udata.hdcRef = hdc;
    end
    
    if isfield(udata,'dataTipStyleDelta')
        deltaOn = udata.dataTipStyleDelta;
    end
    
    %Check if the current reference cursor exists
    for i=1:length(hdcs)
        if udata.hdcRef == hdcs(i)
            refExist = 1;
            break;
        end
    end
    
    if isempty(udata.hdcRef) || refExist == 0 || deltaOn == 0
        udata.hdcRef = hdc;
    end
    
    %Update the Fig User data
    set(hfig,'UserData',udata);
    
    %Update for the Reference Cursor
    if hdc == udata.hdcRef
        pos = get(event_obj,'Position');
        output_txt{1} = sprintf('X: %s',num2str(pos(1),12));
        output_txt{2} = sprintf('Y: %s',num2str(pos(2),12));
        %If there is a Z-coordinate in the position, display it as well
        if length(pos) > 2
            output_txt{3} = sprintf('Z: %s',num2str(pos(3),12));
        end
        
        if deltaOn == 1
            output_txt{end+1} = 'Ref Cursor';
        end
        
        %Since the reference cursor has been moved all other cursors must be updated.
        if deltaOn == 1
            posRef = pos;
            for i=1:length(hdcs)
                if hdcs(i) ~= hdc%Update all but the reference cursor, which has already been handled
                    pos = get(hdcs(i),'Position');
                    update_txt = {};
                    update_txt{1} = sprintf('X: %s',num2str(pos(1),12));
                    update_txt{2} = sprintf('Y: %s',num2str(pos(2),12));
                    %If there is a Z-coordinate in the position, display it as well
                    if length(posRef) > 2 && length(pos) > 2
                        update_txt{3} = sprintf('Z: %s',num2str(pos(3),12));
                    end
                    update_txt{end+1} = sprintf('dX: %s',num2str(pos(1)-posRef(1),12));
                    update_txt{end+1} = sprintf('dY: %s',num2str(pos(2)-posRef(2),12));
                    %If there is a Z-coordinate in the position, display it as well
                    if length(posRef) > 2 && length(pos) > 2
                        update_txt{end+1} = sprintf('dZ: %s',num2str(pos(3)-posRef(3),12));
                    end
                    set(hdcs(i),'String',update_txt);
                end
            end
        end
    %Update a cursor that is not the reference cursor
    else
        %Get the Reference Cursor Position
        posRef = get(udata.hdcRef,'Position');
        pos = get(event_obj,'Position');
        output_txt = {};
        output_txt{1} = sprintf('X: %s',num2str(pos(1),12));
        output_txt{2} = sprintf('Y: %s',num2str(pos(2),12));
        %If there is a Z-coordinate in the position, display it as well
        if length(posRef) > 2 && length(pos) > 2
            output_txt{3} = sprintf('Z: %s',num2str(pos(3),12));
        end
        output_txt{end+1} = sprintf('dX: %s',num2str(pos(1)-posRef(1),12));
        output_txt{end+1} = sprintf('dY: %s',num2str(pos(2)-posRef(2),12));
        %If there is a Z-coordinate in the position, display it as well
        if length(posRef) > 2 && length(pos) > 2
            output_txt{end+1} = sprintf('dZ: %s',num2str(pos(3)-posRef(3),12));
        end
    end
                    
    
    
    
    
    
    
end