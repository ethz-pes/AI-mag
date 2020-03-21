function test_plot()

addpath(genpath('source_ann'))
addpath(genpath('source_code'))
addpath(genpath('source_data'))
close('all')

%% file
load('data/compute.mat')

is_valid = true(1, n_valid);

obj = design.InductorDisplay(is_valid, fom, operating);

obj.get_gui(45, 3);

end
