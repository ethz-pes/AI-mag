function data = get_grid_map(data_raw, tol)

%% matrix
f_vec = uniquetol(data_raw.f_vec, tol);
B_ac_peak_vec = uniquetol(data_raw.B_ac_peak_vec, tol);
T_vec = uniquetol(data_raw.T_vec, tol);
P_mat = NaN(length(f_vec), length(B_ac_peak_vec), length(T_vec));

%% fill
for i=1:length(f_vec)
    for j=1:length(B_ac_peak_vec)
        for k=1:length(T_vec)
            idx_f = abs(data_raw.f_vec-f_vec(i))<tol;
            idx_B_ac_peak = abs(data_raw.B_ac_peak_vec-B_ac_peak_vec(j))<tol;
            idx_T = abs(data_raw.T_vec-T_vec(k))<tol;
            idx = idx_f&idx_B_ac_peak&idx_T;
            
            assert(nnz(idx)==1, 'invalid data')
            P_mat(i,j,k) = data_raw.P_vec(idx);
        end
    end
end

%% assign
data.f_vec = f_vec;
data.B_ac_peak_vec = B_ac_peak_vec;
data.T_vec = T_vec;
data.P_mat = P_mat;

end
