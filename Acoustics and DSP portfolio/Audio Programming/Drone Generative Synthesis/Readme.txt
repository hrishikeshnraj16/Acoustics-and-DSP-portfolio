Petrichor – JUCE Audio Plugin Project
=====================================

Author: Hrishikesh N Raj
Date: February 2026

Overview
--------
This folder contains a JUCE-based audio plugin project developed for an
Audio Programming assignment. The project implements a custom audio effect /
instrument workflow, combining waveform generation with modulation-based DSP
effects.

The project includes source code for the plugin, supporting DSP classes,
the Projucer project file, a report, and a rendered audio example.

Files Included
--------------

1. Drone2.jucer
   ------------------------------------
   JUCE Projucer project file.

   Key Features:
   - Defines the plugin project structure
   - Stores module and build configuration
   - Used to generate IDE project files

   Concept:
   This is the main JUCE project file used to open and manage the plugin in
   Projucer.


2. Petrichor Report.pdf
   ------------------------------------
   Project report describing the design and implementation.

   Key Features:
   - Documents the plugin concept
   - Explains DSP choices and programming approach
   - Summarises outcomes of the assignment

   Concept:
   Provides the written explanation of the project and its technical design.


3. Petrichor.wav
   ------------------------------------
   Rendered / exported audio example from the project.

   Key Features:
   - Demonstrates the sonic result of the plugin
   - Useful as a listening reference
   - Acts as an example output for evaluation

   Concept:
   Shows the practical output of the processing / synthesis implemented in
   the source code.


4. Source/Oscillator.h
   ------------------------------------
   Header file for the oscillator implementation.

   Key Features:
   - Defines waveform generation logic
   - Provides the basis for audio signal creation
   - Supports synthesis functionality within the plugin

   Concept:
   The oscillator is the core sound source, generating periodic signals used
   as the input to further processing.


5. Source/PluginEditor.cpp
   ------------------------------------
   Implementation of the plugin graphical user interface.

   Key Features:
   - Handles layout and user interaction
   - Connects controls to plugin parameters
   - Manages the front-end of the plugin

   Concept:
   This file defines how the user interacts with the plugin visually.


6. Source/PluginEditor.h
   ------------------------------------
   Header file for the plugin editor.

   Key Features:
   - Declares the editor class
   - Defines GUI-related members and structure

   Concept:
   Works together with PluginEditor.cpp to build the plugin interface.


7. Source/PluginProcessor.cpp
   ------------------------------------
   Main audio processing implementation.

   Key Features:
   - Handles DSP processing block-by-block
   - Integrates oscillator and modulation effects
   - Manages plugin parameters and signal flow

   Concept:
   This is the core processing file where the input signal is generated
   and/or transformed in real time.


8. Source/PluginProcessor.h
   ------------------------------------
   Header file for the plugin processor.

   Key Features:
   - Declares the processor class
   - Defines parameters, state, and DSP components

   Concept:
   Provides the structural backbone for the plugin’s audio engine.


9. Source/SimpleChorus.h
   ------------------------------------
   Header file implementing a chorus effect.

   Key Features:
   - Uses modulated delay to thicken the signal
   - Produces a wider and richer sound
   - Demonstrates classic delay-based DSP

   Concept:
   Chorus is created by mixing the original signal with one or more slightly
   delayed, continuously modulated copies.


10. Source/SimpleFlanger.h
    ------------------------------------
    Header file implementing a flanger effect.

    Key Features:
    - Uses a short modulated delay line
    - Produces a sweeping comb-filter effect
    - Demonstrates time-varying interference in audio DSP

    Concept:
    Flanging results from combining the dry signal with a very short,
    modulated delay, creating moving peaks and notches in the spectrum.


How to Run
----------
- Open `Drone2.jucer` in Projucer
- Export the project to your preferred IDE
- Build the plugin target
- Run it in a DAW or plugin host

Requirements
------------
- JUCE framework
- C++ compiler / supported IDE
- DAW or plugin host for testing
- Audio output device

Key Concepts Demonstrated
-------------------------
- Audio plugin development in JUCE
- Real-time DSP processing
- Oscillator-based sound generation
- Chorus and flanger implementation
- GUI and parameter integration
- Modular C++ audio programming

Notes
-----
- The project is structured as a standard JUCE plugin with separated DSP
  and GUI components.
- `Petrichor.wav` is included as an example output / reference render.
- Supporting DSP modules are implemented as separate header files for
  clarity and modularity.

------------------------------------------------------------