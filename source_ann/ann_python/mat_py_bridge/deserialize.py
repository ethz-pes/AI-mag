import numpy as np
import struct


def get(bytes_array):
    """Deserialize data from MATLAB into a Python dict.

    This function can only deserialize very specific Python data:
        - The data has to be a dictionary
        - The keys of the dictionary should be strings
        - The values of the dictionary can be strings
        - The values of the dictionary can be numpy array:
            - Multi-dimensional arrays are supported
            - float64, float32, bool, int8, uint8, int32, uint32, int64, uint64

    The reasons of these limitation are:
        - To keep this function as simple as possible
        - The mismatch between the Pythpn data types and the MATLAB data types

    Parameters:
    bytes_array (bytes): Data to be deserialized

    Returns:
    dict: Deserialized data

   """

    # check the type
    assert isinstance(bytes_array, bytearray), 'invalid data type'

    # check that the data start with a dict
    (bytes_array, bytes_tmp) = get_byte(bytes_array, 1)
    cls = class_decode(bytes_tmp)
    assert cls=='dict', 'invalid data type'

    # deserialize data, at the end the byte array should be empty
    (data, bytes_array) = deserialize_struct(bytes_array)
    assert len(bytes_array) == 0, 'invalid data length'

    return data


def deserialize_struct(bytes_array):
    """Deserialize a Python dict.

    Parameters:
    bytes_array (bytes): Data to be deserialized

    Returns:
    dict: Deserialized data
    bytes: Remaining data to be deserialized 

   """
    
    # init
    data = {}

    # get the number of keys
    [bytes_array, bytes_tmp] = get_byte(bytes_array, 4)
    n_field = struct.unpack('I', bytes_tmp)[0]

    # decode the keys and values
    for i in range(n_field):
        (v_field, bytes_array) = deserialize_data(bytes_array)
        (v_value, bytes_array) = deserialize_data(bytes_array)
        data[v_field] = v_value

    return (data, bytes_array)


def deserialize_data(bytes_array):
    """Deserialize a Python string or a numpy array.

    Parameters:
    bytes_array (bytes): Data to be deserialized

    Returns:
    str/array: Deserialized data
    bytes: Remaining data to be deserialized 

   """
    
    # get the type
    (bytes_array, bytes_tmp) = get_byte(bytes_array, 1)
    cls = class_decode(bytes_tmp)

    # decode the data
    if cls=='str':
        (data, bytes_array) = deserialize_char(bytes_array, cls)
    else:
        (data, bytes_array) = deserialize_matrix(bytes_array, cls)

    return (data, bytes_array)


def deserialize_char(bytes_array, cls):
    """Deserialize a Python string.

    Parameters:
    bytes_array (bytes): Data to be deserialized

    Returns:
    str: Deserialized data
    bytes: Remaining data to be deserialized

   """

    # get the length
    [bytes_array, bytes_tmp] = get_byte(bytes_array, 4)
    n_length = struct.unpack('I', bytes_tmp)[0]

    # decode the data
    n_byte = class_size(cls)
    [bytes_array, bytes_tmp] = get_byte(bytes_array, n_length*n_byte)
    data = bytes_tmp.decode('utf-8')

    return (data, bytes_array)


def deserialize_matrix(bytes_array, cls):
    """Deserialize a numpy array.

    Parameters:
    bytes_array (bytes): Data to be deserialized

    Returns:
    array: Deserialized data
    bytes: Remaining data to be deserialized

   """

    # get number of dimension
    [bytes_array, bytes_tmp] = get_byte(bytes_array, 4)
    n_dim = struct.unpack('I', bytes_tmp)[0]

    # decode the number of element per dimension
    [bytes_array, bytes_tmp] = get_byte(bytes_array, n_dim*4)
    size_vec = struct.unpack('%sI' % n_dim, bytes_tmp)

    # get the data
    n_byte = class_size(cls)
    n_elem = np.prod(size_vec)
    [bytes_array, bytes_tmp] = get_byte(bytes_array, n_elem*n_byte)

    # decode the data: warning MATLAB is using FORTRAN byte order, not the C one
    data = np.frombuffer(bytes_tmp, dtype=cls)
    data = np.reshape(data, size_vec, order='F')

    return (data, bytes_array)


def class_size(cls):
    """Get the number of bytes per element for a given data type.

    Parameters:
    cls (str): Name of the data type

    Returns:
    int: Number of byte per element

   """

    if cls in ['float64', 'int64', 'uint64']:
        n_byte = 8
    elif cls in ['float32', 'int32', 'uint32']:
        n_byte = 4
    elif cls in ['bool', 'str', 'int8', 'uint8']:
        n_byte = 1
    else:
        raise TypeError('invalid data type')

    return n_byte

def class_decode(b):
    """Decode the data type from a byte.

    Parameters:
    b (byte): Byte with the encoded type

    Returns:
    str: Name of the decoded data type

   """

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
        raise TypeError('invalid data type')

    return cls


def get_byte(bytes_array, n):
    """Get a number of bytes from a byte array and remove them.

    Parameters:
    bytes_array (bytes): Byte array
    n (int): Bytes to be return and removed

    Returns:
    bytes: Resulting byte array (with n bytes less)
    bytes: Read bytes (n bytes)

   """

    assert len(bytes_array) >= n, 'invalid data length'
    bytes_tmp = bytes_array[0:n]
    bytes_array = bytes_array[n:]

    return (bytes_array, bytes_tmp)
