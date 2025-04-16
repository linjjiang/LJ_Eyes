# LJ_Eyes: An Automated Eye-Tracking Analysis Toolbox

LJ_Eyes is a comprehensive, end-to-end eye-tracking analysis pipeline built in MATLAB. It streamlines preprocessing, quality control, feature extraction, and visualization, enabling efficient and customizable analysis of eye-tracking data.

## Description

LJ_Eyes supports the following key functionalities:
* Import raw eye-tracking data into MATLAB-friendly format
* Perform artifact detection and quality checks
* Apply data denoising techniques
* Conduct preliminary pupil and blink analyses
* Extract key features (e.g., saccades and fixations) during task-relevant epochs
* Visualize data using a user-friendly Graphical User Interface (GUI)


Core features of this toolbox:
* Transparency:
All analysis parameters are stored in a single settings.m file, allowing for easy review and adjustment.
* Flexibility
Offers a variety of preprocessing and analysis options (e.g., blink removal methods, saccade classification algorithms) to suit different research needs.
* Automation
Once the settings are configured, the entire pipeline can be executed via a single script—just one click to run the full analysis.

## Getting Started

### Dependencies

* Edf2Mat© Matlab Toolbox: https://github.com/uzh/edf-converter
* MATLAB R2019b or higher version.
* Input eye data must be collected by SR Research Eyelink eye-tracker and in .edf format.

### Installing

* Install Edf2Mat© Matlab Toolbox: https://github.com/uzh/edf-converter
* Download the repo, add it to your matlab path.
```
addpath(genpath("./LJ_Eyes"))
```
* You are ready to go!

### Executing program

I provided two examples of how to use this toolbox under the demo/ folder:
* data1: a basic example of analyzing eye data using this toolbox, from raw eye data import to event (ex. saccade) segmentation.
```
open setting.m # open and check settings before running the main script.
run full_example.m # run the main processing script.
```
* training_spring2023: a more detailed tutorial of analyzing actual eye data I collected. This tutorial comes from a training session I gave to my lab in spring 2023.
```
open tutorial_setting.m # open and check settings before running the main script.
run preprocess_tutorial.m # run the main processing script.
open preprocess_assignment.m # optional: complete an assignment I designed to understand the scripts & analysis in depth ;)
```

## Help & Potential Issues


## Authors

Linjing Jiang
[@linjjiang](https://github.com/linjjiang)

## Version History

* 0.1
    * Initial Release

## License

This project is licensed under the BSD-3-Clause License - see the LICENSE.md file for details

## Acknowledgments

* [Edf2Mat©](https://github.com/uzh/edf-converter)
