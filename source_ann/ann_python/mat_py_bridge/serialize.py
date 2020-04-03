import numpy as np
import struct

def get(data):
    assert isinstance(data, dict), 'invalid data'
    byte = serialize_struct(data)
    return byte

def serialize_struct(data):
    byte = bytearray()

    # byte type
    byte_add = class_encode(data)
    byte = append_byte(byte, byte_add)

    # number of fields
    byte_add = len(data)
    byte_add = struct.pack('I', byte_add)
    byte = append_byte(byte, byte_add)

    # add field and byte
    for field in data:
        byte_add = serialize_data(field)
        byte = append_byte(byte, byte_add)

        byte_add = serialize_data(data[field])
        byte = append_byte(byte, byte_add)

    return byte

def serialize_data(data):
    byte = bytearray()

    # byte type
    byte_add = class_encode(data)
    byte = append_byte(byte, byte_add)

    if isinstance(data, str):
        byte = serialize_char(byte, data)
    else:
        byte = serialize_matrix(byte, data)

    return byte


def serialize_char(byte, data):
    n_length = len(data)

    byte_add = struct.pack('I', n_length)
    byte = append_byte(byte, byte_add)

    byte_add = bytes(data, 'utf-8')
    byte = append_byte(byte, byte_add)

    return byte

def serialize_matrix(byte, data):
    size_vec = data.shape

    byte_add = struct.pack('I', len(size_vec))
    byte = append_byte(byte, byte_add)

    byte_add = struct.pack('%sI' % len(size_vec), *size_vec)
    byte = append_byte(byte, byte_add)

    byte_add = data.tobytes(order='F')
    byte = append_byte(byte, byte_add)

    return byte

def class_encode(data):
    if isinstance(data, dict):
        b = b'\x0c'
    elif isinstance(data, str):
            b = b'\x03'
    elif isinstance(data, np.ndarray):
        if data.dtype=='float64':
            b = b'\x00'
        elif data.dtype=='float32':
            b = b'\x01'
        elif data.dtype=='bool':
            b = b'\x02'
        elif data.dtype=='int8':
            b = b'\x04'
        elif data.dtype=='uint8':
            b = b'\x05'
        elif data.dtype=='int32':
            b = b'\x08'
        elif data.dtype=='uint32':
            b = b'\x09'
        elif data.dtype=='int64':
            b = b'\x0a'
        elif data.dtype=='uint64':
            b = b'\x0b'
        else:
            raise TypeError('invalid type')
    else:
        raise TypeError('invalid type')
    return b

def append_byte(byte, byte_add):
    byte += byte_add
    return byte