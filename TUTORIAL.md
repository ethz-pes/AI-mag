# AI-mag: Short Tutorial

## Goal of the Tutorial

This is a simple example how to design an inductor:
* Design computation and optimization
    * Single design
    * Pareto optimization
* Result analysis
    * Interactive GUI
    * Pareto fronts exploration

The following inductor is considered.
* Non-isolated DC-DC Buck converter
* Converter ratings: 2kW, 400V input voltage, 200V output voltage
* E-core inductor (ferrite and litz-wire)
* Optimized parameters: frequency, geometry, air gap, number of turns, ripple

## Installation and Initialization

> **WARNING**: The repository does NOT contain the dataset and the trained ANNs.

> **WARNING**: The dataset and the trained ANNs are only included in the releases.

1. Go to the latest release: [Release](https://github.com/ethz-pes/AI-mag/releases/latest)
1. Download the source code: "Source code (zip)" or "Source code (tar.gz)"
1. Unpack the folder "AI-mag-x.x"
1. Download the data: "data.zip" or "data.tar.gz"
1. Unpack the data (replace the folders "dataset" and "design")
1. Start MATLAB and go to the corresponding folder
1. Type "init_toolbox" to load the toolbox

## Run a Single Inductor Design

```
>> run_design_compute_single
  ________________________________________________________
 |       _________   ___                                  |
 |      /  ___   /  /__/         _ __ ___   __ _  __ _    |
 |     /  /__/  /  /  /   ___   | `_ ` _ \ / _` |/ _` |   |
 |    /  ___   /  /  /   /___|  | | | | | | (_| | (_| |   |
 |   /__/  /__/  /__/           |_| |_| |_|\__,_|\__, |   |
 |                                               |___/    |
 |________________________________________________________|
 |                                                        |
 |   Fast and Accurate Inductor Modeling and Design       |
 |   With Artificial Neural Network (ANN)                 |
 |   With Finite Element Method (FEM)                     |
 |________________________________________________________|
 |      ____________________   ___                        |
 |     /  ________   ___   /__/  /   ETH Zurich           |
 |    /  _____/  /  /  /  ___   /    Power Electronic     |
 |   /_______/  /__/  /__/  /__/     Systems Laboratory   |
 |________________________________________________________|
 |                                                        |
 |   T. Guillod, Power Electronic Systems Laboratory      |
 |   Copyright 2019-2020 ETH Zurich / BSD License         |
 |________________________________________________________|
 
Select the simulation type:
    1 - ANN-based model
    2 - Analytical approximation
    2 - FEM simulation (require COMSOL Livelink)
Enter your choice >> 1

################## master_compute_single
load
ann fem
run
info
    single design
    diff = 00:00:00
save
################## master_compute_single
################## master_plot_single
load
gui
################## master_plot_single
```

<p float="middle">
    <img src="resources/img_tutorial/tutorial_single.png" width="700">
</p>

## Run a Pareto Fronts

```
>> run_design_compute_pareto
  ________________________________________________________
 |       _________   ___                                  |
 |      /  ___   /  /__/         _ __ ___   __ _  __ _    |
 |     /  /__/  /  /  /   ___   | `_ ` _ \ / _` |/ _` |   |
 |    /  ___   /  /  /   /___|  | | | | | | (_| | (_| |   |
 |   /__/  /__/  /__/           |_| |_| |_|\__,_|\__, |   |
 |                                               |___/    |
 |________________________________________________________|
 |                                                        |
 |   Fast and Accurate Inductor Modeling and Design       |
 |   With Artificial Neural Network (ANN)                 |
 |   With Finite Element Method (FEM)                     |
 |________________________________________________________|
 |      ____________________   ___                        |
 |     /  ________   ___   /__/  /   ETH Zurich           |
 |    /  _____/  /  /  /  ___   /    Power Electronic     |
 |   /_______/  /__/  /__/  /__/     Systems Laboratory   |
 |________________________________________________________|
 |                                                        |
 |   T. Guillod, Power Electronic Systems Laboratory      |
 |   Copyright 2019-2020 ETH Zurich / BSD License         |
 |________________________________________________________|
 
Select the simulation type:
    1 - ANN-based model
    2 - Analytical approximation
Enter your choice >> 1

################## master_compute_pareto
load
ann fem
sweep
split
run
    6 / 6
    5 / 6
    4 / 6
    3 / 6
    2 / 6
    1 / 6
assemble
info
    diff = 00:00:20
    n_tot = 519683
    n_filter_var = 519683
    n_filter_fom = 120399
    n_sol = 44333
save
################## master_compute_pareto
################## master_plot_pareto
load
gui
################## master_plot_pareto
```

<p float="middle">
    <img src="resources/img_tutorial/tutorial_pareto.png" width="700">
</p>

## Change the Simulation Parameters

All the files describing the inductor computation and optimization are located in the [run_design](run_design) folder:
* [run_design_compute_single.m](run_design/run_design_compute_single.m) - Single design (entry point)
* [run_design_compute_pareto.m](run_design/run_design_compute_pareto.m) - Pareto fronts (entry point)
* [material](run_design/material) - Material database
    * [core_data.mat](run_design/material/core_data.mat) - Core data (losses, permeability, saturation, etc.)
    * [iso_data.mat](run_design/material/iso_data.mat) - Insulation data (weight, thermal properties, etc.)
    * [winding_data.mat](run_design/material/winding_data.mat) - Winding data (stranding, fill factor, etc.)
* [param](run_design/param) - User defined parameters
    * [get_design_param_compute_pareto.m](run_design/param/get_design_param_compute_pareto.m) - Definition of the parameter sweep (many designs)
    * [get_design_param_compute_pareto.m](run_design/param/get_design_param_compute_single.m) - Definition of the parameter (single design)
    * [get_design_param_plot_pareto.m](run_design/param/get_design_param_plot_pareto.m) - Parameters for the Pareto fronts
    * [get_design_circuit.m](run_design/param/get_design_circuit.m) - Applied stress on the inductor (current, voltage, etc.)
    * [get_design_excitation.m](run_design/param/get_design_excitation.m) - Inductor operating point definition
    * [get_design_data_vec.m](run_design/param/get_design_data_vec.m) - Inductor parameters
    * [get_design_fct.m](run_design/param/get_design_fct.m) - Functions for filtering invalid designs
    * [get_design_data_const.m](run_design/param/get_design_data_const.m) - Parameters for the numerical methods

## FEM Dataset and ANN Training

In this tutorial, pre-trained ANNs have been used.
However, if required, the dataset and the ANNs can be generated from scratch.

All the files describing the dataset generation and the ANN training are located in the [run_dataset](run_dataset) folder:
* [run_dataset_1_init.m](run_dataset/run_dataset_1_init.m) - Init the simulations with constant data (entry point)
* [run_dataset_2_fem.m](run_dataset/run_dataset_2_fem.m) - Run the different FEM simulations (entry point)
* [run_dataset_3_assemble.m](run_dataset/run_dataset_3_assemble.m) - Assemble the FEM simulations results, add the analytical solutions (entry point)
* [run_dataset_4_train.m](run_dataset/run_dataset_4_train.m) - Train the regressions with ANNs with simulation results (entry point)
* [run_dataset_5_export.m](run_dataset/run_dataset_5_export.m) - Export the ANNs in prevision of the evaluation of inductor designs (entry point)
* [model](run_dataset/model) - COMSOL models
    * [model_ht.mph](run_dataset/model/model_ht.mph) - COMSOL 3D model for the thermal simulations
    * [model_mf.mph](run_dataset/model/model_mf.mph) - COMSOL 3D model for the magnetic simulations
* [param](run_dataset/param) - User defined parameters
    * [get_dataset_param_init.m](run_dataset/param/get_dataset_param_init.m) - Constant physical parameters
    * [get_dataset_param_fem.m](run_dataset/param/get_dataset_param_fem.m) - Parameters for generating the FEM dataset
    * [get_dataset_param_train.m](run_dataset/param/get_dataset_param_train.m) - Parameters for training the ANNs
