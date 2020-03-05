function geom_out = get_geom(geom_in, geom_type)

switch geom_type
    case 'rel'
        geom_out = geom_in;
    case 'abs'
        % compute param
        A_window = geom_in.x_window.*geom_in.y_window;
        A_core = geom_in.z_core.*geom_in.t_core;
        x_box = 2.*geom_in.x_window+2.*geom_in.t_core;
        y_box = geom_in.y_window+geom_in.t_core;
        z_box = geom_in.z_core+2.*(geom_in.x_window+geom_in.fact_curve.*geom_in.t_core./2);
        
        % assign
        geom_out.fact_window = geom_in.y_window./geom_in.x_window;
        geom_out.fact_core = geom_in.z_core./geom_in.t_core;
        geom_out.fact_gap = geom_in.d_gap./sqrt(A_core);
        geom_out.fact_core_window = A_core./A_window;
        geom_out.volume_target = x_box.*y_box.*z_box;
    otherwise
        error('invalid geom')
end

end