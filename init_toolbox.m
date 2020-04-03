function init_toolbox()

% add path
addpath(genpath('source_ann'))
addpath(genpath('source_code'))
addpath(genpath('source_data'))

% close figures
close('all')

% print copyright
fprintf('FEM/ANN Inductor Optimization\n')
fprintf('    T. Guillod, Power Electronic Systems Laboratory\n')
fprintf('    Copyright 2019-2020 ETH Zurich / xxx License\n')

end