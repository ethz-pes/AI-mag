function excitation = get_design_excitation(L, f, load)
% Function for getting a specific operating point.
%
%    Parameters:
%        L (float): inductance value
%        f (float): operating frequency
%        load (float): operating point load (relative to full load)
%
%    Returns:
%        excitation (struct): struct containing the operating point
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% thermal parameters
%    - h_convection: convection coefficient reference value
%    - T_ambient: ambient temperature
excitation.thermal.h_convection = 20.0;
excitation.thermal.T_ambient = 40.0;

% current excitation parameters
%    - f: operating frequency
%    - I_dc: DC current
%    - I_peak_peak: peak to peak current
%    - d_c: duty cycle (only for triangular waveform, not for sinus)
%    - type_id: id of the waveform shape ('sin' or 'tri')
excitation.waveform.f = f;
excitation.waveform.I_dc = load.*10.0;
excitation.waveform.I_peak_peak = 200./(2.*f.*L);
excitation.waveform.d_c = 0.5;
excitation.waveform.type_id = get_map_str_to_int('tri');

end
