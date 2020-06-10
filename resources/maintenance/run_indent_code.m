function run_indent_code()
% Auto indent all the source code.
%
%    Find all the MATLAB files.
%    Correct the indentation.
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% path of the root of the project
folder = '../..';

% find the MATLAB files
file_list = get_matlab_file(folder);

% find the MATLAB files
get_matlab_indent(file_list);

end

function file_list = get_matlab_file(folder)
% Find all the MATLAB file in a folder (recursive).
%
%    Parameters:
%        folder (str): folder to parse (including subfolders)
%
%    Returns:
%        file_list (cell): cell with the MATLAB files

% init the list
file_list = {};

% get the MATLAB file (at the root, not in the subfolders)
file_list_tmp = get_matlab_file_sub(folder);
file_list = [file_list file_list_tmp];

% get the subfolders and apply recursively
folder_list = get_m_folder(folder);
for i=1:length(folder_list)
    file_list_tmp = get_matlab_file(folder_list{i});
    file_list = [file_list file_list_tmp];
end

end

function file_list = get_matlab_file_sub(folder)
% Find all the MATLAB file in a folder (non-recursive).
%
%    Parameters:
%        folder (str): folder to parse (without subfolders)
%
%    Returns:
%        file_list (cell): cell with the MATLAB files

data = dir(fullfile(folder, '*.m'));

file_list = {};
for i=1:length(data)
    file_list{end+1} = [data(i).folder filesep() data(i).name];
end

end

function folder_list = get_m_folder(folder)
% Find the subfolders on a folder.
%
%    Parameters:
%        folder (str): folder to parse
%
%    Returns:
%        folder_list (cell): cell with the subfolders

% find all the elements
data = dir(fullfile(folder, '*'));

% keep only the subfolders
folder_list = {};
for i=1:length(data)
    if data(i).isdir==true
        % ignore the hidden folder (and the current and parent folder)
        if isempty(regexp(data(i).name, '^\.*', 'ONCE'))
            folder_list{end+1} = [data(i).folder filesep() data(i).name];
        end
    end
end

end

function get_matlab_indent(file_list)
% Indent a list of MATLAB files.
%
%    Parameters:
%        file_list (cell): cell with the files to indent

for i=1:length(file_list)
    fprintf('%d / %d / %s\n', i, length(file_list), file_list{i})
    indent_file(file_list{i})
end

end

function indent_file(filename)
% Indent a MATLAB file.
%
%    Parameters:
%        filename (str): MATLAB file to indent

h = matlab.desktop.editor.openDocument(filename);
h.smartIndentContents();
h.save();
h.close();

end