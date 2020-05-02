function get_zip(folder_fem)
% Assemble many FEM simulation into a zip file and remove the folder.
%
%    Parameters:
%        folder_fem (str): path of the folder where the results are stored
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% get MATLAB file in the directory
filelist = dir([folder_fem filesep() '*.mat']);
assert(isempty(filelist)==false, 'invalid number of data to assemble (empty)')

% get name
file_fem = [folder_fem '.zip'];
for i=1:length(filelist)
    filelist_cell{i} = [filelist(i).folder filesep()  filelist(i).name];
end

% zip data
zip(file_fem, filelist_cell);

% remove folder
[s, m] = rmdir(folder_fem, 's');

end
