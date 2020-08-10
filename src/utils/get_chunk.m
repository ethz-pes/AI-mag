function [n_chunk, idx_chunk] = get_chunk(n_split, n_sol)
% Split data into chunks with maximum size.
%
%    The division of computational data is useful:
%        - Dividing the data for parallel loop (loop)
%        - Reducing the data in the memory while computing
%
%    Parameters:
%        n_split (int): number of data per chunk
%        n_sol (int): number of data to be splitted in chunks
%
%    Returns:
%        n_chunk (int): number of created chunks
%        idx_chunk (cell): cell with the indices of the chunks
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% init the data
idx = 1;
idx_chunk = {};

% create the chunks indices
while idx<=n_sol
    idx_new = min(idx+n_split,n_sol+1);
    vec = idx:(idx_new-1);
    idx_chunk{end+1} = vec;
    idx = idx_new;
end

% count the chunks
n_chunk = length(idx_chunk);

end