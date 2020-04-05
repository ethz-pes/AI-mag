# (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

import numpy as np
import tensorflow.keras as keras
from .ann_engine import ann_run
from .ann_engine import ann_dump
from .mat_py_bridge import server


class AnnHandler(server.HandlerAbstract):
    """Server handler for ANN with Keras/TensorFlow.

    Implementation of the abtract class server.HandlerAbstract.
    The handler is used by server.PythonMatlabConnection.

    The handler responds to server requests for training and evaluating ANNs.

   """

    def __init__(self, fct_model, fct_train):
        """Constructor.

        Parameters:
        fct_model (fct): Function for creating the ANN
        fct_train (fct): Function for training the ANN

       """

        # init superclass
        super().__init__()

        # assign ANN functions
        self.fct_model = fct_model
        self.fct_train = fct_train

        # dict containing the ANNs
        self.ann_data = {}

    def run_data(self, data_inp):
        """Respond to a server request.

        Load, unload, train, and evaluate ANNs.
        This function also manage the error handling.

        Parameters:
        data_inp (dict): Server request

        Returns:
        dict: Request response

       """

        try:
            print('    type: %s / n_model: %d' % (data_inp['type'], len(self.ann_data)))

            data_info = self.__run_data_sub(data_inp)
            data_status = {'status': np.array(True, dtype='bool')}

            print('    status: ok / n_model: %d' % len(self.ann_data))
        except Exception as e:
            data_info = {}
            data_status = {'status': np.array(False, dtype='bool')}

            print('    status: fail / n_model: %d' % len(self.ann_data))

        data_out = {**data_info, **data_status}
        return data_out

    def __run_data_sub(self, data_inp):
        """Respond to a server request.

        Load, unload, train, and evaluate ANNs.
        Check which command is concerned and parse the corresponding data.

        Parameters:
        data_inp (dict): Server request

        Returns:
        dict: Request response

       """

        if data_inp['type']=='train':
            inp = data_inp['inp']
            out = data_inp['out']
            tag_train = data_inp['tag_train']
            (model_dump, history_dump) =  self.__train(tag_train, inp, out)
            return {'model': model_dump, 'history': history_dump}
        elif data_inp['type']=='unload':
            name = data_inp['name']
            self.__unload(name)
            return {}
        elif data_inp['type']=='load':
            name = data_inp['name']
            model = data_inp['model']
            history = data_inp['history']
            self.__load(name, model, history)
            return {}
        elif data_inp['type'] == 'predict':
            name = data_inp['name']
            inp = data_inp['inp']
            out = self.__predict(name, inp)
            return {'out': out}
        else:
            raise ValueError('invalid request type')

    def __train(self, tag_train, inp, out):
        """Train an ANN and serialize the resulting model.

        Parameters:
        tag_train (str): Tag for enabling different training modes
        inp (matrix): Matrix with the input data
        out (matrix): Matrix with the output data

        Returns:
        bytes: Keras/TensorFlow model (serialized)
        bytes: Keras/TensorFlow training history (serialized)

       """

        # set tag_train for the provided function
        fct_model_tmp = lambda n_sol, n_inp, n_out: self.fct_model(tag_train, n_sol, n_inp, n_out)
        fct_train_tmp = lambda model, inp_ref, out_ref: self.fct_train(tag_train, model, inp_ref, out_ref)

        # get the model and train it
        (model, history) = ann_run.train(inp, out, fct_model_tmp, fct_train_tmp)
        history = ann_dump.parse_keras_history(history)
        assert self.__check_model_history(model, history), 'invalid model/history type'

        # serialize the data
        model_dump = ann_dump.dump_keras_model(model)
        history_dump = ann_dump.dump_keras_history(history)

        return (model_dump, history_dump)

    def __unload(self, name):
        """Remove an ANN from the memory.

        Parameters:
        name (str): Name of the ANN to be removed

       """

        # remove the entry (also if not existing)
        self.ann_data.pop(name, None)

    def __load(self, name, model_dump, history_dump):
        """Deserialize an ANN and load it to the memory.

        Parameters:
        name (str): Name of the ANN to be loaded
        model_dump (bytes): Keras/TensorFlow model (serialized)
        history_dump (bytes): Keras/TensorFlow training history (serialized)

       """

        # deserialize the data
        model = ann_dump.undump_keras_model(model_dump)
        history = ann_dump.undump_keras_history(history_dump)
        assert self.__check_model_history(model, history), 'invalid model/history type'

        # load the data to the memory
        self.ann_data[name] = {'model': model, 'history': history}

    def __predict(self, name, inp):
        """Evaluate an ANN with given input data.

        Parameters:
        name (str): Name of the ANN to be evaluated
        inp (matrix): Matrix with the input data

        Parameters:
        matrix: Matrix with the output data

       """

        # get the model
        model = self.ann_data[name]['model']
        history = self.ann_data[name]['history']
        assert self.__check_model_history(model, history), 'invalid model/history type'

        # evaluate the model
        out = ann_run.predict(model, inp)

        return out

    def __check_model_history(self, model, history):
        """Check the type of the model and training history.

        Parameters:
        model (model): Keras/TensorFlow model
        history (dict): Keras/TensorFlow training history

        Returns:
        bool: Result of the check

       """

        is_ok = True
        is_ok = is_ok and isinstance(model, keras.Sequential)
        is_ok = is_ok and isinstance(history, dict)

        return is_ok


def run(hostname, port, n_connection, fct_model, fct_train):
    """Start the ANN server for MATLAB.

    Parameters:
    hostname (str): Server hostname
    port (int): Server port
    n_connection (int): Number of connection to accept
    fct_model (fct): Function for creating the ANN
    fct_train (fct): Function for training the ANN

   """

    # lamdba to init the ann_server.AnnHandler class
    handler_class = lambda: AnnHandler(fct_model, fct_train)

    # run the server
    obj = server.PythonMatlabServer(hostname, port, n_connection, handler_class)
    obj.start_server()
