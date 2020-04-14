# (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'
import sys
sys.path.append('..')
import tensorflow.keras as keras
import ann_python.ann_server as ann_server


def fct_model(tag_train, n_sol, n_inp, n_out):
    """Function provided to ann_server.AnnHandler for ANN initialization.

    Create and return the Keras/TensorFlow model.

    Parameters:
    tag_train (various): Tag for enabling different model types
    n_sol (int): Number of samples that are available
    n_inp (int): Number of inputs
    n_out (int): Number of outputs

    Returns:
    model: Keras/TensorFlow model (created)

   """

    # check network size
    assert isinstance(n_sol, int), 'invalid sample size'
    assert isinstance(n_inp, int), 'invalid input size'
    assert isinstance(n_out, int), 'invalid ouput size'

    # check tag_train data
    assert isinstance(tag_train, dict), 'invalid tag_train'
    n_layer = int(tag_train['n_layer'])
    n_neuron = int(tag_train['n_neuron'])
    activation = tag_train['activation']
    assert isinstance(n_layer, int), 'invalid layer size'
    assert isinstance(n_neuron, int), 'invalid neuron size'
    assert isinstance(activation, str), 'invalid activation'

    # create the Keras/TensorFlow model
    model = keras.Sequential()
    if n_layer == 1:
        # one layer, input and output layers are the same
        model.add(keras.layers.Dense(n_out, input_dim=n_inp, activation='linear'))
    elif n_layer >= 2:
        # input, hidden, and output layers
        model.add(keras.layers.Dense(n_neuron, input_dim=n_inp, activation=activation))
        for i in range(n_layer - 2):
            model.add(keras.layers.Dense(n_neuron, activation=activation))
        model.add(keras.layers.Dense(units=n_out, activation='linear'))
    else:
        raise ValueError('invalid layer size')

    return model


def fct_train(tag_train, model, inp, out):
    """Function provided to ann_server.AnnHandler for ANN training.

    Compile the Keras/TensorFlow model.
    Train the model.

    Parameters:
    tag_train (various): Tag for enabling different training modes
    model (model): Keras/TensorFlow model (to be trained)
    inp (matrix): Matrix with the input data
    out (matrix): Matrix with the output data

    Returns:
    model: Keras/TensorFlow model (trained)
    history: Keras/TensorFlow training history

   """

    # tag_train is not used for this training
    assert isinstance(tag_train, dict), 'invalid tag_train'

    # compile and train
    model.compile(loss='mse', optimizer=keras.optimizers.Adam(lr=0.001), metrics=['mae', 'mse'])
    history = model.fit(
        inp, out,
        batch_size=10,
        validation_split=0.2,
        epochs=100,
        shuffle=False,
        verbose=False,
        callbacks=[keras.callbacks.EarlyStopping(monitor='val_loss', patience=10)],
    )

    return (model, history)


if __name__ == '__main__':
    """Main function, starting the ANN server for MATLAB."""

    ann_server.run('localhost', 10000, 10, fct_model, fct_train)
