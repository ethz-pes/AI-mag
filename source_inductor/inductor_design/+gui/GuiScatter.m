classdef GuiScatter < handle
    % Class for plotting scattered data in a GUI.
    %
    %    Manage the axis.
    %    Plot the data.
    %    Highlight a specific point.
    %    Callback when a point is selected with the mouse.
    %
    %    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod
    
    %% properties
    properties (SetAccess = private, GetAccess = public)
        ax % axes: handle to the figure axis
        panel % uipanel: handle to uipanel containing the feature
        plot_data % struct: data and axis setup
        callback % fct: callback when a point is selected with the mouse
        h_pts % obj: handle of the scatter plot
        h_select % obj: handle of the scatter plot
        idx_perm % vector: permutation for keeping track of the plot order
    end
    
    %% public
    methods (Access = public)
        function self = GuiScatter(parent, position)
            % Constructor.
            %
            %    Parameters:
            %        parent (obj): parent object to create the feature
            %        position (vector): position of the panel (normalized or pixels units)
            
            % create panel
            self.panel = uipanel(parent, 'BorderType', 'none');
            self.set_position(position)
            
            % do not create the axis
            self.ax = [];
            self.plot_data = [];
            self.callback = [];
            self.h_pts = [];
            self.h_select = [];
        end
        
        function panel = get_panel(self)
            % Return the uipanel where the feature is places.
            %
            %    Returns:
            %        panel (uipanel): handle to uipanel containing the feature
            
            panel = self.panel;
        end
        
        function delete_panel(self)
            % Delete all the data of the features.
            %
            %    Delete the axis.
            %    Delete of the children of the axis.
            
            if ishandle(self.ax)
                delete(self.ax);
            end
        end
        
        function set_visible(self, visible)
            % Make the feature visible (or not).
            %
            %    Parameters:
            %        visible (logical): if the feature is visible (or not)
            
            if visible==true
                set(self.panel, 'Visible', 'on');
            else
                set(self.panel, 'Visible', 'off');
            end
        end
        
        function set_data(self, plot_data, callback)
            % Setup the axis and make the a scatter plot.
            %
            %    Parameters:
            %        plot_data (struct): data and axis setup
            %        callback (fct): callback when a point is selected with the mouse
            
            % assign the data
            self.plot_data = plot_data;
            self.callback = callback;
            
            % make the plot
            self.init_perm();
            self.init_plot();
            self.make_plot();
        end
        
        function set_select(self, id)
            % Highlight a specific point.
            %
            %    Parameters:
            %        id (int): id of the point to be highlighted
            
            % get the vector
            id_vec = self.plot_data.id_data;
            x_vec = self.plot_data.x_data;
            y_vec = self.plot_data.y_data;
            
            % find the selected point
            idx = id_vec==id;
            assert(nnz(idx)==1, 'invalid selected point id')
            x = x_vec(idx);
            y = y_vec(idx);
            
            % set the data in the handle
            set(self.h_select, 'XData', x);
            set(self.h_select, 'YData', y);
        end
        
        function clear_select(self)
            % Clear a highlighted point.
            %
            %    Remove the data from the handle.
            %    Do not remove the handle.
            
            set(self.h_select, 'XData', NaN);
            set(self.h_select, 'YData', NaN);
        end
    end
    
    %% private
    methods (Access = private)
        function init_perm(self)
            % Permuation for plotting.
            %
            %    For visualization different plotting order can be interesting:
            %        - original order
            %        - ascending color value order
            %        - descending color value order
            %        - random order
            
            % extract the color data and the order information
            c_vec = self.plot_data.c_data;
            order = self.plot_data.order;
            
            % set the permutation for keeping track of the plot order
            switch order
                case 'none'
                    self.idx_perm = 1:length(c_vec);
                case 'random'
                    self.idx_perm = randperm(length(c_vec));
                case 'ascend'
                    [v, self.idx_perm] = sort(c_vec, 'ascend');
                case 'descend'
                    [v, self.idx_perm] = sort(c_vec, 'descend');
                otherwise
                    error('invalid sorting method')
            end
        end
        
        function init_plot(self)
            % Create new axis, and set it up.
            %
            %    Create axis.
            %    Manage toolbar.
            %    Manage format.
            
            % create axis
            self.ax = axes(self.panel);
            set(self.ax, 'Box', 'on');
            set(self.ax, 'FontSize', 10);
            
            % create toolbar
            axtoolbar(self.ax, {'pan', 'zoomin','zoomout','restoreview'}, 'Visible', 'on');
            
            % set up colorbar
            cbar = colorbar(self.ax);
            set(cbar, 'Location', 'southoutside')
            set(cbar, 'Units', 'pixels')
            set(cbar, 'FontSize', 10)
            text = get(cbar, 'Label');
            set(text, 'interpreter', 'none')
            set(text, 'String', self.plot_data.c_label)
            set(text, 'FontSize', 11)
            
            % set uo label
            xlabel(self.ax, self.plot_data.x_label, 'FontSize', 11, 'interpreter', 'none')
            ylabel(self.ax, self.plot_data.y_label, 'FontSize', 11, 'interpreter', 'none')
            
            % set up axis type
            set(self.ax, 'XScale', self.plot_data.x_scale);
            set(self.ax, 'YScale', self.plot_data.y_scale);
            set(self.ax,'ColorScale', self.plot_data.c_scale)
            
            % if existing, put the axis limit
            if length(self.plot_data.x_lim)==2
                set(self.ax, 'XLim', self.plot_data.x_lim);
            end
            if length(self.plot_data.y_lim)==2
                set(self.ax, 'YLim', self.plot_data.y_lim);
            end
            if length(self.plot_data.c_lim)==2
                set(self.ax, 'CLim', self.plot_data.c_lim);
            end
            
            % grid and hold plots
            grid(self.ax, 'on')
            hold(self.ax, 'on')
        end
        
        function make_plot(self)
            % Make a scatter plot.
            %
            %    Make the plot.
            %    Set up the mouse click callback.
            %    Set up the plot to highlight a point.
            
            % get the data (permutate them)
            x_vec = self.plot_data.x_data(self.idx_perm);
            y_vec = self.plot_data.y_data(self.idx_perm);
            c_vec = self.plot_data.c_data(self.idx_perm);
            marker_pts_size = self.plot_data.marker_pts_size;
            marker_select_size = self.plot_data.marker_select_size;
            marker_select_color = self.plot_data.marker_select_color;
            
            % scatter plot and callback
            callback_tmp = @(obj, event) self.get_callback_idx(obj, event);
            self.h_pts = scatter(self.ax, x_vec, y_vec, marker_pts_size, c_vec,...
                'filled',...
                'Marker', 'o',...
                'ButtonDownFcn', callback_tmp);
            
            % plot to highlight a point (without data)
            self.h_select = plot(self.ax, NaN, NaN,...
                'MarkerSize', marker_select_size,...
                'Marker', 'h',...
                'MarkerEdgeColor', marker_select_color,...
                'MarkerFaceColor', marker_select_color);
        end
        
        function get_callback_idx(self, obj, event)
            % Internal callback to find the id of the clicked point.
            %
            %    Warning: This is quite a hack with the pixel coordinate.
            %             Portability between MATLAB version questionnable.
            %             However, it is not possible to achieve that with 'datacursormode'.
            %
            %    Parameters:
            %        obj (obj): scatter plot handle
            %        event (event): mouse click event
            
            % check the object and event
            assert(isa(obj, 'matlab.graphics.chart.primitive.Scatter'), 'invalid click object')
            assert(isa(event, 'matlab.graphics.eventdata.Hit'), 'invalid click event')
            
            % get the axis coordinate of the clicked point
            currentPoint = get(self.ax, 'CurrentPoint');
            x_select = currentPoint(1,1);
            y_select = currentPoint(1,2);
            
            % get the size of the axis in pixels
            pos = getpixelposition(self.ax);
            px_x = pos(3);
            px_y = pos(4);
            
            % get the data points and the corresponding id (permutate them)
            x_vec = self.plot_data.x_data(self.idx_perm);
            y_vec = self.plot_data.y_data(self.idx_perm);
            id_vec = self.plot_data.id_data(self.idx_perm);
            
            % get the axis limit and type
            x_lim = get(self.ax, 'XLim');
            y_lim = get(self.ax, 'YLim');
            x_scale = self.plot_data.x_scale;
            y_scale = self.plot_data.y_scale;
            
            % get the deviation in pixel between the click and the points
            d_px_x_vec = self.get_deviation(x_select, x_vec, x_lim, px_x, x_scale);
            d_px_y_vec = self.get_deviation(y_select, y_vec, y_lim, px_y, y_scale);
            
            % find the nearest point
            d_px_vec = hypot(d_px_x_vec, d_px_y_vec);
            [d_px, idx] = min(d_px_vec);
            assert(isfinite(d_px), 'invalid click pixel distance')
            
            % find the id of the selected point
            id = id_vec(idx);
            
            % highlight it, force redraw to make the GUI look more fluid
            self.set_select(id);
            drawnow();
            
            % call the user defined callback
            self.callback(id);
        end
        
        function d_px_vec = get_deviation(self, v_select, v_vec, v_lim, d_px, scale)
            % Find the distance (in pixels) between the click and the data points.
            %
            %    Parameters:
            %        v_select (float): coordinate of the click
            %        v_vec (vector): coordinate of the data points
            %        v_lim (vector): axis limit
            %        d_px (float): axis size in pixel
            %        scale (str): axis type ('lin' or 'lin')
            %
            %    Returns:
            
            % compute the distance between the click and the points and the axis span
            switch scale
                case 'lin'
                    d_vec = v_select-v_vec;
                    d_lim = max(v_lim)-min(v_lim);
                case 'log'
                    d_vec = log10(v_select)-log10(v_vec);
                    d_lim = max(log10(v_lim))-min(log10(v_lim));
                otherwise
                    error('invalid axis scaling')
            end
            
            % calculate the number of pixels
            d_px_vec = (d_vec./d_lim).*d_px;
        end
        
        function set_position(self, position)
            % Set panel position (detect if normalized or pixels units).
            %
            %    Parameters:
            %        position (vector): position of the panel (normalized or pixels units)
            
            if all(position>=0)&&all(position<=1)
                set(self.panel, 'Units', 'normalized');
                set(self.panel, 'Position', position);
            else
                set(self.panel, 'Units', 'pixels');
                set(self.panel, 'Position', position);
            end
        end
    end
end