classdef GuiText < handle
    %% init
    methods (Static, Access = public)
        function obj = get_text_field(parent, offset, margin_title, margin_text, txt_data)
            obj = uipanel(parent, 'BorderType', 'none', 'Units', 'normalized', 'Position', [0 0 1 1]);
            pos = getpixelposition(obj);
            offset = pos(4)-offset;
            
            for i=1:length(txt_data)
                title = txt_data{i}.title;
                text = txt_data{i}.text;
                
                h = design.GuiText.set_text_title(obj, margin_title, offset, title);
                offset = offset-h;
                
                for j=1:length(margin_text)
                    text_tmp = text(j:length(margin_text):end);
                    h_vec(j) = design.GuiText.set_text_matrix(obj, margin_text(j), offset, text_tmp);
                end
                offset = offset-max(h_vec);
            end
        end
        
        function obj = set_table(parent, offset, margin_col, txt_header, txt_data)
            obj = uipanel(parent, 'BorderType', 'none', 'Units', 'normalized', 'Position', [0 0 1 1]);
            pos = getpixelposition(obj);
            offset = pos(4)-offset;
            
            for i=1:length(margin_col)
                h_vec(i) = design.GuiText.set_text_title(obj, margin_col(i), offset, txt_header{i});
            end
            offset = offset-max(h_vec);
            for i=1:length(margin_col)
                design.GuiText.set_text_matrix(obj, margin_col(i), offset, txt_data(:,i));
            end
        end
    end
    
    methods (Static, Access = private)
        function h = set_text_title(panel, margin, offset, data)
            handle = uicontrol(panel, ...
                'Style','text',...
                'FontSize', 11,...
                'FontWeight', 'bold',...
                'HorizontalAlignment', 'left',...
                'String', data...
                );
            w = handle.Extent(3);
            h = handle.Extent(4);
            set(handle, 'Position', [margin offset-h w h]);
        end
        
        function h = set_text_matrix(panel, margin, offset, data)
            handle = uicontrol(panel, ...
                'Style','text',...
                'FontSize', 11,...
                'FontWeight', 'normal',...
                'HorizontalAlignment', 'left',...
                'String', data...
                );
            w = handle.Extent(3);
            h = handle.Extent(4);
            set(handle, 'Position', [margin offset-h w h]);
        end
    end
end