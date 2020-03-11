function data = get_struct_size(data, n)

field = fieldnames(data);
for i=1:length(field)
    tmp = data.(field{i});
    assert(islogical(tmp)||isnumeric(tmp), 'invalid data')
    if length(tmp)==1
        data.(field{i}) = repmat(tmp, 1, n);
    elseif length(tmp)==n
        data.(field{i}) = tmp;
    else
        error('invalid size')
    end
end

end