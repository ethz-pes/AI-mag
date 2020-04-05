function data_ac = extract_map_ac(data_ac, tol, add_pts)
% Parse, extrapolate, and put into a regular grid for the AC loss map.
%
%    Parameters:
%        data_ac (struct): AC loss map (not parsed)
%        tol (float): duplicated points tolerance
%        add_pts (cell): points to extrapolate
%
%    Returns:
%        data_ac (struct): AC loss map (parsed)
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% parse the matrix file
data_ac = get_parse(data_ac);

% extrapolate points
for i=1:length(add_pts)
   data_ac = get_extrapolate(data_ac, tol, add_pts{i});
end

% put the data into a regular grid
data_ac = get_grid_map(data_ac, tol);

end

function data_ac_out = get_parse(data_ac_in)
% Parse the AC loss map.
%
%    Parameters:
%        data_ac_in (matrix): AC loss map (not parsed)
%
%    Returns:
%        data_ac_out (struct): AC loss map (parsed)

data_ac_out.f_vec = 1e3.*data_ac_in(:,1).';
data_ac_out.B_ac_peak_vec = 1e-3.*data_ac_in(:,2).';
data_ac_out.T_vec = data_ac_in(:,3).';
data_ac_out.P_vec = 1e3.*data_ac_in(:,4).';

end

function data_ac = get_extrapolate(data_ac, tol, add_pts)
% Extrapolate the AC loss map.
%
%    Parameters:
%        data_ac (struct): AC loss map
%        tol (float): duplicated points tolerance
%        add_pts (cell): points to extrapolate
%
%    Returns:
%        data_ac (struct): AC loss map

T_vec = unique(data_ac.T_vec);
for i=1:length(T_vec)
    % get the points for the interpolation
    P_1 = get_P_idx(data_ac, tol, add_pts.f_other, add_pts.B_ac_peak, T_vec(i));
    P_2 = get_P_idx(data_ac, tol, add_pts.f, add_pts.B_ac_peak_other, T_vec(i));
    P_3 = get_P_idx(data_ac, tol, add_pts.f_other, add_pts.B_ac_peak_other, T_vec(i));

    % form the scattered interpolation vector
    f_vec = [add_pts.f_other, add_pts.f, add_pts.f_other];
    B_ac_peak_vec = [add_pts.B_ac_peak, add_pts.B_ac_peak_other, add_pts.B_ac_peak_other];
    P_vec = [P_1 P_2 P_3];

    % interpolate in log scale
    fct = scatteredInterpolant(log10(f_vec).', log10(B_ac_peak_vec).', log10(P_vec).', 'linear', 'linear');
    P = 10.^fct(log10(add_pts.f), log10(add_pts.B_ac_peak));
    
    % add the result
    data_ac.f_vec = [data_ac.f_vec add_pts.f];
    data_ac.B_ac_peak_vec = [data_ac.B_ac_peak_vec add_pts.B_ac_peak];
    data_ac.T_vec = [data_ac.T_vec T_vec(i)];
    data_ac.P_vec = [data_ac.P_vec P];
end

end

function data = get_grid_map(data_ac, tol)
% Put the AC loss map into a regular grid.
%
%    Parameters:
%        data_ac (matrix): AC loss map (vector format)
%        tol (float): duplicated points tolerance
%
%    Returns:
%        data_ac (struct): AC loss map (grid format)

% form the grid vecotors
f_vec = uniquetol(data_ac.f_vec, tol);
B_ac_peak_vec = uniquetol(data_ac.B_ac_peak_vec, tol);
T_vec = uniquetol(data_ac.T_vec, tol);

% fill the matrix
P_mat = NaN(length(f_vec), length(B_ac_peak_vec), length(T_vec));
for i=1:length(f_vec)
    for j=1:length(B_ac_peak_vec)
        for k=1:length(T_vec)            
            P_mat(i,j,k) = get_P_idx(data_ac, tol, f_vec(i), B_ac_peak_vec(j), T_vec(k));
        end
    end
end

% assign the result
data.f_vec = f_vec;
data.B_ac_peak_vec = B_ac_peak_vec;
data.T_vec = T_vec;
data.P_mat = P_mat;

end

function P = get_P_idx(data_ac, tol, f, B_ac_peak, T)
% Get the loss for a specified point.
%
%    Parameters:
%        data_ac (struct): AC loss map
%        tol (float): tolerance for finding the loss points
%        f (float): seletected frequency
%        B_ac_peak (float): tolerance AC flux density
%        T (float): tolerance temperature
%
%    Returns:
%        P (float): extracted loss point

% get the index
idx_f = abs(data_ac.f_vec-f)<tol;
idx_B_ac_peak = abs(data_ac.B_ac_peak_vec-B_ac_peak)<tol;
idx_T = abs(data_ac.T_vec-T)<tol;
idx = idx_f&idx_B_ac_peak&idx_T;

% check and extract
assert(nnz(idx)==1, 'invalid loss data')
P = data_ac.P_vec(idx);

end
