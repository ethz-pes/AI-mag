function [inp, is_hash, filename] = get_fem_idx(folder_fem, inp, idx)
% Extract the variable and check if the simulation hash already exists.
%
%    The results are stored for every simulation with an hash as filename.
%    If the hash already exists, a flag is raised.
%
%    Parameters:
%        folder_fem (str): path of the folder where the results are stored
%        inp (struct): struct of vectors with the input combinations
%        idx (integer): simulation index to be computed
%
%    Returns:
%        inp (struct): struct of scalars with the selected input combination
%        is_hash (logical): if the hash already exists (or not)
%        filename (str): filename for the selected combination
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% get a specific combination
inp =  get_struct_filter(inp, idx);

% get filename with an hash
hash = get_struct_hash(inp);
filename = [folder_fem filesep() hash '.mat'];

% check if the hash already exists
is_hash = (exist(filename, 'file')~=2)==false;

end