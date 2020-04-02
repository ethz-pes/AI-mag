function run_ann_example()

addpath('../ann_matlab');
addpath('ann_data');
close('all')

% master_train
fprintf('AnnManager Example\n')
fprintf('    1 - ANN regression with MATLAB Deep Learning\n')
fprintf('    2 - ANN regression with Python Keras and TensorFlow\n')
fprintf('    3 - MATLAB regression with nonlinear least-squares\n')
fprintf('    4 - MATLAB regression with genetic algorithm\n')
idx = input('Enter your choice >> ');

choice = {'matlab_ann', 'python_ann', 'matlab_lsq', 'matlab_ga'};
choice = get_choice(choice, idx);

if isempty(choice)
    fprintf('Invalid input\n')
else
    fprintf('\n')
    get_ann_manager(choice)
end

end

function choice = get_choice(choice, idx)

if isnumeric(idx)&&(length(idx)==1)&&(idx>=1)&&(idx<=length(choice))
    choice = choice{idx};
else
    choice = [];
end

end
