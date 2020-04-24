function struct_out = get_struct_assemble(struct_in)
% Assemble an array of structs into a struct of vectors.
%
%    The following data are accepted:
%        - The struct can contains other sub-structs
%        - The array of structs can contains numeric or logical scalar
%
%    Parameters:
%        struct_in (struct): array of structs (input)
%        idx (vector): indices to be kept
%
%    Returns:
%        struct_out (struct): struct of vectors (output)
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% check type
assert(isstruct(struct_in)==1, 'invalid data')

% handle data
struct_out = struct();
field = fieldnames(struct_in);
for i=1:length(field)
    struct_in_tmp = [struct_in.(field{i})];
    
    if isstruct(struct_in_tmp)
        % if struct, recursive call
        struct_out.(field{i}) = get_struct_assemble(struct_in_tmp);
    else
        % if data, convert to a row vector
        assert(size(struct_in_tmp, 1)==1, 'invalid data')
        struct_out.(field{i}) = struct_in_tmp;
    end
end

end