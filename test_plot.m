function test_plot()

addpath(genpath('source_ann'))
addpath(genpath('source_code'))
addpath(genpath('source_data'))
close('all')

%% file
load('data/compute.mat')


obj = design.InductorDisplay(fom, operating);
obj.get_gui(45);
obj.get_data(45);
obj.get_text(45);


end
