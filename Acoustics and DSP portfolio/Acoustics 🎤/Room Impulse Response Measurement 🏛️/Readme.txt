Room Impulse Response Measurement & Analysis
============================================

Author: Hrishikesh N Raj  
Date: February 2026  

Overview
--------
This folder contains a detailed report on the measurement and analysis of
Room Impulse Responses (RIRs) in three real-world spaces at the University
of Edinburgh.

The project investigates how room geometry, materials, and intended use
influence acoustic behaviour, using both swept-sine and impulsive
measurement techniques.

The three spaces studied are:
- St Cecilia’s Hall (concert room)
- E22 Lecture Theatre (ECA Building)
- A2 Lecture Room (Alison House)

The work combines practical measurement, signal processing, and acoustic
analysis to evaluate reverberation, clarity, and frequency response.


Files Included
--------------

1. Impulse Response Measurement Report.pdf
   ----------------------------------------
   Comprehensive project report documenting the full study.

   Contents:
   - Background and theoretical context
   - Description of measured spaces
   - Measurement setup and equipment
   - Experimental procedures (swept sine + handclap)
   - Signal processing (deconvolution, averaging)
   - Acoustic parameter extraction (RT60, C50, D50, etc.)
   - Comparative analysis across rooms
   - Conclusions and recommendations

   Key Concepts:
   - Room Impulse Response (RIR)
   - Deconvolution using inverse sweeps
   - Reverberation Time (RT60)
   - Energy Decay Curves (EDC)
   - Clarity metrics (C50, C80, D50)

   Concept:
   The impulse response captures how sound evolves in a room over time,
   including direct sound, early reflections, and late reverberation.
   From this, objective acoustic parameters are derived to evaluate room
   performance.


Methodology Summary
------------------
- Excitation:
  - Exponential sine sweeps (5s, 11s, 20s)
  - Impulsive excitation (handclap)

- Recording Setup:
  - Genelec 8030A loudspeaker
  - Schoeps MK2S stereo microphone pair
  - RME Fireface UCX II audio interface

- Processing:
  - Deconvolution using inverse sweep
  - Averaging across multiple takes
  - Time alignment and normalisation

- Analysis Tools:
  - MATLAB (signal processing & plots)
  - Room EQ Wizard (REW) for acoustic parameters


Key Findings
------------
- Smaller rooms (A2) exhibit shorter reverberation times and higher
  speech clarity.

- Larger lecture spaces (E22) show longer decay and reduced clarity,
  particularly at greater listening distances.

- The concert hall (St Cecilia’s) provides a more reverberant and
  enveloping acoustic suitable for music rather than speech.

- Sweep-based and handclap measurements show strong agreement in
  mid-frequency ranges, with differences at low frequencies due to
  noise and excitation limitations.


Key Concepts Demonstrated
------------------------
- Room acoustics measurement techniques
- System identification using deconvolution
- Comparison of measurement methods (sweep vs impulse)
- Relationship between architecture and acoustic behaviour
- Practical acoustic analysis of real spaces


Notes
-----
- Measurements were conducted at limited source–receiver positions.
- Background noise influenced low-frequency RT estimates in some cases.
- Handclap measurements provide quick validation but are less reliable
  than sweep-based methods.

------------------------------------------------------------