function obj = test_plot()

addpath(genpath('source_ann'))
addpath(genpath('source_code'))
addpath(genpath('source_data'))
close('all')

%% file
load('data/compute.mat')

obj = design.InductorGui(id_design, fom, operating);

% obj.open_gui(56);

% pause(3)
% 
% obj.open_gui(57);


end
