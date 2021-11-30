classdef InductorDisplay < handle
    % Class for managing the inductor design results for 'InductorGUI'.
    %
    %    The class is not displaying anything, it is just managing data.
    %    Prepare the data (plots, figures of merit, and operating points) for a selected design.
    %    Manage the text data for the clipboard with 'GuiClipboard'.
    %
    %    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod
    
    %% properties
    properties (SetAccess = private, GetAccess = public)
        id_design % vector: unique id for each design
        fom % struct: computed inductor figures of merit (independent of any operating points)
        operating % struct: struct containing the excitation, losses, and temperatures for the operating points
    end
    
    %% public
    methods (Access = public)
        function self = InductorDisplay(id_design, fom, operating)
            % Constructor.
            %
            %    Parameters:
            %        id_design (vector): unique id for each design
            %        fom (struct): computed inductor figures of merit (independent of any operating points)
            %        operating (struct): struct containing the excitation, losses, and temperatures for the operating points
            
            self.id_design = id_design;
            self.fom = fom;
            self.operating = operating;
        end
        
        function [plot_data, fom_data, operating_data, txt] = get_data_id(self, id_select)
            % Get the GUI data for a specific inductor with the id.
            %
            %    Parameters:
            %        id_select (int): id of the design to be selected
            %
            %    Returns:
            %        plot_data (struct): data for plotting the inductor geometry
            %        fom_data (struct): data for displaying the figures of merit field
            %        operating_data (struct): data for displaying the operating points field
            %        txt (str): data as text for the clipboard
            
            % get the array index corresponding to the id
            idx = self.id_design==id_select;
            assert(nnz(idx)==1, 'invalid inductor id')
            
            % filter to provided data
            fom_tmp = get_struct_filter(self.fom, idx);
            operating_tmp = get_struct_filter(self.operating, idx);
            
            % get the data for the clipboard
            gui_clipboard_obj = gui.GuiClipboard();
            gui_clipboard_obj.add_title('InductorDisplay');
            gui_clipboard_obj.add_text('id_design = %d', id_select);
            
            % get the data for the plots
            plot_data = self.get_plot_data(fom_tmp);
            
            % get the figures of merit data (and add to clipboard)
            fom_data = self.get_text_data_fom(fom_tmp);
            self.disp_block(gui_clipboard_obj, 'fom', fom_data);
            
            % get the data of the different operating points (and add to clipboard)
            field = fieldnames(operating_tmp);
            for i=1:length(field)
                operating_pts = operating_tmp.(field{i});
                operating_data_pts = self.get_text_data_operating(operating_pts);
                self.disp_block(gui_clipboard_obj, field{i}, operating_data_pts);
                operating_data.(field{i}) = operating_data_pts;
            end
            
            % flush the clipboard data as a string
            txt = gui_clipboard_obj.get_txt();
        end
    end
    
    %% private
    methods (Access = private)
        function data = get_text_data_fom(self, fom_tmp)
            % Get the figures of merit data.
            %
            %    Parameters:
            %        fom_tmp (struct): inductor figures of merit to be parsed
            %
            %    Returns:
            %        data (struct): data for displaying a text field
            
            % init the different blocks
            text_data = {};
            
            % validity information
            text = {};
            text{end+1} = sprintf('is_valid_geom = %d', fom_tmp.is_valid_geom);
            text{end+1} = sprintf('is_valid_mf = %d', fom_tmp.is_valid_mf);
            text{end+1} = sprintf('is_valid_limit = %d', fom_tmp.is_valid_limit);
            text_data{end+1} = struct('title', 'is_valid', 'text', {text});
            
            % geometry data
            text = {};
            text{end+1} = sprintf('z_core = %.2f mm', 1e3.*fom_tmp.geom.z_core);
            text{end+1} = sprintf('t_core = %.2f mm', 1e3.*fom_tmp.geom.t_core);
            text{end+1} = sprintf('x_window = %.2f mm', 1e3.*fom_tmp.geom.x_window);
            text{end+1} = sprintf('y_window = %.2f mm', 1e3.*fom_tmp.geom.y_window);
            text{end+1} = sprintf('d_gap = %.2f mm', 1e3.*fom_tmp.geom.d_gap);
            text{end+1} = sprintf('d_iso = %.2f mm', 1e3.*fom_tmp.geom.d_iso);
            text{end+1} = sprintf('r_curve = %.2f mm', 1e3.*fom_tmp.geom.r_curve);
            text{end+1} = sprintf('fill_pack = %.2f %%', 1e2.*fom_tmp.geom.fill_pack);
            text{end+1} = sprintf('n_turn = %d', fom_tmp.geom.n_turn);
            text_data{end+1} = struct('title', 'geom', 'text', {text});
            
            % material data
            text = {};
            text{end+1} = sprintf('core_id = %s', get_map_int_to_str(fom_tmp.material.core_id));
            text{end+1} = sprintf('winding_id = %s', get_map_int_to_str(fom_tmp.material.winding_id));
            text{end+1} = sprintf('iso_id = %s', get_map_int_to_str(fom_tmp.material.iso_id));
            text_data{end+1} = struct('title', 'material', 'text', {text});
            
            % geometrical figures of merit
            text = {};
            text{end+1} = sprintf('A_iso = %.2f cm2', 1e4.*fom_tmp.area.A_iso);
            text{end+1} = sprintf('V_iso = %.2f cm3', 1e6.*fom_tmp.volume.V_iso);
            text{end+1} = sprintf('A_core = %.2f cm2', 1e4.*fom_tmp.area.A_core);
            text{end+1} = sprintf('V_core = %.2f cm3', 1e6.*fom_tmp.volume.V_core);
            text{end+1} = sprintf('A_winding = %.2f cm2', 1e4.*fom_tmp.area.A_winding);
            text{end+1} = sprintf('V_winding = %.2f cm3', 1e6.*fom_tmp.volume.V_winding);
            text{end+1} = sprintf('A_box = %.2f cm2', 1e4.*fom_tmp.area.A_box);
            text{end+1} = sprintf('V_box = %.2f cm3', 1e6.*fom_tmp.volume.V_box);
            text_data{end+1} = struct('title', 'area / volume', 'text', {text});
            
            % other figures of the merit
            text = {};
            text{end+1} = sprintf('m_core = %.2f g', 1e3.*fom_tmp.mass.m_core);
            text{end+1} = sprintf('c_core = %.2f $', fom_tmp.cost.c_core);
            text{end+1} = sprintf('m_winding = %.2f g', 1e3.*fom_tmp.mass.m_winding);
            text{end+1} = sprintf('c_winding = %.2f $', fom_tmp.cost.c_winding);
            text{end+1} = sprintf('m_iso = %.2f g', 1e3.*fom_tmp.mass.m_iso);
            text{end+1} = sprintf('c_iso = %.2f $', fom_tmp.cost.c_iso);
            text{end+1} = sprintf('m_tot = %.2f g', 1e3.*fom_tmp.mass.m_tot);
            text{end+1} = sprintf('c_tot = %.2f $', fom_tmp.cost.c_tot);
            text_data{end+1} = struct('title', 'mass / cost', 'text', {text});
            
            % magnetic data
            text = {};
            text{end+1} = sprintf('L = %.2f uH', 1e6.*fom_tmp.circuit.L);
            text{end+1} = sprintf('V_t_sat_sat = %.2f Vms', 1e3.*fom_tmp.circuit.V_t_sat_sat);
            text{end+1} = sprintf('I_sat = %.2f A', fom_tmp.circuit.I_sat);
            text{end+1} = sprintf('I_rms = %.2f A', fom_tmp.circuit.I_rms);
            text{end+1} = sprintf('J_norm = %.2f 1/mm2', 1e-6.*fom_tmp.circuit.J_norm);
            text{end+1} = sprintf('H_norm = %.2f 1/mm', 1e-3.*fom_tmp.circuit.H_norm);
            text{end+1} = sprintf('B_norm = %.2f mT/A', 1e3.*fom_tmp.circuit.B_norm);
            text_data{end+1} = struct('title', 'circuit', 'text', {text});
            
            % assign the block and the status
            data.is_valid = fom_tmp.is_valid;
            data.text_data = text_data;
        end
        
        function data = get_text_data_operating(self, operating_pts)
            % Get the figures of merit data.
            %
            %    Parameters:
            %        operating_pts (struct): operating point to be parsed
            %
            %    Returns:
            %        data (struct): data for displaying a text field
            
            % init the different blocks
            text_data = {};
            
            % validity information
            text = {};
            text{end+1} = sprintf('is_valid_iter = %d', operating_pts.is_valid_iter);
            text{end+1} = sprintf('is_valid_thermal = %d', operating_pts.is_valid_thermal);
            text{end+1} = sprintf('is_valid_core = %d', operating_pts.is_valid_core);
            text{end+1} = sprintf('is_valid_winding = %d', operating_pts.is_valid_winding);
            text_data{end+1} = struct('title', 'is_valid', 'text', {text});
            
            % applied excitation
            text = {};
            text{end+1} = sprintf('type_id = %s', get_map_int_to_str(operating_pts.waveform.type_id));
            text{end+1} = sprintf('f = %.2f kHz', 1e-3.*operating_pts.waveform.f);
            text{end+1} = sprintf('I_dc = %.2f A', operating_pts.waveform.I_dc);
            text{end+1} = sprintf('I_all_peak = %.2f A', operating_pts.waveform.I_all_peak);
            text{end+1} = sprintf('I_peak_peak = %.2f A', operating_pts.waveform.I_peak_peak);
            text{end+1} = sprintf('I_ac_rms = %.2f A', operating_pts.waveform.I_ac_rms);
            text{end+1} = sprintf('I_all_rms = %.2f A', operating_pts.waveform.I_all_rms);
            text{end+1} = sprintf('V_t_area = %.2f Vms', 1e3.*operating_pts.waveform.V_t_area);
            text{end+1} = sprintf('r_peak_peak = %.2f %%', 1e2.*operating_pts.waveform.r_peak_peak);
            text{end+1} = sprintf('fact_sat = %.2f %%', 1e2.*operating_pts.waveform.fact_sat);
            text{end+1} = sprintf('fact_rms = %.2f %%', 1e2.*operating_pts.waveform.fact_rms);
            text_data{end+1} = struct('title', 'waveform', 'text', {text});
            
            % physical fields
            text = {};
            text{end+1} = sprintf('J_dc = %.2f A/mm2', 1e-6.*operating_pts.field.J_dc);
            text{end+1} = sprintf('J_ac_rms = %.2f A/mm2', 1e-6.*operating_pts.field.J_ac_rms);
            text{end+1} = sprintf('H_dc = %.2f A/mm', 1e-3.*operating_pts.field.H_dc);
            text{end+1} = sprintf('H_ac_rms = %.2f A/mm', 1e-3.*operating_pts.field.H_ac_rms);
            text{end+1} = sprintf('B_dc = %.2f mT', 1e3.*operating_pts.field.B_dc);
            text{end+1} = sprintf('B_peak_peak = %.2f mT', 1e3.*operating_pts.field.B_peak_peak);
            text_data{end+1} = struct('title', 'field', 'text', {text});
            
            % temperatures
            text = {};
            text{end+1} = sprintf('h_convection = %.2f W/Km2', operating_pts.thermal.h_convection);
            text{end+1} = sprintf('T_ambient = %.2f C', operating_pts.thermal.T_ambient);
            text{end+1} = sprintf('T_core_max = %.2f C', operating_pts.thermal.T_core_max);
            text{end+1} = sprintf('T_core_avg = %.2f C', operating_pts.thermal.T_core_avg);
            text{end+1} = sprintf('T_winding_max = %.2f C', operating_pts.thermal.T_winding_max);
            text{end+1} = sprintf('T_winding_avg = %.2f C', operating_pts.thermal.T_winding_avg);
            text{end+1} = sprintf('T_iso_max = %.2f C', operating_pts.thermal.T_iso_max);
            text{end+1} = sprintf('T_max = %.2f C', operating_pts.thermal.T_max);
            text{end+1} = sprintf('stress_core = %.2f %%', 1e2.*operating_pts.thermal.stress_core);
            text{end+1} = sprintf('stress_winding = %.2f %%', 1e2.*operating_pts.thermal.stress_winding);
            text{end+1} = sprintf('stress_iso = %.2f %%', 1e2.*operating_pts.thermal.stress_iso);
            text_data{end+1} = struct('title', 'thermal', 'text', {text});
            
            % losses
            text = {};
            text{end+1} = sprintf('P_core = %.2f W', operating_pts.losses.P_core);
            text{end+1} = sprintf('P_winding = %.2f W', operating_pts.losses.P_winding);
            text{end+1} = sprintf('P_winding_dc = %.2f W', operating_pts.losses.P_winding_dc);
            text{end+1} = sprintf('P_winding_ac_lf = %.2f W', operating_pts.losses.P_winding_ac_lf);
            text{end+1} = sprintf('P_winding_ac_hf = %.2f W', operating_pts.losses.P_winding_ac_hf);
            text{end+1} = sprintf('P_add = %.2f W', operating_pts.losses.P_add);
            text{end+1} = sprintf('P_tot = %.2f W', operating_pts.losses.P_tot);
            text{end+1} = sprintf('core_losses = %.2f %%', 1e2.*operating_pts.losses.core_losses);
            text{end+1} = sprintf('winding_losses = %.2f %%', 1e2.*operating_pts.losses.winding_losses);
            text{end+1} = sprintf('add_losses = %.2f %%', 1e2.*operating_pts.losses.add_losses);
            text{end+1} = sprintf('winding_hf_res = %.2f x', operating_pts.losses.winding_hf_res);
            text_data{end+1} = struct('title', 'losses', 'text', {text});
            
            % assign the block and the status
            data.is_valid = operating_pts.is_valid;
            data.text_data = text_data;
        end
        
        function disp_block(self, gui_clipboard_obj, name, data)
            % Add a text field to the clipboard data.
            %
            %    Parameters:
            %        gui_clipboard_obj (GuiClipboard): clipboard object
            %        name (str): name of the text field
            %        data (struct): data for displaying a text field
            
            % extract test field
            is_valid = data.is_valid;
            text_data = data.text_data;
            
            % add to clipboard
            gui_clipboard_obj.add_title('%s / is_valid = %d', name, is_valid)
            gui_clipboard_obj.add_text_data(text_data);
        end
        
        function data = get_plot_data(self, fom_tmp)
            % Get the data to plot the inductor geometry.
            %
            %    Parameters:
            %        fom_tmp (struct): inductor figures of merit to be parsed
            %
            %    Returns:
            %        data (struct): data for plotting the geometry
            
            % front and top view plot data
            plot_data_front = self.get_plot_data_front(fom_tmp.geom);
            plot_data_top = self.get_plot_data_top(fom_tmp.geom);
            
            % assign the data and the status
            data.is_valid = fom_tmp.is_valid_geom;
            data.plot_data_front = plot_data_front;
            data.plot_data_top = plot_data_top;
        end
        
        function plot_data = get_plot_data_front(self, geom_tmp)
            % Get the data to plot the inductor geometry (front view).
            %
            %    Parameters:
            %        geom_tmp (struct): inductor geometrical data
            %
            %    Returns:
            %        plot_data (struct): data for plotting the geometry with a specific view
            
            % extract geometry
            x_window = geom_tmp.x_window;
            y_window = geom_tmp.y_window;
            t_core = geom_tmp.t_core;
            d_gap = geom_tmp.d_gap;
            d_iso = geom_tmp.d_iso;
            
            % computing position
            x_core = 2.*x_window+2.*t_core;
            y_core = y_window+t_core;
            x_winding = x_window-2.*d_iso;
            y_winding = y_window-2.*d_iso;
            x_window_offset = t_core./2+x_window./2;
            
            % description of the elements
            plot_data = {};
            plot_data{end+1} = struct('type', 'core', 'pos', [0 0], 'size', [x_core y_core], 'r', 0);
            plot_data{end+1} = struct('type', 'air', 'pos', [0 0], 'size', [x_core d_gap], 'r', 0);
            plot_data{end+1} = struct('type', 'insulation', 'pos', [+x_window_offset 0], 'size', [x_window y_window], 'r', 0);
            plot_data{end+1} = struct('type', 'insulation', 'pos', [-x_window_offset 0], 'size', [x_window y_window], 'r', 0);
            plot_data{end+1} = struct('type', 'winding', 'pos', [+x_window_offset 0], 'size', [x_winding y_winding], 'r', 0);
            plot_data{end+1} = struct('type', 'winding', 'pos', [-x_window_offset 0], 'size', [x_winding y_winding], 'r', 0);
        end
        
        function plot_data = get_plot_data_top(self, geom_tmp)
            % Get the data to plot the inductor geometry (top view).
            %
            %    Parameters:
            %        geom_tmp (struct): inductor geometrical data
            %
            %    Returns:
            %        plot_data (struct): data for plotting the geometry with a specific view
            
            % extract geometry
            x_window = geom_tmp.x_window;
            t_core = geom_tmp.t_core;
            z_core = geom_tmp.z_core;
            d_iso = geom_tmp.d_iso;
            r_curve = geom_tmp.r_curve;
            
            % core size
            x_core = 2.*x_window+2.*t_core;
            
            % winding head curvature radius
            r_curve_1 = r_curve;
            r_curve_2 = r_curve+d_iso;
            r_curve_3 = r_curve+x_window-d_iso;
            r_curve_4 = r_curve+x_window;
            
            % winding size (z direction)
            z_1 = z_core+2.*r_curve;
            z_2 = z_core+2.*r_curve+2.*d_iso;
            z_3 = z_core+2.*r_curve+2.*x_window-2.*d_iso;
            z_4 = z_core+2.*r_curve+2.*x_window;
            
            % winding size (x direction)
            x_1 = t_core;
            x_2 = t_core+2.*d_iso;
            x_3 = t_core+2.*x_window-2.*d_iso;
            x_4 = t_core+2.*x_window;
            
            % description of the elements
            plot_data = {};
            plot_data{end+1} = struct('type', 'insulation', 'pos', [0 0], 'size', [z_4 x_4], 'r', r_curve_4);
            plot_data{end+1} = struct('type', 'winding', 'pos', [0 0], 'size', [z_3 x_3], 'r', r_curve_3);
            plot_data{end+1} = struct('type', 'insulation', 'pos', [0 0], 'size', [z_2 x_2], 'r', r_curve_2);
            plot_data{end+1} = struct('type', 'air', 'pos', [0 0], 'size', [z_1 x_1], 'r', r_curve_1);
            plot_data{end+1} = struct('type', 'core', 'pos', [0 0], 'size', [z_core x_core], 'r', 0);
        end
    end
end
