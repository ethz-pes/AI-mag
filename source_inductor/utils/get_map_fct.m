function varargout = get_map_fct(id_set, id_vec, fct, input)
% Vector evaluation of a function with different discrete ids.
%
%    The function is meant as a vectorized switch statement.
%    A function handle should be applied to provided vector data.
%    Different ids are provided (switch case)
%    The function handle should be called a single time for each id.
%
%    The function handle should have the following prototype:
%        - First input argument: scalar integer with the id
%        - Other input arguments: vectors with the input data
%        - Output arguments: vectors with the output data
%
%    Parameters:
%        id_set (vector): vector with the existing set of ids
%        id_vec (vector): vector with the ids to be evaluated
%        fct (fct): function to be applied to the inputs
%        input (cell): input arguments for the function
%
%    Returns:
%        varargout (cell): input arguments of the function
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% initialize the output
for i=1:nargout
    varargout{i} = NaN(1, length(id_vec));
end

% check the input
for i=1:length(input)
    assert(size(input{i}, 1)==1, 'invalid data size')
    assert(length(input{i})==length(id_vec), 'invalid data size')
end

% track which samples are treated
is_ok = false(1, length(id_vec));

% call the function for the different ids in the set
for i=1:length(id_set)
    % get the indices to be evaluated
    id_tmp = id_set(i);
    idx = id_vec==id_tmp;
    
    % get the input
    input_tmp = input;
    for j=1:length(input_tmp)
        input_tmp{j} = input_tmp{j}(idx);
    end
    
    % evaluate the function
    varargout_tmp = cell(1, nargout);
    [varargout_tmp{:}] = fct(id_tmp, input_tmp{:});
    
    % assign the output
    for j=1:nargout
        varargout{j}(idx) = varargout_tmp{j};
    end
    
    % set the flag
    is_ok(idx) = true;
end

% check the output
assert(all(is_ok==true), 'invalid id vector and/or set')

end