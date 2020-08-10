classdef InductorCompute < handle
    % Class for computing inductor designs with ANN/regression.
    %
    %    Offers the following features:
    %        - compute geometry
    %        - compute physical properties: volume, cost, mass, etc.
    %        - compute magnetic properties: inductance, saturation current, etc.
    %        - check the validity of the design
    %        - compute many operating points
    %        - core loss map (DC bias) and winding losses (proximity losses)
    %        - sinus or triangular current excitation
    %        - thermal/loss coupling
    %
    %    Both the magnetic and the thermal model are powered by a ANN data-driven model.
    %
    %    The code is completely vectorized: compute many designs at the same time.
    %
    %    The material are managed by 'CoreData', 'WindingData', and 'IsoData'.
    %    The thermal/loss iteration is managed by 'ThermalLossIter'.
    %    The ANN/regression for the thermal and magnetic parameters is managed by 'AnnFem'.
    %
    %    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod
    
    %% properties
    properties (SetAccess = private, GetAccess = public)
        n_sol % int: number of designs or samples
        data_vec % struct: struct of vectors with one value per sample
        data_const % struct: data common for all the sample (not only numeric, any data type)
        ann_fem_obj % AnnFem: instance of the ANN/regression engine for thermal and magnetic model
        fom % struct: computed figures of merit (independent of any operating points)
        core_obj % CoreData: object mananaging the core properties
        winding_obj % WindingData: object mananaging the winding properties
        iso_obj % IsoData: object mananaging the insulation properties
        thermal_losses_iter_obj % ThermalLossIter: object mananaging the thermal/loss coupling
        waveform_model_obj % WaveformModel: object for managing the waveforms
    end
    
    %% public
    methods (Access = public)
        function self = InductorCompute(n_sol, data_vec, data_const, ann_fem_obj)
            % Constructor.
            %
            %    Parameters:
            %        n_sol (int): number of designs or samples
            %        data_vec (struct:) struct of vectors with one value per sample
            %        data_const (struct): data common for all the sample (not only numeric, any data type)
            %        ann_fem_obj (AnnFem): instance of the ANN/regression engine for thermal and magnetic model
            
            % assign the data
            self.n_sol = n_sol;
            self.data_vec = data_vec;
            self.data_const = data_const;
            self.ann_fem_obj = ann_fem_obj;
            
            % make sure that all the samples have the right dimension
            self.data_vec = get_struct_size(self.data_vec, self.n_sol);
            
            % init the different objects
            self.init_geom_material()
            self.init_magnetic()
            self.init_limit()
            self.init_thermal_loss_waveform()
        end
        
        function fom = get_fom(self)
            % Get the figures of merit of the different inductors.
            %
            %    Returns:
            %        fom (struct): computed figures of merit (independent of any operating points)
            
            fom = self.fom;
        end
        
        function operating = get_operating(self, excitation)
            % Compute several operating points (losses and temperatures) for the different designs.
            %
            %    Parameters:
            %        excitation (struct): struct containing the operating points (e.g., full load, partial load)
            %
            %    Returns:
            %        operating (struct): struct containing the excitation, losses, and temperatures
            
            field = fieldnames(excitation);
            for j=1:length(field)
                excitation_pts = excitation.(field{j});
                operating_pts = self.get_operating_pts(excitation_pts);
                operating.(field{j}) = operating_pts;
            end
        end
    end
    
    %% private / init
    methods (Access = private)
        function init_geom_material(self)
            % Create the material manager and init the inductor geometry.
            %
            %    Get the geometry from the ANN/regression object.
            %    Create the material objects.
            %    Compute all the geometrical, mass, and cost figures of merit.
            
            % set the geometry to the ANN/regression object and get the parsed result
            self.ann_fem_obj.set_geom(self.n_sol, self.data_vec.geom);
            [is_valid_geom, geom] = self.ann_fem_obj.get_geom();
            
            % create the object for mananing the material
            %    - the material data are common for all the designs
            %    - the material of the different designs is select with the respective id
            self.core_obj = design_compute.CoreData(self.data_const.material_core, self.data_vec.material.core_id, geom.V_core);
            self.winding_obj = design_compute.WindingData(self.data_const.material_winding, self.data_vec.material.winding_id, geom.V_winding, geom.fill_pack);
            self.iso_obj = design_compute.IsoData(self.data_const.material_iso, self.data_vec.material.iso_id, geom.V_iso);
            
            % set the data to the figures of merit
            self.fom.is_valid_geom = is_valid_geom;
            self.fom.material.core_id = self.data_vec.material.core_id;
            self.fom.material.winding_id = self.data_vec.material.winding_id;
            self.fom.material.iso_id = self.data_vec.material.iso_id;
            
            % set the raw geometry
            self.fom.geom.z_core = geom.z_core;
            self.fom.geom.t_core = geom.t_core;
            self.fom.geom.x_window = geom.x_window;
            self.fom.geom.y_window = geom.y_window;
            self.fom.geom.d_gap = geom.d_gap;
            self.fom.geom.d_iso = geom.d_iso;
            self.fom.geom.r_curve = geom.r_curve;
            self.fom.geom.n_turn = geom.n_turn;
            self.fom.geom.fill_pack = geom.fill_pack;
            
            % set the area
            self.fom.area.A_iso = geom.A_iso;
            self.fom.area.A_core = geom.A_core;
            self.fom.area.A_winding = geom.A_winding;
            self.fom.area.A_box = geom.A_box;
            
            % set the volume (scaling and offset for the global value)
            V_offset = self.data_vec.fom_data.V_offset;
            V_scale = self.data_vec.fom_data.V_scale;
            self.fom.volume.V_iso = geom.V_iso;
            self.fom.volume.V_core = geom.V_core;
            self.fom.volume.V_winding = geom.V_winding;
            self.fom.volume.V_box = V_offset+V_scale.*geom.V_box;
            
            % set the mass (scaling and offset for the global value)
            m_offset = self.data_vec.fom_data.m_offset;
            m_scale = self.data_vec.fom_data.m_scale;
            self.fom.mass.m_iso = self.iso_obj.get_mass();
            self.fom.mass.m_core = self.core_obj.get_mass();
            self.fom.mass.m_winding = self.winding_obj.get_mass();
            self.fom.mass.m_tot = m_offset+m_scale.*(self.fom.mass.m_iso+self.fom.mass.m_core+self.fom.mass.m_winding);
            
            % set the cost (scaling and offset for the global value)
            c_offset = self.data_vec.fom_data.c_offset;
            c_scale = self.data_vec.fom_data.c_scale;
            self.fom.cost.c_iso = self.iso_obj.get_cost();
            self.fom.cost.c_core = self.core_obj.get_cost();
            self.fom.cost.c_winding = self.winding_obj.get_cost();
            self.fom.cost.c_tot = c_offset+c_scale.*(self.fom.cost.c_iso+self.fom.cost.c_core+self.fom.cost.c_winding);
        end
        
        function init_magnetic(self)
            % Get the magnetic properties of the different designs.
            %
            %    Get the magnetic results from the ANN/regression object.
            %    Parse this result to obtain the inductance, saturation current, etc.
            
            % get the magnetic simulation results from the ANN/regression object
            mu_core = self.core_obj.get_permeability();
            beta_core = self.core_obj.get_beta_steinmetz();
            I_winding = self.fom.geom.n_turn.*self.data_vec.other.I_test;
            excitation_tmp = struct('I_winding', I_winding, 'mu_core', mu_core, 'beta_core', beta_core);
            [is_valid_mf, fom_mf] = self.ann_fem_obj.get_mf(excitation_tmp);
            
            % set the data to the figures of merit (scaled with the numer of turns)
            self.fom.is_valid_mf = is_valid_mf;
            self.fom.circuit.B_norm = self.fom.geom.n_turn.*fom_mf.B_norm;
            self.fom.circuit.J_norm = self.fom.geom.n_turn.*fom_mf.J_norm;
            self.fom.circuit.H_norm = self.fom.geom.n_turn.*fom_mf.H_norm;
            self.fom.circuit.L = self.fom.geom.n_turn.^2.*fom_mf.L_norm;
            
            % set the saturation, RMS current, and voltage time area properties
            B_sat_max = self.core_obj.get_flux_density();
            J_rms_max = self.winding_obj.get_current_density();
            self.fom.circuit.I_sat = B_sat_max./self.fom.circuit.B_norm;
            self.fom.circuit.I_rms = J_rms_max./self.fom.circuit.J_norm;
            self.fom.circuit.V_t_sat_sat = 2.*self.fom.circuit.L.*self.fom.circuit.I_sat;
        end
        
        function init_limit(self)
            % Get the validity of the different designs.
            %
            %    Check if the geometrical and magnetic properties are reasonable.
            %    This function does not compute losses, it is just a rough filter.
            
            % check if the figures of merit are in the right range
            is_valid_limit = true;
            is_valid_limit = is_valid_limit&self.init_is_valid_check(self.fom.volume.V_box, self.data_vec.fom_limit.V_box);
            is_valid_limit = is_valid_limit&self.init_is_valid_check(self.fom.cost.c_tot, self.data_vec.fom_limit.c_tot);
            is_valid_limit = is_valid_limit&self.init_is_valid_check(self.fom.mass.m_tot, self.data_vec.fom_limit.m_tot);
            is_valid_limit = is_valid_limit&self.init_is_valid_check(self.fom.circuit.L, self.data_vec.fom_limit.L);
            is_valid_limit = is_valid_limit&self.init_is_valid_check(self.fom.circuit.I_sat, self.data_vec.fom_limit.I_sat);
            is_valid_limit = is_valid_limit&self.init_is_valid_check(self.fom.circuit.I_rms, self.data_vec.fom_limit.I_rms);
            is_valid_limit = is_valid_limit&self.init_is_valid_check(self.fom.circuit.V_t_sat_sat, self.data_vec.fom_limit.V_t_sat_sat);
            self.fom.is_valid_limit = is_valid_limit;
            
            % validity of the different designs
            self.fom.is_valid = self.fom.is_valid_geom&self.fom.is_valid_mf&self.fom.is_valid_limit;
        end
        
        function is_valid_tmp = init_is_valid_check(self, vec, limit)
            % Check the validity of a parameter.
            %
            %    Parameters:
            %        vec (vector): parameter to be checked
            %        limit (struct:) accepted lower and upper bounds
            %
            %    Parameters:
            %        is_valid_tmp (vector): validity of the different elements
            
            is_valid_min = vec>=limit.min;
            is_valid_max = vec<=limit.max;
            is_valid_tmp = is_valid_min&is_valid_max;
        end
        
        function init_thermal_loss_waveform(self)
            % Init the thermal/loss iterator and the waveform model.
            %
            %    Get the different functions describing the loss and thermal models.
            %    Create the thermal/loss object.
            %    Create the waveform model object.
            
            % thermal/loss iteration
            fct.get_thermal = @(operating) self.get_thermal(operating);
            fct.get_losses = @(operating) self.get_losses(operating);
            fct.get_thermal_vec = @(operating) self.get_thermal_vec(operating);
            fct.get_losses_vec = @(operating) self.get_losses_vec(operating);
            self.thermal_losses_iter_obj = design_compute.ThermalLossIter(self.data_const.iter, fct);
            
            % waveform model
            self.waveform_model_obj = design_compute.WaveformModel(self.n_sol, self.data_const.signal);
        end
        
    end
    
    %% private / operating
    methods (Access = private)
        function operating = get_operating_pts(self, excitation)
            % Compute a single operating point (losses and temperatures) for the different designs.
            %
            %    Parameters:
            %        excitation (struct): struct containing the operating point excitation
            %
            %    Returns:
            %        operating (struct): struct containing the excitation, losses, and temperatures
            
            % make sure that all the samples have the right dimension
            excitation = get_struct_size(excitation, self.n_sol);
            
            % init, compute the data which are independent of the iterations
            operating = self.get_operating_init(excitation);
            
            % compute the coupled loss and thermal models
            [operating, is_valid_iter] = self.thermal_losses_iter_obj.get_iter(operating);
            
            % extract the different validity flags
            is_valid_fom = self.fom.is_valid;
            is_valid_thermal = operating.is_valid_thermal;
            is_valid_core = operating.is_valid_core;
            is_valid_winding = operating.is_valid_winding;
            
            % set the validity of the operating point
            operating.is_valid_iter = is_valid_iter;
            operating.is_valid = is_valid_fom&is_valid_iter&is_valid_thermal&is_valid_core&is_valid_winding;
        end
        
        function operating = get_operating_init(self, excitation)
            % Initialize an operating point with the data which are independent of the iterations.
            %
            %    Compute the waveforms and the associated figures of merit.
            %    Initialize the thermal data for the first thermal loss iteration.
            %
            %    Parameters:
            %        excitation (struct): struct containing the operating point excitation
            %
            %    Returns:
            %        operating (struct): struct with the operating point data
            
            operating = struct();
            operating = self.get_waveform_init(operating, excitation.waveform);
            operating = self.get_thermal_init(operating, excitation.thermal);
        end
        
        function operating = get_waveform_init(self, operating, excitation)
            % Compute the waveforms and the associated figures of merit.
            %
            %    Parameters:
            %        operating (struct): struct with the operating point data
            %        excitation (struct): struct containing the waveform parameters
            %
            %    Returns:
            %        operating (struct): struct with the operating point data
            
            % set the waveform
            self.waveform_model_obj.set_excitation(excitation);
            
            % get the inductor circuit and field parameters
            B_norm = self.fom.circuit.B_norm;
            J_norm = self.fom.circuit.J_norm;
            H_norm = self.fom.circuit.H_norm;
            L = self.fom.circuit.L;
            I_sat = self.fom.circuit.I_sat;
            I_rms = self.fom.circuit.I_rms;
            
            % get the current waveform parameters
            operating.waveform = self.waveform_model_obj.get_waveform(L, I_sat, I_rms);
            
            % get the inductor field values
            operating.field = self.waveform_model_obj.get_field(J_norm, H_norm, B_norm);
        end
        
        function operating = get_thermal_init(self, operating, excitation)
            % Init the thermal model for the starting the thermal/loss iterations.
            %
            %    Parameters:
            %        operating (struct): struct with the operating point data
            %        excitation (struct): struct with the thermal excitation data
            %
            %    Returns:
            %        operating (struct): struct with the operating point data
            
            % get the ambient condition
            thermal.T_ambient = excitation.T_ambient;
            thermal.h_convection = excitation.h_convection;
            
            % the temperature is constant and is an initial guess
            thermal.T_core_max = self.data_vec.other.T_core_init;
            thermal.T_core_avg = self.data_vec.other.T_core_init;
            thermal.T_winding_max = self.data_vec.other.T_winding_init;
            thermal.T_winding_avg = self.data_vec.other.T_winding_init;
            thermal.T_iso_max = (self.data_vec.other.T_core_init+self.data_vec.other.T_winding_init)./2;
            
            % add the utilization and check the bounds
            [thermal, is_valid_thermal] = self.check_thermal_limit(thermal, true);
            
            % assign the thermal data
            operating.is_valid_thermal = is_valid_thermal;
            operating.thermal = thermal;
        end
        
        function operating = get_thermal(self, operating)
            % Run the thermal model with given losses.
            %
            %    Get the thermal results from the ANN/regression object.
            %    Parse and check the results.
            %
            %    Parameters:
            %        operating (struct): struct with the operating point data
            %
            %    Returns:
            %        operating (struct): struct with the operating point data
            
            % get the ambient condition and the losses
            T_ambient = operating.thermal.T_ambient;
            h_convection = operating.thermal.h_convection;
            P_core = operating.losses.P_core;
            P_winding = operating.losses.P_winding;
            
            % get the thermal simulation results from the ANN/regression object
            excitation_tmp = struct('h_convection', h_convection, 'P_winding', P_winding, 'P_core', P_core, 'T_ambient', T_ambient);
            [is_valid_thermal, fom_tmp] = self.ann_fem_obj.get_ht(excitation_tmp);
            
            % assign the absolute temperature values
            thermal.T_ambient = T_ambient;
            thermal.h_convection = h_convection;
            thermal.T_core_max = T_ambient+fom_tmp.dT_core_max;
            thermal.T_core_avg = T_ambient+fom_tmp.dT_core_avg;
            thermal.T_winding_max = T_ambient+fom_tmp.dT_winding_max;
            thermal.T_winding_avg = T_ambient+fom_tmp.dT_winding_avg;
            thermal.T_iso_max = T_ambient+fom_tmp.dT_iso_max;
            
            % add the utilization and check the bounds
            [thermal, is_valid_thermal] = self.check_thermal_limit(thermal, is_valid_thermal);
            
            % assign the thermal data
            operating.is_valid_thermal = is_valid_thermal;
            operating.thermal = thermal;
        end
        
        function [thermal, is_valid_thermal] = check_thermal_limit(self, thermal, is_valid_thermal)
            % Compute the thermal stress and check the validity of the temperatures.
            %
            %    Parameters:
            %        thermal (struct): struct with the thermal data
            %        is_valid_thermal (vector): if the temperatures are valid (or not)
            %
            %    Returns:
            %        thermal (struct): struct with the thermal data
            %        is_valid_thermal (vector): if the temperatures are valid (or not)
            
            % get the limits
            T_core_max = self.core_obj.get_temperature();
            T_winding_max = self.winding_obj.get_temperature();
            T_iso_max = self.iso_obj.get_temperature();
            
            % extract the differemt temperatures
            T_ambient = thermal.T_ambient;
            T_core = max(thermal.T_core_max, thermal.T_core_avg);
            T_winding = max(thermal.T_winding_max, thermal.T_winding_avg);
            T_iso = thermal.T_iso_max;
            
            % check if the limits are respected
            is_valid_core = T_core<=T_core_max;
            is_valid_winding = T_winding<=T_winding_max;
            is_valid_iso = T_iso<=T_iso_max;
            
            % assign the maximum temperature
            thermal.T_max = max([T_core ; T_winding ; T_iso], [], 1);
            
            % check the thermal utilization (temperature elevation compared to the limit)
            thermal.stress_core = (T_core-T_ambient)./(T_core_max-T_ambient);
            thermal.stress_winding = (T_winding-T_ambient)./(T_winding_max-T_ambient);
            thermal.stress_iso = (T_iso-T_ambient)./(T_iso_max-T_ambient);
            
            % assign the results
            is_valid_thermal = is_valid_thermal&is_valid_core&is_valid_winding&is_valid_iso;
        end
        
        function [T_vec, is_valid] = get_thermal_vec(self, operating)
            % Get a matrix with all the temperatures for the thermal/loss iterations.
            %
            %    Parameters:
            %        operating (struct): struct with the operating point data
            %
            %    Returns:
            %        T_vec (matrix): all the temperatures for all the designs
            %        is_valid (vector): if the temperatures are finite (or not)
            
            % temperature matrix (number of temperatures x number of samples)
            T_vec = [...
                operating.thermal.T_ambient;...
                operating.thermal.T_core_max;...
                operating.thermal.T_core_avg;...
                operating.thermal.T_winding_max;...
                operating.thermal.T_winding_avg;...
                operating.thermal.T_iso_max;...
                operating.thermal.T_max;...
                ];
            
            % validity, do not check bounds just that is numbers exist
            is_valid = all(isfinite(T_vec), 1);
        end
        
        function operating = get_losses(self, operating)
            % Run the loss model with given temperatures.
            %
            %    Core losses with the core data manager.
            %    Winding losses with the winding data manager.
            %
            %    Parameters:
            %        operating (struct): struct with the operating point data
            %
            %    Returns:
            %        operating (struct): struct with the operating point data
            
            % get inductor field parameters
            B_norm = self.fom.circuit.B_norm;
            J_norm = self.fom.circuit.J_norm;
            H_norm = self.fom.circuit.H_norm;
            
            % get the applied temperatures
            T_core_avg = operating.thermal.T_core_avg;
            T_winding_avg = operating.thermal.T_winding_avg;
            
            % get the stress applied to the core (time domain)
            [t_vec, B_time_vec, B_loop_vec, B_dc] = self.waveform_model_obj.get_core(B_norm);
            
            % compute the core losses
            [is_valid_core, P_core] = self.core_obj.get_losses(t_vec, B_time_vec, B_loop_vec, B_dc, T_core_avg);
            
            % get the stress applied to the winding (Fourier harmonics)
            [f_vec, J_freq_vec, H_freq_vec, J_dc] = self.waveform_model_obj.get_winding(J_norm, H_norm);
            
            % compute the winding losses
            [is_valid_winding, P_winding, P_dc, P_ac_lf, P_ac_hf] = self.winding_obj.get_losses(f_vec, J_freq_vec, H_freq_vec, J_dc, T_winding_avg);
            
            % get the total losses (scaling and offset)
            P_scale = self.data_vec.fom_data.P_scale;
            P_offset = self.data_vec.fom_data.P_offset;
            P_add = P_offset+(1-P_scale).*(P_core+P_winding);
            P_tot = P_add+P_core+P_winding;
            
            % assign the losses
            operating.losses.P_core = P_core;
            operating.losses.P_winding = P_winding;
            operating.losses.P_winding_dc = P_dc;
            operating.losses.P_winding_ac_lf = P_ac_lf;
            operating.losses.P_winding_ac_hf = P_ac_hf;
            operating.losses.P_add = P_add;
            operating.losses.P_tot = P_tot;
            
            % assign relative figures of merits (ratios)
            operating.losses.core_losses = P_core./P_tot;
            operating.losses.winding_losses = P_winding./P_tot;
            operating.losses.add_losses = P_add./P_tot;
            operating.losses.winding_hf_res = (P_ac_lf+P_ac_hf)./P_ac_lf;
            
            % assign validity
            operating.is_valid_core = is_valid_core;
            operating.is_valid_winding = is_valid_winding;
        end
        
        function [P_vec, is_valid] = get_losses_vec(self, operating)
            % Get a matrix with all the losses for the thermal/loss iterations.
            %
            %    Parameters:
            %        operating (struct): struct with the operating point data
            %
            %    Returns:
            %        P_vec (matrix): all the losses for all the designs
            %        is_valid (vector): if the losses are finite (or not)
            
            % loss matrix (number of losses x number of samples)
            P_vec = [...
                operating.losses.P_core;...
                operating.losses.P_winding;...
                operating.losses.P_add;...
                operating.losses.P_tot;...
                ];
            
            % validity, do not check bounds just that is numbers exist
            is_valid = all(isfinite(P_vec), 1);
        end
    end
end