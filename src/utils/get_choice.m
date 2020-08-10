function choice = get_choice(choice_cell, idx)
% Check and parse the user input and return the corresponding choice.
%
%    Parameters:
%        choice_cell (cell): Cell of tag for the possible choice
%        idx (int): Index of the selected item
%
%    Returns:
%        choice (str): Tag of the selected item
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

if isnumeric(idx)&&(length(idx)==1)&&(idx>=1)&&(idx<=length(choice_cell))
    choice = choice_cell{idx};
else
    choice = [];
end

end
