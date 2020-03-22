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
        
        function is_valid_tmp = get_is_valid(self, idx)
            is_valid_tmp = self.is_valid(idx);
        end
        
        function data = get_data(self, idx)
            data.idx = idx;
            data.is_valid = self.is_valid(idx);
            data.fom = get_struct_filter(self.fom, idx);
            data.operating = get_struct_filter(self.operating, idx);
        end
        
        function get_text(self, idx)
            txt = [];
            
            
            is_valid_tmp = self.is_valid(idx);
            fom_tmp = get_struct_filter(self.fom, idx);
            operating_tmp = get_struct_filter(self.operating, idx);

            
        end
        
        
        
        function [plot_data, text_data, operating_data] = get_gui(self, idx)
            fom_tmp = get_struct_filter(self.fom, idx);
            operating_tmp = get_struct_filter(self.operating, idx);
            
            plot_data.front = self.get_plot_data_front(fom_tmp.geom);
            plot_data.top = self.get_plot_data_top(fom_tmp.geom);
            text_data = self.get_text_data_fom(fom_tmp);

            field = fieldnames(operating_tmp);
            for i=1:length(field)
                operating_pts = operating_tmp.(field{i});
                
                operating_data.(field{i}).is_valid = operating_pts.is_valid;
                operating_data.(field{i}).text_data = self.get_text_data_operating(operating_pts.operating);
            end
        end
    end
    
    methods (Access = private)        
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
            text{2}{end+1} = sprintf('I_sat = %.2f A', fom_tmp.circuit.I_sat);
            text{1}{end+1} = sprintf('I_rms = %.2f A', fom_tmp.circuit.I_rms);
            text{2}{end+1} = sprintf('V_t_area = %.2f Vms', 1e3.*fom_tmp.circuit.V_t_area);
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
    end
end