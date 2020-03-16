function data = extract_map(data_mat, tol, add)

data_raw = get_data_map(data_mat, tol, add);
data = get_grid_map(data_raw, tol);

end
