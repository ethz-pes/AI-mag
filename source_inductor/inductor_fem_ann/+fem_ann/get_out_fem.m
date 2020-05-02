function out_fem = get_out_fem(model, model_type, inp)
% Make a FEM simulation for given parameters, extract the results.
%
%    Parameters:
%        model (model): COMSOL model containg the physics
%        model_type (str): name of the physics to be solved
%        inp (struct): struct of scalars with the parameters
%
%    Returns:
%        out_fem (struct): struct of vectors with the FEM results
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% get expression to be evaluated
switch model_type
    case 'mf'
        % magnetic output variables:
        %    - inductance (for a single turn)
        %    - quasi-RMS flux density, integral of B^beta, normalized for one turn and 1A, for the core losses
        %    - RMS current density, integral of J^2, normalized for one turn and 1A, for the LF winding losses
        %    - RMS magnetic density, integral of H^2, normalized for one turn and 1A, for the HF winding losses
        expr = {'L_norm', 'B_norm', 'J_norm', 'H_norm'};
    case 'ht'
        % thermal output variables:
        %    - maximum temperature elevation of the core, for the thermal limit
        %    - average temperature elevation of the core, for the losses
        %    - maximum temperature elevation of the winding, for the thermal limit
        %    - average temperature elevation of the winding, for the losses
        %    - maximum temperature elevation of the insulation, for the thermal limit
        expr = {'dT_core_max', 'dT_core_avg', 'dT_winding_max', 'dT_winding_avg', 'dT_iso_max'};
    otherwise
        error('invalid physics type')
end

% tag of the COMSOL solution and parameter node
tag_sol = 'sol1';
tag_param = 'default';

% extend the parameters with the mesh size
inp = get_mesh(inp);

% set the parameters in the model
set_parameter(model, tag_param, inp)

% run the model
model.sol(tag_sol).runAll;

% extract the results
out_fem = get_global(model, expr);

end

function inp = get_mesh(inp)
% Compute the mesh size for the different bodies.
%
%    Parameters:
%        inp (struct): struct of vectors with the data
%
%    Returns:
%        inp (struct): struct of vectors with the data

% get the characteristic dimensions of the different bodies
d_char_all = max([inp.x_box inp.y_box inp.z_box]);
d_char_core = min([inp.t_core inp.z_core]);
d_char_winding = min([inp.x_window inp.y_window inp.z_core]);
d_char_min = min([inp.d_gap inp.d_iso inp.r_fill]);
d_char_air = min([inp.x_box inp.y_box inp.z_box]);
d_char_iso = min([d_char_core d_char_winding]);

% assign the mesh size
inp.d_air = d_char_all.*inp.fact_air;
inp.d_mesh_core = d_char_core./inp.n_mesh_max;
inp.d_mesh_winding = d_char_winding./inp.n_mesh_max;
inp.d_mesh_air = d_char_air./inp.n_mesh_max;
inp.d_mesh_iso = d_char_iso./inp.n_mesh_max;
inp.d_mesh_min = d_char_min./inp.n_mesh_min;

end

function set_parameter(model, tag_param, inp)
% Set parameters in the COMSOL model (only is the parameter alrey exists).
%
%    Parameters:
%        model (model): COMSOL model
%        tag_param (str): tag of the COMSOL parameter node
%        inp (struct): struct of vectors with the data

str = model.param(tag_param).varnames();
for i=1:length(str)
    str_tmp = char(str(i));
    model.param(tag_param).set(str_tmp, inp.(str_tmp));
end

end

function data = get_global(model, expr)
% Extract variables from the COMSOL solution.
%
%    Parameters:
%        model (model): COMSOL model
%        expr (cell): expression to be evaluated
%
%    Returns:
%        out_fem (struct): struct of vectors with the FEM results

% evaluate the expression
data_raw = cell(1,length(expr));
[data_raw{:}] = model.mphglobal(expr, 'Complexout','on');

% assign the results
for i=1:length(expr)
    data_tmp = data_raw{i};
    assert(length(data_tmp)==1 , 'invalid length')
    data.(expr{i}) = data_tmp;
end

end