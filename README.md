# mANNgnetics: Inductor Optimization with FEM/ANN

**mANNgnetics** is a **MATLAB** toolbox (using also COMSOL and Python) for **power electronic inductor optimization**. 
The goal of this tool is to **combine** the **accuracy of the Finite Element Method (FEM)** with the **evaluation speed** of **Artificial Neural Network (ANN)**.
This project developed by the **Power Electronic Systems Laboratory at ETH Zurich** and is available under the **BSD License**. 

More precisely, the following **workflow** is implemented:
* Simulating many designs with **FEM thermal and magnetic** simulations (COMSOL)
* Extracting the important figures of merit out of the FEM simulations
* Extracting the same figures of merit with a simplified analytical model (for comparison)
* **Training regression ANNs** to reproduce the figures of merit (MATLAB or Python Keras and TensorFlow)
* Using the **ANNs**, **quickly** generate **accurate inductor designs** (without solving any FEM model)
* **Multi-objective** data exploration with a **GUI**

The following performances are achieved:
* The **average error** between the FEM simulations and the ANN predictions is **below 1%** 
* The **worst-case error** between the FEM simulations and the ANN predictions is **below 3%** 
* The tool is able **generate 300'000 designs per second** on a laptop computer
* The tool is able for compute **50'000 operating points per second** on a laptop computer

## Simplified Workflow

<p float="middle">
    <img src="resources/img_readme/workflow.png" width="700">
</p>

## GUI Screenshots

<p float="middle">
    <img src="resources/img_readme/screenshot_1.png" width="400">
    <img src="resources/img_readme/screenshot_2.png" width="400">
</p>
<p float="middle">
    <img src="resources/img_readme/screenshot_3.png" width="400">
    <img src="resources/img_readme/screenshot_4.png" width="400">
</p>
<p float="middle">
    <img src="resources/img_readme/screenshot_5.png" width="400">
    <img src="resources/img_readme/screenshot_6.png" width="400">
</p>

## Getting Started / Example

The following code structure is considered:
* [resources](resources) - Different resources which are not directly used in the toolbox
* [source_ann](source_ann) - ANN library for regression/fitting (standalone code, see [README.md](source_ann/README.md))
* [source_inductor](source_inductor) - Source code for the FEM/ANN inductor design tool
* [source_input](source_input) - Input data and parameters defined by the user
* [source_input](source_input) - Input data and parameters defined by the user
* [init_toolbox.m](init_toolbox.m) - Load the MATLAB toolbox
* [run_0_init.m](run_0_init.m) - Init the simulations with constant data
* [run_1_fem.m](run_1_fem.m) - Run the different FEM simulations
* [run_2_assemble.m](run_2_assemble.m) - Assemble the FEM simulations results, add the analytical solutions
* [run_3_train.m](run_3_train.m) - Train the regressions with ANNs with simulation results
* [run_4_export.m](run_4_export.m) - Export the ANNs in prevision of the evaluation of inductor designs 
* [run_5_compute_all.m](run_5_compute_all.m) - Simulate many inductor designs (ANN or ana. approx.)
* [run_6_compute_single.m](run_6_compute_single.m) - Simulate a single inductor design (ANN or FEM or ana. approx)
* [run_7_plot_all.m](run_7_plot_all.m) - Plot the optimization results (Pareto fronts) in a GUI
* [run_8_plot_single.m](run_8_plot_single.m) - Display a single design in a GUI
* [run_ann_server.py](run_ann_server.py) - Python ANN server for using Keras and TensorFlow from MATLAB
* Shell script (Linux) and (batch) script (MS Windows) for starting the Python ANN server
* Shell script (Linux) and (batch) script (MS Windows) for starting the COMSOL MATLAB Livelink
* Readme and license files

The example shows the complete workflow: FEM simulations, ANN training, design generation, and display with GUI:
* The inductor of a DC-DC Buck converter is optimized
* The converter has the following ratings: 2kW, 400V input voltage, 200V output voltage
* The following parameters are optimized: frequency, geometry, air gap, number of turns, ripple

## Inductor Optimization Capabilities

Currently the following inductors are optimized:
* E-core inductor with an air-gap (with fringing field)
* Ferrite core (with loss map, DC bias, and IGSE)
* Litz wire winding (no packing model, with proximity losses)
* Forced convection cooling
* Sinus or PWM excitation (with DC bias)
* Coupled thermal/loss models

However, this toolbox is made in order to be **easily extended** with other inductors types, magnetic components (e.g., transformers, chokes), or optimization method (e.g., genetic algoritm).

## Compatibility

The tool is tested with the following MATLAB setup:
* Tested with MATLAB R2018b or 2019a
* Deep Learning Toolbox ("neural_network_toolbox")
* Global Optimization Toolbox ("gads_toolbox")
* Optimization Toolbox ("optimization_toolbox")
* Signal Processing Toolbox ("signal_toolbox")

The tool is tested with the following COMSOL setup (for FEM simulations):
* COMSOL Multiphysics 5.4 or 5.5
* AC/DC Module (for the magnetic simulation)
* Heat Transfer Module (for the thermal simulation)
* CAD Import Module (for 3d geometry manipulation)
* MATLAB Livelink (for communication with MATLAB)

It should be noted that COMSOL is only required to run the FEM simulations, not for the ANN/regression or the inductor design evaluation.
In other word, COMSOL is required to generate the ANN training set, but not for running the design tool.

The tool is tested with the following Python setup (for ANN with Keras and TensorFlow):
* Python 3.6.8
* Numpy 1.18.1
* TensorFlow 2.1.0

However, the toolbox can work without Python, as long as the Python ANN engine is not used.

The tool is known to run with the following operating systems:
* Linux Ubuntu 18.04.4 LTS
* Linux CentOS 7.5
* Microsoft Windows 10

The following softwares were used to generate resources but are not required to run the code:
* Adobe Illustrator 2020 - generating the GUI artwork
* Wolfram Mathematica 12 - generating analytical expressions
* PyCharm Community Edition 2019 - running and debugging the Python code

## Releases

The source code is available in the GitHub Git repository and contains:
* All the code is included (MATLAB, Python, and COMSOL)
* All the ressources (generation of material data, images, analytical equations, etc.) are included
* The generated data (FEM solution, trained ANN, etc.) are NOT included
* [GitHub Repository](https://github.com/otvam/mANNgnetics)

The releases are available at GitHub and contains:
* A stable version of the source code (code and ressources)
* An zip archive containg the generated data (FEM solution, trained ANN, etc.)
* [GitHub Releases](https://github.com/otvam/mANNgnetics/releases)

## Metrics

```
-------------------------------------------------------------------------------
Language                     files          blank        comment           code
-------------------------------------------------------------------------------
MATLAB                         101           1648           4806           4539
Python                           8            365            451            450
Markdown                         4             75              0            281
DOS Batch                        3              9              0             34
Bourne Shell                     3              9              9             21
-------------------------------------------------------------------------------
SUM:                           119           2106           5266           5325
-------------------------------------------------------------------------------
```

# FAQ

Do I need Python?
* Only if the Keras/TensorFlow ANN engine is used.
* Python is not required if the MATLAB ANN engine is used.

Do I need COMSOL?
* Only for generating the training/testing datasets for the ANN.
* Only for computing inductor design with FEM (without ANN).
* COMSOL is not required for designing inductors with ANN

Can this toolbox handle big data?
* Depending what is big data, few 10 millions of designs are definitely OK.
* The memory management model (everything is stored in RAM) does not allow billions of samples.

How fast is the code, do I need a powerful machine?
* The computation of the inductors is fully parallelized and/or vectorized.
* The code can compute tens of thousands inuductor design per second.
* The training of the ANN takes some minutes.
* The generation of the FEM training/testing sets takes some tens of hours.
* The following mid-range laptop is used: Intel Core i7-8650U @ 1.90GHz / 16GB RAM

I have a powerful cluster, can I use it?
* Yes, the code can run in parallel (multithreaded and/or completely distributed).
* The code has been run succesfully on a HPC cluster (bith a LSF batching system). 

Can this code run with GNU Octave?
* The code is not compatible with GNU Octave.
* The ANN library is not compatible with GNU Octave.
* The COMSOL MATLAB Livelink is not compatible with GNU Octave.
* The GUI is not compatible with GNU Octave.

Why the tool in MATLAB and Python and not only in Python?
* Mainly due to the COMSOL MATLAB Livelink which is great on MATLAB.
* The MATLAB ANN engine is also simpler to begin than Keras/TensorFlow.
* Due to legacy code on MATLAB (some inductor models).

Can I use another FEM solver (e.g., Ansys, OpenFOAM)?
* The tool has been written in order to minimize the dependencies to COMSOL
* Therefore, it would be easy to use another FEM solver.

## Author

* **Thomas Guillod, ETH Zurich, Power Electronic Systems Laboratory** - [GitHub Profile](https://github.com/otvam)

## Acknowledgement

* Prof. J.W. Kolar, ETH Zurich, Power Electronic Systems Laboratory
* P. Papamanolis, ETH Zurich, Power Electronic Systems Laboratory
* The Pareto optimization team at ETH Zurich, Power Electronic Systems Laboratory
* The Euler cluster team at ETH Zurich
* Jan, from MATLAB File Exchange for the inspiration for the md5 hashing code
* Tim, from MATLAB File Exchange for the inspiration for the serialization code
* Keras and TensorFlow communities

## License

* This project is licensed under the **BSD License**, see [LICENSE.md](LICENSE.md).
* This project is copyrighted by: (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod.
* The "ETH Zurich" and "Power Electronic Systems Laboratory" logos are the property of their respective owners.
