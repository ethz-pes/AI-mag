function [diff, n_tot, n_sol, model_type, file_model, inp, out_fem] = get_assemble(folder_fem)
% Assemble many FEM simulation results into a single dataset.
%
%    Parameters:
%        folder_fem (str): path of the folder where the results are stored
%
%    Returns:
%        diff (duration): total duration of all te
%        n_tot (int): total number of simulations (including invalid simulations)
%        n_sol (int): total number of valid simulations
%        model_type (str): name of the physics that is solved
%        file_model (str): name of the COMSOL file used for the simulation
%        inp (struct): struct of vectors with the parameters
%        out_fem (struct): struct of vectors with the FEM results
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% get MATLAB file in the directory
filelist = dir([folder_fem filesep() '*.mat']);
assert(isempty(filelist)==false, 'invalid number of data to assemble (empty)')

% for all the files
for i=1:length(filelist)
    fprintf('    %d / %d\n', i, length(filelist))
    
    % load
    filename_tmp = [filelist(i).folder filesep()  filelist(i).name];
    data_tmp = load(filename_tmp);
    
    % assign
    diff(i) = data_tmp.diff;
    is_valid(i) = data_tmp.is_valid;
    inp{i} = data_tmp.inp;
    out_fem{i} = data_tmp.out_fem;
    model_type{i} = data_tmp.model_type;
    file_model{i} = data_tmp.file_model;
end

% assemble simulation data
diff = sum(diff);
n_tot = length(is_valid);
n_sol = nnz(is_valid);
inp = [inp{is_valid}];
out_fem = [out_fem{is_valid}];

% all the simulations should have the same physics
model_type = unique(model_type);
assert(length(model_type)==1, 'invalid physics type (not unique)')
model_type = model_type{:};

% all the simulations should have the same model file
file_model = unique(file_model);
assert(length(file_model)==1, 'invalid FEM model file (not unique)')
file_model = file_model{:};

% transform the array of structs into structs of arrays
inp = get_struct_assemble(inp);
out_fem = get_struct_assemble(out_fem);

end
