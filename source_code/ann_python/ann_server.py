import numpy as np
import tensorflow.keras as keras
from .ann_engine import ann_run
from .ann_engine import ann_dump
from .mat_py_bridge import server


class AnnHandler(server.PythonMatlabServer):
    def __init__(self, hostname, port, fct_model, fct_train):
        super().__init__(hostname, port)
        self.data = {}
        self.fct_model = fct_model
        self.fct_train = fct_train

    def handler_connect(self):
        keys = list(self.data.keys())
        print("        message: hello")
        print("        name: %s" % keys)

    def handler_disconnect(self):
        keys = list(self.data.keys())
        print("        name: %s" % keys)
        print("        message: bye")

    def handler_run_data(self, data_inp):
        try:
            keys = list(self.data.keys())
            print("        type: %s / %s" % (data_inp["type"], keys))

            data_info = self.__run_data_sub(data_inp)
            data_status = {"status": np.array(True, dtype="bool")}

            keys = list(self.data.keys())
            print("        status: ok / %s" % keys)
        except Exception as e:
            data_info = {}
            data_status = {"status": np.array(False, dtype="bool")}

            keys = list(self.data.keys())
            print("        status: fail / %s" % keys)

        data_out = {**data_info, **data_status}
        return data_out

    def __run_data_sub(self, data_inp):
        if data_inp["type"]=="train":
            inp = data_inp["inp"]
            out = data_inp["out"]
            tag_train = data_inp["tag_train"]
            (model_dump, history_dump) =  self.__train(tag_train, inp, out)
            return {"model": model_dump, "history": history_dump}
        elif data_inp["type"]=="delete":
            name = data_inp["name"]
            self.__delete(name)
            return {}
        elif data_inp["type"]=="load":
            name = data_inp["name"]
            model = data_inp["model"]
            history = data_inp["history"]
            self.__load(name, model, history)
            return {}
        elif data_inp["type"] == "predict":
            name = data_inp["name"]
            inp = data_inp["inp"]
            out = self.__predict(name, inp)
            return {"out": out}
        else:
            raise ValueError('invalid type')

    def __train(self, tag_train, inp, out):
        fct_model_tmp = lambda n_sol, n_inp, n_out: self.fct_model(tag_train, n_sol, n_inp, n_out)
        fct_train_tmp = lambda model, inp_ref, out_ref: self.fct_train(tag_train, model, inp_ref, out_ref)

        (model, history) = ann_run.train(inp, out, fct_model_tmp, fct_train_tmp)
        history = ann_dump.parse_keras_history(history)
        assert self.__check_model_history(model, history), 'model/history error'

        model_dump = ann_dump.dump_keras_model(model)
        history_dump = ann_dump.dump_keras_history(history)

        return (model_dump, history_dump)

    def __delete(self, name):
        self.data.pop(name, None)

        return {}

    def __load(self, name, model_dump, history_dump):
        model = ann_dump.undump_keras_model(model_dump)
        history = ann_dump.undump_keras_history(history_dump)
        assert self.__check_model_history(model, history), 'model/history error'

        self.data[name] = {"model": model, "history": history}

        return {}


    def __predict(self, name, inp):
        model = self.data[name]["model"]
        history = self.data[name]["history"]
        assert self.__check_model_history(model, history), 'model/history error'

        out = ann_run.predict(model, inp)

        return out

    def __check_model_history(self, model, history):
        is_ok = True
        is_ok = is_ok and isinstance(model, keras.Sequential)
        is_ok = is_ok and isinstance(history, dict)

        return is_ok


def run(hostname, port, fct_model, fct_train):
    obj = AnnHandler(hostname, port, fct_model, fct_train)
    obj.start()