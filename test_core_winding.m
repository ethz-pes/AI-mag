function test_core_winding()

close('all');
addpath(genpath('utils'))

%% grid
data_tmp = load('source_scratch\loss_map\core_data.mat');
data = data_tmp.data;

%% obj
id = [95 95 97 97 97 97 49];
n = length(id);
obj = CoreData(data, id);

m = obj.get_mass();
m = obj.get_cost();
T_max = obj.get_temperature();

f = repmat(50e3, 1, n);
B_peak = repmat(50e-3, 1, n);
B_dc = repmat(50e-3, 1, n);
T = repmat(70, 1, n);

[is_valid1, P1] = obj.get_losses_sin(f, B_peak, B_dc, T);

[is_valid2, P2] = obj.get_losses_tri(f, 0.6, B_peak, B_dc, T);

fdgdfg

%% grid
data_tmp = load('source_scratch\loss_map\winding_data.mat');
data = data_tmp.data;

%% obj
id = [71 71 100 50 100];
obj = WindingData(data, id);

m = obj.get_mass();
m = obj.get_cost();
T_max = obj.get_temperature();

J_dc = repmat(1e6, 1, 7);
J_rms = repmat(1e6, 1, 7);
H_rms = repmat(10e4, 1, 7);
T = repmat(70, 1, 7);

[is_valid, P] = obj.get_losses_sin(f, J_rms, H_rms, J_dc, T);


end