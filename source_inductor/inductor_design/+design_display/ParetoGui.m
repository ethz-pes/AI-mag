classdef ParetoGui < handle
    % Class for displaying inductor Pareto fronts.
    %
    %    The class is just displaying, the data are mananaged by 'ParetoDisplay'.
    %    Start a GUI with several Pareto fronts.
    %    Plots can be customized.
    %    Design can be selected with the mouse.
    %    Allow a multi-objective data exploration.
    %    Clipboard and screenshot functions.
    %    More details about a selected design with 'InductorGui'.
    %
    %    Warning: the GUI is using fixed pixel size due to the poor resize function of MATLAB.
    %
    %    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod
    
    %% properties / constant
    properties (SetAccess = private, GetAccess = public)
        id_fig % int: number of MATLAB figure
        pareto_display_obj % ParetoDisplay: object managing the data
        inductor_gui_obj % InductorGui: GUI for showing the details of a selected design
        plot_data % struct: data for plotting the Pareto fronts
        size_data % struct: size information about the number of design
        txt_size % str: size data as text for the clipboard
    end
    
    %% properties / dynamic
    properties (SetAccess = private, GetAccess = public)
        id_select % int: id of the selected inductor
        is_select % logical: if an inductor id is selected (or not)
        txt_fom % str: selected design fom data as text for the clipboard
        text_obj % obj: text object for displaying size information
        clear_obj % obj: clear the selected design button
        details_obj % obj: details on the selected design button
        gui_text_obj % obj: text panel for displaying the fom data  of the selected design
        gui_scatter_obj_vec %obj: vector wuith the different scatter plot objects
    end
    
    %% public
    methods (Access = public)
        function self = ParetoGui(id_design, fom, operating, fct_data, plot_param, text_param)
            % Constructor.
            %
            %   Set the data.
            %   Start the GUI.
            %
            %    Parameters:
            %        id_design (vector): unique id for each design
            %        fom (struct): computed inductor figures of merit (independent of any operating points)
            %        operating (struct): struct containing the excitation, losses, and temperatures for the operating points
            %        fct_data (fct): function for getting the designs be plotted and getting the user defined custom figures of merit
            %        plot_param (struct): definition of the different plots
            %        text_param (struct): definition of variable to be shown in the text field
            
            % create data manager
            self.pareto_display_obj = design_display.ParetoDisplay(id_design, fom, operating, fct_data, plot_param, text_param);
            
            % GUI for displaying the details of an inductor design ('InductorGUI')
            self.inductor_gui_obj = design_display.InductorGui(id_design, fom, operating);
            
            % set the data
            self.id_fig = randi(1e9);
            self.is_select = false;
            [self.plot_data, self.size_data, self.txt_size] = self.pareto_display_obj.get_data_base();
            
            % start the GUI
            self.init_gui();
        end
        
        function delete(self)
            % Close and delete the GUI.
            %
            %    If open, close the GUI window with the selected inductor details ('InductorGUI').
            %    This method override a standard MATLAB method.
            
            self.inductor_gui_obj.close_gui();
        end
    end
    methods (Access = private)
        function init_gui(self)
            % Display the GUI window with the data.
            %
            %   Open the window.
            %   Set the data.
            
            % open the window
            name = sprintf('InductorPareto');
            fig = gui.GuiUtils.get_gui(self.id_fig, [200 200 1390 600], name);
            
            % no scatter plot until now
            self.gui_scatter_obj_vec = [];
            
            % first Pareto plot panel
            panel_plot_header_1 = gui.GuiUtils.get_panel(fig, [10 520 450 70], 'Plot A');
            panel_plot_data_1 = gui.GuiUtils.get_panel(fig, [10 10 450 500], []);
            self.display_plot(panel_plot_header_1, panel_plot_data_1);
            
            % second Pareto plot panel
            panel_plot_header_2 = gui.GuiUtils.get_panel(fig, [470 520 450 70], 'Plot B');
            panel_plot_data_2 = gui.GuiUtils.get_panel(fig, [470 10 450 500], []);
            self.display_plot(panel_plot_header_2, panel_plot_data_2);
            
            % size information panel
            panel_size = gui.GuiUtils.get_panel(fig, [930 520 450 70], 'Pareto Data');
            self.display_size(panel_size);
            
            % panel for figures of merit data of the selected design
            panel_data = gui.GuiUtils.get_panel(fig, [930 150 450 360], []);
            self.display_data(panel_data);
            
            % panel for the buttons
            panel_button = gui.GuiUtils.get_panel(fig, [930 80 450 60], []);
            self.display_button(panel_button);
            
            % panel for the logo
            panel_logo = gui.GuiUtils.get_panel(fig, [930 10 450 60], []);
            self.display_logo(panel_logo);
            
            % force display callback (no event at the start)
            self.callback_display();
        end
        
        function display_plot(self, panel_header, panel_data)
            % Display the a Pareto front plot.
            %
            %    Parameters:
            %        panel_header (obj): parent object to create the feature (status field)
            %        panel_data (obj): parent object to create the feature (text field)
            
            % callback for selected a point with the mouse
            callback = @(id_select) self.callback_select(id_select);
            
            % display the plots on top of each other
            field = fieldnames(self.plot_data);
            for i=1:length(field)
                % get data
                plot_data_tmp = self.plot_data.(field{i});
                
                % create panel
                gui_scatter_obj_tmp = gui.GuiScatter(panel_data, [0 0 1 1]);
                gui_scatter_obj_tmp.set_data(plot_data_tmp, callback);
                
                % put the handle in a vector for the menu and the callback
                obj_vec(i) = gui_scatter_obj_tmp;
            end
            
            % select the plot to be shown with a menu
            callback = @(menu_obj, event) self.callback_menu(menu_obj, obj_vec);
            menu_obj = gui.GuiUtils.get_menu(panel_header, [0.02 0.75 0.96 0.0], field, callback);
            self.callback_menu(menu_obj, obj_vec);
            
            % add the all scatter plot handles in an vector for click callback
            self.gui_scatter_obj_vec = [self.gui_scatter_obj_vec, obj_vec];
        end
        
        function callback_select(self, id_select)
            % Mouser click on point callback.
            %
            %    Parameters:
            %        id_select (int): id of the design to be selected
            
            % set the data of the selected points
            self.is_select = true;
            self.id_select = id_select;
            
            % force display callback
            self.callback_display();
        end
        
        function callback_menu(self, menu_obj, obj_vec)
            % Plot menu menu callback.
            %
            %    Parameters:
            %        menu_obj (obj): handle to the menu itself
            %        obj_vec (obj): vector with the scatter plot objects to be shown/hidden
            
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
        end
        
        function display_size(self, panel)
            % Text field for showing the size information.
            %
            %    Create the object.
            %    Do not display content, the display callback will do it.
            %
            %    Parameters:
            %        panel (obj): parent object to create the feature
            
            self.text_obj = gui.GuiUtils.get_text(panel, [0.03 0.10 0.94 0.65]);
        end
        
        function display_data(self, panel)
            % Panel for the figures of merit data of the selected design.
            %
            %    Put an image on the background.
            %    Put a text field in front of the logo.
            %    Do not display content, the display callback will do it.
            %
            %    The image is show to the user when the text field is invisible.
            %
            %    Parameters:
            %        panel (obj): parent object to create the feature
            
            % logo file
            %    - the logo is done with Illustrator
            %    - the Illustrator source file is 'resources/artwork/logo_fem_ann.ai'
            filename = 'logo_fem_ann.png';
            
            % set the logo
            path = fileparts(mfilename('fullpath'));
            filename = [path filesep() filename];
            gui.GuiUtils.set_logo(panel, filename);
            
            % text field
            self.gui_text_obj = gui.GuiText(panel, 10, [10, 25, 240]);
        end
        
        function display_button(self, panel)
            % Display the copy, save, clear, and details buttons.
            %
            %    Parameters:
            %        parent (obj): parent object to create the feature
            
            % save a screenshot
            callback = @(src,event) self.callback_save();
            gui.GuiUtils.get_button(panel, [0.02 0.1 0.21 0.8], 'Save', callback);
            
            % copy the data to the clipboard
            callback = @(src,event) self.callback_copy();
            gui.GuiUtils.get_button(panel, [0.27 0.1 0.21 0.8], 'Copy', callback);
            
            % clear the selected design
            callback = @(src,event) self.callback_clear();
            self.clear_obj = gui.GuiUtils.get_button(panel, [0.52 0.1 0.21 0.8], 'Clear', callback);
            
            % show details about the selected design
            callback = @(src,event) self.callback_details();
            self.details_obj = gui.GuiUtils.get_button(panel, [0.77 0.1 0.21 0.8], 'Details', callback);
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
            %    Put the text data (with/without selected design).
            %    Put them into the operating system clipboard.
            
            if self.is_select==true
                txt = [self.txt_size newline() newline() self.txt_fom];
            else
                txt = self.txt_size;
            end
            clipboard('copy', txt)
        end
        
        function callback_clear(self)
            % Clear the selected design.
            %
            %    A design should be selected.
            %    Remove the selection.
            %    Force display callback.
            
            assert(self.is_select==true, 'invalid button')
            self.is_select = false;
            self.callback_display();
        end
        
        function callback_details(self)
            % Show details about the selected design.
            %
            %    A design should be selected.
            %    Open the GUI showing the details ('InductorGUI').
            
            assert(self.is_select==true, 'invalid button')
            self.inductor_gui_obj.open_gui();
        end
        
        function display_logo(self, panel)
            % Display the logo at the bottom.
            %
            %    Parameters:
            %        parent (obj): parent object to create the feature
            
            % logo file
            %    - the logo is done with Illustrator
            %    - the Illustrator source file is 'resources/artwork/logo_pes_ethz.ai'
            filename = 'logo_pes_ethz.png';
            
            % set the logo
            path = fileparts(mfilename('fullpath'));
            filename = [path filesep() filename];
            gui.GuiUtils.set_logo(panel, filename);
        end
        
        function callback_display(self)
            % Display callback for handling the selected design (of the lack of).
            %
            %    The callback is called:
            %        - when the GUI is opening
            %        - when a design is selected
            %        - when a design is unselected
            
            if self.is_select==true
                self.callback_display_select();
            else
                self.callback_display_unselect();
            end
        end
        
        function callback_display_select(self)
            % Display callback for handling the the display wit a selected design.
            %
            %    Update scatter plots.
            %    Update size information panel.
            %    Update the panel with figures of merit data of the selected design.
            %    Update the buttons.
            %    Update the 'InductorGUI' window.
            
            % highlight design of the scatter plots
            for i=1:length(self.gui_scatter_obj_vec)
                self.gui_scatter_obj_vec(i).set_select(self.id_select);
            end
            
            % fill the size info panel
            str = sprintf('n_sol = %d / n_plot = %d / id_design = %d', ...
                self.size_data.n_sol, self.size_data.n_plot, self.id_select);
            gui.GuiUtils.set_text(self.text_obj, str);
            
            % fill the panel with the figures of merit data of the selected design
            [text_data_fom, self.txt_fom] = self.pareto_display_obj.get_data_id(self.id_select);
            self.gui_text_obj.delete_panel();
            self.gui_text_obj.set_text(text_data_fom);
            self.gui_text_obj.set_visible(true);
            
            % enable clear and details buttons
            gui.GuiUtils.set_button(self.clear_obj, true);
            gui.GuiUtils.set_button(self.details_obj, true);
            
            % upda the 'InductorGUI' with the selected design
            self.inductor_gui_obj.set_id_select(self.id_select);
        end
        
        function callback_display_unselect(self)
            % Display callback for handling the the display witout a selected design.
            %
            %    Update scatter plots.
            %    Update size information panel.
            %    Update the panel with figures of merit data of the selected design.
            %    Update the buttons.
            %    Update the 'InductorGUI' window.
            
            % remove the highlighted design of the scatter plots
            for i=1:length(self.gui_scatter_obj_vec)
                self.gui_scatter_obj_vec(i).clear_select();
            end
            
            % fill the size info panel
            str = sprintf('n_sol = %d / n_plot = %d / id_design = None', ...
                self.size_data.n_sol, self.size_data.n_plot);
            gui.GuiUtils.set_text(self.text_obj, str);
            
            % remove the panel with the figures of merit
            self.gui_text_obj.set_visible(false);
            
            % disable clear and details buttons
            gui.GuiUtils.set_button(self.clear_obj, false);
            gui.GuiUtils.set_button(self.details_obj, false);
            
            % close the 'InductorGUI', if opened
            self.inductor_gui_obj.close_gui();
        end
    end
end