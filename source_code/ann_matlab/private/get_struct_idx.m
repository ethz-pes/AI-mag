function data = get_struct_idx(data, idx)
field = fieldnames(data);
for i=1:length(field)
    tmp = data.(field{i});
    data.(field{i}) = tmp(idx);
end
end
