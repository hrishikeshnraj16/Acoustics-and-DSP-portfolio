Room Acoustics – Image Source Method (MATLAB)
============================================

Author: Hrishikesh N Raj  
Date: February 2026  

Overview
--------
This folder contains MATLAB implementations of room acoustics simulation
using the Image Source Method (ISM). The work focuses on generating and
analysing Room Impulse Responses (RIRs), along with extensions such as
stereo rendering, angle-dependent reflections, and frequency-dependent
wall absorption.

Files Included
--------------

1. Basic Image Source Method.m
   ------------------------------------
   Core implementation of the Image Source Method.

   Key Features:
   - Generates Room Impulse Response (RIR)
   - Models early reflections using virtual sources
   - Computes delay and attenuation based on geometry

   Concept:
   Reflections are simulated by mirroring the source across room
   boundaries, creating image sources that contribute to the RIR.


2. Stereo Image Source Method.m
   ------------------------------------
   Extends the ISM implementation to stereo output.

   Key Features:
   - Simulates left and right ear signals
   - Incorporates spatial differences in arrival time and amplitude
   - Enables basic spatial perception of reflections

   Concept:
   Models how reflections are perceived differently at each ear,
   introducing spatial cues.


3. ISM - Angle-Dependent Reflections.m
   ------------------------------------
   Models reflections with angle-dependent behaviour.

   Key Features:
   - Reflection strength varies with angle of incidence
   - More realistic modelling compared to uniform reflections

   Concept:
   Accounts for directional properties of reflections, improving realism
   over basic ISM.


4. ISM - Frequency-dependent wall absorption.m
   --------------------------------------------
   Incorporates frequency-dependent absorption into the ISM model.

   Key Features:
   - Different frequencies attenuate differently at surfaces
   - Produces more realistic reverberation characteristics

   Concept:
   Real-world materials absorb frequencies unevenly; this model simulates
   that behaviour.


5. analyse_IR(Function).m
   ------------------------------------
   Utility function for analysing generated impulse responses.

   Key Features:
   - Time-domain visualisation
   - Energy decay observation
   - Helps distinguish early reflections

   Concept:
   Provides tools to interpret and evaluate the generated RIRs.


6. DryGuitar_mono.wav
   ------------------------------------
   Input audio signal used for testing.

   Key Features:
   - Dry (anechoic) guitar recording
   - Can be convolved with generated RIRs to simulate room acoustics

   Concept:
   Demonstrates practical application of RIRs through convolution.


How to Run
----------
- Open any .m script in MATLAB
- Run the script to generate impulse responses
- Use the provided audio file for convolution (if applicable)
- Plots and/or audio output will be generated

Requirements
------------
- MATLAB
- Standard signal processing functions
- Audio output device (for playback)

Key Concepts Demonstrated
------------------------
- Room Impulse Response (RIR)
- Image Source Method (ISM)
- Early reflections modelling
- Stereo spatialisation
- Angle-dependent reflections
- Frequency-dependent absorption
- Convolution-based audio rendering

Notes
-----
- Higher reflection orders improve realism but increase computational cost.
- The implementation primarily focuses on early reflections.
- Assumes rectangular room geometry unless otherwise specified.

References
----------
Allen, J. B., & Berkley, D. A. (1979).
"Image Method for Efficiently Simulating Small-Room Acoustics."
Journal of the Acoustical Society of America.

------------------------------------------------------------