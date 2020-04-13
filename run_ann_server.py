# (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'
import tensorflow.keras as keras
import source_ann.ann_python.ann_server as ann_server


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

    # network size and tag_train are not used for this model
    assert isinstance(tag_train, str), 'invalid size'
    assert isinstance(n_sol, int), 'invalid size'
    assert isinstance(n_inp, int), 'invalid size'
    assert isinstance(n_out, int), 'invalid size'

    # create the Keras/TensorFlow model
    model = keras.Sequential([
        keras.layers.Dense(64, input_dim=n_inp, activation='relu'),
        keras.layers.Dense(64, activation='relu'),
        keras.layers.Dense(64, activation='relu'),
        keras.layers.Dense(64, activation='relu'),
        keras.layers.Dense(64, activation='relu'),
        keras.layers.Dense(64, activation='relu'),
        keras.layers.Dense(64, activation='relu'),
        keras.layers.Dense(activation='linear', units=n_out),
    ])

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
    assert isinstance(tag_train, str), 'invalid size'

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


if __name__ == "__main__":
    """Main function, starting the ANN server for MATLAB."""

    ann_server.run('localhost', 10000, 10, fct_model, fct_train)
