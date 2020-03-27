classdef ParetoGui < handle
    %% init
    properties (SetAccess = private, GetAccess = private)
        id_fig
        pareto_display_obj
        inductor_gui_obj
        plot_data
        size_data
        txt_base
    end
    properties (SetAccess = private, GetAccess = private)
        text_obj
        gui_table_obj
        gui_scatter_obj_vec
        id_select
    end
    
    %% init
    methods (Access = public)
        function self = ParetoGui(id_design, fom, operating, fct_data, plot_param)
            self.id_fig = randi(1e9);
            
            self.pareto_display_obj = design.ParetoDisplay(id_design, fom, operating, fct_data, plot_param);
            [self.plot_data, self.size_data, self.txt_base] = self.pareto_display_obj.get_base();
            
            self.gui_scatter_obj_vec = [];
            self.id_select = [];
            self.panel = [];
            self.text = [];
            
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
            
            panel_size = design.GuiUtils.get_panel(fig, [930 520 450 70], 'Pareto Data');

            panel_data = design.GuiUtils.get_panel(fig, [930 150 450 360], []);
            self.display_logo(panel_data, 'logo_fem_ann.png');

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
        
        function callback_save_image(self)
           [file, path, indx] = uiputfile('*.png');
           if indx~=0
               fig = figure(self.id_fig);
               img = getframe(fig);
               imwrite(img.cdata, [path file])
           end
        end

        function callback_copy_data(self, txt)
            clipboard('copy', txt)
        end
        
        function callback_menu(self, panel_vec, src)
            idx = src.Value;
            design.GuiUtils.set_visible(panel_vec, 'off');
            design.GuiUtils.set_visible(panel_vec(idx), 'on');
        end
        
        function callback_select(self, idx)
            
            
        end
        
        function callback_display()
            %             self.text = design.GuiUtils.get_text(panel, [0.03 0.10 0.94 0.65], 'n_sol = 1000 / n_plot = 12025 / id_design = None');

                        for i=1:9
               txt_data{i, 1} = 'dsfgdsg'; 
               txt_data{i, 2} = 'dsfgdsg'; 
               txt_data{i, 3} = 'dsfgdsg'; 
            end
            
            design.GuiText.set_table(panel, 10, [10 180 310], {'Name', 'Value', 'Units'}, txt_data);

        end
                                
        function display_plot(self, panel_header, panel_data)
            
            callback = @(src, event) self.callback_select(idx);
            field = fieldnames(self.plot_data);
            for i=1:length(field)
                plot_data_tmp = self.plot_data.(field{i});

                gui_scatter_obj_tmp = design.GuiScatter(panel_data, [0 0 1 1]);
                gui_scatter_obj_tmp.set_data(plot_data_tmp, callback);
                panel_tmp = gui_scatter_obj_tmp.get_panel();

                panel_vec(i) = panel_tmp;
                obj_vec(i) = gui_scatter_obj_tmp;
            end
                               
            callback = @(src, event) self.callback_menu(panel_vec, src);
            menu = design.GuiUtils.get_menu(panel_header, [0.02 0.75 0.96 0.0], field, callback);
            callback(menu, []);
            
            self.gui_scatter_obj_vec = [self.gui_scatter_obj_vec, obj_vec];
        end
    end
end