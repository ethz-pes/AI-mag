import tensorflow.keras as keras
import numpy as np
import tempfile
import pickle
import os


def dump_keras_model(model):
    """Serialize a Keras/TensorFlow model.

    This is quite a hack: write the model as a h5 file, read it, delete the file.
    Warning: Keras/TensorFlow model is code, serialization is unsafe if you cannot trust the data.

    Parameters:
    model (model): Keras/TensorFlow model

    Returns:
    bytes: Keras/TensorFlow model (serialized)

   """

    # get a file name, from some reason delete=True is not possible with Keras
    tf = tempfile.NamedTemporaryFile(delete=False)

    # save the file, read it, delete the file, cast to numpy array
    try:
        keras.models.save_model(model, tf.name, save_format='h5')
        byte = tf.read()
        tf.close()
        data = np.frombuffer(byte, dtype='uint8')
    finally:
        os.remove(tf.name)

    return data


def undump_keras_model(data):
    """Deserialize a Keras/TensorFlow model.

    This is quite a hack: write the data to a file, load it, delete the file.
    Warning: Keras/TensorFlow model is code, deserialization is unsafe if you cannot trust the data.

    Parameters:
    data (bytes): Keras/TensorFlow model (serialized)

    Returns:
    model: Keras/TensorFlow model

   """

    # get a file name, from some reason delete=True is not possible with Keras
    tf = tempfile.NamedTemporaryFile(delete=False)

    # caste the numpy array to bytes, write the file, load the model, remove the file
    try:
        byte = data.tobytes()
        tf.write(byte)
        tf.close()
        model = keras.models.load_model(tf.name)
    finally:
        os.remove(tf.name)

    return model


def parse_keras_history(history_inp):
    """Convert a Keras/TensorFlow history to a dict.

    Keras/TensorFlow history are incompatible with pickle.
    Keep the data (dict), remove everything else to make it pickable.

    Parameters:
    history_inp (history): Keras/TensorFlow training history

    Returns:
    dict: Keras/TensorFlow training history

   """

    history_out = {}
    history_out['history'] = history_inp.history
    history_out['params'] = history_inp.params
    history_out['epoch'] = history_inp.epoch

    return history_out


def dump_keras_history(history):
    """Serialize a Keras/TensorFlow training history with pickle.

    Parameters:
    history (dict): Keras/TensorFlow training history

    Returns:
    bytes: Keras/TensorFlow training history (serialized)

   """

    byte = pickle.dumps(history)
    data = np.frombuffer(byte, dtype='uint8')

    return data


def undump_keras_history(data):
    """Deserialize a Keras/TensorFlow training history with pickle.

    Parameters:
    data (bytes): Keras/TensorFlow training history  (serialized)

    Returns:
    dict: Keras/TensorFlow training history

   """

    byte = data.tobytes()
    history = pickle.loads(byte)

    return history
