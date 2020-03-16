function run_iso()

%% data
id = [1 2];
rho = [1500 1600];
kappa = [0.5 0.4];

%% parse
data_tmp = {};
for i=1:length(id)
   material = get_data(rho(i), kappa(i));
   
   data_tmp{end+1} = struct('id', id(i), 'material', material);
end

%% assign
data.n = length(id);
data.data = data_tmp;

%% save
save('data/iso_data.mat', '-struct', 'data')

end

function material = get_data(rho, kappa)

material.rho = rho;
material.lambda = rho.*kappa;
material.T_max = 130.0;

end