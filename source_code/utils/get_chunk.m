function [n_chunk, idx_chunk] = get_chunk(n_split, n_sweep)

idx = 1;
idx_chunk = {};

while idx<=n_sweep
    idx_new = min(idx+n_split,n_sweep+1);
    vec = idx:(idx_new-1);
    idx_chunk{end+1} = vec;
    idx = idx_new;
end

n_chunk = length(idx_chunk);

end