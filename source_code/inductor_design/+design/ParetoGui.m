classdef ParetoGui < handle
    %% init
    properties (SetAccess = private, GetAccess = private)
        id_fig
        pareto_display_obj
        inductor_gui_obj
        gui_base
        txt_base
    end
    
    %% init
    methods (Access = public)
        function self = ParetoGui(id_design, fom, operating, fct_data, plot_data)
            self.id_fig = randi(1e9);
            
            self.pareto_display_obj = design.ParetoDisplay(id_design, fom, operating, fct_data, plot_data);
            [self.gui_base, self.txt_base] = self.pareto_display_obj.get_base();
            
            self.inductor_gui_obj = design.InductorGui(id_design, fom, operating);
        end
        
        function fig = get_gui(self)
            name = sprintf('InductorPareto');
            fig = design.GuiUtils.get_gui(self.id_fig, [200 200 1390 600], name);
            
            panel_plot_header_1 = design.GuiUtils.get_panel(fig, [10 520 450 70], 'Plot A');
            panel_plot_data_1 = design.GuiUtils.get_panel(fig, [10 10 450 500], []);
            self.display_plot(panel_plot_header_1, panel_plot_data_1);
            
            panel_plot_header_2 = design.GuiUtils.get_panel(fig, [470 520 450 70], 'Plot B');
            panel_plot_data_2 = design.GuiUtils.get_panel(fig, [470 10 450 500], []);
            self.display_plot(panel_plot_header_2, panel_plot_data_2);
            
            panel_number = design.GuiUtils.get_panel(fig, [930 520 450 70], 'Pareto Data');
            self.display_number(panel_number);

            panel_data = design.GuiUtils.get_panel(fig, [930 150 450 360], []);
            self.display_logo(panel_data, 'logo_fem_ann.png');
            self.display_data(panel_data);

            panel_logo = design.GuiUtils.get_panel(fig, [930 10 450 60], []);
            self.display_logo(panel_logo, 'logo_pes_ethz.png');
            
            panel_button = design.GuiUtils.get_panel(fig, [930 80 450 60], []);
            self.display_button(panel_button, fig);
        end
    end
    
    methods (Access = private)
        function display_logo(self, panel, filename)
            path = fileparts(mfilename('fullpath'));
            filename = [path filesep() filename];
            design.GuiUtils.set_logo(panel, filename);
        end
        
        function display_button(self, panel, data, fig, txt)
            callback = @(src,event) self.callback_save_data(data);
            callback = [];
            design.GuiUtils.get_button(panel, [0.02 0.1 0.21 0.8], 'Save', callback)
            
%             callback = @(src,event) self.callback_save_image(fig);
            design.GuiUtils.get_button(panel, [0.27 0.1 0.21 0.8], 'Copy', callback)
            
%             callback = @(src,event) self.callback_copy_data(txt);
            design.GuiUtils.get_button(panel, [0.52 0.1 0.21 0.8], 'Clear', callback)
            
            design.GuiUtils.get_button(panel, [0.77 0.1 0.21 0.8], 'Details', callback)
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
        
        function display_number(self, panel)
                        
            handle = design.GuiUtils.get_text(panel, [0.03 0.10 0.94 0.65], 'n_sol = 1000 / n_plot = 12025 / id_design = None');

            
        end
        
        function display_data(self, panel)
            for i=1:9
               txt_data{i, 1} = 'dsfgdsg'; 
               txt_data{i, 2} = 'dsfgdsg'; 
               txt_data{i, 3} = 'dsfgdsg'; 
            end
            
            design.GuiText.set_table(panel, 10, [10 180 310], {'Name', 'Value', 'Units'}, txt_data);
        end
        
        function display_plot(self, panel_header, panel_data)
            callback = [];
            field = {'yolo', 'yolo'};
            
            menu = design.GuiUtils.get_menu(panel_header, [0.02 0.75 0.96 0.0], field, callback);
            
            ax = axes(panel_data);
            set(ax, 'Box', 'on');
            set(ax, 'FontSize', 10);
            axtoolbar(ax, {'pan', 'zoomin','zoomout','restoreview'}, 'Visible', 'on');
            
            cbar = colorbar(ax);
            set(cbar, 'Location', 'southoutside')
            set(cbar, 'Units', 'pixels')
            set(cbar, 'FontSize', 10)
            text = get(cbar, 'Label');
            set(text, 'interpreter', 'none')
            set(text, 'String', 'sdfsd')
            set(text, 'FontSize', 11)

            hold(ax, 'on')
            plot(ax, [1001 1002], [2001 3002])
            
            xlabel(ax, 'dfsdfs', 'FontSize', 11)
            ylabel(ax, 'dfsdfs', 'FontSize', 11)
        end
    end
end