# MATLAB/Python Toolbox for Regression/Fitting with ANN

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

The MATLAB and Python runtimes are communicating over TCP/IP sockets (Python is the server, MATLAB the client).
The MATLAB code is the main entry point and is making requests to the Python code.

This toolbox is primarily meant for regression with ANN but is also useful for other methods (such as least-squares or genetic algorithm).
This toolbox is made in order to be **easily extended** by other fitting and regression methods (abstract class).

## Getting Started / Example

The following code structure is considered:
* [ann_matlab](ann_matlab) - MATLAB code, the class "AnnManager" is the main class
* [ann_matlab](ann_matlab) - Python code, the module "ann_server" is the main module
* [ann_example](ann_example) - MATLAB/Python example
    * [run_ann_example.m](ann_example/run_ann_example.m) - the MATLAB main file
    * [run_ann_server.py](ann_example/run_ann_server.py) - the Python ANN server main file
    * Shell script (Linux) and (batch) script (MS Windows) for starting the Python ANN server

The examples show the capabilities of the toolbox:
* ANN regression with MATLAB Deep Learning
* ANN regression with Python Keras and TensorFlow
* MATLAB regression with nonlinear least-squares
* MATLAB regression with genetic algorithm

## Compatibility

The toolbox was tested with the following MATLAB setup:
* Tested with MATLAB R2018b
* MATLAB Deep Learning Toolbox ("neural_network_toolbox")
* MATLAB Global Optimization Toolbox ("gads_toolbox")
* MATLAB Optimization Toolbox ("optimization_toolbox")
* MATLAB Signal Processing Toolbox ("signal_toolbox")

The toolbox was tested with the following Python setup:
* Tested with Python 3.6.8
* Numpy 1.18.1
* TensorFlow 2.1.0

However, the toolbox can work without Python (only MATLAB), as long as the Python ANN engine is not used.

The toolbox was tested with the following operating systems:
* Linux Ubuntu 18.04.4 LTS
* Microsoft Windows 10

## Author

**Thomas Guillod, ETH Zurich, Power Electronic Systems Laboratory** - [GitHub Profile](https://github.com/otvam)

## Acknowledgement

* Prof. J.W. Kolar, ETH Zurich, Power Electronic Systems Laboratory
* P. Papamanolis, ETH Zurich, Power Electronic Systems Laboratory
* Keras and TensorFlow communities

## License

* This project is licensed under the **xxx License**, see [LICENSE.md](LICENSE.md).
* This project is copyrighted by: (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod.
