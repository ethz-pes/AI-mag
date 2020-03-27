classdef GuiGeom < handle
    %% init
    properties (SetAccess = private, GetAccess = private)
        ax
        panel
    end
    methods (Access = public)
        function self = GuiGeom(parent, position)
            self.panel = uipanel(parent, 'BorderType', 'none', 'Units', 'normalized');
            self.ax = axes(self.panel);
            design.GuiUtils.set_position(self.panel, position)
        end
        
        function panel = get_panel(self)
            panel = self.panel;
        end
        
        function set_plot_geom_cross(self)
            self.set_axis();
            
            x = xlim(self.ax);
            y = ylim(self.ax);
            
            plot(self.ax, [x(1) x(2)], [y(1) y(2)], 'r', 'LineWidth', 2)
            plot(self.ax, [x(2) x(1)], [y(1) y(2)], 'r', 'LineWidth', 2)
        end
        
        function set_plot_geom_data(self, plot_data, fact)
            self.set_axis();
            
            % set the the plot
            x_vec = [];
            y_vec = [];
            
            % plot the core element
            for i=1:length(plot_data)
                [x_vec, y_vec] = self.set_element(x_vec, y_vec, plot_data{i});
            end
            
            self.set_lim(x_vec, x_vec, fact);
        end
    end
    methods (Access = private)
        function set_axis(self)            
            set(self.ax, 'Box','on');
            set(self.ax, 'FontSize', 10);
            
            axtoolbar(self.ax, {'pan', 'zoomin','zoomout','restoreview'}, 'Visible', 'on');
            hold(self.ax, 'on');
            axis(self.ax, 'equal');
            xlabel(self.ax, '[mm]', 'FontSize', 11);
            ylabel(self.ax, '[mm]', 'FontSize', 11);
            xtickformat('%+.1f')
            ytickformat('%+.1f')
        end
        
        function [x_vec, y_vec] = set_element(self, x_vec, y_vec, plot_data)            
            x_min = plot_data.pos(1)-plot_data.size(1)./2;
            x_max = plot_data.pos(1)+plot_data.size(1)./2;
            y_min = plot_data.pos(2)-plot_data.size(2)./2;
            y_max = plot_data.pos(2)+plot_data.size(2)./2;
            
            r = 2.*plot_data.r./min(plot_data.size);
            vec = [x_min y_min x_max-x_min y_max-y_min];
            x_vec = [x_vec x_min x_max];
            y_vec = [y_vec y_min y_max];
            
            switch plot_data.type
                case 'core'
                    rectangle(self.ax, 'Position', 1e3.*vec, 'Curvature', r, 'FaceColor', [0.5 0.5 0.5], 'LineStyle','none')
                case 'air'
                    rectangle(self.ax, 'Position', 1e3.*vec, 'Curvature', r, 'FaceColor', [1.0 1.0 1.0], 'LineStyle','none')
                case 'winding'
                    rectangle(self.ax, 'Position', 1e3.*vec, 'Curvature', r,'FaceColor', [0.9 0.5 0.0], 'LineStyle','none')
                case 'insulation'
                    rectangle(self.ax, 'Position', 1e3.*vec, 'Curvature', r,'FaceColor', [0.5 0.5 0.0], 'LineStyle','none')
                otherwise
                    error('invalid data')
            end
        end
        
        function set_lim(self, x_vec, y_vec, fact)
            dx = 1e3.*max(abs(x_vec));
            dy = 1e3.*max(abs(y_vec));

            dx_ax = max(xlim(self.ax))-min(xlim(self.ax));
            dy_ax = max(ylim(self.ax))-min(ylim(self.ax));
            
            dx_scale = (1+fact).*dx;
            dy_scale = (1+fact).*dy;
            
            dx_ratio = dy_scale.*(dx_ax./dy_ax);
            dy_ratio = dx_scale.*(dy_ax./dx_ax);
            
            dx_new = max(dx_scale, dx_ratio);
            dy_new = max(dy_scale, dy_ratio);
            
            xlim(self.ax, [-dx_new +dx_new]);
            ylim(self.ax, [-dy_new +dy_new]);
        end
    end
end