classdef InductorGui < handle
    %% init
    properties (SetAccess = private, GetAccess = private)
        id_fig
        inductor_display_obj
    end
    
    %% init
    methods (Access = public)
        function self = InductorGui(id_design, fom, operating)
            self.id_fig = randi(1e9);
            self.inductor_display_obj = design.InductorDisplay(id_design, fom, operating);
        end
        
        function fig = get_gui(self, idx)
            [gui, txt] = self.inductor_display_obj.get_idx(idx);

            name = sprintf('InductorDisplay : id_design = %d', gui.id_design);
            fig = design.GuiUtils.get_gui(self.id_fig, [200 200 1390 700], name);

            panel_plot = design.GuiUtils.get_panel(fig, [10 10 450 680], 'Plot');
            self.display_plot(panel_plot, gui.plot_gui);
            
            panel_inductor_header = design.GuiUtils.get_panel(fig, [470 620 450 70], 'Inductor');
            panel_inductor_data = design.GuiUtils.get_panel(fig, [470 80 450 530], []);
            self.display_inductor(panel_inductor_header, panel_inductor_data, gui.fom_gui);

            panel_operating_header = design.GuiUtils.get_panel(fig, [930 620 450 70], 'Operating');
            panel_operating_data = design.GuiUtils.get_panel(fig, [930 80 450 530], []);
            self.display_operating(panel_operating_header, panel_operating_data, gui.operating_gui);
            
            panel_logo = design.GuiUtils.get_panel(fig, [930 10 450 60], []);
            self.display_logo(panel_logo, 'logo_pes_ethz.png');
            
            panel_button = design.GuiUtils.get_panel(fig, [470 10 450 60], []);
            self.display_button(panel_button, fig, txt);
        end
    end
    
    methods (Access = private)
        function display_logo(self, panel_logo, filename)
            path = fileparts(mfilename('fullpath'));
            filename = [path filesep() filename];
            design.GuiUtils.set_logo(panel_logo, filename);
        end
        
        function display_button(self, panel_button, fig, txt)            
            callback = @(src,event) self.callback_save_image(fig);
            design.GuiUtils.get_button(panel_button, [0.02 0.1 0.46 0.8], 'Save', callback)
            
            callback = @(src,event) self.callback_copy_data(txt);
            design.GuiUtils.get_button(panel_button, [0.52 0.1 0.46 0.8], 'Copy', callback)
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
        
        function callback_menu(self, is_valid_vec, panel_vec, src)      
            idx = src.Value;
            design.GuiUtils.set_visible(panel_vec, 'off');
            design.GuiUtils.set_visible(panel_vec(idx), 'on');
            
            is_valid_tmp = is_valid_vec(idx);
            design.GuiUtils.set_menu(src, is_valid_tmp);
        end

        function display_operating(self, panel_header, panel_data, operating_gui)
            field = fieldnames(operating_gui);
            for i=1:length(field)
                is_valid_tmp = operating_gui.(field{i}).is_valid;
                text_data_tmp = operating_gui.(field{i}).text_data;

                panel_tmp = design.GuiText.get_text_field(panel_data, 10, 10, [25 240], text_data_tmp);

                panel_vec(i) = panel_tmp;
                is_valid_vec(i) = is_valid_tmp;
            end
                   
            callback = @(src, event) self.callback_menu(is_valid_vec, panel_vec, src);
            menu = design.GuiUtils.get_menu(panel_header, [0.02 0.75 0.96 0.0], field, callback);
            callback(menu, []);
        end
        
        function display_inductor(self, panel_header, panel_data, fom_gui)
            
            status = design.GuiUtils.get_status(panel_header, [0.02 0.13 0.96 0.62]);
            design.GuiUtils.set_status(status, fom_gui.is_valid);

            design.GuiText.get_text_field(panel_data, 10, 10, [25 240], fom_gui.text_data);
        end
        
        function display_plot(self, panel, plot_gui)
            ax_front = design.GuiGeom.get_plot_geom(panel, [70 60 350 250]);
            ax_top = design.GuiGeom.get_plot_geom(panel, [70 380 350 250]);

            if plot_gui.is_valid==true
                design.GuiGeom.set_plot_geom_data(ax_front, plot_gui.plot_data_front, 0.1);
                design.GuiGeom.set_plot_geom_data(ax_top, plot_gui.plot_data_top, 0.1);
            else
                design.GuiGeom.set_plot_geom_cross(ax_front)
                design.GuiGeom.set_plot_geom_cross(ax_top)
            end
        end
    end
end