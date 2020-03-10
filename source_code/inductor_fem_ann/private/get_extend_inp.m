function [is_valid, inp] = get_extend_inp(const, model_type, var_type, n_sol, inp)

% inp
const = get_struct_size(const, n_sol);
inp = get_struct_merge(inp, const);
[is_valid, inp] = get_extend_inp_sub(model_type, var_type, inp);

end

function [is_valid, inp] = get_extend_inp_sub(model_type, var_type, inp)

% extract
geom_type = var_type.geom_type;
excitation_type = var_type.excitation_type;

% get geom
inp = get_base(geom_type, inp);
inp = get_core(inp);
inp = get_winding(inp);
inp = get_iso(inp);
inp = get_box(inp);

% get model
inp = get_model(model_type, excitation_type, inp);

% check
is_valid = get_is_valid(inp);

end

function inp = get_model(model_type, excitation_type, inp)

switch model_type
    case 'none'
        % pass
    case 'mf'
        switch excitation_type
            case 'rel'
                inp.I_winding = inp.J_winding.*inp.A_winding;
            case 'abs'
                inp.J_winding = inp.I_winding./inp.A_winding;
            otherwise
                error('invalid type')
        end
    case 'ht'
        switch excitation_type
            case 'rel'
                inp.P_tot = inp.p_density_tot.*inp.S_box;
                inp.P_core = inp.P_tot.*(1./(1+inp.p_ratio_winding_core));
                inp.P_winding = inp.P_tot.*(inp.p_ratio_winding_core./(1+inp.p_ratio_winding_core));
            case 'abs'
                inp.P_tot = inp.P_winding+inp.P_core;
                inp.p_density_tot = inp.P_tot./inp.S_box;
                inp.p_ratio_winding_core = inp.P_winding./inp.P_core;
            otherwise
                error('invalid type')
        end
    otherwise
        error('invalid type')
end

end

function inp = get_base(geom_type, inp)

switch geom_type
    case 'rel'
        inp.A_core_window = get_area_product(inp);
        
        inp.A_window = sqrt(inp.A_core_window./inp.fact_core_window);
        inp.x_window = sqrt(inp.A_window./inp.fact_window);
        inp.y_window = sqrt(inp.A_window.*inp.fact_window);
        
        inp.A_core = sqrt(inp.A_core_window.*inp.fact_core_window);
        inp.t_core = sqrt(inp.A_core./inp.fact_core);
        inp.z_core = sqrt(inp.A_core.*inp.fact_core);
        
        inp.d_gap = inp.fact_gap.*sqrt(inp.A_core);
    case 'abs'
        inp.A_window = inp.x_window.*inp.y_window;
        inp.fact_window = inp.y_window./inp.x_window;
        
        inp.A_core = inp.z_core.*inp.t_core;
        inp.fact_core = inp.z_core./inp.t_core;
        
        inp.A_core_window = inp.A_window.*inp.A_core;
        inp.fact_core_window = inp.A_core./inp.A_window;
        
        inp.fact_gap = inp.d_gap./sqrt(inp.A_core);
    otherwise
        error('invalid data')
end

% fillet
inp.r_fill = inp.r_fill_fact.*inp.d_gap;
inp.r_fill = min(inp.r_fill, inp.r_fill_max);
inp.r_fill = max(inp.r_fill, inp.r_fill_min);

% isolation
inp.d_iso = inp.d_iso_fact.*min(inp.x_window, inp.x_window);
inp.d_iso = min(inp.d_iso, inp.d_iso_max);
inp.d_iso = max(inp.d_iso, inp.d_iso_min);

% curvature
inp.r_curve = inp.fact_curve.*(inp.t_core./2);

end

function A_core_window = get_area_product(inp)

% extract
V_box = inp.V_box;
fact_core = inp.fact_core;
fact_window = inp.fact_window;
fact_core_window = inp.fact_core_window;
fact_curve = inp.fact_curve;

% solve
fact = 2.*((fact_core.^(-1).*fact_core_window.^(1/2)).^(1/2)+((fact_core_window.^(-1)).^(1/2).*fact_window.^(-1)).^(1/2)).*((fact_core.*fact_core_window.^(1/2)).^(1/2)+(fact_core.^(-1).*fact_core_window.^(1/2)).^(1/2).*fact_curve+2.*((fact_core_window.^(-1)).^(1/2).*fact_window.^(-1)).^(1/2)).*((fact_core.^(-1).*fact_core_window.^(1/2)).^(1/2)+((fact_core_window.^(-1)).^(1/2).*fact_window).^(1/2));
x = (V_box./fact).^(1./3);
A_core_window = x.^4;

end

function inp = get_core(inp)

inp.x_core = 2.*inp.x_window+2.*inp.t_core;
inp.y_core = inp.y_window+inp.t_core;
inp.l_core = 2.*(inp.x_window+inp.y_window-inp.d_gap)+2.*inp.t_core;
inp.V_core = inp.z_core.*(inp.x_core.*inp.y_core-2.*inp.x_window.*inp.y_window-2.*inp.t_core.*inp.d_gap);

end

function inp = get_winding(inp)

inp.x_winding = inp.x_window-2.*inp.d_iso;
inp.y_winding = inp.y_window-2.*inp.d_iso;
inp.A_winding = inp.x_winding.*inp.y_winding;
inp.l_winding = 2.*(inp.z_core+inp.t_core-2*inp.r_curve)+2.*pi.*(inp.r_curve+inp.d_iso+inp.x_winding./2);
inp.V_winding = inp.l_winding.*inp.A_winding;

end

function inp = get_iso(inp)

inp.A_iso = inp.A_window-inp.A_winding;
inp.l_iso = 2.*(inp.z_core+inp.t_core-2*inp.r_curve)+2.*pi.*(inp.r_curve+inp.x_window./2);
inp.V_iso = inp.l_iso.*inp.A_iso;

end

function inp = get_box(inp)

% mesh
inp.x_box = 2.*inp.x_window+2.*inp.t_core;
inp.y_box = inp.y_window+inp.t_core;
inp.z_box = inp.z_core+2.*(inp.x_window+inp.fact_curve.*inp.t_core./2);
inp.S_box = 2.*(inp.x_box.*inp.y_box+inp.x_box.*inp.z_box+inp.y_box.*inp.z_box);
inp.V_box = inp.x_box.*inp.y_box.*inp.z_box;

end

function is_valid = get_is_valid(inp)

% check
is_valid = true;
is_valid = is_valid&isfinite(inp.A_core_window);
is_valid = is_valid&isreal(inp.A_core_window);
is_valid = is_valid&(inp.A_core_window>=0);
is_valid = is_valid&(inp.x_window>=(4.*inp.d_iso));
is_valid = is_valid&(inp.y_window>=(4.*inp.d_iso));
is_valid = is_valid&(inp.t_core>=(2.*inp.r_curve));
is_valid = is_valid&(inp.d_gap>=inp.d_gap_min);

end
