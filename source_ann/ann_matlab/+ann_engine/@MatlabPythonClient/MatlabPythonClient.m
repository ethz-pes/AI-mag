classdef MatlabPythonClient < handle
    % MATLAB TCP/IP client for communicating with Python.
    %
    %    Connect to a Python TCP/IP server.
    %    Send request and get response from the server.
    
    %% properties
    properties (SetAccess = private, GetAccess = public)
        tcp % tcpclient: contain the connection to the server
    end
    
    %% public
    methods (Access = public)
        function self = MatlabPythonClient(hostname, port, timeout)
            % Constructor.
            %
            %    Check if the server if available.
            %    Connect to the server.
            %
            %    Parameters:
            %        hostname (str): hostname of the Python server
            %        port (int): port of the Python server
            %        timeout (int): timeout for Python server requests
            
            try
                self.tcp = tcpclient(hostname, port, 'Timeout', timeout);
            catch
                error('Connection failure: Python server : %s / %d', hostname, port)
            end
        end
        
        function data_out = run(self, data_inp)
            % Make a request and get a response from the server (blocking).
            %
            %    Parameters:
            %        data_inp (struct): request to be send
            %
            %    Returns:
            %        data_out (struct): response of the server
            
            self.send(data_inp);
            data_out = self.receive();
        end
    end
    
    %% private
    methods (Access = private)
        function send(self, data)
            % Send a request to the server.
            %
            %    Parameters:
            %        data (struct): request to be send
            
            % serialize the data
            byte = self.get_serialize(data);
            
            % get the length of the data
            n = length(byte);
            n = typecast(uint32(n), 'uint8');
            
            % send the header and the data
            self.tcp.write(n)
            self.tcp.write(byte)
        end
        
        function data = receive(self)
            % Wait for a response from the server (blocking).
            %
            %    Returns:
            %        data_out (struct): response of the server
            
            % get the length of the server
            n = self.tcp.read(4);
            n = typecast(n, 'uint32');
            
            % wait for all the response
            byte = self.tcp.read(n);
            
            % deserialize the data
            data = self.get_deserialize(byte);
        end
    end
    
    %% static / external
    methods(Static, Access = private)
        byte = get_serialize(data)
        data = get_deserialize(byte)
    end
end
