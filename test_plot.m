function test_plot()

addpath(genpath('source_ann'))
addpath(genpath('source_code'))
addpath(genpath('source_data'))
close('all')

%% file
load('data/compute.mat')


obj = design.InductorGui(fom, operating);
obj.get_gui(45, 25);

end
