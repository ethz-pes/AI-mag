function [is_valid, inp] = get_extend_inp(const, model_type, var_type, n_sol, inp)
% Merge the input and the constant data, extend the data with additional info.
%
%    Merge the input and the constant data.
%    Parse the geometry from given absolute dimension or boxed volume constraints.
%    Add data about core, winding, insulation (size, area, volume, etc.).
%    Add data about the box volume, the applied excitation.
%
%    Parameters:
%        const (struct): struct of with the constant data
%        model_type (str): name of the physics to be solved
%        var_type (struct): type of the different variables used in the solver
%        n_sol (int): number of samples in the input data
%        inp (struct): struct of vectors with the input combinations
%
%    Returns:
%        is_valid (vector): validity of the different evaluated samples
%        inp (struct): merged data with additional info
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% extend the constant data with the required size, merge it with the input
const = get_struct_size(const, n_sol);
inp = get_struct_merge(inp, const);

% add additional info, get the validity
[is_valid, inp] = get_extend_inp_sub(model_type, var_type, inp);

end

function [is_valid, inp] = get_extend_inp_sub(model_type, var_type, inp)
% Merge the input and the constant data, extend the data with additional info.
%
%    Parameters:
%        model_type (str): name of the physics to be solved
%        var_type (struct): type of the different variables used in the solver
%        inp (struct): struct of vectors with the data (input merged with the constant data)
%
%    Returns:
%        is_valid (vector): validity of the different evaluated samples
%        inp (struct): merged data with additional info

% extract the type
geom_type = var_type.geom_type;
excitation_type = var_type.excitation_type;

% get the geometry, area, volume, etc.
inp = get_base(geom_type, inp);
inp = get_core(inp);
inp = get_winding(inp);
inp = get_iso(inp);
inp = get_box(inp);

% get the physics based data (excitation)
inp = get_model(model_type, excitation_type, inp);

% check the validity
is_valid = get_is_valid(inp);

end

function inp = get_base(geom_type, inp)
% Parse the basic geometry from the provided data.
%
%    Parameters:
%        geom_type (str): type of the provided geometry ('rel' or 'abs')
%        inp (struct): struct of vectors with the data
%
%    Returns:
%        inp (struct): struct of vectors with the data

% parse the very basic properties depending on the type
switch geom_type
    case 'rel'
        % the geometry is specified with:
        %    - the boxed volume
        %    - the different aspect ratios
        %    - the relative air gap length
        
        % get the area product for the specified data
        inp.A_core_window = get_area_product(inp);
        
        % get the window geometry
        inp.A_window = sqrt(inp.A_core_window./inp.fact_core_window);
        inp.x_window = sqrt(inp.A_window./inp.fact_window);
        inp.y_window = sqrt(inp.A_window.*inp.fact_window);
        
        % get the core geometry
        inp.A_core = sqrt(inp.A_core_window.*inp.fact_core_window);
        inp.t_core = sqrt(inp.A_core./inp.fact_core);
        inp.z_core = sqrt(inp.A_core.*inp.fact_core);
        
        % get the air gap length
        inp.d_gap = inp.fact_gap.*sqrt(inp.A_core);
    case 'abs'
        % the geometry is specified with:
        %    - core absolute geometry
        %    - winding absolute geometry
        %    - absolute air gap length
        
        % get the window geometry
        inp.A_window = inp.x_window.*inp.y_window;
        inp.fact_window = inp.y_window./inp.x_window;
        
        % get the core geometry
        inp.A_core = inp.z_core.*inp.t_core;
        inp.fact_core = inp.z_core./inp.t_core;
        
        % get the area product
        inp.A_core_window = inp.A_window.*inp.A_core;
        inp.fact_core_window = inp.A_core./inp.A_window;
        
        % get the air gap length
        inp.fact_gap = inp.d_gap./sqrt(inp.A_core);
    otherwise
        error('invalid geometry type')
end

% compute the core corner fillet radius, relative relative to the air gap length, with boundaries
inp.r_fill = inp.r_fill_fact.*inp.d_gap;
inp.r_fill = min(inp.r_fill, inp.r_fill_max);
inp.r_fill = max(inp.r_fill, inp.r_fill_min);

% get the insulation distance, relative to the window size, with boundaries
inp.d_iso = inp.d_iso_fact.*min(inp.x_window, inp.x_window);
inp.d_iso = min(inp.d_iso, inp.d_iso_max);
inp.d_iso = max(inp.d_iso, inp.d_iso_min);

% compute the winding head fillet radius, relative to the core limb size
inp.r_curve = inp.fact_curve.*(inp.t_core./2);

end

function A_core_window = get_area_product(inp)
% Compute the area product from a given box volume.
%
%    Parameters:
%        inp (struct): struct of vectors with the data
%
%    Returns:
%        A_core_window (vector): computed area product

% extract the data
V_box = inp.V_box;
fact_core = inp.fact_core;
fact_window = inp.fact_window;
fact_core_window = inp.fact_core_window;
fact_curve = inp.fact_curve;

% solve the equation, get area product
%    - this constrain problem is solved with Mathematica
%    - the solution is exported to MATLAB
%    - the Mathematica source file is 'resources/mathematica/geom_volume.nb'
fact = 2.*((fact_core.^(-1).*fact_core_window.^(1/2)).^(1/2)+((fact_core_window.^(-1)).^(1/2).*fact_window.^(-1)).^(1/2)).*((fact_core.*fact_core_window.^(1/2)).^(1/2)+(fact_core.^(-1).*fact_core_window.^(1/2)).^(1/2).*fact_curve+2.*((fact_core_window.^(-1)).^(1/2).*fact_window.^(-1)).^(1/2)).*((fact_core.^(-1).*fact_core_window.^(1/2)).^(1/2)+((fact_core_window.^(-1)).^(1/2).*fact_window).^(1/2));
x = (V_box./fact).^(1./3);
A_core_window = x.^4;

end

function inp = get_core(inp)
% Parse the core geometry from the provided data.
%
%    Parameters:
%        inp (struct): struct of vectors with the data
%
%    Returns:
%        inp (struct): struct of vectors with the data

% core external dimension
inp.x_core = 2.*inp.x_window+2.*inp.t_core;
inp.y_core = inp.y_window+inp.t_core;

% average magnetic length and total volume
inp.l_core = 2.*(inp.x_window+inp.y_window-inp.d_gap)+2.*inp.t_core;
inp.V_core = inp.z_core.*(inp.x_core.*inp.y_core-2.*inp.x_window.*inp.y_window-2.*inp.t_core.*inp.d_gap);

end

function inp = get_winding(inp)
% Parse the winding geometry from the provided data.
%
%    Parameters:
%        inp (struct): struct of vectors with the data
%
%    Returns:
%        inp (struct): struct of vectors with the data

% winding size
inp.x_winding = inp.x_window-2.*inp.d_iso;
inp.y_winding = inp.y_window-2.*inp.d_iso;

% winding area, average length, and total volume
inp.A_winding = inp.x_winding.*inp.y_winding;
inp.l_winding = 2.*(inp.z_core+inp.t_core-2*inp.r_curve)+2.*pi.*(inp.r_curve+inp.d_iso+inp.x_winding./2);
inp.V_winding = inp.l_winding.*inp.A_winding;

end

function inp = get_iso(inp)
% Parse the insulation geometry from the provided data.
%
%    Parameters:
%        inp (struct): struct of vectors with the data
%
%    Returns:
%        inp (struct): struct of vectors with the data

% get the insulation cross section area
inp.A_iso = inp.A_window-inp.A_winding;

% get the insulation length (around the winding)
inp.l_iso = 2.*(inp.z_core+inp.t_core-2*inp.r_curve)+2.*pi.*(inp.r_curve+inp.x_window./2);

% get the insulation total volume
inp.V_iso = inp.l_iso.*inp.A_iso;

end

function inp = get_box(inp)
% Parse the boxed geometry from the provided data.
%
%    Parameters:
%        inp (struct): struct of vectors with the data
%
%    Returns:
%        inp (struct): struct of vectors with the data

% total external dimension
inp.x_box = 2.*inp.x_window+2.*inp.t_core;
inp.y_box = inp.y_window+inp.t_core;
inp.z_box = inp.z_core+2.*(inp.x_window+inp.fact_curve.*inp.t_core./2);

% boxed area and volume
inp.A_box = 2.*(inp.x_box.*inp.y_box+inp.x_box.*inp.z_box+inp.y_box.*inp.z_box);
inp.V_box = inp.x_box.*inp.y_box.*inp.z_box;

end

function inp = get_model(model_type, excitation_type, inp)
% Add the physics based data (excitation).
%
%    Parameters:
%        model_type (str): name of the physics to be solved ('none' or 'mf', 'ht')
%        excitation_type (str): type of the provided excitation ('rel' or 'abs')
%        inp (struct): struct of vectors with the data
%
%    Returns:
%        inp (struct): struct of vectors with the data

switch model_type
    case 'none'
        % no physics, do nothing
    case 'mf'
        % compute the normalized inductance
        mu0 = 4.*pi.*1e-7;
        inp.L_norm = (mu0.*inp.A_core)./(2.*inp.d_gap);

        % compute the saturation current
        inp.I_sat = (inp.B_sat_core.*inp.A_core)./inp.L_norm;
        
        % magnetic model, the current is the excitation
        %    - 'rel': the ratio with the saturation current is given, the current is calculated
        %    - 'abs': the current is used, the ratio with the saturation current is calculated
        switch excitation_type
            case 'rel'                
                inp.I_winding = inp.r_sat.*inp.I_sat;
            case 'abs'                
                inp.r_sat = inp.I_winding./inp.I_sat;
            otherwise
                error('invalid physics excitation')
        end
    case 'ht'
        % thermal model, the losses (core and winding) are the excitation
        %    - 'rel': the loss sharing and density are used, the absolute losses are added
        %    - 'abs': the absolute losses are used, the loss sharing and density are added
        switch excitation_type
            case 'rel'
                inp.P_tot = inp.p_surface.*inp.A_box;
                inp.P_core = inp.P_tot.*(1./(1+inp.r_winding_core));
                inp.P_winding = inp.P_tot.*(inp.r_winding_core./(1+inp.r_winding_core));
            case 'abs'
                inp.P_tot = inp.P_winding+inp.P_core;
                inp.p_surface = inp.P_tot./inp.A_box;
                inp.r_winding_core = inp.P_winding./inp.P_core;
            otherwise
                error('invalid physics excitation')
        end
    otherwise
        error('invalid physics type')
end

end

function is_valid = get_is_valid(inp)
% Check which designs are valid.
%
%    Parameters:
%        inp (struct): struct of vectors with the data
%
%    Returns:
%        is_valid (vector): validity of the different evaluated samples
%        inp (struct): merged data with additional info

% init, everything is valid
is_valid = true;

% if the area product has been computed from the box volume, invalid data are possible
is_valid = is_valid&isfinite(inp.A_core_window);
is_valid = is_valid&isreal(inp.A_core_window);
is_valid = is_valid&(inp.A_core_window>=0);

% the winding window should have space for the insulation and winding
is_valid = is_valid&(inp.x_window>=(4.*inp.d_iso));
is_valid = is_valid&(inp.y_window>=(4.*inp.d_iso));

% the curvature of the winding head should be compatible with the core size
is_valid = is_valid&(inp.t_core>=(2.*inp.r_curve));

% too small air gaps cannot be practically realized
is_valid = is_valid&(inp.d_gap>=inp.d_gap_min);

end
