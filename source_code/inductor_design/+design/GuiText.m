classdef GuiText < handle
    %% init
    methods (Static, Access = public)
        function set_text(panel, offset, margin_title, margin_text, txt_data)
            pos = getpixelposition(panel);
            offset = pos(4)-offset;
            
            for i=1:length(txt_data)
                title = txt_data{i}.title;
                text = txt_data{i}.text;
                
                h = design.GuiText.set_text_title(panel, margin_title, offset, title);
                offset = offset-h;
                
                for j=1:length(margin_text)
                    text_tmp = text(j:length(margin_text):end);
                    h_vec(j) = design.GuiText.set_text_matrix(panel, margin_text(j), offset, text_tmp);
                end
                offset = offset-max(h_vec);
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