classdef GuiTextTable < handle
    properties (SetAccess = private, GetAccess = private)
        panel
        offset
        margin_col
        h_vec
    end

    %% init
    methods (Access = public)
        function self = GuiTextTable(parent, offset, margin_col)
            self.panel = uipanel(parent, 'BorderType', 'none', 'Units', 'normalized', 'Position', [0 0 1 1]);
            self.offset = offset;
            self.margin_col = margin_col;
            self.h_vec = [];
        end
        
        function panel = get_panel(self)
            panel = self.panel;
        end
        
        function delete_panel(self)
            delete(self.h_vec);
            self.h_vec = [];
        end
        
        function set_table(self, offset, margin_col, txt_header, txt_data)
            pos = getpixelposition(self.panel);
            self.offset = pos(4)-self.offset;
            
            n_col = length(self.margin_col);
            for i=1:n_col
                y_vec(i) = self.set_text_col(txt_header{i}, i, 'bold');
            end
            self.offset = self.offset-max(y_vec);
            for i=1:n_col
                self.set_text_col(txt_data(:,i), i, 'normal');
            end
        end
        
        function set_text(self, txt_data)
            pos = getpixelposition(self.panel);
            self.offset = pos(4)-self.offset;
            
            for i=1:length(txt_data)
                title = txt_data{i}.title;
                text = txt_data{i}.text;
                
                y = self.set_text_col(title, 1, 'bold');
                self.offset = self.offset-y;
                
                n_col = length(self.margin_col)-1;
                for j=1:n_col
                    text_tmp = text(j:n_col:end);
                    y_vec(j) = self.set_text_col(text_tmp, j+1, 'normal');
                end
                self.offset = self.offset-max(y_vec);
            end
        end
                
        function y = set_text_col(self, data, idx, font)
            obj = uicontrol(self.panel, ...
                'Style','text',...
                'FontSize', 11,...
                'FontWeight', font,...
                'HorizontalAlignment', 'left',...
                'String', data...
                );
            self.h_vec = [self.h_vec obj];

            x = obj.Extent(3);
            y = obj.Extent(4);
            set(obj, 'Position', [self.margin_col(idx) self.offset-y x y]);
        end
    end
end