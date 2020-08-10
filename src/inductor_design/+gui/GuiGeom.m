classdef GuiGeom < handle
    % Class for plotting a magnetic component in a GUI.
    %
    %    Manage the axis.
    %    Plot core, winding, and insulation.
    %
    %    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod
    
    %% properties
    properties (SetAccess = private, GetAccess = public)
        ax % axes: handle to the figure axis
        panel % uipanel: handle to uipanel containing the feature
    end
    
    %% public
    methods (Access = public)
        function self = GuiGeom(parent, position)
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
        
        function set_plot_geom_cross(self)
            % Cross the axis with red lines.
            %
            %    Setup the axis.
            %    Get the axis limit, and cross them.
            
            % create new axis
            self.set_axis();
            
            % get the limit
            x = xlim(self.ax);
            y = ylim(self.ax);
            
            % make the cross
            plot(self.ax, [x(1) x(2)], [y(1) y(2)], 'r', 'LineWidth', 2)
            plot(self.ax, [x(2) x(1)], [y(1) y(2)], 'r', 'LineWidth', 2)
        end
        
        function set_plot_geom_data(self, plot_data, fact)
            % Plot a magnetic component in the axis.
            %
            %    Setup the axis.
            %    Plot the component.
            %    Setup the axis limit.
            %
            %    Parameters:
            %        plot_data (cell): cell with the different core, winding, and insulation
            %        fact (float): free space around the component compared to the size of the component
            
            % create new axis
            self.set_axis();
            
            % vector containing all the coordinates
            x_vec = [];
            y_vec = [];
            
            % plot the core, winding, and insulation
            for i=1:length(plot_data)
                [x_vec_tmp, y_vec_tmp] = self.set_element(plot_data{i});
                x_vec = [x_vec, x_vec_tmp];
                y_vec = [y_vec, y_vec_tmp];
            end
            
            % set the axis limit
            self.set_lim(x_vec, y_vec, fact);
        end
    end
    
    %% private
    methods (Access = private)
        function set_axis(self)
            % Create new axis, and set it up.
            %
            %    Create axis.
            %    Manage toolbar.
            %    Manage format.
            
            % create axis
            self.ax = axes(self.panel);
            set(self.ax, 'Box','on');
            set(self.ax, 'FontSize', 10);
            
            % create toolbar
            axtoolbar(self.ax, {'pan', 'zoomin','zoomout','restoreview'}, 'Visible', 'on');
            
            % set up format
            hold(self.ax, 'on');
            axis(self.ax, 'equal');
            xlabel(self.ax, '[mm]', 'FontSize', 11);
            ylabel(self.ax, '[mm]', 'FontSize', 11);
            xtickformat('%+.1f')
            ytickformat('%+.1f')
        end
        
        function [x_vec, y_vec] = set_element(self, plot_data)
            % Plot an element (winding, core, or insulation).
            %
            %    Parameters:
            %        plot_data (cell): cell with the different core, winding, and insulation
            %
            %    Returns:
            %        x_vec (vector): x coordinates of the element, for axis limit control
            %        y_vec (vector): y coordinates of the element, for axis limit control
            
            % get the coordinates
            x_min = plot_data.pos(1)-plot_data.size(1)./2;
            x_max = plot_data.pos(1)+plot_data.size(1)./2;
            y_min = plot_data.pos(2)-plot_data.size(2)./2;
            y_max = plot_data.pos(2)+plot_data.size(2)./2;
            
            % make the coordinate vector, for axis limit control
            x_vec = [x_min x_max];
            y_vec = [y_min y_max];
            
            % make the plot data (position and relative curvature radius)
            r = 2.*plot_data.r./min(plot_data.size);
            vec = [x_min y_min x_max-x_min y_max-y_min];
            
            % get the color
            switch plot_data.type
                case 'core'
                    color = [0.5 0.5 0.5];
                case 'air'
                    color = [1.0 1.0 1.0];
                case 'winding'
                    color = [0.9 0.5 0.0];
                case 'insulation'
                    color = [0.5 0.5 0.0];
                otherwise
                    error('invalid material type')
            end
            
            % plot the element, in mm
            rectangle(self.ax, 'Position', 1e3.*vec, 'Curvature', r,'FaceColor', color, 'LineStyle','none')
        end
        
        function set_lim(self, x_vec, y_vec, fact)
            % Set the axis with a specified margin around the component.
            %
            % The component is accepted:
            %    - to be centered compared to the x axis
            %    - to be centered compared to the y axis
            %    - the x and y axis are equal (not deformed)
            %
            %    Parameters:
            %        x_vec (vector): vector with all x coordinates
            %        y_vec (vector): vector with all y coordinates
            %        fact (float): free space around the component compared to the size of the component
            
            % get the component size
            dx = 1e3.*max(abs(x_vec));
            dy = 1e3.*max(abs(y_vec));
            
            % add the margin to the component size
            dx_scale = (1+fact).*dx;
            dy_scale = (1+fact).*dy;
            
            % get the axis limit
            dx_ax = max(xlim(self.ax))-min(xlim(self.ax));
            dy_ax = max(ylim(self.ax))-min(ylim(self.ax));
            
            % get the component size with the axis ratio
            dx_ratio = dy_scale.*(dx_ax./dy_ax);
            dy_ratio = dx_scale.*(dy_ax./dx_ax);
            
            % select the critical case: size with margin or size from ratio
            dx_new = max(dx_scale, dx_ratio);
            dy_new = max(dy_scale, dy_ratio);
            
            % set the axis
            xlim(self.ax, [-dx_new +dx_new]);
            ylim(self.ax, [-dy_new +dy_new]);
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