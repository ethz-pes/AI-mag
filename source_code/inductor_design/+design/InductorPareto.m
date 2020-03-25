classdef InductorPareto < handle
    %% init
    properties (SetAccess = private, GetAccess = private)
        id_fig
        id_design
        n_sol
        n_plot
        data_add
        plot_data
        inductor_gui_obj
    end
    
    %% init
    methods (Access = public)
        function self = InductorPareto(id_design, fom, operating, fct_data, plot_data)
            [is_valid, data_add] = fct_data(fom, operating, length(id_design));

            self.id_fig = randi(1e9);
            self.n_sol = length(id_design);
            self.n_plot = nnz(is_valid);
            
            id_design = id_design(is_valid);
            fom = get_struct_filter(fom, is_valid);
            operating = get_struct_filter(operating, is_valid);
            
            self.inductor_gui_obj = design.InductorGui(id_design, fom, operating);
            self.id_design = id_design;
            
            field = fieldnames(data_add);
            for i=1:length(field)
                data_add.(field{i}).value = data_add.(field{i}).value(is_valid);
            end
            
            self.data_add = data_add;
            self.plot_data = plot_data;
        end
      

        function fig = get_gui(self)
            name = sprintf('InductorPareto');
            fig = design.GuiUtils.get_gui(self.id_fig, [200 200 1390 600], name);
           
            panel_plot_1 = design.GuiUtils.get_panel(fig, [10 10 450 580], 'Plot 1');
            self.display_plot(panel_plot_1);
            
            panel_plot_2 = design.GuiUtils.get_panel(fig, [470 10 450 580], 'Plot 2');
            self.display_plot(panel_plot_2);
            
            panel_number = design.GuiUtils.get_panel(fig, [930 490 450 100], 'Pareto Data');

            panel_data = design.GuiUtils.get_panel(fig, [930 150 450 330], 'Design Data');
%             self.display_operating(panel_operating, gui.operating_gui);
                        self.display_logo(panel_data, 'logo_fem_ann.png');

            panel_logo = design.GuiUtils.get_panel(fig, [930 10 450 60], []);
            self.display_logo(panel_logo, 'logo_pes_ethz.png');
            
            panel_button = design.GuiUtils.get_panel(fig, [930 80 450 60], []);
            self.display_button(panel_button, fig);
        end
    end
    
    methods (Access = private)
        function display_logo(self, panel_logo, filename)
            path = fileparts(mfilename('fullpath'));
            filename = [path filesep() filename];
            design.GuiUtils.set_logo(panel_logo, filename);
        end
        
        function display_button(self, panel_button, data, fig, txt)
            callback = @(src,event) self.callback_save_data(data);
            callback = [];
            design.GuiUtils.get_button(panel_button, [0.02 0.1 0.21 0.8], 'Save', callback)
            
%             callback = @(src,event) self.callback_save_image(fig);
            design.GuiUtils.get_button(panel_button, [0.27 0.1 0.21 0.8], 'Copy', callback)
            
%             callback = @(src,event) self.callback_copy_data(txt);
            design.GuiUtils.get_button(panel_button, [0.52 0.1 0.21 0.8], 'Clear', callback)
            
            design.GuiUtils.get_button(panel_button, [0.77 0.1 0.21 0.8], 'Details', callback)
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
            design.GuiUtils.set_panel_hidden(panel_vec, 'off');
            design.GuiUtils.set_panel_hidden(panel_vec(idx), 'on');

            is_valid_tmp = is_valid_vec(idx);
            design.GuiUtils.set_status(status, is_valid_tmp);
        end

        function display_operating(self, panel_operating, operating_gui)
            field = fieldnames(operating_gui);
            for i=1:length(field)
                is_valid_tmp = operating_gui.(field{i}).is_valid;
                text_data_tmp = operating_gui.(field{i}).text_data;

                panel_tmp = design.GuiUtils.get_panel_hidden(panel_operating, [0 0 450 540]);
                design.GuiUtils.set_text(panel_tmp, 540, 10, [25 240], text_data_tmp);

                panel_vec(i) = panel_tmp;
                is_valid_vec(i) = is_valid_tmp;
            end
            
            status = design.GuiUtils.get_status(panel_operating, [340 550 100 27]);
            callback = @(src, event) self.callback_menu(status, is_valid_vec, panel_vec, src.Value);
            menu = design.GuiUtils.get_list(panel_operating, [10 550 320 27], field, callback);
            callback(menu, []);
        end
        
        function display_inductor(self, panel_inductor, fom_gui)
            status = design.GuiUtils.get_status(panel_inductor, [10 550 430 27]);
            design.GuiUtils.set_status(status, fom_gui.is_valid);
            design.GuiUtils.set_text(panel_inductor, 540, 10, [25 240], fom_gui.text_data);
        end
        
        function display_plot(self, panel_plot)
            callback = [];
            field = {'yolo', 'yolo'};
            
            menu = design.GuiUtils.get_list(panel_plot, [70 520 350 27], field, callback);
            
            ax = axes(panel_plot);
            set(ax, 'Box', 'on');
            set(ax, 'FontSize', 10);

            set(ax, 'Units', 'pixels')
%             set(ax, 'Position', [70 150 350 340])
            set(ax, 'OuterPosition', [70 150 350 340])
             
            cbar = colorbar(ax);
            set(cbar, 'Location', 'southoutside')
                        set(cbar, 'Units', 'pixels')
            set(cbar, 'Position', [70 60 350 20])
            set(cbar, 'FontSize', 10)
            text = get(cbar, 'Label');
            set(text, 'interpreter', 'none')
            set(text, 'String', 'sdfsd')
            set(text, 'FontSize', 11)

            hold(ax, 'on')
            plot(ax, [1001 1002], [1001 1002])
            
            xlabel(ax, 'dfsdfs', 'FontSize', 11)
            ylabel(ax, 'dfsdfs', 'FontSize', 11)
        end
    end
end