function disp_data(name, data)
% Display data (on screen) in a pretty way.
%
%    Parameters:
%        name (str): name of the variable to be displayed
%        data (various): data to be displayed
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

disp_data_sub(0, name, data)

end

function disp_data_sub(level, name, data)
% Display data (on screen) in a pretty way.
%
%    This function is recursive for struct and cell.
%    This function can handle a small subset of the MATLAB data types.
%
%    Parameters:
%        level (int): indentation level
%        name (str): name of the variable to be displayed
%        data (various): data to be displayed

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
    error('invalid data type')
end

end

function print_indent(level, str, varargin)
% Display a string (on screen) with indentation
%
%    Parameters:
%        level (int): indentation level
%        str (str): string to be displayed (with format data)
%        varargin (cell): data for the format fields

indent = repmat(' ', 1, 4*level);
str = sprintf(str, varargin{:});
fprintf('%s%s\n', indent, str);

end