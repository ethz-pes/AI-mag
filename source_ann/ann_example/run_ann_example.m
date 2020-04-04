function run_ann_example()
% Test the ANN regression library with a simple example.
%
%    Different regression type are available:
%        - ANN regression with MATLAB Deep Learning
%        - ANN regression with Python Keras and TensorFlow
%        - MATLAB regression with nonlinear least-squares
%        - MATLAB regression with genetic algorithm

% init
addpath('../ann_matlab');
addpath('ann_data');
close('all')

% get the type of regression to be done
fprintf('AnnManager Example\n')
fprintf('    1 - ANN regression with MATLAB Deep Learning\n')
fprintf('    2 - ANN regression with Python Keras and TensorFlow\n')
fprintf('    3 - MATLAB regression with nonlinear least-squares\n')
fprintf('    4 - MATLAB regression with genetic algorithm\n')
idx = input('Enter your choice >> ');

% parse the user choice
choice_cell = {'matlab_ann', 'python_ann', 'matlab_lsq', 'matlab_ga'};
choice = get_choice(choice_cell, idx);

% run the regression
if isempty(choice)
    fprintf('Invalid input\n')
else
    fprintf('\n')
    get_ann_manager(choice)
end

end

function choice = get_choice(choice_cell, idx)
% Check and parse the user input and return the corresponding choice.
%
%    Parameters:
%        choice_cell (cell): Cell of tag for the possible choice
%        idx (int): Index of the selected item
%
%    Returns:
%        choice (str): Tag of the selected item

if isnumeric(idx)&&(length(idx)==1)&&(idx>=1)&&(idx<=length(choice_cell))
    choice = choice_cell{idx};
else
    choice = [];
end

end
