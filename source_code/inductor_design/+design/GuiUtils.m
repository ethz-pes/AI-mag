classdef GuiUtils < handle
    %% init
    methods (Static, Access = public)
        function fig = get_gui(id, position, name)
            fig = figure(id);
            
            clf(fig)
            set(fig, 'Position', position)
            set(fig, 'Name', name)
            set(fig, 'NumberTitle', 'off')
            set(fig, 'MenuBar', 'none')
            set(fig, 'Resize','off')
        end
        
        function set_logo(parent, filename)
            [img, map, alphachannel] = imread(filename);
            n_img_x = size(img, 2);
            n_img_y = size(img, 1);
            
            ax = axes(parent, 'Units', 'normalized', 'Position',[0 0 1 1]);
            
            pos = getpixelposition(ax);
            n_ax_x = pos(3);
            n_ax_y = pos(4);
            
            n_img_x_new = n_ax_y.*(n_img_x./n_img_y);
            n_img_y_new = n_ax_x.*(n_img_y./n_img_x);
            
            n_img_x_new = min(n_img_x_new, n_ax_x);
            n_img_y_new = min(n_img_y_new, n_ax_y);
            
            img = imresize(img, [n_img_y_new n_img_x_new]);
            alphachannel = imresize(alphachannel, [n_img_y_new n_img_x_new]);
            
            image(ax, img, 'AlphaData', alphachannel);
            axis(ax, 'off');
            axis(ax, 'image');
        end
        
        function obj = get_panel(parent, position, name)
            obj = uipanel(parent, 'Title', name, 'FontSize', 12);
            design.GuiUtils.set_position(obj, position)
        end
        
        function obj = get_panel_hidden(parent, position)
            obj = uipanel(parent, 'BorderType', 'none', 'Visible', 'off');
            design.GuiUtils.set_position(obj, position)
        end
    end
    methods (Static, Access = public)
        function get_button(parent, position, name, callback)
            obj = uicontrol(parent, 'Style', 'pushbutton', 'FontSize', 12, 'String', name, 'CallBack', callback);
            design.GuiUtils.set_position(obj, position)
        end
        
        function obj = get_menu(parent, position, name, callback)
            obj = uicontrol(parent, 'Style', 'popupmenu', 'FontSize', 12, 'String', name, 'CallBack', callback);
            design.GuiUtils.set_outer_position(obj, position)
        end
        
        function obj = get_status(parent, position)
            obj = uicontrol(parent, 'Style', 'pushbutton', 'Enable', 'inactive', 'FontSize', 12);
            design.GuiUtils.set_outer_position(obj, position)
        end
        
        function set_status(obj, is_valid)
            if is_valid==true
                set(obj, 'BackgroundColor', 'g')
                set(obj, 'String', 'valid')
            else
                set(obj, 'BackgroundColor', 'r')
                set(obj, 'String', 'invalid')
            end
        end
        
        function set_list(obj, is_valid)
            if is_valid==true
                set(obj, 'BackgroundColor', 'g')
            else
                set(obj, 'BackgroundColor', 'r')
            end
        end
    end
    
    methods (Static, Access = public)
        function ax = get_plot_geom(panel, position)
            ax = axes(panel);
            set(ax, 'Box','on');
            set(ax, 'FontSize', 10);
            design.GuiUtils.set_position(ax, position)
            
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
            
            design.GuiUtils.set_plot_geom_axis(ax, dx, dy, fact);
        end
    end
    
    methods (Static, Access = public)
        function set_text(panel, offset, margin_title, margin_text, txt_data)
            pos = getpixelposition(panel);
            offset = pos(4)-offset;
            
            for i=1:length(txt_data)
                title = txt_data{i}.title;
                text = txt_data{i}.text;
                                                
                h = design.GuiUtils.set_text_title(panel, margin_title, offset, title);
                offset = offset-h;
                
                for j=1:length(margin_text)
                    text_tmp = text(j:length(margin_text):end);
                    h_vec(j) = design.GuiUtils.set_text_matrix(panel, margin_text(j), offset, text_tmp);
                end
                offset = offset-max(h_vec);
            end
        end
    end
    
    methods (Static, Access = public)
        function set_position(obj, position)
            if all(position>=0)&&all(position<=1)
                set(obj, 'Units', 'normalized');
                set(obj, 'Position', position);
            else
                set(obj, 'Units', 'pixels');
                set(obj, 'Position', position);
            end
        end
        
        function set_outer_position(obj, position)
            if all(position>=0)&&all(position<=1)
                set(obj, 'Units', 'normalized');
                set(obj, 'OuterPosition', position);
            else
                set(obj, 'Units', 'pixels');
                set(obj, 'OuterPosition', position);
            end
        end
        
        function set_visible(obj, visible)
            set(obj, 'Visible', visible);
        end
    end
    
    methods (Static, Access = private)
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
        
        function h = set_text_title(panel, margin, offset, data)
            handle = uicontrol(panel, ...
                'Style','text',...
                'FontSize', 11,...
                'FontWeight', 'bold',...
                'HorizontalAlignment', 'left',...
                'String', data...
                );
            w = handle.Extent(3);
            h = handle.Extent(4);
            set(handle, 'Position', [margin offset-h w h]);
        end
        
        function h = set_text_matrix(panel, margin, offset, data)
            handle = uicontrol(panel, ...
                'Style','text',...
                'FontSize', 11,...
                'FontWeight', 'normal',...
                'HorizontalAlignment', 'left',...
                'String', data...
                );
            w = handle.Extent(3);
            h = handle.Extent(4);
            set(handle, 'Position', [margin offset-h w h]);
        end
    end
end