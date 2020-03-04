import socket
import struct
from abc import ABC, abstractmethod
from . import deserialize
from . import serialize


class PythonMatlabServer(ABC):
    def __init__(self, hostname, port):
        super().__init__()

        self.hostname = hostname
        self.port = port
        self.connection = None

    def start(self):
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.bind((self.hostname, self.port))
        sock.listen(1)

        while True:
            print('[SERVER] waiting for a connection')
            self.connection, client_address = sock.accept()
            try:
                print('    [SERVER] connected')
                self.handler_connect()
                self.__loop()
            finally:
                print('    [SERVER] disconnected')
                self.handler_disconnect()
                self.connection.close()
                self.connection = None

    def __loop(self):
        while True:
            try:
                data = self.__receive()
                print('    [SERVER] run data')
                data = self.handler_run_data(data)
                self.__send(data)
            except socket.error:
                break

    def __receive(self):
        byte = self.__recv_size(4)
        n = struct.unpack("I", byte)[0]

        byte = self.__recv_size(n)
        data = deserialize.get(byte)

        return data

    def __recv_size(self, size):
        byte = bytearray()
        while True:
            size_remain = size-len(byte)
            byte_tmp = self.connection.recv(size_remain)
            if len(byte_tmp)==0:
                raise socket.error("connection error")

            byte += bytearray(byte_tmp)
            if len(byte)==size:
                return byte

    def __send(self, data):
        byte = serialize.get(data)

        n = len(byte)
        n = struct.pack("I", n)

        self.connection.sendall(n)
        self.connection.sendall(byte)

    @abstractmethod
    def handler_connect(self):
        pass

    @abstractmethod
    def handler_disconnect(self):
        pass

    @abstractmethod
    def handler_run_data(self, data):
        pass