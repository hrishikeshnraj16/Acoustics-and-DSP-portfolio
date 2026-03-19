Karplus–Strong Algorithm Implementations for plucked string (MATLAB)
================================================

Author: Hrishikesh N Raj  
Date: February 2026  

Overview
--------
This folder contains MATLAB implementations of the Karplus–Strong plucked string synthesis algorithm, along with several extensions exploring timbral control, tuning accuracy, and polyphonic synthesis.

The work was developed as part of coursework and focuses on both theoretical understanding and practical audio results.

Files Included
--------------

1. KS with Fractional Delay.m
   --------------------------------
   Implements a modified Karplus–Strong algorithm using a first-order
   allpass filter to achieve fractional delay.

   Key Features:
   - Corrects pitch inaccuracies caused by integer delay quantisation
   - Improves tuning precision, especially at higher frequencies
   - Includes waveform and spectral analysis plots

   Concept:
   Uses an allpass filter to simulate non-integer delay lengths, ensuring
   that the fundamental frequency closely matches the desired value.


2. KS = Major 7th Chord.m
   --------------------------------
   Generates a Major 7th chord using multiple Karplus–Strong strings.

   Key Features:
   - Synthesises four notes (root, major 3rd, perfect 5th, major 7th)
   - Uses equal temperament frequency ratios
   - Combines and normalises signals for polyphonic output

   Concept:
   Demonstrates how the Karplus–Strong algorithm can be extended from
   single-note synthesis to harmonic and musical structures.


3. KS - Variable Pick Position.m
   --------------------------------
   Explores the effect of pluck position on timbre.

   Key Features:
   - Implements pick position using a comb filter
   - Compares two extreme pluck locations (near bridge vs centre)
   - Includes waveform and spectral comparisons

   Concept:
   Based on Jaffe & Smith (1983), showing how excitation position affects
   harmonic content without changing pitch.


How to Run
----------
- Open any .m file in MATLAB
- Run the script
- Audio will be played automatically 
- Plots will be generated where applicable

Requirements
------------
- MATLAB (tested with standard signal processing functions)
- Audio output device for playback

Key Concepts Demonstrated
------------------------
- Digital waveguide / plucked string synthesis
- Feedback delay networks
- Fractional delay using allpass filters
- Harmonic shaping via excitation filtering
- Polyphonic sound synthesis

Notes
-----
- Random excitation is used (white noise burst), so output varies slightly
  between runs unless a fixed RNG seed is set.
- Scripts are designed for clarity and learning, not real-time optimisation.

References
----------
Jaffe, D. A., & Smith, J. O. (1983).
"Extensions of the Karplus-Strong Plucked-String Algorithm."
Computer Music Journal.

------------------------------------------------------------