classdef InductorGui < handle
    % Class for displaying a single inductor design.
    %
    %    The class is just displaying, the data are mananaged by 'InductorDisplay'.
    %    Plot the geometry.
    %    Display the figures of merits.
    %    Display the different operating points.
    %    Clipboard and screenshot functions.
    %
    %    Warning: the GUI is using fixed pixel size due to the poor resize function of MATLAB.
    %
    %    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod
    
    %% properties / constant
    properties (SetAccess = private, GetAccess = public)
        id_fig % int: number of MATLAB figure
        inductor_display_obj % InductorDisplay: object managing the data
    end
    
    %% properties / dynamic
    properties (SetAccess = private, GetAccess = public)
        id_select % int: id of the selected inductor
        is_select % logical: if an inductor id is selected (or not)
        plot_data % struct: data for plotting the inductor geometry
        fom_data % struct: data for displaying the figures of merit field
        operating_data % struct: data for displaying the operating points field
        txt % str: data as text for the clipboard
    end
    
    %% public
    methods (Access = public)
        function self = InductorGui(id_design, fom, operating)
            % Constructor.
            %
            %   Select a random figure number.
            %   Start the data manager.
            %   Do not select a design.
            %   Do not open the GUI.
            %
            %    Parameters:
            %        id_design (vector): unique id for each design
            %        fom (struct): computed inductor figures of merit (independent of any operating points)
            %        operating (struct): struct containing the excitation, losses, and temperatures for the operating points
            
            self.id_fig = randi(1e9);
            self.inductor_display_obj = design_display.InductorDisplay(id_design, fom, operating);
            self.is_select = false;
        end
        
        function set_id_select(self, id_select)
            % Select a specific inductor with the id.
            %
            %   Get the data.
            %   If the GUI is open, update the data.
            %   If the is not open, do not open it.
            %
            %    Parameters:
            %        id_select (int): id of the design to be selected
            
            % get the data
            assert(length(id_select)==1, 'invalid data');
            [self.plot_data, self.fom_data, self.operating_data, self.txt] = self.inductor_display_obj.get_data_id(id_select);
            
            % set the id and switch the flag
            self.id_select = id_select;
            self.is_select = true;
            
            % update the GUI only if already opened
            is_found = gui.GuiUtils.find_gui(self.id_fig);
            if is_found==true
                self.update_gui();
            end
        end
        
        function close_gui(self)
            % Close the GUI.
            %
            %   Close if existing.
            %   Do bothing if not openend.
            
            gui.GuiUtils.close_gui(self.id_fig);
        end
        
        function open_gui(self)
            % Open the GUI with the selected data.
            %
            %   Check if data are existing.
            %   Open the GUI.
            
            assert(self.is_select==true, 'inductor id is not set')
            self.update_gui();
        end
    end
    
    methods (Access = private)
        function fig = update_gui(self)
            % Display the GUI window with the data.
            %
            %   Open the window or clear it.
            %   Set the data.
            
            % open the window
            name = sprintf('InductorDisplay / id_design = %d', self.id_select);
            fig = gui.GuiUtils.get_gui(self.id_fig, [200 200 1390 800], name);
            
            % geometry plot panel
            panel_plot = gui.GuiUtils.get_panel(fig, [10 10 450 780], 'Plot');
            self.display_plot(panel_plot);
            
            % panel for the figures of merit
            panel_inductor_header = gui.GuiUtils.get_panel(fig, [470 720 450 70], 'Inductor');
            panel_inductor_data = gui.GuiUtils.get_panel(fig, [470 80 450 630], []);
            self.display_inductor(panel_inductor_header, panel_inductor_data);
            
            % panel for the operating points
            panel_operating_header = gui.GuiUtils.get_panel(fig, [930 720 450 70], 'Operating');
            panel_operating_data = gui.GuiUtils.get_panel(fig, [930 80 450 630], []);
            self.display_operating(panel_operating_header, panel_operating_data);
            
            % panel for the buttons
            panel_button = gui.GuiUtils.get_panel(fig, [470 10 450 60], []);
            self.display_button(panel_button);
            
            % panel for the logo
            panel_logo = gui.GuiUtils.get_panel(fig, [930 10 450 60], []);
            self.display_logo(panel_logo);
        end
        
        function display_plot(self, panel)
            % Display the inductor geometry in a plot.
            %
            %    Parameters:
            %        panel (obj): parent object to create the feature
            
            % create the axis
            gui_geom_front_obj = gui.GuiGeom(panel, [0.0 0.02 1.0 0.48]);
            gui_geom_top_obj = gui.GuiGeom(panel, [0.0 0.52 1.0 0.48]);
            
            % only plot valid geometry
            if self.plot_data.is_valid==true
                % plot the geometry
                gui_geom_front_obj.set_plot_geom_data(self.plot_data.plot_data_front, 0.1);
                gui_geom_top_obj.set_plot_geom_data(self.plot_data.plot_data_top, 0.1);
            else
                % cross the axis
                gui_geom_front_obj.set_plot_geom_cross()
                gui_geom_top_obj.set_plot_geom_cross()
            end
        end
        
        function display_inductor(self, panel_header, panel_data)
            % Display the panels with the inductor figures of merits.
            %
            %    Parameters:
            %        panel_header (obj): parent object to create the feature (status field)
            %        panel_data (obj): parent object to create the feature (text field)
            
            % status field, showing the validity
            status = gui.GuiUtils.get_status(panel_header, [0.02 0.13 0.96 0.62]);
            gui.GuiUtils.set_status(status, self.fom_data.is_valid);
            
            % text field, showing the figures of merits
            gui_text_obj = gui.GuiText(panel_data, 10, [10, 25, 230]);
            gui_text_obj.set_text(self.fom_data.text_data);
        end
        
        function display_operating(self, panel_header, panel_data)
            % Display the panels with the inductor operating points.
            %
            %    Parameters:
            %        panel_header (obj): parent object to create the feature (status/menu field)
            %        panel_data (obj): parent object to create the feature (text field)
            
            % display the text fields on top of each other for the different operating points
            field = fieldnames(self.operating_data);
            for i=1:length(field)
                % get data
                is_valid_tmp = self.operating_data.(field{i}).is_valid;
                text_data_tmp = self.operating_data.(field{i}).text_data;
                
                % create panel
                gui_text_obj_tmp = gui.GuiText(panel_data, 10, [10, 25, 230]);
                gui_text_obj_tmp.set_text(text_data_tmp);
                
                % put the handle and the validity in a vector for the menu
                obj_vec(i) = gui_text_obj_tmp;
                is_valid_vec(i) = is_valid_tmp;
            end
            
            % select the panel to be shown and the status with a menu
            callback = @(menu_obj, event) self.callback_menu(menu_obj, is_valid_vec, obj_vec);
            menu_obj = gui.GuiUtils.get_menu(panel_header, [0.02 0.75 0.96 0.0], field, callback);
            self.callback_menu(menu_obj, is_valid_vec, obj_vec);
        end
        
        function callback_menu(self, menu_obj, is_valid_vec, obj_vec)
            % Operating points menu callback.
            %
            %    Parameters:
            %        menu_obj (obj): handle to the menu itself
            %        is_valid_vec (vector): vector with the validity of the different operating points
            %        obj_vec (obj): vector with the text field objects to be shown/hidden
            
            % get the menu choice
            idx = gui.GuiUtils.get_menu_idx(menu_obj);
            
            % set the selected panel visible, hide the others
            for i=1:length(obj_vec)
                if i==idx
                    obj_vec(i).set_visible(true);
                else
                    obj_vec(i).set_visible(false);
                end
            end
            
            % change the status of the menu to show the validity
            is_valid_tmp = is_valid_vec(idx);
            gui.GuiUtils.set_menu(menu_obj, is_valid_tmp);
        end
        
        function display_button(self, panel)
            % Display the copy and save buttons.
            %
            %    Parameters:
            %        parent (obj): parent object to create the feature
            
            % save a screenshot
            callback = @(src,event) self.callback_save();
            gui.GuiUtils.get_button(panel, [0.02 0.1 0.46 0.8], 'Save', callback);
            
            % copy the data to the clipboard
            callback = @(src,event) self.callback_copy();
            gui.GuiUtils.get_button(panel, [0.52 0.1 0.46 0.8], 'Copy', callback);
        end
        
        function callback_save(self)
            % Save screenshot button callback.
            %
            %    Ask for a file name.
            %    If valid, write the screenshot.
            
            [file, path, indx] = uiputfile('*.png');
            if indx~=0
                fig = figure(self.id_fig);
                img = getframe(fig);
                imwrite(img.cdata, [path file])
            end
        end
        
        function callback_copy(self)
            % Copy data to the clipboard button callback.
            %
            %    Put the text data.
            %    Put them into the operating system clipboard.
            
            clipboard('copy', self.txt)
        end
        
        function display_logo(self, panel)
            % Display the logo at the bottom.
            %
            %    Parameters:
            %        parent (obj): parent object to create the feature
            
            % logo file
            %    - the logo is done with Illustrator
            %    - the Mathematica source file is 'resources/logo_pes_ethz.ai'
            filename = 'logo_pes_ethz.png';
            
            % set the logo
            path = fileparts(mfilename('fullpath'));
            filename = [path filesep() filename];
            gui.GuiUtils.set_logo(panel, filename);
        end
    end
end