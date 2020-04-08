classdef GuiUtils < handle
    % Class (all static) with different GUI widgets.
    %
    %    Figure management.
    %    Widgets: button, list, logo, etc.
    %
    %    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod
    
    %% public / static / figure utils
    methods (Static, Access = public)
        function fig = get_gui(id, position, name)
            % Create a GUI figure (clear if already exists).
            %
            %    Parameters:
            %        id (int): figure number
            %        position (vector): position of the figure (pixels units)
            %        name (str): figure name
            %
            %    Returns:
            %        fig (figure): created figure
            
            % try to find the figure
            fig = findobj(0, 'Number', id);
            
            if isempty(fig)
                % if new, create the setup
                fig = figure(id);
                set(fig, 'Position', position)
                set(fig, 'NumberTitle', 'off')
                set(fig, 'MenuBar', 'none')
                set(fig, 'Resize','off')
                set(fig, 'Name', name)
            else
                % if exist, clear
                set(fig, 'Name', name)
                clf(fig)
            end
        end
        
        function is_found = find_gui(id)
            % Try to find a figure from the number.
            %
            %    Parameters:
            %        id (int): figure number
            %
            %    Returns:
            %        is_found (logical): if the figure exists (or not)
            
            fig = findobj(0, 'Number', id);
            is_found = isempty(fig)==false;
        end
        
        function close_gui(id)
            % Try to close a figure from the number (do nothing if not existing).
            %
            %    Parameters:
            %        id (int): figure number
            
            fig = findobj(0, 'Number', id);
            close(fig);
        end
        
        function set_logo(parent, filename)
            % Display a PNG image without resizing it (with transparency).
            %
            %    Parameters:
            %        parent (obj): parent object to create the feature
            %        filename (str): name of the PNG file
            
            % load the image, find the size
            [img, map, alphachannel] = imread(filename);
            n_img_x = size(img, 2);
            n_img_y = size(img, 1);
            
            % create axis, get the size in pixels
            ax = axes(parent, 'Units', 'normalized', 'Position',[0 0 1 1]);
            pos = getpixelposition(ax);
            n_parent_x = pos(3);
            n_parent_y = pos(4);
            
            % computing the margin between the axis and image size
            n_margin_x = round((n_parent_x-n_img_x)./2);
            n_margin_y = round((n_parent_y-n_img_y)./2);
            
            % the image should be smaller than the available space
            assert(n_margin_x>=0, 'invalid data')
            assert(n_margin_y>=0, 'invalid data')
            
            % resize the axis, center it, and display the image
            set(ax, 'Units', 'pixels', 'Position',[n_margin_x n_margin_y n_img_x n_img_y]);
            image(ax, img, 'AlphaData', alphachannel);
            axis(ax, 'off');
            axis(ax, 'image');
        end
        
        function obj = get_panel(parent, position, name)
            % Create a panel in the GUI (with title).
            %
            %    Parameters:
            %        parent (obj): parent object to create the feature
            %        position (vector): position of the panel (normalized or pixels units)
            %        name (str): title of the panel
            %
            %    Returns:
            %        obj (obj): created object
            
            obj = uipanel(parent, 'Title', name, 'FontSize', 12);
            gui.GuiUtils.set_position(obj, position)
        end
    end
    
    %% public / static / widget utils
    methods (Static, Access = public)
        function obj = get_button(parent, position, name, callback)
            % Create a push button.
            %
            %    Parameters:
            %        parent (obj): parent object to create the feature
            %        position (vector): position of the object (normalized or pixels units)
            %        name (str): name of the button
            %        callback (fct): click callback
            %
            %    Returns:
            %        obj (obj): created object
            
            obj = uicontrol(parent, 'Style', 'pushbutton', 'FontSize', 12, 'String', name, 'CallBack', callback);
            gui.GuiUtils.set_position(obj, position)
        end
        
        function set_button(obj, enable)
            % Enable or disable a push button.
            %
            %    Parameters:
            %        obj (obj): considered object
            %        visible (logical): if the feature is enabled (or not)
            
            if enable==true
                set(obj, 'Enable', 'on');
            else
                set(obj, 'Enable', 'off');
            end
        end
        
        function obj = get_menu(parent, position, name, callback)
            % Create a popup list menu.
            %
            %    Parameters:
            %        parent (obj): parent object to create the feature
            %        position (vector): position of the object (normalized or pixels units)
            %        name (cell): name of items
            %        callback (fct): menu switch callback
            %
            %    Returns:
            %        obj (obj): created object
            
            obj = uicontrol(parent, 'Style', 'popupmenu', 'FontSize', 12, 'String', name, 'CallBack', callback);
            gui.GuiUtils.set_position(obj, position)
        end
        
        function idx = get_menu_idx(obj)
            % Get the current index of a popup list menu.
            %
            %    Parameters:
            %        obj (obj): considered object
            %
            %    Returns:
            %        idx (int): current index
            
            idx = obj.Value;
        end
        
        function set_menu(obj, is_valid)
            % Change the color of a popup list menu depending of validity.
            %
            %    Parameters:
            %        obj (obj): considered object
            %
            %    Returns:
            %        visible (logical): if the item is valid or not
            
            if is_valid==true
                set(obj, 'BackgroundColor', 'g')
            else
                set(obj, 'BackgroundColor', 'r')
            end
        end
        
        function obj = get_status(parent, position)
            % Create a status field (inactive push button).
            %
            %    Parameters:
            %        parent (obj): parent object to create the feature
            %        position (vector): position of the object (normalized or pixels units)
            %
            %    Returns:
            %        obj (obj): created object
            
            obj = uicontrol(parent, 'Style', 'pushbutton', 'Enable', 'inactive', 'FontSize', 12);
            gui.GuiUtils.set_position(obj, position)
        end
        
        function set_status(obj, is_valid)
            % Set the status of a status field.
            %
            %    Parameters:
            %        obj (obj): considered object
            %        is_valid (logical): if the feature is is_valid (or not)
            
            if is_valid==true
                set(obj, 'BackgroundColor', 'g')
                set(obj, 'String', 'valid')
            else
                set(obj, 'BackgroundColor', 'r')
                set(obj, 'String', 'invalid')
            end
        end
        
        
        function obj = get_text(parent, position)
            % Create a text field (empty).
            %
            %    Parameters:
            %        parent (obj): parent object to create the feature
            %        position (vector): position of the object (normalized or pixels units)
            %
            %    Returns:
            %        obj (obj): created object
            
            obj = uicontrol(parent, ...
                'Style','text',...
                'FontSize', 12,...
                'FontWeight', 'bold',...
                'HorizontalAlignment', 'left'...
                );
            gui.GuiUtils.set_position(obj, position)
        end
        
        function set_text(obj, name)
            % Set the text of a text field.
            %
            %    Parameters:
            %        obj (obj): considered object
            %        name (str): text to be displayes
            
            set(obj, 'String', name)
        end
    end
    
    %% private / static
    methods (Static, Access = private)
        function set_position(obj, position)
            % Set object position (detect if normalized or pixels units).
            %
            %    Parameters:
            %        obj (obj): object to be placed
            %        position (vector): position of the panel (normalized or pixels units)
            
            if all(position>=0)&&all(position<=1)
                set(obj, 'Units', 'normalized');
                set(obj, 'Position', position);
            else
                set(obj, 'Units', 'pixels');
                set(obj, 'Position', position);
            end
        end
    end
end