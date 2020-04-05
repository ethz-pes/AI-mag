classdef GuiClipboard < handle
    %% init
    properties (SetAccess = private, GetAccess = public)
        txt
    end
    
    %% init
    methods (Access = public)
        function self = GuiClipboard()
            self.txt = [];
        end
        
        function txt = get_txt(self)            
            txt = strtrim(self.txt);
        end
        
        function add_text_data(self, text_data)
            for i=1:length(text_data)
                title = text_data{i}.title;
                text = text_data{i}.text;
                
                self.add_text('======== %s', title);
                for j=1:length(text)
                    self.add_text('    %s', text{j});
                end
            end
        end
        
        function add_title(self, varargin)
            self.add_text('');
            self.add_text('======================================');
            self.add_text(varargin{:});
            self.add_text('======================================');
            self.add_text('');
        end
                
        function add_text(self, varargin)
            self.txt = [self.txt sprintf(varargin{:})];
            self.txt = [self.txt newline()];
        end
    end
end