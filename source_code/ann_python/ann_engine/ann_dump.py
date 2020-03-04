import tensorflow.keras as keras
import numpy as np
import tempfile
import pickle
import os

def dump_keras_model(model):
    tf = tempfile.NamedTemporaryFile(delete=False)

    try:
        keras.models.save_model(model, tf.name, save_format='h5')
        byte = tf.read()
        tf.close()
        data = np.frombuffer(byte, dtype='uint8')
    finally:
        os.remove(tf.name)

    return data

def undump_keras_model(data):
    tf = tempfile.NamedTemporaryFile(delete=False)

    try:
        byte = data.tobytes()
        tf.write(byte)
        tf.close()
        model = keras.models.load_model(tf.name)
    finally:
        os.remove(tf.name)

    return model

def parse_keras_history(history_inp):
    history_out = {}
    history_out["history"] = history_inp.history
    history_out["params"] = history_inp.params
    history_out["epoch"] = history_inp.epoch

    return history_out

def dump_keras_history(history):
    byte = pickle.dumps(history)
    data = np.frombuffer(byte, dtype='uint8')

    return data

def undump_keras_history(data):
    byte = data.tobytes()
    history = pickle.loads(byte)

    return history
