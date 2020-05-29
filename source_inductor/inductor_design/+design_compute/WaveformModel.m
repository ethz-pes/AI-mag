classdef WaveformModel < handle
    % Class for generating the waveform for the loss computation.
    %
    %    Generate the following parameters:
    %        - factor between peak and RMS
    %        - harmonics for the winding losses
    %        - time domain for the core losses
    %
    %    The code is completely vectorized.
    %
    %    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod
    
    %% properties
    properties (SetAccess = private, GetAccess = public)
        waveform % struct: contains the control parameters
        id % struct: struct with the waveform ids
    end
    
    %% public
    methods (Access = public)
        function self = WaveformModel(waveform)
            % Constructor.
            %
            %    Parameters:
            %        waveform (struct): contains the control parameters
            
            % assign data
            self.waveform = waveform;
            
            % compute the id
            tri = get_map_str_to_int('tri');
            sin = get_map_str_to_int('sin');
            self.id = struct('tri', tri, 'sin', sin, 'all', [tri, sin]);
        end
        
        function fact_rms = get_fact_rms(self, type_id, d_c)
            % Get the factor between peak and RMS values of the waveform.
            %
            %    Parameters:
            %        type_id (vector): vector with the waveform type ids
            %        d_c (vector): vector with the waveform duty cycle
            %
            %    Returns:
            %        fact_rms (vector): factor between peak and RMS values of the waveform
            
            
            fct = @(type_id, d_c) get_fact_rms_sub(self, type_id, d_c);
            fact_rms = get_map_fct(self.id.all, type_id, fct, {d_c});
        end
        
        function [freq, value] = get_waveform_harm(self, type_id, d_c)
            % Get the harmonics of the waveform.
            %
            %    Both the frequency and the amplitude are normalized.
            %
            %    Parameters:
            %        type_id (vector): vector with the waveform type ids
            %        d_c (vector): vector with the waveform duty cycle
            %
            %    Returns:
            %        freq (matrix): frequencies (row) for the different samples (col)
            %        value (matrix): RMS harmonics (row) for the different samples (col)
            
            fct = @(type_id, d_c) get_waveform_harm_sub(self, type_id, d_c);
            [freq, value] = get_map_fct(self.id.all, type_id, fct, {d_c});
        end
        
        function [time, value] = get_waveform_time(self, type_id, d_c)
            % Get the time domain representation of the waveform.
            %
            %    Both the frequency and the amplitude are normalized.
            %
            %    Parameters:
            %        type_id (vector): vector with the waveform type ids
            %        d_c (vector): vector with the waveform duty cycle
            %
            %    Returns:
            %        time (matrix): time information (row) for the different samples (col)
            %        value (matrix): amplitude information (row) for the different samples (col)
            
            fct = @(type_id, d_c) get_waveform_time_sub(self, type_id, d_c);
            [time, value] = get_map_fct(self.id.all, type_id, fct, {d_c});
        end
    end
    
    %% private
    methods (Access = private)
        function fact_rms = get_fact_rms_sub(self, type_id, d_c)
            % Get the factor between peak and RMS values of the waveform (scalar id).
            %
            %    Parameters:
            %        type_id (scalar): vector with the waveform type id
            %        d_c (vector): vector with the waveform duty cycle
            %
            %    Returns:
            %        fact_rms (vector): factor between peak and RMS values of the waveform
            
            switch type_id
                case self.id.tri
                    fact_rms = (1./sqrt(3)).*ones(1, length(d_c));
                case self.id.sin
                    fact_rms = (1./sqrt(2)).*ones(1, length(d_c));
                otherwise
                    error('invalid waveform id')
            end
        end
        
        function [freq, value] = get_waveform_harm_sub(self, type_id, d_c)
            % Get the harmonics of the waveform (scalar id).
            %
            %    Both the frequency and the amplitude are normalized.
            %
            %    Parameters:
            %        type_id (scalar): vector with the waveform type ids
            %        d_c (vector): vector with the waveform duty cycle
            %
            %    Returns:
            %        freq (matrix): frequencies (row) for the different samples (col)
            %        value (matrix): RMS harmonics (row) for the different samples (col)
            
            % harmonic vector
            freq = 1:self.waveform.n_freq;
                        
            % initialize the matrix (frequency, reciprocal of the duty cycle)
            [freq, duty] = ndgrid(freq, 1./d_c);
            
            % compute the Fourier series coefficients
            switch type_id
                case self.id.tri
                    value = -(2.*(-1).^freq.*duty.^2)./(freq.^2.*(duty-1).*pi.^2).*sin((freq.*(duty-1).*pi)./duty);
                case self.id.sin
                    value = NaN(size(freq));
                    value(freq==1) = 1;
                    value(freq~=1) = 0;
                otherwise
                    error('invalid waveform id')
            end
            
            % transform peak to RMS coefficient
            value = value./sqrt(2);
        end
        
        function [time, value] = get_waveform_time_sub(self, type_id, d_c)
            % Get the time domain representation of the waveform (scalar id).
            %
            %    Both the frequency and the amplitude are normalized.
            %
            %    Parameters:
            %        type_id (scalar): vector with the waveform type ids
            %        d_c (vector): vector with the waveform duty cycle
            %
            %    Returns:
            %        time (matrix): time information (row) for the different samples (col)
            %        value (matrix): amplitude information (row) for the different samples (col)
            
            % time vector
            time = (0:(self.waveform.n_time-1))./self.waveform.n_time;

            % initialize the matrix (time, duty cycle)
            [time, duty] = ndgrid(time, d_c);
            
            % compute time domain values
            switch type_id
                case self.id.tri
                    % compute the rise and fall parts
                    value_rise = -1+2.*time./duty;
                    value_fall = +1-2.*(time-duty)./(1-duty);
                    
                    % assign the values
                    value = NaN(size(time));
                    value(time<=duty) = value_rise(time<=duty);
                    value(time>=duty) = value_fall(time>=duty);
                case self.id.sin
                    value = sin(2.*pi.*time);
                otherwise
                    error('invalid waveform id')
            end
        end
    end
end