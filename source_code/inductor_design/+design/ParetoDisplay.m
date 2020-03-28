classdef ParetoDisplay < handle
    %% init
    properties (SetAccess = private, GetAccess = private)
        n_sol
        n_plot
        id_design
        is_valid
        data_add
        plot_param
    end

    %% init
    methods (Access = public)
        function self = ParetoDisplay(id_design, fom, operating, fct_data, plot_param)
            self.id_design = id_design;
            
            [is_valid, data_add] = fct_data(fom, operating, length(id_design));
                                    
            self.n_sol = length(id_design);
            self.n_plot = nnz(is_valid);
            self.id_design = id_design;
            self.is_valid = is_valid;
            self.data_add = data_add;
            self.plot_param = plot_param;
        end
        
        function [plot_data, size_data, txt_size] = get_data_base(self)            
            gui_clipboard_obj = gui.GuiClipboard();
            gui_clipboard_obj.add_title('size')
            gui_clipboard_obj.add_text('n_sol = %d', self.n_sol)
            gui_clipboard_obj.add_text('n_plot = %d', self.n_plot)
            txt_size = gui_clipboard_obj.get_txt();
            
            field = fieldnames(self.plot_param);
            for i=1:length(field)
                plot_data_tmp = self.get_plot_data(self.plot_param.(field{i}));
                plot_data.(field{i}) = plot_data_tmp;
            end
            
            % size_gui
            size_data.n_sol = self.n_sol;
            size_data.n_plot = self.n_plot;
        end
        
        function [fom_data, txt_sub] = get_data_id(self, id_select)            
            idx = self.get_get_idx(id_select);
            gui_clipboard_obj = gui.GuiClipboard();
            gui_clipboard_obj.add_title('fom / id_design = %d', id_select)

            field = fieldnames(self.data_add);
            for i=1:length(field)
                [data, txt] = self.get_fom(field{i}, idx);
                
                fom_data(i, :) = data;
                gui_clipboard_obj.add_text(txt)
            end
            
            txt_sub = gui_clipboard_obj.get_txt();
        end
    end
    
    methods (Access = private)
        function plot_data = get_plot_data(self, plot_param)
            [plot_data.x_label, plot_data.x_data] = self.get_axis(plot_param.x_var);
            [plot_data.y_label, plot_data.y_data] = self.get_axis(plot_param.y_var);
            [plot_data.c_label, plot_data.c_data] = self.get_axis(plot_param.c_var);
            plot_data.id_data = self.id_design(self.is_valid);
                        
            plot_data.x_lim = plot_param.x_lim;
            plot_data.y_lim = plot_param.y_lim;
            plot_data.c_lim = plot_param.c_lim;
            
            plot_data.x_scale = plot_param.x_scale;
            plot_data.y_scale = plot_param.y_scale;
            plot_data.c_scale = plot_param.c_scale;
                        
            plot_data.marker_pts_size = plot_param.marker_pts_size;
            plot_data.marker_select_size = plot_param.marker_select_size;
            plot_data.marker_select_color = plot_param.marker_select_color;
            plot_data.order = plot_param.order;
        end
        
        function [label, data] = get_axis(self, var)
            data_add_tmp = self.data_add.(var);
            
            data = data_add_tmp.scale.*data_add_tmp.value(self.is_valid);
            label = sprintf('%s [%s]', data_add_tmp.name, data_add_tmp.unit);
        end
        
        function idx = get_get_idx(self, id_select)
            idx = self.id_design==id_select;
            assert(nnz(idx)==1, 'invalid data')
        end
        
        function [data, txt] = get_fom(self, var, idx)
            data_add_tmp = self.data_add.(var);
            
            value = data_add_tmp.scale.*data_add_tmp.value(idx);
            value = sprintf('%.3f', value);
            
            data = {data_add_tmp.name, value, data_add_tmp.unit};
            txt = sprintf('%s = %s %s', data_add_tmp.name, value, data_add_tmp.unit);
        end
    end
end