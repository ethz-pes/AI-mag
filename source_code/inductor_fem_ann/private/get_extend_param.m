function [is_valid, param] = get_extend_param(model_type, var_type, param)

% type
geom_type = var_type.geom;
excitation_type = var_type.excitation;

% get geom
param = get_base(geom_type, param);
param = get_core(param);
param = get_winding(param);
param = get_box(param);

% get model
param = get_model(model_type, excitation_type, param);

% check
is_valid = get_is_valid(param);

end

function param = get_model(model_type, excitation_type, param)

switch model_type
    case 'mf'
        % pass
    case 'ht'
        switch excitation_type
            case 'rel'
                param.P_tot = param.ht_stress.*param.S_box;
                param.P_core = param.P_tot.*(1./(1+param.ht_sharing));
                param.P_winding = param.P_tot.*(param.ht_sharing./(1+param.ht_sharing));
            case 'abs'
                param.P_tot = param.P_winding+param.P_core;
                param.ht_stress = param.P_tot./param.S_box;
                param.ht_sharing = param.P_winding./param.P_core;
            otherwise
                error('invalid type')
        end
    otherwise
        error('invalid type')
end

end

function param = get_base(geom_type, param)

switch geom_type
    case 'rel'
        param.A_core_window = get_area_product(param);
        
        param.A_window = sqrt(param.A_core_window./param.fact_core_window);
        param.x_window = sqrt(param.A_window./param.fact_window);
        param.y_window = sqrt(param.A_window.*param.fact_window);
        
        param.A_core = sqrt(param.A_core_window.*param.fact_core_window);
        param.t_core = sqrt(param.A_core./param.fact_core);
        param.z_core = sqrt(param.A_core.*param.fact_core);
        
        param.d_gap = param.fact_gap.*sqrt(param.A_core);
    case 'abs'
        param.A_window = param.x_window.*param.y_window;
        param.fact_window = param.y_window./param.x_window;
        
        param.A_core = param.z_core.*param.t_core;
        param.fact_core = param.z_core./param.t_core;
        
        param.A_core_window = param.A_window.*param.A_core;
        param.fact_core_window = param.A_core./param.A_window;
        
        param.fact_gap = param.d_gap./sqrt(param.A_core);
        param.volume_target = NaN;
    otherwise
        error('invalid data')
end

% fillet
param.r_fill = param.r_fill_fact.*param.d_gap;
param.r_fill = min(param.r_fill, param.r_fill_max);
param.r_fill = max(param.r_fill, param.r_fill_min);

% isolation
param.d_iso = param.d_iso_fact.*min(param.x_window, param.x_window);
param.d_iso = min(param.d_iso, param.d_iso_max);
param.d_iso = max(param.d_iso, param.d_iso_min);

% curvature
param.r_curve = param.fact_curve.*(param.t_core./2);

end

function A_core_window = get_area_product(param)

% extract
volume_target = param.volume_target;
fact_core = param.fact_core;
fact_window = param.fact_window;
fact_core_window = param.fact_core_window;
fact_curve = param.fact_curve;

% solve
fact = 2.*((fact_core.^(-1).*fact_core_window.^(1/2)).^(1/2)+((fact_core_window.^(-1)).^(1/2).*fact_window.^(-1)).^(1/2)).*((fact_core.*fact_core_window.^(1/2)).^(1/2)+(fact_core.^(-1).*fact_core_window.^(1/2)).^(1/2).*fact_curve+2.*((fact_core_window.^(-1)).^(1/2).*fact_window.^(-1)).^(1/2)).*((fact_core.^(-1).*fact_core_window.^(1/2)).^(1/2)+((fact_core_window.^(-1)).^(1/2).*fact_window).^(1/2));
x = (volume_target./fact).^(1./3);
A_core_window = x.^4;

end

function param = get_core(param)

param.x_core = 2.*param.x_window+2.*param.t_core;
param.y_core = param.y_window+param.t_core;
param.l_core = 2.*(param.x_window+param.y_window-param.d_gap)+2.*param.t_core;
param.V_core = param.z_core.*(param.x_core.*param.y_core-2.*param.x_window.*param.y_window-2.*param.t_core.*param.d_gap);

end

function param = get_winding(param)

param.x_winding = param.x_window-2.*param.d_iso;
param.y_winding = param.y_window-2.*param.d_iso;
param.A_winding = param.x_winding.*param.y_winding;
param.l_winding = 2.*(param.z_core+param.t_core-2*param.r_curve)+2.*pi.*(param.r_curve+param.d_iso+param.x_winding./2);
param.V_winding = param.l_winding.*param.A_winding;

end

function param = get_box(param)

% mesh
param.x_box = 2.*param.x_window+2.*param.t_core;
param.y_box = param.y_window+param.t_core;
param.z_box = param.z_core+2.*(param.x_window+param.fact_curve.*param.t_core./2);
param.S_box = 2.*(param.x_box.*param.y_box+param.x_box.*param.z_box+param.y_box.*param.z_box);
param.V_box = param.x_box.*param.y_box.*param.z_box;

end

function is_valid = get_is_valid(param)

% check
is_valid = true;
is_valid = is_valid&isfinite(param.A_core_window);
is_valid = is_valid&isreal(param.A_core_window);
is_valid = is_valid&(param.A_core_window>=0);
is_valid = is_valid&(param.x_window>=(4.*param.d_iso));
is_valid = is_valid&(param.y_window>=(4.*param.d_iso));
is_valid = is_valid&(param.t_core>=(2.*param.r_curve));
is_valid = is_valid&(param.d_gap>=param.d_gap_min);

end
