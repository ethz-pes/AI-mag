import socket
import struct
from abc import ABC, abstractmethod
from threading import Thread
from . import deserialize
from . import serialize
import numpy as np

class PythonMatlabConnection(Thread):
    def __init__(self, connection, client_address, handler_obj):
        Thread.__init__(self)
        self.connection = connection
        self.client_address = client_address
        self.handler_obj = handler_obj

    def run(self):
        try:
            print('[SERVER] connected: %s / %d' % self.client_address)
            self.__loop()
        finally:
            print('[SERVER] disconnected: %s / %d' % self.client_address)
            self.connection.close()

    def __loop(self):
        while True:
            try:
                data = self.__receive()
                print('[SERVER] run data: %s / %d' % self.client_address)
                data = self.handler_obj.run_data(data)
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


class HandlerAbtract(ABC):
    def __init__(self):
        super().__init__()

    @abstractmethod
    def run_data(self, handler_data):
        pass


class PythonMatlabServer():
    def __init__(self, hostname, port, n_connection, handler_class):
        self.hostname = hostname
        self.port = port
        self.n_connection = n_connection
        self.handler_class = handler_class

    def start_server(self):
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.bind((self.hostname, self.port))
        sock.listen(self.n_connection)

        print('[SERVER] waiting for connections')
        while True:
            (connection, client_address) = sock.accept()
            handler_obj = self.handler_class()
            thread_obj = PythonMatlabConnection(connection, client_address, handler_obj)
            thread_obj.start()