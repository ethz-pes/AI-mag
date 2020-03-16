function run_0_init()

addpath(genpath('source_code'))
addpath(genpath('source_input'))
close('all')

%% file
file_init = 'data/fem_ann/init.mat';

%% run
const = get_data_const();

%% save
save(file_init, '-struct', 'const')

end
