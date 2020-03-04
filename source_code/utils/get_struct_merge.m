function data = get_struct_merge(data_1, data_2)

cell = [struct2cell(data_1) ; struct2cell(data_2)];
field = [fieldnames(data_1) ; fieldnames(data_2)];
data = cell2struct(cell, field);

end