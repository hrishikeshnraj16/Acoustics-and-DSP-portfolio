%-------------------------------------------------------------------------
%
% Modified Karplus-Strong Algorithm (Fractional Delay Allpass Version)
%
% This script implements the Karplus-Strong algorithm with
% frequency correction using a first-order allpass filter.
%  
% Hrishikesh N Raj, 16/02/2026
%------------------------------------------------------------------------- 


% Clearing variables and workspace
close all;
clear;
clc;



% Modified Karplus-Strong model :
%
% Basic KS lowpass feedback:
%   w[n] = (rho/2) * ( y[n - N] + y[n - N - 1] )
%
% Fractional delay allpass stage:
%   Hc(z) = (C + z^-1) / (1 + C z^-1)
%
% Difference equation of allpass filter:
%   y[n] = C*w[n] + w[n-1] - C*y[n-1]
%
% The fundamental frequency becomes:
%   f0 = Fs / (N + 1/2 + Nfrac)



% Setting the parameters
Fs    = 44.1e3;          % sampling rate in Hz
T_dur = 2;               % duration in seconds
f0    = 880;             % desired fundamental (Hz)

R     = 0.95;            % dynamics parameter 
rho   = 0.998;           % loss factor (between 0 and 1)



% Derived quantities for fractional delay implementation

M = round(T_dur * Fs);                 % duration in samples (output length)

Nexact = (Fs / f0) - 0.5;              % ideal (fractional) delay length
N      = floor(Nexact);                % integer part of delay
Nfrac  = Nexact - N;                   % fractional delay component

C = (1 - Nfrac) / (1 + Nfrac);         % allpass filter coefficient


% RNG seed to ensure both basic and modified KS use the
% same excitation signal for fair comparison.
% This is only for testing/comparison purposes.


% rng(0);                              % Comment out to restore natural randomness

 

% Vector initialisation
v = 2 * rand(N,1) - 1;                 % white noise burst in [-1, 1]
x = zeros(N,1);                        % output of dynamics filter
y = zeros(M,1);                        % KS output signal



% Pre-filter (Dynamics Filter)
%
% x[n] = (1 - R)*v[n] + R*x[n-1]
%
% For n = 0 (MATLAB index 1), assume x[-1] = 0 to maintain causality.

x(1) = (1 - R) * v(1);

for n = 2:N
    
    x(n) = (1 - R) * v(n) + R * x(n-1);
    
end



% Main Modified Karplus-Strong algorithm
%
% Stage 1: Two-point lowpass filter (inside feedback loop)
% Stage 2: First-order allpass filter for fractional delay correction

y(1:N) = x;                 % Prefill delay line



% Temporary states for allpass stage
w  = 0;                     % current lowpass output
w1 = 0;                     % previous lowpass output (w[n-1])



% Special causal case at n = N+1

if (N+1) <= M
    
    % Lowpass stage
    w = (rho/2) * ( y(1) + 0 );
    
    % Allpass stage
    y(N+1) = C * w + w1 - C * y(N);
    
    % Update stored lowpass state
    w1 = w;
    
end



% Full recursion for n > N

for n = N+2:M
    
    % Lowpass stage
    w = (rho/2) * ( y(n-N) + y(n-N-1) );
    
    % Allpass stage (fractional delay correction)
    y(n) = C * w + w1 - C * y(n-1);
    
    % Update stored lowpass state
    w1 = w;
    
end



% Sound playback
soundsc(y, Fs);

% -------------------------------------------------------------------------
% Audio Observations (Modified KS):
%
% At 880 Hz, the note sounds similar in character to the basic model,
% but the pitch matches the intended frequency more accurately.
%
% At a higher frequency (say 2000 Hz), the improvement is clearer.
% The pitch remains correct, showing that the fractional delay allpass
% filter successfully corrects the tuning error.
% -------------------------------------------------------------------------



% Plotting and analysis
t = (0:M-1).' / Fs;                     % time axis in seconds



% Spectrum (0 to Nyquist)

FFTlen   = 2^nextpow2(M);
Y_fft    = fft(y, FFTlen);

freqAxis = (0:FFTlen-1).' * (Fs / FFTlen);

nyqIndex = floor(FFTlen/2) + 1;
freqHalf = freqAxis(1:nyqIndex);

magnitude    = abs(Y_fft(1:nyqIndex));
magnitude_dB = 20 * log10(magnitude + eps);



% Figure 1: full waveform - full spectrum

figure;
subplot(2,1,1);
plot(t, y);
grid on;
xlabel('Time (s)');
ylabel('Amplitude');
title('Modified KS waveform');

subplot(2,1,2);
plot(freqHalf, magnitude_dB);
grid on;
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Modified KS spectrum');
xlim([0, Fs/2]);

hold on;
xline(f0, '--');     % desired frequency
hold off;



% Figure 2: zoomed waveform and spectrum
figure;

f0_actual = Fs / (N + 0.5 + Nfrac);     % corrected fundamental
nCycles   = 6;
t_zoom_max = nCycles / f0_actual;

subplot(2,1,1);
plot(t, y);
grid on;
xlabel('Time (s)');
ylabel('Amplitude');
title('Waveform (zoom)');
xlim([0, t_zoom_max]);

subplot(2,1,2);
plot(freqHalf, magnitude_dB);
grid on;
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Spectrum (zoom around f0)');
xlim([max(0, f0 - 200) (f0 + 200)]);

hold on;
xline(f0, '--');
hold off;



% -------------------------------------------------------------------------
% Observations:
%
% The waveform decays similarly to the basic KS model, but the spectral
% peak now aligns almost exactly with the desired f0. This confirms that
% the fractional delay allpass filter successfully corrects the tuning
% error caused by integer delay quantisation.
%
% Compared to the basic implementation, the frequency match is significantly
% improved, especially at higher frequencies where tuning errors are larger.
% -------------------------------------------------------------------------
