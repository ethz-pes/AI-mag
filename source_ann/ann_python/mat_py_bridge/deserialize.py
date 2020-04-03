import numpy as np
import struct

def get(byte):
    assert isinstance(byte, bytearray), 'invalid byte'

    (byte, byte_tmp) = get_byte(byte, 1)
    cls = class_decode(byte_tmp)
    assert cls=='dict', 'invalid type'

    (data, byte) = deserialize_struct(byte)
    assert len(byte)==0, 'invalid byte'

    return data

def deserialize_struct(byte):
    [byte, byte_tmp] = get_byte(byte, 4)
    n_field = struct.unpack('I', byte_tmp)[0]

    data = {}
    for i in range(n_field):
        (v_field, byte) = deserialize_data(byte)
        (v_value, byte) = deserialize_data(byte)
        data[v_field] = v_value

    return (data, byte)

def deserialize_data(byte):
    (byte, byte_tmp) = get_byte(byte, 1)
    cls = class_decode(byte_tmp)

    if cls=='str':
        (data, byte) = deserialize_char(byte, cls)
    else:
        (data, byte) = deserialize_matrix(byte, cls)

    return (data, byte)

def deserialize_char(byte, cls):
    [byte, byte_tmp] = get_byte(byte, 4)
    n_length = struct.unpack('I', byte_tmp)[0]

    n_byte = class_size(cls)
    [byte, byte_tmp] = get_byte(byte, n_length*n_byte)
    data = byte_tmp.decode('utf-8')

    return (data, byte)

def deserialize_matrix(byte, cls):
    [byte, byte_tmp] = get_byte(byte, 4)
    n_dim = struct.unpack('I', byte_tmp)[0]

    [byte, byte_tmp] = get_byte(byte, n_dim*4)
    size_vec = struct.unpack('%sI' % n_dim, byte_tmp)

    n_byte = class_size(cls)
    n_elem = np.prod(size_vec)
    [byte, byte_tmp] = get_byte(byte, n_elem*n_byte)

    data = np.frombuffer(byte_tmp, dtype=cls)
    data = np.reshape(data, size_vec, order='F')

    return (data, byte)

def class_size(cls):
    if cls in ['float64', 'int64', 'uint64']:
        n_byte = 8
    elif cls in ['float32', 'int32', 'uint32']:
        n_byte = 4
    elif cls in ['bool', 'str', 'int8', 'uint8']:
        n_byte = 1
    else:
        raise TypeError('invalid type')

    return n_byte



def class_decode(b):
    if b == b'\x00':
        cls = 'float64'
    elif b == b'\x01':
        cls = 'float32'
    elif b == b'\x02':
        cls = 'bool'
    elif b == b'\x03':
        cls = 'str'
    elif b == b'\x04':
        cls = 'int8'
    elif b == b'\x05':
        cls = 'uint8'
    elif b == b'\x08':
        cls = 'int32'
    elif b == b'\x09':
        cls = 'uint32'
    elif b == b'\x0a':
        cls = 'int64'
    elif b == b'\x0b':
        cls = 'uint64'
    elif b == b'\x0c':
        cls = 'dict'
    else:
        raise TypeError('invalid type')

    return cls

def get_byte(byte, n):
    byte_tmp = byte[0:n]
    byte = byte[n:]
    return (byte, byte_tmp)
