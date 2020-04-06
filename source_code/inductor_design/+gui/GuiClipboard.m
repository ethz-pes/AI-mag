classdef GuiClipboard < handle
    % Class for managing clipboard data.
    %
    %    Set text and title.
    %    Get the parsed resulting text.
    %    This class manage text but do not access the operating system clipboard.
    %
    %    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

    %% properties
    properties (SetAccess = private, GetAccess = public)
        txt % str: current text in the memory
    end
    
    %% public
    methods (Access = public)
        function self = GuiClipboard()
            % Constructor.
            %
            %    Init the clipboard.
            %    Text is empty.

            self.txt = [];
        end
        
        function txt = get_txt(self)
            % Get the current clipboard.
            %
            %    Returns:
            %        txt (str): current text in the memory
            
            txt = strtrim(self.txt);
        end
        
        function add_text_data(self, text_data)
            % Add content to the clipboard from a struct (subtitle and text).
            %
            %    Parameters:
            %        text_data (cell): cell with subtitle/text blocks
            
            for i=1:length(text_data)
                % get the block subtitle and text
                subtitle = text_data{i}.title;
                text = text_data{i}.text;
                
                % flush the data
                self.add_text('======== %s', subtitle);
                for j=1:length(text)
                    self.add_text('    %s', text{j});
                end
            end
        end
        
        function add_title(self, str, varargin)
            % Add a title node to the clipboard.
            %
            %    Parameters:
            %        str (str): string to be displayed (with format data)
            %        varargin (cell): data for the format fields
            
            self.add_text('');
            self.add_text('======================================');
            self.add_text(str ,varargin{:});
            self.add_text('======================================');
            self.add_text('');
        end
        
        function add_text(self, str, varargin)
            % Add text to the clipboard.
            %
            %    Parameters:
            %        str (str): string to be displayed (with format data)
            %        varargin (cell): data for the format fields
            
            self.txt = [self.txt sprintf(str, varargin{:})];
            self.txt = [self.txt newline()];
        end
    end
end