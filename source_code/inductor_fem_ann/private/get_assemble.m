function [n_tot, n_sol, inp, out_fem] = get_assemble(folder)

% get file
filelist = dir([folder filesep() '*.mat']);
assert(length(filelist)>0, 'invalid data')

% load
for i=1:length(filelist)
    fprintf('    %d / %d\n', i, length(filelist))

    filename_tmp = [filelist(i).folder filesep()  filelist(i).name];
    data_tmp = load(filename_tmp);
    
    is_valid(i) = data_tmp.is_valid;
    inp{i} = data_tmp.inp;
    out_fem{i} = data_tmp.out_fem;
end

% filter
n_tot = length(is_valid);
n_sol = nnz(is_valid);
inp = [inp{is_valid}];
out_fem = [out_fem{is_valid}];

% merge
inp = get_struct_assemble(inp);
out_fem = get_struct_assemble(out_fem);

end
