# (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

import numpy as np


def train(inp, out, fct_model, fct_train):
    """Create and train an ANN with Keras/TensorFlow.

    Parameters:
    inp (matrix): Matrix with the input data
    out (matrix): Matrix with the output data
    fct_model (fct): Function for creating the ANN
    fct_train (fct): Function for training the ANN

    Returns:
    model: Keras/TensorFlow model (trained)
    history: Keras/TensorFlow training history

   """

    # get the size of the samples
    n_inp = inp.shape[0]
    n_out = out.shape[0]
    n_sol_inp = inp.shape[1]
    n_sol_out = out.shape[1]

    # check and get the number of samples
    assert n_sol_inp==n_sol_out, 'invalid number of samples'
    n_sol = {n_sol_inp, n_sol_out}.pop()

    # get ANN model
    assert n_sol>0, 'invalid number of samples'
    assert n_inp>0, 'invalid number of inputs'
    assert n_out>0, 'invalid number of outputs'
    model = fct_model(n_sol, n_inp, n_out)

    #  transpose data due to Keras/TensorFlow format
    inp = np.swapaxes(inp, 0, 1)
    out = np.swapaxes(out, 0, 1)

    # train the ANN
    (model, history) = fct_train(model, inp, out)

    return (model, history)


def predict(model, inp):
    """Evaluate an ANN with Keras/TensorFlow.

    Parameters:
    model (model): Keras/TensorFlow model (trained)
    inp (matrix): Matrix with the input data

    Returns:
    matrix: Matrix with the output data

   """

    #  transpose data due to Keras/TensorFlow format
    inp = np.swapaxes(inp, 0, 1)

    # evaluate the model
    out = model.predict(inp)

    #  transpose data back to the original format
    out = np.swapaxes(out, 0, 1)
    inp = np.swapaxes(inp, 0, 1)

    # check the number of samples
    assert inp.shape[1] == out.shape[1], 'invalid number of samples'

    return out
