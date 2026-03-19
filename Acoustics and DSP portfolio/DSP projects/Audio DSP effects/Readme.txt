Audio DSP Effects (MATLAB)
==========================

Author: Hrishikesh N Raj  
Date: February 2026  

Overview
--------
This folder contains MATLAB implementations of classic audio effects
based on Digital Signal Processing (DSP) techniques.

The work focuses on time-domain effects using delay lines, including
chorus, flanger, and comb filtering. These effects demonstrate how simple
signal processing structures can be used to create rich and widely used
audio transformations.

Files Included
--------------

1. Chorus.m
   ------------------------------------
   Implements a chorus effect using modulated delay.

   Key Features:
   - Time-varying delay using a low-frequency oscillator (LFO)
   - Simulates multiple slightly detuned copies of the signal
   - Produces a thicker, richer sound

   Concept:
   The chorus effect is created by mixing the original signal with
   delayed versions whose delay time is continuously modulated.


2. Flanger.m
   ------------------------------------
   Implements a flanger effect using a short modulated delay line.

   Key Features:
   - Small delay range with sinusoidal modulation
   - Creates characteristic sweeping “whooshing” sound
   - Includes feedback for enhanced effect

   Concept:
   Flanging results from constructive and destructive interference
   between the original and delayed signals, producing a comb-like
   frequency response.


3. CombFiltering.m
   ------------------------------------
   Demonstrates comb filtering using a fixed delay.

   Key Features:
   - Implements feedforward/feedback comb filter structure
   - Produces periodic peaks and notches in the frequency response
   - Forms the basis of many audio effects

   Concept:
   Comb filtering occurs when a signal is combined with a delayed
   version of itself, causing interference patterns in the spectrum.


4. Slow Dancing In The Burning Room - John Mayer Isolated Guitar.wav
   -----------------------------------------------------------------
   Input audio file used for processing.

   Key Features:
   - Clean guitar recording
   - Used as input to demonstrate DSP effects

   Concept:
   Allows practical listening tests by applying DSP effects to a real
   musical signal.


How to Run
----------
- Open any `.m` file in MATLAB
- Ensure the audio file is in the same directory
- Run the script
- Processed audio will be played using `sound` or `soundsc`

Requirements
------------
- MATLAB
- Audio output device

Key Concepts Demonstrated
------------------------
- Time-delay systems
- Modulated delay lines
- Comb filtering
- Interference in frequency domain
- Audio effects processing

Notes
-----
- Delay parameters and modulation depth can be adjusted to explore
  different sound characteristics.
- Effects are implemented for clarity rather than real-time performance.

------------------------------------------------------------