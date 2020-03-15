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
B_ac_peak = repmat(50e-3, 1, n);
B_dc = repmat(50e-3, 1, n);
T = repmat(70, 1, n);
d_c = repmat(0.8, 1, n);

[is_valid1, P1] = obj.get_losses_sin(f, B_ac_peak, B_dc, T)

[is_valid2, P2] = obj.get_losses_tri(f, d_c, B_ac_peak, B_dc, T)

%% grid
data_tmp = load('source_scratch\loss_map\winding_data.mat');
data = data_tmp.data;

%% obj
id = [71 71 100 50 100];
n = length(id);

obj = WindingData(data, id);

m = obj.get_mass();
m = obj.get_cost();
T_max = obj.get_temperature();

f = repmat(50e3, 1, n);
J_dc = repmat(1e6, 1, n);
J_ac_peak = repmat(1e6, 1, n);
H_ac_peak = repmat(5e3, 1, n);
T = repmat(70, 1, n);
d_c = repmat(0.8, 1, n);

[is_valid, P] = obj.get_losses_sin(f, J_dc, J_ac_peak, H_ac_peak, T)
[is_valid, P] = obj.get_losses_tri(f, d_c, J_dc, J_ac_peak, H_ac_peak, T)

%% grid
data_tmp = load('source_scratch\loss_map\iso_data.mat');
data = data_tmp.data;

%% obj
id = [1 1 2];

obj = IsoData(data, id);

m = obj.get_mass();
m = obj.get_cost();
T_max = obj.get_temperature();


end