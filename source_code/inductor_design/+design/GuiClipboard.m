classdef GuiClipboard < handle
    %% init
    properties (SetAccess = private, GetAccess = private)
        txt
    end
    
    %% init
    methods (Access = public)
        function self = GuiClipboard(txt)
            self.txt = txt;
        end
        
        function txt = get_txt(self)            
            txt = strtrim(self.txt);
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