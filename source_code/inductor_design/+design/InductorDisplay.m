classdef InductorDisplay < handle
    %% init
    properties (SetAccess = immutable, GetAccess = private)
        is_valid
        fom
        operating
    end
    
    %% init
    methods (Access = public)
        function self = InductorDisplay(is_valid, fom, operating)
            self.is_valid = is_valid;
            self.fom = fom;
            self.operating = operating;
            
            self.fom = get_struct_size(self.fom, length(self.is_valid));
            self.operating = get_struct_size(self.operating, length(self.is_valid));
        end
        
        function get_gui(self, idx, id)
            is_valid_tmp = self.is_valid(idx);
            fom_tmp = get_struct_filter(self.fom, idx);
            operating_tmp = get_struct_filter(self.operating, idx);
            
            fig = figure(id);
            clf(id)
            
            set(fig, 'Position', [200 200 1390 700])
            set(fig, 'name', sprintf('InductorDisplay : idx = %d', idx))
            set(fig, 'NumberTitle', 'off')
            set(fig, 'MenuBar', 'none')
            set(fig, 'ToolBar', 'none')
            set(fig, 'Resize','off')
            
            panel_plot = uipanel('Title','Plot', 'Units', 'pixels', 'FontSize', 12, 'Position',[10 10 450 680]);
            panel_inductor = uipanel('Title','Inductor', 'Units', 'pixels', 'FontSize', 12, 'Position',[470 80 450 610]);
            panel_operating = uipanel('Title','Operating', 'Units', 'pixels', 'FontSize', 12, 'Position',[930 80 450 610]);
            panel_button = uipanel('Units', 'pixels', 'FontSize', 12, 'Position',[470 10 450 60]);
            panel_logo = uipanel('Units', 'pixels', 'FontSize', 12, 'Position',[930 10 450 60]);
            
            self.logo_pannel(panel_logo, 'test.png');


            button_1 = uicontrol(panel_button, 'Units', 'normalized', 'Style', 'pushbutton', 'FontSize', 12, 'String', 'Save Data', 'Position', [0.02 0.1 0.3 0.8]);
            button_1 = uicontrol(panel_button, 'Units', 'normalized', 'Style', 'pushbutton', 'FontSize', 12, 'String', 'Save Image', 'Position', [0.35 0.1 0.3 0.8]);
            button_1 = uicontrol(panel_button, 'Units', 'normalized', 'Style', 'pushbutton', 'FontSize', 12, 'String', 'Copy Data', 'Position', [0.68 0.1 0.3 0.8]);

            if is_valid_tmp==false
                self.cross_panel(panel_plot);
                self.cross_panel(panel_inductor);
                self.cross_panel(panel_operating);
                self.cross_panel(panel_button);
            else
                self.display_plot(fom_tmp, panel_plot);
                self.display_inductor(fom_tmp, panel_inductor);
                self.display_operating(operating_tmp, panel_operating);
            end
        end
    end
    
    methods (Access = private)
        function display_operating(self, operating_tmp, panel_operating)            
            field = fieldnames(operating_tmp);
            for i=1:length(field)
                panel_vec(i) = uipanel(panel_operating, 'Units', 'pixels', 'BorderType', 'none', 'Visible', 'off', 'Position', [0 0 450 540]);
                is_valid_vec(i) = operating_tmp.(field{i}).is_valid;
                
                operating_tmp_tmp = operating_tmp.(field{i}).operating;
                text_data = self.get_text_data_operating(operating_tmp_tmp);
                self.set_text(panel_vec(i), 540, text_data);
            end
            
            status = uicontrol(panel_operating, 'Style', 'pushbutton', 'Enable', 'inactive', 'FontSize', 12, 'Position', [340 550 100 27]);

            select_operating = @(src,event) self.get_menu(status, is_valid_vec, panel_vec, src.Value);
            menu = uicontrol(panel_operating, 'Style', 'popupmenu', 'FontSize', 12, 'String', field, 'Position', [10 550 320 27], 'CallBack', select_operating);
            self.get_menu(status, is_valid_vec, panel_vec, menu.Value);
                        
        end
        
        function get_menu(self, status, is_valid_vec, panel_vec, idx)


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
        
        function display_inductor(self, fom_tmp, panel_inductor)
            text_data = self.get_text_data_fom(fom_tmp);
            self.set_text(panel_inductor, 580, text_data);
        end
        
        function display_plot(self, fom_tmp, panel_plot)
            plot_data_front = self.get_plot_data_front(fom_tmp.geom);
            plot_data_top = self.get_plot_data_top(fom_tmp.geom);
            
            ax = self.init_axes(panel_plot, [50 50 380 270]);
            self.set_plot_data(ax, plot_data_front);
            
            ax = self.init_axes(panel_plot, [50 380 380 270]);
            self.set_plot_data(ax, plot_data_top);
        end
        
        function text_data = get_text_data_operating(self, operating_tmp)
            text_data = {};
                       
            text = {{}, {}};
            text{1}{end+1} = sprintf('T_ambient = %.2f C', operating_tmp.excitation.T_ambient);
            text{2}{end+1} = sprintf('is_pwm = %d', operating_tmp.excitation.is_pwm);
            text{1}{end+1} = sprintf('f = %.2f kHz', 1e-3.*operating_tmp.excitation.f);
            text{2}{end+1} = sprintf('d_c = %.2f %%', 1e2.*operating_tmp.excitation.d_c);
            text{1}{end+1} = sprintf('I_dc = %.2f A', operating_tmp.excitation.I_dc);
            text{2}{end+1} = sprintf('I_ac_peak = %.2f A', operating_tmp.excitation.I_ac_peak);
            text_data{end+1} = struct('title', 'excitation', 'text', {text});
            
            text = {{}, {}};
            text{1}{end+1} = sprintf('J_dc = %.2f A/mm2', 1e-6.*operating_tmp.field.J_dc);
            text{2}{end+1} = sprintf('J_ac_peak = %.2f A/mm2', 1e-6.*operating_tmp.field.J_ac_peak);
            text{1}{end+1} = sprintf('B_dc = %.2f mT', 1e3.*operating_tmp.field.B_dc);
            text{2}{end+1} = sprintf('B_ac_peak = %.2f mT', 1e3.*operating_tmp.field.B_ac_peak);
            text{1}{end+1} = sprintf('H_dc = %.2f A/mm', 1e-3.*operating_tmp.field.H_dc);
            text{2}{end+1} = sprintf('H_ac_peak = %.2f A/mm', 1e-3.*operating_tmp.field.H_ac_peak);
            text_data{end+1} = struct('title', 'field', 'text', {text});
            
            text = {{}, {}};
            text{1}{end+1} = sprintf('T_core_max = %.2f W', operating_tmp.thermal.T_core_max);
            text{2}{end+1} = sprintf('T_core_avg = %.2f W', operating_tmp.thermal.T_core_avg);
            text{1}{end+1} = sprintf('T_winding_max = %.2f C', operating_tmp.thermal.T_winding_max);
            text{2}{end+1} = sprintf('T_winding_avg = %.2f C', operating_tmp.thermal.T_winding_avg);
            text{1}{end+1} = sprintf('T_iso_max = %.2f C', operating_tmp.thermal.T_iso_max);
            text{1}{end+1} = sprintf('T_max = %.2f C', operating_tmp.thermal.T_max);
            text{1}{end+1} = sprintf('is_valid_thermal = %d', operating_tmp.thermal.is_valid_thermal);
            text_data{end+1} = struct('title', 'thermal', 'text', {text});


            text = {{}, {}};
            text{1}{end+1} = sprintf('P_core = %.2f W', operating_tmp.losses.P_core);
            text{2}{end+1} = sprintf('P_winding = %.2f W', operating_tmp.losses.P_winding);
            text{1}{end+1} = sprintf('P_winding_dc = %.2f W', operating_tmp.losses.P_winding_dc);
            text{2}{end+1} = sprintf('P_winding_ac_lf = %.2f W', operating_tmp.losses.P_winding_ac_lf);
            text{1}{end+1} = sprintf('P_winding_ac_hf = %.2f W', operating_tmp.losses.P_winding_ac_hf);
            text{2}{end+1} = sprintf('P_add = %.2f W', operating_tmp.losses.P_add);
            text{1}{end+1} = sprintf('P_tot = %.2f W', operating_tmp.losses.P_tot);
            text{1}{end+1} = sprintf('is_valid_core = %d', operating_tmp.losses.is_valid_core);
            text{1}{end+1} = sprintf('is_valid_winding = %d', operating_tmp.losses.is_valid_winding);
            text_data{end+1} = struct('title', 'losses', 'text', {text});



        end
        
        function text_data = get_text_data_fom(self, fom_tmp)
            text_data = {};
            
            text = {{}, {}};
            text{1}{end+1} = sprintf('z_core = %.2f mm', 1e3.*fom_tmp.geom.z_core);
            text{2}{end+1} = sprintf('t_core = %.2f mm', 1e3.*fom_tmp.geom.t_core);
            text{1}{end+1} = sprintf('x_window = %.2f mm', 1e3.*fom_tmp.geom.x_window);
            text{2}{end+1} = sprintf('y_window = %.2f mm', 1e3.*fom_tmp.geom.y_window);
            text{1}{end+1} = sprintf('d_gap = %.2f mm', 1e3.*fom_tmp.geom.d_gap);
            text{2}{end+1} = sprintf('d_iso = %.2f mm', 1e3.*fom_tmp.geom.d_iso);
            text{1}{end+1} = sprintf('r_curve = %.2f mm', 1e3.*fom_tmp.geom.r_curve);
            text{2}{end+1} = sprintf('n_turn = %d', fom_tmp.geom.n_turn);
            text_data{end+1} = struct('title', 'geom', 'text', {text});
            
            text = {{}, {}};
            text{1}{end+1} = sprintf('core_id = %d', fom_tmp.material.core_id);
            text{1}{end+1} = sprintf('winding_id = %d', fom_tmp.material.winding_id);
            text{1}{end+1} = sprintf('iso_id = %d', fom_tmp.material.iso_id);
            text_data{end+1} = struct('title', 'material', 'text', {text});
                       
            text = {{}, {}};
            text{1}{end+1} = sprintf('A_core = %.2f cm2', 1e4.*fom_tmp.area.A_core);
            text{2}{end+1} = sprintf('V_core = %.2f dm3', 1e3.*fom_tmp.volume.V_core);
            text{1}{end+1} = sprintf('A_winding = %.2f cm2', 1e4.*fom_tmp.area.A_winding);
            text{2}{end+1} = sprintf('V_winding = %.2f dm3', 1e3.*fom_tmp.volume.V_winding);
            text{1}{end+1} = sprintf('A_box = %.2f cm2', 1e4.*fom_tmp.area.A_box);
            text{2}{end+1} = sprintf('V_box = %.2f dm3', 1e3.*fom_tmp.volume.V_box);
            text_data{end+1} = struct('title', 'area / volume', 'text', {text});
            
            text = {{}, {}};
            text{1}{end+1} = sprintf('m_core = %.2f kg', fom_tmp.mass.m_core);
            text{2}{end+1} = sprintf('c_core = %.2f $', fom_tmp.cost.c_core);
            text{1}{end+1} = sprintf('m_winding = %.2f kg', fom_tmp.mass.m_winding);
            text{2}{end+1} = sprintf('c_winding = %.2f $', fom_tmp.cost.c_winding);
            text{1}{end+1} = sprintf('m_iso = %.2f kg', fom_tmp.mass.m_iso);
            text{2}{end+1} = sprintf('c_iso = %.2f $', fom_tmp.cost.c_iso);
            text{1}{end+1} = sprintf('m_box = %.2f kg', fom_tmp.mass.m_box);
            text{2}{end+1} = sprintf('c_box = %.2f $', fom_tmp.cost.c_box);
            text_data{end+1} = struct('title', 'mass / cost', 'text', {text});
            
            text = {{}, {}};
            text{1}{end+1} = sprintf('L = %.2f uH', 1e6.*fom_tmp.circuit.L);
            text{1}{end+1} = sprintf('I_sat = %.2f A', fom_tmp.circuit.I_sat);
            text{1}{end+1} = sprintf('I_rms = %.2f A', fom_tmp.circuit.I_rms);
            text_data{end+1} = struct('title', 'circuit', 'text', {text});                      
        end
        
        function plot_data = get_plot_data_front(self, geom_tmp)
            x_window = geom_tmp.x_window;
            y_window = geom_tmp.y_window;
            t_core = geom_tmp.t_core;
            d_gap = geom_tmp.d_gap;
            d_iso = geom_tmp.d_iso;
            
            x_core = 2.*x_window+2.*t_core;
            y_core = y_window+t_core;
            x_winding = x_window-2.*d_iso;
            y_winding = y_window-2.*d_iso;
            x_window_offset = t_core./2+x_window./2;
            
            plot_data = {};
            plot_data{end+1} = struct('type', 'core', 'pos', [0 0], 'size', [x_core y_core], 'r', 0);
            plot_data{end+1} = struct('type', 'air', 'pos', [0 0], 'size', [x_core d_gap], 'r', 0);
            plot_data{end+1} = struct('type', 'insulation', 'pos', [+x_window_offset 0], 'size', [x_window y_window], 'r', 0);
            plot_data{end+1} = struct('type', 'insulation', 'pos', [-x_window_offset 0], 'size', [x_window y_window], 'r', 0);
            plot_data{end+1} = struct('type', 'winding', 'pos', [+x_window_offset 0], 'size', [x_winding y_winding], 'r', 0);
            plot_data{end+1} = struct('type', 'winding', 'pos', [-x_window_offset 0], 'size', [x_winding y_winding], 'r', 0);
        end
        
        function plot_data = get_plot_data_top(self, geom_tmp)
            x_window = geom_tmp.x_window;
            t_core = geom_tmp.t_core;
            z_core = geom_tmp.z_core;
            d_iso = geom_tmp.d_iso;
            r_curve = geom_tmp.r_curve;
            
            x_core = 2.*x_window+2.*t_core;
            
            r_curve_1 = r_curve;
            r_curve_2 = r_curve+d_iso;
            r_curve_3 = r_curve+x_window-d_iso;
            r_curve_4 = r_curve+x_window;
            
            z_1 = z_core+2.*r_curve;
            z_2 = z_core+2.*r_curve+2.*d_iso;
            z_3 = z_core+2.*r_curve+2.*x_window-2.*d_iso;
            z_4 = z_core+2.*r_curve+2.*x_window;
            
            x_1 = t_core;
            x_2 = t_core+2.*d_iso;
            x_3 = t_core+2.*x_window-2.*d_iso;
            x_4 = t_core+2.*x_window;
            
            plot_data = {};
            plot_data{end+1} = struct('type', 'insulation', 'pos', [0 0], 'size', [z_4 x_4], 'r', r_curve_4);
            plot_data{end+1} = struct('type', 'winding', 'pos', [0 0], 'size', [z_3 x_3], 'r', r_curve_3);
            plot_data{end+1} = struct('type', 'insulation', 'pos', [0 0], 'size', [z_2 x_2], 'r', r_curve_2);
            plot_data{end+1} = struct('type', 'air', 'pos', [0 0], 'size', [z_1 x_1], 'r', r_curve_1);
            plot_data{end+1} = struct('type', 'core', 'pos', [0 0], 'size', [z_core x_core], 'r', 0);
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

                h_1 = self.set_text_matrix(panel, 25, offset, text{1});
                h_2 = self.set_text_matrix(panel, 240, offset, text{2});
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
        
        function logo_pannel(self, panel, filename)
            ax = axes(panel, 'Units', 'normalized', 'Position',[0 0 1 1]);
            img = imread(filename);
            image(ax, img);
            axis(ax, 'off');
            axis(ax, 'image');
        end
        
        function cross_panel(self, panel)
            ax = axes(panel, 'Units', 'normalized', 'position',[0, 0, 1, 1]);
            axis(ax, 'off')
            hold(ax, 'on');
            plot(ax, [-1 +1], [-1 +1], 'r', 'LineWidth', 2)
            plot(ax, [-1 +1], [+1 -1], 'r', 'LineWidth', 2)
        end
    end
    
end