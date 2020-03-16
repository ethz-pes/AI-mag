function run_0_init()

addpath(genpath('source_code'))
addpath(genpath('source_input'))
close('all')

%% run
file_init = 'data/fem_ann/init.mat';

const = get_data_const();
save(file_init, 'const')

end
