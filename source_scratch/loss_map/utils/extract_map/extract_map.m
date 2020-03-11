function extract_map(name, tol, add)

data_raw = get_data_map(name, tol, add);
data = get_grid_map(data_raw, tol);
plot_map(name, data)

save(['data/' name '_map.mat'], 'data')

end
