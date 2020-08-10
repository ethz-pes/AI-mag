function excitation = get_design_excitation(f, L, load)
% Function for getting a specific operating point.
%
%    Parameters:
%        f (float): operating frequency
%        L (float): inductance value
%        load (float): operating point load (relative to full load)
%
%    Returns:
%        excitation (struct): struct containing the operating point
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% get circuit data (inductance and load are known at this stage)
circuit = get_design_circuit(f, L, load);

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
excitation.waveform.f = circuit.f;
excitation.waveform.I_dc = circuit.I_dc;
excitation.waveform.I_peak_peak = circuit.I_peak_peak;
excitation.waveform.d_c = circuit.d_c;
excitation.waveform.type_id = get_map_str_to_int('tri');

end
