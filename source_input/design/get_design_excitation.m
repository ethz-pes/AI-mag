function excitation = get_design_excitation(L, T_ambient, f, load, type)
% Function for getting a specific operating point.
%
%    Parameters:
%        L (float): inductance value
%        T_ambient (float): ambient temperature
%        f (float): operating frequency
%        load (float): operating point load (relative to full load)
%        type (float): waveform type ('sinus' or 'pwm')
%
%    Returns:
%        excitation (struct): struct containing the operating point
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% excitation data
%    - f: operating frequency
%    - T_ambient: ambient temperature
%    - I_dc: DC current
%    - I_ac_peak: AC peak current
%    - is_pwm: is the waveform are sinus or PWM (triangular)
%    - d_c: duty cycle
excitation.f = f;
excitation.T_ambient = T_ambient;
excitation.I_dc = load.*10.0;
excitation.I_ac_peak = 200./(4.*f.*L);
switch type
    case 'sinus'
        excitation.is_pwm = false;
        excitation.d_c = NaN;
    case 'pwm'
        excitation.is_pwm = true;
        excitation.d_c = 0.5;
    otherwise
        error('invalid type')
end

end
