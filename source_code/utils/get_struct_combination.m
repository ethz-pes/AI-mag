function [n, data] = get_struct_combination(data)

field = fieldnames(data);
for i=1:length(field)
    vec = data.(field{i});
    x_cell{i} =  vec;
    n_vec(i) = length(vec);
end

x_tmp = cell(1,length(x_cell));
[x_tmp{:}] = ndgrid(x_cell{:});
n = prod(n_vec);

for i=1:length(field)
    vec = x_tmp{i};
    data.(field{i}) =  vec(:).';
end

end