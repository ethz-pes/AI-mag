function disp_data(name, data)

disp_data_sub(0, name, data)

end

function disp_data_sub(level, name, data)

if isa(data, 'char')
    print_indent(level, '%s : %s', name, data)
elseif isa(data, 'double')
    print_indent(level, '%s : %.3e', name, data)
elseif isa(data, 'logical')
    print_indent(level, '%s : %d', name, data)
elseif isa(data, 'function_handle')
    print_indent(level, '%s : %s', name, char(data))
elseif isa(data, 'struct')
    field = fieldnames(data);
    print_indent(level, '%s : n_field = %d', name, length(field))
    for i=1:length(field)
        name_tmp = field{i};
        data_tmp = data.(field{i});
        disp_data_sub(level+1, name_tmp, data_tmp)
    end
elseif isa(data, 'cell')
    print_indent(level, '%s : n_cell = %d', name, length(data))
    for i=1:length(data)
        name_tmp = [name ' / ' num2str(i)];
        data_tmp = data{i};
        disp_data_sub(level+1, name_tmp, data_tmp)
    end
else
    error('invalid type')
end

end

function print_indent(varargin)

level = varargin{1};
arg = varargin(2:end);

indent = repmat(' ', 1, 4*level);
str = sprintf(arg{:});
fprintf('%s%s\n', indent, str);

end