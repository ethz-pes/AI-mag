function circuit = get_design_circuit(f, L, load)
% Function for getting the stress applied to the inductor.
%
%    Parameters:
%        f (float): operating frequency
%        L (float): inductance value
%        load (float): operating point load (relative to full load)
%
%    Returns:
%        circuit (struct): struct with the stress applied to the inductor by the circuit
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% DC current (current imposed)
I_dc = 10.0;

% PWM voltage (voltage imposed)
V_pwm = 200.0;

% PWM voltage duty cycle
d_c = 0.5;

% max ripple
ripple_max = 3.0;

% safety factor for saturation and RMS currents
factor_current = 1.1;

% get the stress of the component (minimum values)
circuit.I_test = factor_current.*I_dc;
circuit.I_sat_min = factor_current.*I_dc;
circuit.I_rms_min = factor_current.*I_dc;
circuit.V_t_sat_sat_min = (d_c.*V_pwm)./f;
circuit.L_min = (d_c.*V_pwm)./(f.*I_dc.*ripple_max);

% get the stress of the component (actual stress)
circuit.I_dc = load.*I_dc;
circuit.I_peak_peak = (d_c.*V_pwm)./(f.*L);
circuit.d_c = d_c;
circuit.f = f;

end