function out_approx = get_out_approx(model_type, inp)
% Get the analytical approximations for different given parameters.
%
%    Parameters:
%        model_type (str): name of the physics to be solved
%        inp (struct): struct of vectors with the parameters
%
%    Returns:
%        out_approx (struct): struct of vectors with the analytical results
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

switch model_type
    case 'mf'
        out_approx = fem_ann.get_out_approx_mf(inp);
    case 'ht'
        out_approx = fem_ann.get_out_approx_ht(inp);
    otherwise
        error('invalid model')
end

end