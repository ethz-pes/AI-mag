function data_raw = get_data_map(name, tol, add)

data_raw = load_file(name);

for i=1:length(add.pts_grid)
   data_raw = add_pts_grid(data_raw, tol, add.pts_grid{i});
end
for i=1:length(add.frequency)
   data_raw = add_frequency(data_raw, tol, add.frequency{i});
end
for i=1:length(add.temperature)
   data_raw = add_temperature(data_raw, tol, add.temperature{i});
end

end

function data_raw = load_file(name)

data_mat = load(['data/' name '_map.txt']);

data_raw.f = 1e3.*data_mat(:,1).';
data_raw.B_peak = 1e-3.*data_mat(:,2).';
data_raw.T = data_mat(:,3).';
data_raw.P = 1e3.*data_mat(:,4).';

end

function data_raw = add_pts_grid(data_raw, tol, add)

for i=1:length(add.T)
    P_1 = get_P_idx(data_raw, tol, add.f_other, add.B_peak, add.T(i));
    P_2 = get_P_idx(data_raw, tol, add.f, add.B_peak_other, add.T(i));
    P_3 = get_P_idx(data_raw, tol, add.f_other, add.B_peak_other, add.T(i));

    f_vec = [add.f_other, add.f, add.f_other];
    B_peak_vec = [add.B_peak, add.B_peak_other, add.B_peak_other];
    P_vec = [P_1 P_2 P_3];

    fct = scatteredInterpolant(log10(f_vec).', log10(B_peak_vec).', log10(P_vec).', 'linear', 'linear');
    P = add.fact.*(10.^fct(log10(add.f), log10(add.B_peak)));
    
    data_raw.f = [data_raw.f add.f];
    data_raw.B_peak = [data_raw.B_peak add.B_peak];
    data_raw.T = [data_raw.T add.T(i)];
    data_raw.P = [data_raw.P P];
end

end

function data_raw = add_frequency(data_raw, tol, add)

for i=1:length(add.T)
    P_1 = get_P_idx(data_raw, tol, add.f_other_1, add.B_peak, add.T(i));
    P_2 = get_P_idx(data_raw, tol, add.f_other_2, add.B_peak, add.T(i));

    f_vec = [add.f_other_1, add.f_other_2];
    P_vec = [P_1 P_2];
    P = add.fact.*(10.^interp1(log10(f_vec), log10(P_vec), log10(add.f), 'linear', 'extrap'));
    
    data_raw.f = [data_raw.f add.f];
    data_raw.B_peak = [data_raw.B_peak add.B_peak];
    data_raw.T = [data_raw.T add.T(i)];
    data_raw.P = [data_raw.P P];
end

end

function data_raw = add_temperature(data_raw, tol, add)

for i=1:length(add.f)
    P_1 = get_P_idx(data_raw, tol, add.f(i), add.B_peak, add.T_other_1);
    P_2 = get_P_idx(data_raw, tol, add.f(i), add.B_peak, add.T_other_2);

    T_vec = [add.T_other_1, add.T_other_2];
    P_vec = [P_1 P_2];
    P = add.fact.*(10.^interp1(T_vec, log10(P_vec), add.T, 'linear', 'extrap'));
    
    data_raw.f = [data_raw.f add.f(i)];
    data_raw.B_peak = [data_raw.B_peak add.B_peak];
    data_raw.T = [data_raw.T add.T];
    data_raw.P = [data_raw.P P];
end

end

function P = get_P_idx(data_raw, tol, f, B_peak, T)

idx_f = abs(data_raw.f-f)<tol;
idx_B_peak = abs(data_raw.B_peak-B_peak)<tol;
idx_T = abs(data_raw.T-T)<tol;
idx = idx_f&idx_B_peak&idx_T;

assert(nnz(idx)==1, 'invalid data')
P = data_raw.P(idx);

end
