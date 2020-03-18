classdef MatlabPythonClient < handle
    %% properties
    properties (SetAccess = immutable, GetAccess = private)
        hostname
        port
        timeout
    end
    properties (SetAccess = private, GetAccess = private)
        tcp
    end
    
    %% init
    methods (Access = public)
        function self = MatlabPythonClient(hostname, port, timeout)
            self.hostname = hostname;
            self.port = port;
            self.timeout = timeout;
            self.tcp = tcpclient(self.hostname, self.port, 'Timeout', timeout);
        end
                
        function data_out = run(self, data_inp)
            self.send(data_inp);
            data_out = self.receive();
        end
    end
    
    methods (Access = private)
        function send(self, data)
            % dump the data
            byte = self.get_serialize(data);
            
            % get the length
            n = length(byte);
            n = typecast(uint32(n), 'uint8');
            
            % send the data
            self.tcp.write(n)
            self.tcp.write(byte)
        end
        
        function data = receive(self)
            % get the length
            n = self.tcp.read(4);
            n = typecast(n, 'uint32');
            
            % load the data
            byte = self.tcp.read(n);
            data = self.get_deserialize(byte);
        end
    end
    
    methods(Static, Access = private)
        byte = get_serialize(data)
        data = get_deserialize(byte)
    end
end
