function init_toolbox()
% Init the MATLAB Inductor FEM/ANN toolbox.
%
%    Add the code to the MATLAB path.
%    Close all figures.
%    Display a copyright notice.
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% add path
addpath(genpath('source_ann'))
addpath(genpath('source_inductor'))
addpath(genpath('source_input'))

% close figures
close('all')

% print copyright
fprintf('FEM/ANN Inductor Optimization\n')
fprintf('    T. Guillod, Power Electronic Systems Laboratory\n')
fprintf('    Copyright 2019-2020 ETH Zurich / BSD License\n')

end