classdef GuiGeom < handle
    %% init
    methods (Static, Access = public)
        function ax = get_plot_geom(panel, position)
            ax = axes(panel);
            set(ax, 'Box','on');
            set(ax, 'FontSize', 10);
            design.GuiGeom.set_position(ax, position)
            
            axtoolbar(ax, {'pan', 'zoomin','zoomout','restoreview'}, 'Visible', 'on');
            hold(ax, 'on');
            axis(ax, 'equal');
            xlabel(ax, '[mm]', 'FontSize', 11);
            ylabel(ax, '[mm]', 'FontSize', 11);
            xtickformat('%+.1f')
            ytickformat('%+.1f')
        end
        
        function set_plot_geom_cross(ax)
            x = xlim(ax);
            y = ylim(ax);
            
            plot(ax, [x(1) x(2)], [y(1) y(2)], 'r', 'LineWidth', 2)
            plot(ax, [x(2) x(1)], [y(1) y(2)], 'r', 'LineWidth', 2)
        end
        
        function set_plot_geom_data(ax, plot_data, fact)
            % set the the plot
            x_vec = [];
            y_vec = [];
            
            % plot the core element
            for i=1:length(plot_data)
                tmp = plot_data{i};
                
                x_min = tmp.pos(1)-tmp.size(1)./2;
                x_max = tmp.pos(1)+tmp.size(1)./2;
                y_min = tmp.pos(2)-tmp.size(2)./2;
                y_max = tmp.pos(2)+tmp.size(2)./2;
                
                r = 2.*tmp.r./min(tmp.size);
                vec = [x_min y_min x_max-x_min y_max-y_min];
                x_vec = [x_vec x_min x_max];
                y_vec = [y_vec y_min y_max];
                
                switch tmp.type
                    case 'core'
                        rectangle(ax, 'Position', 1e3.*vec, 'Curvature', r, 'FaceColor', [0.5 0.5 0.5], 'LineStyle','none')
                    case 'air'
                        rectangle(ax, 'Position', 1e3.*vec, 'Curvature', r, 'FaceColor', [1.0 1.0 1.0], 'LineStyle','none')
                    case 'winding'
                        rectangle(ax, 'Position', 1e3.*vec, 'Curvature', r,'FaceColor', [0.9 0.5 0.0], 'LineStyle','none')
                    case 'insulation'
                        rectangle(ax, 'Position', 1e3.*vec, 'Curvature', r,'FaceColor', [0.5 0.5 0.0], 'LineStyle','none')
                    otherwise
                        error('invalid data')
                end
            end
            
            dx = 1e3.*max(abs(x_vec));
            dy = 1e3.*max(abs(y_vec));
            
            design.GuiGeom.set_plot_geom_axis(ax, dx, dy, fact);
        end
    end
    
    methods (Static, Access = private)
        function set_position(obj, position)
            if all(position>=0)&&all(position<=1)
                set(obj, 'Units', 'normalized');
                set(obj, 'Position', position);
            else
                set(obj, 'Units', 'pixels');
                set(obj, 'Position', position);
            end
        end
        
        function set_plot_geom_axis(ax, dx, dy, fact)
            dx_ax = max(xlim(ax))-min(xlim(ax));
            dy_ax = max(ylim(ax))-min(ylim(ax));
            
            dx_scale = (1+fact).*dx;
            dy_scale = (1+fact).*dy;
            
            dx_ratio = dy_scale.*(dx_ax./dy_ax);
            dy_ratio = dx_scale.*(dy_ax./dx_ax);
            
            dx_new = max(dx_scale, dx_ratio);
            dy_new = max(dy_scale, dy_ratio);
            
            xlim(ax, [-dx_new +dx_new]);
            ylim(ax, [-dy_new +dy_new]);
        end
    end
end