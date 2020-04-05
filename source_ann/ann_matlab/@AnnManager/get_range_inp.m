function is_valid = get_range_inp(self, inp)
% Check which samples of an input dataset are in the right range.
%
%    Parameters:
%        inp (struct): input data
%
%    Returns:
%        is_valid (vector): validity of the samples

% init, everything is valid
is_valid = true;

% test each variable
for i=1:length(self.var_inp)
    % extract variable
    name_tmp = self.var_inp{i}.name;
    min_tmp = self.var_inp{i}.min;
    max_tmp = self.var_inp{i}.max;
    
    % extract value
    value_tmp = inp.(name_tmp);
    
    % check range
    is_valid = is_valid&(value_tmp>=min_tmp);
    is_valid = is_valid&(value_tmp<=max_tmp);
end

end
