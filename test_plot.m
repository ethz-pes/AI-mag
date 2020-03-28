function obj = test_plot()

addpath(genpath('source_ann'))
addpath(genpath('source_code'))
addpath(genpath('source_data'))
close('all')

%% file
load('data/compute.mat')

obj = design.InductorGui(id_design, fom, operating);
obj.set_id_select(56);
obj.open_gui();
