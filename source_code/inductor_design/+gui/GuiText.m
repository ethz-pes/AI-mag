classdef GuiText < handle
    properties (SetAccess = private, GetAccess = public)
        panel
        offset
        margin_col
        h_vec
    end

    %% init
    methods (Access = public)
        function self = GuiText(parent, offset, margin_col)
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
        
        function set_visible(self, visible)
            if visible==true
                set(self.panel, 'Visible', 'on');
            else
                set(self.panel, 'Visible', 'off');
            end
        end
                
        function set_text(self, txt_data)
            pos = getpixelposition(self.panel);
            offset_tmp = pos(4)-self.offset;
            
            for i=1:length(txt_data)
                title = txt_data{i}.title;
                text = txt_data{i}.text;
                
                y = self.set_text_col(title, offset_tmp, 1, 'bold');
                offset_tmp = offset_tmp-y;
                
                n_col = length(self.margin_col)-1;
                for j=1:n_col
                    text_tmp = text(j:n_col:end);
                    y_vec(j) = self.set_text_col(text_tmp, offset_tmp, j+1, 'normal');
                end
                offset_tmp = offset_tmp-max(y_vec);
            end
        end
                
        function y = set_text_col(self, data, offset, idx, font)
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
            set(obj, 'Position', [self.margin_col(idx) offset-y x y]);
        end
    end
end