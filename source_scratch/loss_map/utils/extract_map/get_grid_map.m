function data = get_grid_map(data_raw, tol)

%% matrix
f = uniquetol(data_raw.f, tol);
B_peak = uniquetol(data_raw.B_peak, tol);
T = uniquetol(data_raw.T, tol);
P_f_B_peak_T = NaN(length(f), length(B_peak), length(T));

%% fill
for i=1:length(f)
    for j=1:length(B_peak)
        for k=1:length(T)
            idx_f = abs(data_raw.f-f(i))<tol;
            idx_B_peak = abs(data_raw.B_peak-B_peak(j))<tol;
            idx_T = abs(data_raw.T-T(k))<tol;
            idx = idx_f&idx_B_peak&idx_T;
            
            assert(nnz(idx)==1, 'invalid data')
            P_f_B_peak_T(i,j,k) = data_raw.P(idx);
        end
    end
end

%% assign
data.f = f;
data.B_peak = B_peak;
data.T = T;
data.P_f_B_peak_T = P_f_B_peak_T;

end
