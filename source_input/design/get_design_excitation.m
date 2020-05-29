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

% excitation data
%    - f: operating frequency
%    - T_ambient: ambient temperature
%    - I_dc: DC current
%    - I_ac_peak: AC peak current
%    - type_id: id of the waveform shape ('sin' or 'tri')
%    - d_c: duty cycle
excitation.type_id = get_map_str_to_int('tri');
excitation.f = f;
excitation.T_ambient = 40.0;
excitation.I_dc = load.*10.0;
excitation.I_ac_peak = 200./(4.*f.*L);
excitation.d_c = 0.5;

end
