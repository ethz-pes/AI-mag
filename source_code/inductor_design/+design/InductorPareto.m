classdef InductorPareto < handle
    %% init
    properties (SetAccess = private, GetAccess = private)
        n_sol
        n_plot
        data_add
        plot_id
        inductor_gui_obj
    end
    
    %% init
    methods (Access = public)
        function self = InductorPareto(n_sol, fom, operating, plot_id, fct_data)
            [is_valid, data_add] = fct_data(fom, operating, n_sol);

            self.n_sol = n_sol;
            self.n_plot = nnz(is_valid);
            self.plot_id = plot_id;
            
            fom = get_struct_filter(fom, is_valid);
            operating = get_struct_filter(operating, is_valid);
            self.inductor_gui_obj = design.InductorGui(fom, operating);

            field = fieldnames(data_add);
            for i=1:length(field)
                data_add.(field{i}).value = data_add.(field{i}).value(is_valid);
            end
            
            self.data_add = data_add;
        end
        
        function n_sol = get_n_sol(self)
            n_sol = self.n_sol;
        end
        
        function n_plot = get_n_plot(self)
            n_plot = self.n_plot;
        end
        
        function get_plot(self, plot_data)            
            fig = figure(self.plot_id.pareto);
            name = plot_data.name;
            subplot_data = plot_data.subplot_data;
            
            clf(fig)
            addToolbarExplorationButtons(fig)
            set(fig, 'Name', sprintf('InductorPareto : %s', name))
            set(fig, 'NumberTitle', 'off')
            
            for i=1:length(subplot_data)
                ax = subplot(length(subplot_data), 1, i, 'box', 'on');
                self.get_subplot(ax, subplot_data{i});
                
            end
            

        end
    end
    
    methods (Access = private)
        function get_subplot(self, ax, subplot_data)            

            title(ax, subplot_data.title, 'interpreter', 'none')
            
            color_label = self.get_label(subplot_data.color_var);
            cbar = colorbar(ax);
            text = get(cbar, 'Label');
            set(text, 'interpreter', 'none')
            set(text, 'String', color_label)
            
            x_label = self.get_label(subplot_data.x_var);
            y_label = self.get_label(subplot_data.y_var);
            xlabel(ax, x_label, 'interpreter', 'none');
            ylabel(ax, y_label, 'interpreter', 'none');
            
            set(ax, 'XScale', subplot_data.x_axis);
            set(ax, 'YScale', subplot_data.y_axis);
            set(gca,'ColorScale', subplot_data.color_axis)
            
            if length(subplot_data.x_lim)==2
                set(ax, 'XLim', subplot_data.x_lim);
            end
            if length(subplot_data.y_lim)==2
                set(ax, 'YLim', subplot_data.y_lim);
            end
            if length(subplot_data.color_lim)==2
                set(ax, 'CLim', subplot_data.color_lim);
            end
            
            x = self.get_value(subplot_data.x_var);
            y = self.get_value(subplot_data.y_var);
            color = self.get_value(subplot_data.color_var);

            keyboard
            
            scatter(x, y, [], color, 'filled')
            
            grid(ax, 'on')
        
        end
        
        function label = get_label(self, var)
            data_add_tmp = self.data_add.(var);
            label = sprintf('%s [%s]', data_add_tmp.name, data_add_tmp.unit);
        end
        
        function value = get_value(self, var)
            data_add_tmp = self.data_add.(var);
            value = data_add_tmp.scale.*data_add_tmp.value;
        end
    end    
end