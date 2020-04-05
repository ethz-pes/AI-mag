# MATLAB/Python toolbox for regression/fitting with ANN

This **MATLAB/Python** toolbox offers many functionalities for **Artificial Neural Network (ANN) regression**:
* **Scaling, variable transformation and normalization**
* **Checking bounds** on the datasets
* **Training/fitting** the data
* **Displaying and plotting** error metrics**
* **Evaluating** the fit for given input data
* **Dumping and reloading** the data stored in the object

Currently, the current regression/fitting methods are implemented:
* **ANN regression** with **MATLAB Deep Learning**
* **ANN regression** with **Python Keras and TensorFlow**
* MATLAB regression with **nonlinear least-squares**, for benchmark with ANN
* MATLAB regression with **genetic algorithm**, for benchmark with ANN

This toolbox is primarily meant for regression with ANN but is also useful for other methods (such as least-squares or genetic algorithm).
This toolbox is made in order to be **easily extended** by other fitting and regression methods.

## Examples

The example [run_ann_example.m](ann_example/run_ann_example.m) show the capabilities of the toolbox:
* ANN regression with MATLAB Deep Learning
* ANN regression with Python Keras and TensorFlow
* MATLAB regression with nonlinear least-squares
* MATLAB regression with genetic algorithm

## Compatibility

The toolbox requires the following MATLAB setup:
* Tested with MATLAB R2018b (should work with newer versions)
* MATLAB Deep Learning Toolbox ("neural_network_toolbox")
* MATLAB Global Optimization Toolbox ("gads_toolbox")
* MATLAB Optimization Toolbox ("optimization_toolbox")
* MATLAB Signal Processing Toolbox ("signal_toolbox")

The toolbox requires the following Python setup:
* Tested with Python 3.6.8 (should work with newer versions)
* Numpy 1.18.1
* TensorFlow 2.1.0

However, the toolbox can work without Python (only MATLAB), as long as the Python ANN engine is not used.

## Author

**Thomas Guillod, PES, ETH Zurich** - [GitHub Profile](https://github.com/otvam)

## License

This project is licensed under the **xxx License**, see [LICENSE.md](LICENSE.md).
This project is copyrighted by: (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod.
