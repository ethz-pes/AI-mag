classdef ParetoDisplay < handle
    % Class for managing the Pareto fronts for 'ParetoGUI'.
    %
    %    The class is not displaying anything, it is just managing data.
    %    Prepare the plots for the designs.
    %    Prepare the data (figures of merit) for the selected design.
    %    Manage the text data for the clipboard with 'GuiClipboard'.
    %
    %    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

    %% properties
    properties (SetAccess = private, GetAccess = public)
        n_sol % int: number of provided solutions
        n_plot % int: number of solution selected for plotting
        id_design % vector: unique id of the designs
        is_plot % vector: indices of the valid designs for plotting
        data_fom % struct: struct with user defined custom figures of merit
        plot_param % struct: definition of the different plots
        text_param % struct: definition of variable to be shown in the text field
    end
    
    %% public
    methods (Access = public)
        function self = ParetoDisplay(id_design, fom, operating, fct_data, plot_param, text_param)
            % Constructor.
            %
            %    Parameters:
            %        id_design (vector): unique id for each design
            %        fom (struct): computed inductor figures of merit (independent of any operating points)
            %        operating (struct): struct containing the excitation, losses, and temperatures for the operating points
            %        fct_data (fct): function for getting the designs be plotted and getting the user defined custom figures of merit
            %        plot_param (struct): definition of the different plots
            %        text_param (struct): definition of variable to be shown in the text field

            % get the designs be to plotted and the user defined custom figures of merit
            [is_plot, data_fom] = fct_data(length(id_design), fom, operating);
                        
            % assign the data
            self.n_sol = length(id_design);
            self.n_plot = nnz(is_plot);
            self.id_design = id_design;
            self.is_plot = is_plot;
            self.data_fom = data_fom;
            self.plot_param = plot_param;
            self.text_param = text_param;
        end
        
        function [plot_data, size_data, txt_size] = get_data_base(self)
            % Get the GUI data for the plots (not for a selected design).
            %
            %    Returns:
            %        plot_data (struct): data for plotting the Pareto fronts
            %        size_data (struct): size information about the number of design
            %        txt_size (str): size data as text for the clipboard
            
            % get the data for the clipboard
            gui_clipboard_obj = gui.GuiClipboard();
            gui_clipboard_obj.add_title('size')
            gui_clipboard_obj.add_text('n_sol = %d', self.n_sol)
            gui_clipboard_obj.add_text('n_plot = %d', self.n_plot)
            txt_size = gui_clipboard_obj.get_txt();
            
            % parse the data for all the specified plots
            field = fieldnames(self.plot_param);
            for i=1:length(field)
                plot_param_tmp = self.plot_param.(field{i});
                plot_data_tmp = self.get_plot_data(plot_param_tmp);
                plot_data.(field{i}) = plot_data_tmp;
            end
            
            % data with the number of designs
            size_data.n_sol = self.n_sol;
            size_data.n_plot = self.n_plot;
        end
        
        function [text_data_fom, txt_fom] = get_data_id(self, id_select)
            % Get the GUI data for a selected design.
            %
            %    Parameters:
            %        id_select (int): id of the design to be selected
            %
            %    Returns:
            %        text_data_fom (cell): data for the text field
            %        txt_fom (str): data as text for the clipboard
            
            % get the array index corresponding to the id
            idx = self.id_design==id_select;
            assert(nnz(idx)==1, 'invalid data')
            
            % format the text data
            for i=1:length(self.text_param)
                text_data_fom{i} = self.get_text(self.text_param{i}, idx);
            end
            
            % get the data for the clipboard
            gui_clipboard_obj = gui.GuiClipboard();
            gui_clipboard_obj.add_title('fom / id_design = %d', id_select)
            gui_clipboard_obj.add_text_data(text_data)
            txt_fom = gui_clipboard_obj.get_txt();
        end
    end
    
    %% private
    methods (Access = private)        
        function plot_data_tmp = get_plot_data(self, plot_param_tmp)
            % Get the GUI data for a specific plot.
            %
            %    Parameters:
            %        plot_param_tmp (struct): definition of a specific different plot
            %
            %    Returns:
            %        plot_data_tmp (struct): data for plotting a specific Pareto front

            % set the data (x, y, and color axis)
            [plot_data_tmp.x_label, plot_data_tmp.x_lim, plot_data_tmp.x_data] = self.get_axis(plot_param_tmp.x_var, plot_param_tmp.x_lim);
            [plot_data_tmp.y_label, plot_data_tmp.y_lim, plot_data_tmp.y_data] = self.get_axis(plot_param_tmp.y_var, plot_param_tmp.y_lim);
            [plot_data_tmp.c_label, plot_data_tmp.c_lim, plot_data_tmp.c_data] = self.get_axis(plot_param_tmp.c_var, plot_param_tmp.c_lim);
            
            % save the id of the plots
            plot_data_tmp.id_data = self.id_design(self.is_plot);
                        
            % axis type
            plot_data_tmp.x_scale = plot_param_tmp.x_scale;
            plot_data_tmp.y_scale = plot_param_tmp.y_scale;
            plot_data_tmp.c_scale = plot_param_tmp.c_scale;
            
            % scatter plot format
            plot_data_tmp.marker_pts_size = plot_param_tmp.marker_pts_size;
            plot_data_tmp.marker_select_size = plot_param_tmp.marker_select_size;
            plot_data_tmp.marker_select_color = plot_param_tmp.marker_select_color;
            plot_data_tmp.order = plot_param_tmp.order;
        end
        
        function [label, lim, data] = get_axis(self, var, lim)
            % Get the label and the associated data for an axis.
            %
            %    Parameters:
            %        var (str): name of the variable to be used for this axis
            %        lim (vector): axis limit (unscaled)
            %
            %    Returns:
            %        label (str): axis label
            %        lim (vector): axis limit (scaled)
            %        data (vector): vector with the data along this axis

            % extract the variable
            data_fom_tmp = self.data_fom.(var);
            
            % axis parameters
            data = data_fom_tmp.scale.*data_fom_tmp.value(self.is_plot);
            lim = data_fom_tmp.scale.*lim;
            label = sprintf('%s [%s]', data_fom_tmp.name, data_fom_tmp.unit);
        end
                
        function text_data_fom_tmp = get_text(self, text_param_tmp, idx)
            % Create a text block with a specified format for the selected design.
            %
            %    Parameters:
            %        text_param_tmp (struct): strcut with the variable to be displayed
            %        idx (int): index of the selected design
            %
            %    Returns:
            %        text_data_fom_tmp (struct): created text block
            
            % extract format
            title = text_param_tmp.title;
            var = text_param_tmp.var;
            
            % for each variable, select the name, data, and unit
            for i=1:length(var)
                data_fom_tmp = self.data_fom.(var{i});
                
                value = data_fom_tmp.scale.*data_fom_tmp.value(idx);
                text{i} = sprintf('%s = %.3f %s', data_fom_tmp.name, value, data_fom_tmp.unit);
            end
            
            % create the text block
            text_data_fom_tmp = struct('title', title, 'text', {text});
        end
    end
end