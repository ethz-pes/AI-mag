import numpy as np

def train(inp, out, fct_model, fct_train):
    # parse var
    n_inp = inp.shape[0]
    n_out = out.shape[0]
    n_sol_inp = inp.shape[1]
    n_sol_out = out.shape[1]

    # get size
    assert n_sol_inp==n_sol_out, 'invalid size'
    n_sol = {n_sol_inp, n_sol_out}.pop()

    # get model
    assert n_sol>0, 'invalid size'
    assert n_inp>0, 'invalid size'
    assert n_out>0, 'invalid size'
    model = fct_model(n_sol, n_inp, n_out)

    # train
    inp = np.swapaxes(inp, 0, 1)
    out = np.swapaxes(out, 0, 1)
    (model, history) = fct_train(model, inp, out)

    return (model, history)

def predict(model, inp):
    # predict
    inp = np.swapaxes(inp, 0, 1)
    out = model.predict(inp)
    out = np.swapaxes(out, 0, 1)
    inp = np.swapaxes(inp, 0, 1)

    # check
    assert inp.shape[1] == out.shape[1], 'invalid size'

    return out