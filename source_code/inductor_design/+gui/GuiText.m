classdef GuiText < handle
    % Class for displaying formatted text in a GUI.
    %
    %    Set text and title.
    %    Manage margin and position.
    %    Set visibility.
    %
    %    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod
    
    %% properties
    properties (SetAccess = private, GetAccess = public)
        panel % uipanel: handle to uipanel containing the feature
        offset % float: vertical margin (pixels units)
        margin_col % vector: horizontal margin for title and columns (pixels units)
        h_vec % obj: vector with all the text objects
    end
    
    %% public
    methods (Access = public)
        function self = GuiText(parent, offset, margin_col)
            % Constructor.
            %
            %    Parameters:
            %        parent (obj): parent object to create the feature
            %        offset (float): vertical margin (pixels units)
            %        offset (vector): horizontal margin for title and columns (pixels units)
            
            % create panel
            self.panel = uipanel(parent, 'BorderType', 'none', 'Units', 'normalized', 'Position', [0 0 1 1]);
            
            % do not create the axis
            self.offset = offset;
            self.margin_col = margin_col;
            self.h_vec = [];
        end
        
        function panel = get_panel(self)
            % Return the uipanel where the feature is places.
            %
            %    Returns:
            %        panel (uipanel): handle to uipanel containing the feature
            
            panel = self.panel;
        end
        
        function delete_panel(self)
            % Delete all the data of the features.
            %
            %    Delete the axis.
            %    Delete of the children of the axis.
            
            delete(self.h_vec);
            self.h_vec = [];
        end
        
        function set_visible(self, visible)
            % Make the feature visible (or not).
            %
            %    Parameters:
            %        visible (logical): if the feature is visible (or not)
            
            if visible==true
                set(self.panel, 'Visible', 'on');
            else
                set(self.panel, 'Visible', 'off');
            end
        end
        
        function set_text(self, txt_data)
            % Write the text blocks to the panel.
            %
            %    For each blocks.
            %        - Bold title
            %        - Text over several columns
            %
            %    Parameters:
            %        text_data (cell): cell with title/text blocks
            
            % get the height of the panel, get the absolute offset from the top of the panel
            pos = getpixelposition(self.panel);
            offset_tmp = pos(4)-self.offset;
            
            % display every block
            for i=1:length(txt_data)
                offset_tmp = self.set_block(offset_tmp, txt_data{i});
            end
        end
    end
    
    %% private
    methods (Access = private)
        function offset_tmp = set_block(self, offset_tmp, txt_data_tmp)
            % Write a specific text block.
            %
            %    Parameters:
            %        offset_tmp (float): absolute offset from the top of the panel
            %        txt_data_tmp (struct): title/text blocks
            %
            %    Parameters:
            %        offset_tmp (float): absolute offset from the top of the panel
            
            % get the block data
            title = txt_data_tmp.title;
            text = txt_data_tmp.text;
            
            % write title, remove height from offset_tmp
            y = self.set_text_col(title, offset_tmp, 1, 'bold');
            offset_tmp = offset_tmp-y;
            
            % write text in columns, remove height from offset_tmp
            n_col = length(self.margin_col)-1;
            for j=1:n_col
                text_tmp = text(j:n_col:end);
                y_vec(j) = self.set_text_col(text_tmp, offset_tmp, j+1, 'normal');
            end
            offset_tmp = offset_tmp-max(y_vec);
        end
        
        function y = set_text_col(self, data, offset_tmp, idx, font)
            % Write a text field.
            %
            %    Parameters:
            %        data (str/cell): text to be written
            %        offset_tmp (float): absolute offset from the top of the panel
            %        idx (int): column index (column one is title, the rest is text)
            %        font (str): font weight
            %
            %    Parameters:
            %        y (float): height of the text block in pixels
            
            % create the text block
            obj = uicontrol(self.panel, ...
                'Style','text',...
                'FontSize', 11,...
                'FontWeight', font,...
                'HorizontalAlignment', 'left',...
                'String', data...
                );
            
            % add it the the handle list
            self.h_vec = [self.h_vec obj];
            
            % get and set the position
            x = obj.Extent(3);
            y = obj.Extent(4);
            set(obj, 'Position', [self.margin_col(idx) offset_tmp-y x y]);
        end
    end
end