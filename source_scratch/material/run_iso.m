function run_iso()

%% data
id = [1 2];
rho = [1500 1600];
kappa = [0.5 0.4];

%% parse
data = {};
for i=1:length(id)
   material = get_data(rho(i), kappa(i));
   
   data{end+1} = struct('id', id(i), 'material', material);
end

%% assign
type = 'iso';

%% save
save('data/iso_data.mat', 'data', 'type')

end

function material = get_data(rho, kappa)

material.rho = rho;
material.lambda = rho.*kappa;
material.T_max = 130.0;
material.c_offset = 0.3;

end