function norm_param = get_var_norm_param(vec, type)
% Find and return different normalization to a vector.
%
%    Parameters:
%        vec (vector): vector with the data
%        type (str): type of normalization to perform
%
%    Returns:
%        norm_param (struct): normalization data
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% get scaling parameters
switch type
    case 'none'
        norm_param.offset = 0;
        norm_param.scale = 1;
    case 'min_max'
        norm_param.offset = min(vec);
        norm_param.scale = max(vec)-min(vec);
    case 'avg'
        norm_param.offset = mean(vec);
        norm_param.scale = 1;
    case 'std_dev'
        norm_param.offset = 0;
        norm_param.scale = std(vec);
    case 'avg_std_dev'
        norm_param.offset = mean(vec);
        norm_param.scale = std(vec);
    otherwise
        error('invalid normalization method')
end

% remove dangerous values
if abs(norm_param.scale)<eps
    norm_param.scale = 1;
end
if abs(norm_param.offset)<eps
    norm_param.offset = 0;
end

end
