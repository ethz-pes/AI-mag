classdef WaveformModel < handle
    % Class for generating AC waveforms for the operating points.
    %
    %    Generate the following parameters:
    %        - factor between peak and RMS
    %        - harmonics for the winding losses
    %        - time domain for the core losses
    %
    %    The code is completely vectorized.
    %    All the generated waveforms should not feature DC components.
    %    DC components are added separetely.
    %
    %    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod
    
    %% properties
    properties (SetAccess = private, GetAccess = public)
        signal % struct: contains the control parameters
        is_set % logical: if the waveform has been set (or not)
        param % struct: waveform parameters (RMS, peak, dc, etc.)
        time % struct: time domain waveform (without DC)
        freq % struct: frequency domain waveform (without DC)
    end
    
    %% public
    methods (Access = public)
        function self = WaveformModel(signal)
            % Constructor.
            %
            %    Parameters:
            %        signal (struct): contains the control parameters
            
            % assign data
            self.signal = signal;
            
            % init, no waveform
            self.param = struct();
            self.time = struct();
            self.freq = struct();
            
            % set the flag, no waveform is set
            self.is_set = false;
        end
        
        function set_excitation(self, excitation)
            % find the type
            type_id = unique(excitation.type_id);
            assert(length(type_id)==1, 'invalid waveform type')
            
            % set the waveform
            switch type_id
                case get_map_str_to_int('tri')
                    f = excitation.f;
                    d_c = excitation.d_c;
                    I_dc = excitation.I_dc;
                    I_peak_peak = excitation.I_peak_peak;
                    
                    self.param = self.get_param_tri(f, I_dc, I_peak_peak);
                    self.freq = self.get_freq_tri(f, d_c, I_peak_peak);
                    self.time = self.get_time_tri(f, d_c, I_peak_peak);
                case get_map_str_to_int('sin')
                    f = excitation.f;
                    I_dc = excitation.I_dc;
                    I_peak_peak = excitation.I_peak_peak;
                    
                    self.param = self.get_param_sin(f, I_dc, I_peak_peak);
                    self.freq = self.get_freq_sin(f, I_peak_peak);
                    self.time = self.get_time_sin(f, I_peak_peak);
                otherwise
                    error('invalid waveform type')
            end
            
            % set the flag, wave is set
            self.is_set = true;
        end
        
        function waveform = get_waveform(self, I_sat, I_rms)
            % copy basic parameters
            waveform.f = self.param.f;
            waveform.I_dc = self.param.I_dc;
            waveform.I_peak_peak = self.param.I_peak_peak;
            waveform.I_ac_rms = self.param.I_ac_rms;
            waveform.I_all_peak = self.param.I_all_peak;
            waveform.I_all_rms = self.param.I_all_rms;
            
            % compute utilization factor
            waveform.r_peak_peak = self.param.I_peak_peak./self.param.I_dc;
            waveform.fact_sat = self.param.I_all_peak./I_sat;
            waveform.fact_rms = self.param.I_all_rms./I_rms;
        end
        
        function field = get_field(self, J_norm, H_norm, B_norm)
            % compute the different DC field values
            field.J_dc = J_norm.*self.param.I_dc;
            field.B_dc = B_norm.*self.param.I_dc;
            field.H_dc = H_norm.*self.param.I_dc;
            
            % compute the different AC field values
            field.J_ac_rms = J_norm.*self.param.I_ac_rms;
            field.H_ac_rms = H_norm.*self.param.I_ac_rms;
            field.B_peak_peak = B_norm.*self.param.I_peak_peak;
        end
        
        function [t_vec, B_time_vec, B_loop_vec, B_dc] = get_core(self, B_norm)
            % expand the vector into a matrix
            B_norm = repmat(B_norm, [self.signal.n_time 1]);
            
            % compute the applied core excitation in time domain
            t_vec = self.time.t_vec;            
            B_time_vec = self.time.I_time_vec.*B_norm;
            B_loop_vec = self.time.I_loop_vec.*B_norm;
            B_dc = self.param.I_dc.*B_norm;
        end
        
        function [f_vec, J_freq_vec, H_freq_vec, J_dc] = get_winding(self, J_norm, H_norm)
            % expand the vector into a matrix
            J_norm = repmat(J_norm, [self.signal.n_freq 1]);
            H_norm = repmat(H_norm, [self.signal.n_freq 1]);

            % compute the applied winding excitation in frequency domain
            f_vec = self.freq.f_vec;
            J_freq_vec = self.freq.I_freq_vec.*J_norm;
            H_freq_vec = self.freq.I_freq_vec.*H_norm;
            J_dc = self.param.I_dc.*J_norm;
        end
    end
    
    %% private
    methods (Access = private)
        function param = get_param_tri(self, f, I_dc, I_peak_peak)
            % compute param
            I_ac_rms = I_peak_peak./(2.*sqrt(3));
            I_all_peak = I_dc+(I_peak_peak./2);
            I_all_rms = hypot(I_dc, I_ac_rms);
            
            % assign param
            param.f = f;
            param.I_dc = I_dc;
            param.I_peak_peak = I_peak_peak;
            param.I_ac_rms = I_ac_rms;
            param.I_all_peak = I_all_peak;
            param.I_all_rms = I_all_rms;
        end
        
        function param = get_param_sin(self, f, I_dc, I_peak_peak)
            % compute param
            I_ac_rms = I_peak_peak./(2.*sqrt(2));
            I_all_peak = I_dc+(I_peak_peak./2);
            I_all_rms = hypot(I_dc, I_ac_rms);
            
            % assign param
            param.f = f;
            param.I_dc = I_dc;
            param.I_peak_peak = I_peak_peak;
            param.I_ac_rms = I_ac_rms;
            param.I_all_peak = I_all_peak;
            param.I_all_rms = I_all_rms;
        end
        
        function freq = get_freq_tri(self, f, d_c, I_peak_peak)
            % get the frequency vector
            [n_vec, f_vec] = self.get_frequency(f);
            
            % reciprocal of the duty cycle matrix
            d_c_vec = repmat(1./d_c, [self.signal.n_freq 1]);
            
            % cofficient (Fourier series)
            I_freq_vec = abs((2.*(-1).^n_vec.*d_c_vec.^2)./(n_vec.^2.*(d_c_vec-1).*pi.^2).*sin((n_vec.*(d_c_vec-1).*pi)./d_c_vec));
            
            % scale the values
            I_freq_vec = I_freq_vec.*(I_peak_peak./2);
            
            % assign freq
            freq.f_vec = f_vec;
            freq.I_freq_vec = I_freq_vec;
        end
        
        function freq = get_freq_sin(self, f, I_peak_peak)
            % get the frequency vector
            [n_vec, f_vec] = self.get_frequency(f);
            
            % cofficient (Fourier series)
            I_freq_vec = NaN(size(n_vec));
            I_freq_vec(n_vec==1) = 1;
            I_freq_vec(n_vec~=1) = 0;
            
            % scale the values
            I_freq_vec = I_freq_vec.*(I_peak_peak./2);
            
            % assign freq
            freq.f_vec = f_vec;
            freq.I_freq_vec = I_freq_vec;
        end
        
        function time = get_time_tri(self, f, d_c, I_peak_peak)
            % get the time vector
            [d_vec, t_vec] = self.get_time(f);
            
            % the duty cycle matrix
            d_c_vec = repmat(d_c, [self.signal.n_time 1]);
                        
            % compute the rise and fall parts
            I_rise_vec = -1+2.*d_vec./d_c_vec;
            I_fall_vec = +1-2.*(d_vec-d_c_vec)./(1-d_c_vec);
            
            % get the indices
            idx_rise = d_vec<=d_c_vec;
            idx_fall = d_vec>=d_c_vec;
            
            % assign the values
            I_time_vec = NaN(size(d_vec));
            I_loop_vec = 2.*ones(size(d_vec));
            I_time_vec(idx_rise) = I_rise_vec(idx_rise);
            I_time_vec(idx_fall) = I_fall_vec(idx_fall);
            
            % scale the values
            I_time_vec = I_time_vec.*(I_peak_peak./2);
            I_loop_vec = I_loop_vec.*(I_peak_peak./2);

            % assign freq
            time.t_vec = t_vec;
            time.I_time_vec = I_time_vec;
            time.I_loop_vec = I_loop_vec;
        end
        
        function time = get_time_sin(self, f, I_peak_peak)
            % get the time vector
            [d_vec, t_vec] = self.get_time(f);
                                    
            % assign the values
            I_time_vec = sin(2.*pi.*n_vec);
            I_loop_vec = 2.*ones(size(d_vec));
            
            % scale the values
            I_time_vec = I_time_vec.*(I_peak_peak./2);
            I_loop_vec = I_loop_vec.*(I_peak_peak./2);

            % assign freq
            time.t_vec = t_vec;
            time.I_time_vec = I_time_vec;
            time.I_loop_vec = I_loop_vec;
        end
        
        function [n_vec, f_vec] = get_frequency(self, f)
            % harmonics (normalized)
            n = 1:self.signal.n_freq;
            
            % span the matrix
            [n_vec, f_vec] = ndgrid(n, f);
            
            % scale the frequency vector
            f_vec = n_vec.*f_vec;
        end
        
        function [d_vec, t_vec] = get_time(self, f)
            % time (normalized)
            d = linspace(0, 1, self.signal.n_time);
            
            % span the matrix
            [d_vec, f_vec] = ndgrid(d, f);
            
            % scale the frequency vector
            t_vec = d_vec./f_vec;
        end
    end
end