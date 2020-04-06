# (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

import socket
import struct
from abc import ABC, abstractmethod
from threading import Thread
from . import deserialize
from . import serialize


class PythonMatlabConnection(Thread):
    """Python thread managing a specific TCP/IP connection for communicating with MATLAB.

    Read the requests and deserialize them.
    Handle the request with  "server.HandlerAbstract".
    Serialize the reponses and send them.

    Warning: The request read and response write do not feature a robust format.
             Each "packet" has the number of bytes_array contained as the beginning.
             No checksum, escaping, or anything fancy are done.

    The different connections are manager by "server.PythonMatlabServer".

   """

    def __init__(self, connection, client_address, handler_obj):
        """Constructor.

        Parameters:
        hostname (str): Server hostname
        port (int): Server port
        n_connection (int): Number of connection to accept
        handler_class (fct): Function for creating a "server.HandlerAbtract" instance

       """

        # init thread
        super().__init__()

        # assign data
        self.connection = connection
        self.client_address = client_address
        self.handler_obj = handler_obj

    def run(self):
        """Run method of the thread.

        Handle the different request.
        Close the connection and quit when disconnected.

       """

        try:
            print('[SERVER] connected: %s / %d' % self.client_address)
            self.__loop()
        finally:
            print('[SERVER] disconnected: %s / %d' % self.client_address)
            self.connection.close()

    def __loop(self):
        """Main thread loop, handle the requests.

          Read the request, handle the requests, send the responses.
          Quit when disconnected.

         """

        while True:
            try:
                data = self.__receive()
                print('[SERVER] run data: %s / %d' % self.client_address)
                data = self.handler_obj.run_data(data)
                self.__send(data)
            except socket.error:
                break

    def __receive(self):
        """Receive a request from the client.

        This command is blocking until a request is there.
        The first 4 bytes_array contains the number of bytes_array of the data.
        Then get all the bytes_array and deserialize.

        Returns:
        dict: Dict containing the request

       """

        # get the number of bytes_array
        bytes_array = self.__recv_size(4)
        n = struct.unpack('I', bytes_array)[0]

        # get all the bytes_array and deserialize
        bytes_array = self.__recv_size(n)
        data = deserialize.get(bytes_array)

        return data

    def __recv_size(self, size):
        """Read a specified number of bytes from the client.

        This command is blocking the specified number of bytes arrived.
        Raise an error if disconnected.

        Parameters:
        size (int): Number of byte to read (not more)

        Returns:
        bytes: Read bytes

       """

        bytes_array = bytearray()
        while True:
            size_remain = size-len(bytes_array)
            bytes_tmp = self.connection.recv(size_remain)
            if len(bytes_tmp)==0:
                raise socket.error('connection error')

            bytes_array += bytearray(bytes_tmp)
            if len(bytes_array)==size:
                return bytes_array

    def __send(self, data):
        """Send a response to the client.

        First, serialize the data.
        The first 4 bytes_array contains the number of bytes_array of the data.
        Then write the all the bytes_array.

        Parameters:
        data (dict): Dict containing the response

       """

        # serialize the data
        bytes_array = serialize.get(data)

        # get the number of bytes_array
        n = len(bytes_array)
        n = struct.pack('I', n)

        # send the header and data
        self.connection.sendall(n)
        self.connection.sendall(bytes_array)


class HandlerAbstract(ABC):
    """Abstract class definition for a server request handler.

    The class is called by "server.PythonMatlabConnection".
    This abstract class guarantee that the right methods are defined.

   """

    def __init__(self):
        """Constructor."""

        super().__init__()

    @abstractmethod
    def run_data(self, handler_data):
        """Run a client request and get the response.

        Parameters:
        handler_data (dict): Dict containing the request

        Returns:
        dict: Request response

       """

        pass


class PythonMatlabServer():
    """Python TCP/IP server for communicating with MATLAB.

    TCP/IP server, request can be customized with the abstract class "server.HandlerAbstract".
    The server accept multiple connection with the threads "server.PythonMatlabConnection".

   """

    def __init__(self, hostname, port, n_connection, handler_class):
        """Constructor.

        Parameters:
        hostname (str): Server hostname
        port (int): Server port
        n_connection (int): Number of connection to accept
        handler_class (fct): Function for creating a "server.HandlerAbtract" instance

       """

        self.hostname = hostname
        self.port = port
        self.n_connection = n_connection
        self.handler_class = handler_class

    def start_server(self):
        """Start the TCP/IP server.

        Start the server and listen.
        For every new connection, create a new thread.

       """

        # create the socket
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.bind((self.hostname, self.port))
        sock.listen(self.n_connection)
        print('[SERVER] waiting for connections')

        # for each connection, create and start a thread
        while True:
            (connection, client_address) = sock.accept()
            handler_obj = self.handler_class()
            thread_obj = PythonMatlabConnection(connection, client_address, handler_obj)
            thread_obj.start()
