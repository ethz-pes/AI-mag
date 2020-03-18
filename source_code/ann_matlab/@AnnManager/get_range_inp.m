function is_valid = get_range_inp(self, inp)

is_valid = true;

for i=1:length(self.var_inp)
    % extract
    name_tmp = self.var_inp{i}.name;
    min_tmp = self.var_inp{i}.min;
    max_tmp = self.var_inp{i}.max;
    
    value_tmp = inp.(name_tmp);
    
    is_valid = is_valid&(value_tmp>=min_tmp);
    is_valid = is_valid&(value_tmp<=max_tmp);
end

end
