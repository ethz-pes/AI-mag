function run_update_fem()
% Update a FEM dataset with a given function.
%
%    The FEM dataset is a folder with many files. Each file is a sample.
%    Creating the FEM dataset is very time consuming.
%    Therefore, updating (without regenerating) the dataset is useful.
%    This function allows to apply changes to all the samples (files) in the dataset.
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% path of the root of the project
folder = '../..';

% update the datasets
get_assemble('dataset/fem_ht', folder, @fct_handle)
get_assemble('dataset/fem_mf', folder, @fct_handle)

end

function get_assemble(name, folder, fct_handle)
% Create archives (zip and tar.gz) of a folder, add readme, add license.
%
%    Parameters:
%        name (str): name of the folder with the FEM dataset
%        folder (str): path to the root of the project
%        fct_handle (str): function to apply to the dataset samples

% get all the MATLAB files in the directory
fprintf('%s\n', name)
filelist = dir([folder filesep() name filesep() '*.mat']);
assert(isempty(filelist)==false, 'invalid data')

% for all the files, update them
n_update = 0;
fprintf('    parse\n')
for i=1:length(filelist)
    fprintf('        %d / %d\n', i, length(filelist))
    
    % load
    filename_tmp = [filelist(i).folder filesep()  filelist(i).name];
    data_tmp = load(filename_tmp);
    
    % handle the file
    [is_update_tmp, data_tmp] = fct_handle(data_tmp);
    
    % if required, save the new version
    if is_update_tmp==true
        save(filename_tmp, '-v7.3', '-struct', 'data_tmp')
        n_update = n_update+1;
    end
end

% display some statistics
fprintf('    n_file = %d\n', length(filelist))
fprintf('    n_update = %d\n', n_update)

end

function [is_update, data] = fct_handle(data)
% Update function for a sample (file) of the FEM dataset.
%
%    Parameters:
%        data (struct): provided sample data
%
%    Return:
%        is_update (logical): if the sample should be saved (or not)
%        data (struct): updated sample data

is_update = false;

end
