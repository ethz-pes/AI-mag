classdef InductorGui < handle
    %% init
    properties (SetAccess = immutable, GetAccess = private)
        fom
        operating
    end
    properties (SetAccess = private, GetAccess = private)
        inductor_display_obj
    end
    
    %% init
    methods (Access = public)
        function self = InductorGui(fom, operating)
            self.fom = fom;
            self.operating = operating;
            
            self.inductor_display_obj = design.InductorDisplay(self.fom, self.operating);
        end
        
        function get_gui(self, idx, id)            
            fig = figure(id);
            clf(id)
            
            set(fig, 'Position', [200 200 1390 700])
            set(fig, 'name', sprintf('InductorDisplay : idx = %d', idx))
            set(fig, 'NumberTitle', 'off')
            set(fig, 'MenuBar', 'none')
            set(fig, 'ToolBar', 'none')
            set(fig, 'Resize','off')
            
            [gui, data, txt] = self.inductor_display_obj.get_idx(idx);

            panel_plot = uipanel('Title','Plot', 'Units', 'pixels', 'FontSize', 12, 'Position',[10 10 450 680]);
            self.display_plot(panel_plot, gui.plot_gui);

            panel_inductor = uipanel('Title','Inductor', 'Units', 'pixels', 'FontSize', 12, 'Position',[470 80 450 610]);
            self.display_inductor(panel_inductor, gui.fom_gui);
            
            panel_operating = uipanel('Title','Operating', 'Units', 'pixels', 'FontSize', 12, 'Position',[930 80 450 610]);
            self.display_operating(panel_operating, gui.operating_gui);

            panel_logo = uipanel('Units', 'pixels', 'FontSize', 12, 'Position',[930 10 450 60]);
            self.display_logo(panel_logo, 'test.png');
            
            panel_button = uipanel('Units', 'pixels', 'FontSize', 12, 'Position',[470 10 450 60]);
            self.display_button(panel_button, data, fig, txt);
        end
    end
    
    methods (Access = private)
        function display_button(self, panel_button, data, fig, txt)
            callback = @(src,event) self.callback_save_data(data);
            uicontrol(panel_button, 'Units', 'normalized', 'Style', 'pushbutton', 'FontSize', 12, 'String', 'Save Data', 'Position', [0.02 0.1 0.3 0.8], 'CallBack', callback);
            callback = @(src,event) self.callback_save_image(fig);
            uicontrol(panel_button, 'Units', 'normalized', 'Style', 'pushbutton', 'FontSize', 12, 'String', 'Save Image', 'Position', [0.35 0.1 0.3 0.8], 'CallBack', callback);
            callback = @(src,event) self.callback_copy_data(txt);
            uicontrol(panel_button, 'Units', 'normalized', 'Style', 'pushbutton', 'FontSize', 12, 'String', 'Copy Data', 'Position', [0.68 0.1 0.3 0.8], 'CallBack', callback);
        end
        
        
        function callback_save_data(self, data)
           [file, path, indx] = uiputfile('*.mat');
           if indx~=0
               save([path file], 'data')
           end
        end
        
        function callback_save_image(self, fig)
           [file, path, indx] = uiputfile('*.png');
           if indx~=0
               img = getframe(fig);
               imwrite(img.cdata, [path file])
           end
        end

        function callback_copy_data(self, txt)
            clipboard('copy', txt)
        end
        
        function callback_menu(self, status, is_valid_vec, panel_vec, idx)
            set(panel_vec, 'Visible', 'off');
            set(panel_vec(idx), 'Visible', 'on');
            
            is_valid_tmp = is_valid_vec(idx);
            if is_valid_tmp==true
                set(status, 'BackgroundColor', 'g')
                set(status, 'String', 'valid')
            else
                set(status, 'BackgroundColor', 'r')
                set(status, 'String', 'invalid')
            end
        end

        function display_operating(self, panel_operating, operating_gui)
            field = fieldnames(operating_gui);
            for i=1:length(field)
                is_valid_tmp = operating_gui.(field{i}).is_valid;
                text_data_tmp = operating_gui.(field{i}).text_data;

                panel_tmp = uipanel(panel_operating, 'Units', 'pixels', 'BorderType', 'none', 'Visible', 'off', 'Position', [0 0 450 540]);                
                self.set_text(panel_tmp, 540, text_data_tmp);

                panel_vec(i) = panel_tmp;
                is_valid_vec(i) = is_valid_tmp;
            end
            
            status = uicontrol(panel_operating, 'Style', 'pushbutton', 'Enable', 'inactive', 'FontSize', 12, 'Position', [340 550 100 27]);
            callback = @(src, event) self.callback_menu(status, is_valid_vec, panel_vec, src.Value);
            menu = uicontrol(panel_operating, 'Style', 'popupmenu', 'FontSize', 12, 'String', field, 'Position', [10 550 320 27], 'CallBack', callback);
            callback(menu, []);
        end
        
        function display_inductor(self, panel_inductor, fom_gui)
            status = uicontrol(panel_inductor, 'Style', 'pushbutton', 'Enable', 'inactive', 'FontSize', 12, 'Position', [10 550 430 27]);
            if fom_gui.is_valid==true
                set(status, 'BackgroundColor', 'g')
                set(status, 'String', 'valid')
            else
                set(status, 'BackgroundColor', 'r')
                set(status, 'String', 'invalid')
            end

            self.set_text(panel_inductor, 540, fom_gui.text_data);
        end
        
        function display_plot(self, panel_plot, plot_gui)
            ax_front = self.init_axes(panel_plot, [50 50 380 270]);
            ax_top = self.init_axes(panel_plot, [50 380 380 270]);

            if plot_gui.is_valid==true
                self.set_plot_data(ax_front, plot_gui.plot_data_front);
                self.set_plot_data(ax_top, plot_gui.plot_data_top);
            else
                self.cross_axes(ax_front)
                self.cross_axes(ax_top)
            end
        end
                        
        function set_plot_data(self, ax, plot_data)
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
            
            self.set_axis(ax, dx, dy);
        end
    end
    
    methods (Access = private)
        function set_text(self, panel, offset, txt_data)
            for i=1:length(txt_data)
                title = txt_data{i}.title;
                text = txt_data{i}.text;
                                                
                h = self.set_text_title(panel, 10, offset, title);
                offset = offset-h;

                h_1 = self.set_text_matrix(panel, 25, offset, text(1:2:end));
                h_2 = self.set_text_matrix(panel, 240, offset, text(2:2:end));
                offset = offset-max(h_1, h_2);
            end
        end
        
        function h = set_text_title(self, panel, margin, offset, data)
            handle = uicontrol(panel, ...
                'Style','text',...
                'FontSize', 12,...
                'FontWeight', 'bold',...
                'HorizontalAlignment', 'left',...
                'String', data...
                );
            w = handle.Extent(3);
            h = handle.Extent(4);
            set(handle, 'Position', [margin offset-h w h]);
        end
        
        function h = set_text_matrix(self, panel, margin, offset, data)
            handle = uicontrol(panel, ...
                'Style','text',...
                'FontSize', 12,...
                'FontWeight', 'normal',...
                'HorizontalAlignment', 'left',...
                'String', data...
                );
            w = handle.Extent(3);
            h = handle.Extent(4);
            set(handle, 'Position', [margin offset-h w h]);
        end
        
        function set_axis(self, ax, dx, dy)
            dx_ax = max(xlim(ax))-min(xlim(ax));
            dy_ax = max(ylim(ax))-min(ylim(ax));
            
            dx_scale = 1.1.*dx;
            dy_scale = 1.1.*dy;
            
            dx_ratio = dy_scale.*(dx_ax./dy_ax);
            dy_ratio = dx_scale.*(dy_ax./dx_ax);
            
            dx_new = max(dx_scale, dx_ratio);
            dy_new = max(dy_scale, dy_ratio);
            
            xlim(ax, [-dx_new +dx_new]);
            ylim(ax, [-dy_new +dy_new]);
        end

        function ax = init_axes(self, panel, position)
            ax = axes(panel, 'Units', 'pixels', 'box','on', 'Position', position);
            hold(ax, 'on');
            axis(ax, 'equal');
            xlabel(ax, '[mm]');
            ylabel(ax, '[mm]');
        end
        
        function display_logo(self, panel, filename)
            ax = axes(panel, 'Units', 'normalized', 'Position',[0 0 1 1]);
            img = imread(filename);
            image(ax, img);
            axis(ax, 'off');
            axis(ax, 'image');
        end
        
        function cross_axes(self, ax)
            hold(ax, 'on');
            plot(ax, [-1 +1], [-1 +1], 'r', 'LineWidth', 2)
            plot(ax, [-1 +1], [+1 -1], 'r', 'LineWidth', 2)
        end
    end
    
end