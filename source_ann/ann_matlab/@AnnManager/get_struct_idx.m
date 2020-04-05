function data = get_struct_idx(data, idx)
% Filter a struct of vectors with specified indices.
%
%    Parameters:
%        data (struct): struct of vectors (unfiltered)
%        idx (vector): indices to be kept
%
%    Returns:
%        data (struct): struct of vectors (filtered)
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

field = fieldnames(data);
for i=1:length(field)
    tmp = data.(field{i});
    data.(field{i}) = tmp(idx);
end

end
