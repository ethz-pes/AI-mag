classdef GuiScatter < handle
    %% init
    properties (SetAccess = private, GetAccess = private)
        ax
        panel
        position
        plot_data
        callback
        h_pts
        h_select
        idx_perm
    end
    
    %% init
    methods (Access = public)
        function self = GuiScatter(parent, position)
            self.panel = uipanel(parent, 'BorderType', 'none', 'Units', 'normalized');
            self.position = position;
            self.ax = [];
            self.plot_data = [];
            self.callback = [];
            self.h_pts = [];
            self.h_select = [];
        end
        
        function set_data(self, plot_data, callback)
            self.plot_data = plot_data;
            self.callback = callback;
            
            self.init_perm();
            self.init_plot();
            self.make_plot();
        end
        
        function set_visible(self, visible)
            if visible==true
                set(self.panel, 'Visible', 'on');
            else
                set(self.panel, 'Visible', 'off');
            end
        end
        
        function panel = get_panel(self)
            panel = self.panel;
        end
        
        function delete_panel(self)
            if ishandle(self.ax)
                delete(self.ax);
            end
        end
        
        function set_select(self, id)
            id_vec = self.plot_data.id_data;
            x_vec = self.plot_data.x_data;
            y_vec = self.plot_data.y_data;
            
            idx = id_vec==id;
            assert(nnz(idx)==1, 'invalid data')
            x = x_vec(idx);
            y = y_vec(idx);
            
            set(self.h_select, 'XData', x);
            set(self.h_select, 'YData', y);
        end
        
        function clear_select(self)
            set(self.h_select, 'XData', NaN);
            set(self.h_select, 'YData', NaN);
        end
    end
    methods (Access = private)
        function init_perm(self)
            c_vec = self.plot_data.c_data;
            order = self.plot_data.order;
            
            switch order
                case 'random'
                    self.idx_perm = randperm(length(c_vec));
                case 'ascend'
                    [v, self.idx_perm] = sort(c_vec, 'ascend');
                case 'descend'
                    [v, self.idx_perm] = sort(c_vec, 'descend');
                otherwise
                    error('invalid data')
            end
        end
        
        function init_plot(self)
            self.ax = axes(self.panel);
            self.set_position()
            
            set(self.ax, 'Box', 'on');
            set(self.ax, 'FontSize', 10);
            axtoolbar(self.ax, {'pan', 'zoomin','zoomout','restoreview'}, 'Visible', 'on');
            
            cbar = colorbar(self.ax);
            set(cbar, 'Location', 'southoutside')
            set(cbar, 'Units', 'pixels')
            set(cbar, 'FontSize', 10)
            
            text = get(cbar, 'Label');
            set(text, 'interpreter', 'none')
            set(text, 'String', self.plot_data.c_label)
            set(text, 'FontSize', 11)
            
            xlabel(self.ax, self.plot_data.x_label, 'FontSize', 11, 'interpreter', 'none')
            ylabel(self.ax, self.plot_data.y_label, 'FontSize', 11, 'interpreter', 'none')
            hold(self.ax, 'on')
            
            set(self.ax, 'XScale', self.plot_data.x_scale);
            set(self.ax, 'YScale', self.plot_data.y_scale);
            set(self.ax,'ColorScale', self.plot_data.c_scale)
            
            if length(self.plot_data.x_lim)==2
                set(self.ax, 'XLim', self.plot_data.x_lim);
            end
            if length(self.plot_data.y_lim)==2
                set(self.ax, 'YLim', self.plot_data.y_lim);
            end
            if length(self.plot_data.c_lim)==2
                set(self.ax, 'CLim', self.plot_data.c_lim);
            end
            
            grid(self.ax, 'on')
            hold(self.ax, 'on')
        end
        
        function make_plot(self)
            x_vec = self.plot_data.x_data(self.idx_perm);
            y_vec = self.plot_data.y_data(self.idx_perm);
            c_vec = self.plot_data.c_data(self.idx_perm);
            marker_pts_size = self.plot_data.marker_pts_size;
            marker_select_size = self.plot_data.marker_select_size;
            marker_select_color = self.plot_data.marker_select_color;
            
            callback_tmp = @(obj, event) self.get_callback_idx(obj, event);
            self.h_pts = scatter(self.ax, x_vec, y_vec, marker_pts_size, c_vec,...
                'filled',...
                'Marker', 'o',...
                'ButtonDownFcn', callback_tmp);
            
            self.h_select = plot(self.ax, NaN, NaN,...
                'MarkerSize', marker_select_size,...
                'Marker', 'h',...
                'MarkerEdgeColor', marker_select_color,...
                'MarkerFaceColor', marker_select_color);
            
        end
        
        function get_callback_idx(self, obj, event)
            assert(isa(obj, 'matlab.graphics.chart.primitive.Scatter'), 'invalid click')
            assert(isa(event, 'matlab.graphics.eventdata.Hit'), 'invalid click')
            
            currentPoint = get(self.ax, 'CurrentPoint');
            x_select = currentPoint(1,1);
            y_select = currentPoint(1,2);
            
            pos = getpixelposition(self.ax);
            px_x = pos(3);
            px_y = pos(4);
            
            x_vec = self.plot_data.x_data(self.idx_perm);
            y_vec = self.plot_data.y_data(self.idx_perm);
            id_vec = self.plot_data.id_data(self.idx_perm);
            
            x_lim = get(self.ax, 'XLim');
            y_lim = get(self.ax, 'YLim');
            
            x_scale = self.plot_data.x_scale;
            y_scale = self.plot_data.y_scale;
            
            d_px_x_vec = self.get_deviation(x_select, x_vec, x_lim, px_x, x_scale);
            d_px_y_vec = self.get_deviation(y_select, y_vec, y_lim, px_y, y_scale);
            d_px_vec = hypot(d_px_x_vec, d_px_y_vec);
            [d_px, idx] = min(d_px_vec);
            assert(isfinite(d_px), 'invalid click')
            
            id = id_vec(idx);
            self.callback(id);
        end
        
        function d_px_vec = get_deviation(self, v_select, v_vec, v_lim, d_px, scale)
            switch scale
                case 'lin'
                    d_vec = v_select-v_vec;
                    d_lim = max(v_lim)-min(v_lim);
                case 'log'
                    d_vec = log10(v_select)-log10(v_vec);
                    d_lim = max(log10(v_lim))-min(log10(v_lim));
                otherwise
                    error('invalid scale')
            end
            
            d_px_vec = (d_vec./d_lim).*d_px;
        end
        
        function set_position(self)
            if all(self.position>=0)&&all(self.position<=1)
                set(self.panel, 'Units', 'normalized');
                set(self.panel, 'Position', self.position);
            else
                set(self.panel, 'Units', 'pixels');
                set(self.panel, 'Position', self.position);
            end
        end
    end
end