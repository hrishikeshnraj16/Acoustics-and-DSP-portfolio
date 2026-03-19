%-------------------------------------------------------------------------
%
% Karplus-Strong Algorithm with Variable Pick Position
%
% Variable Pick Position (Jaffe & Smith, 1983)
%
% Jaffe & Smith describe how pluck position affects harmonic amplitudes
% in the Karplus–Strong string model. The harmonic content of a plucked
% string depends on where along the string it is excited.
%
% Here, this effect is approximated by shaping the excitation using a
% simple comb filter:
%
%   x_pick[n] = x[n] - g_pick * x[n - P]
%
% This corresponds to H(z) = 1 - g_pick*z^-P, which introduces harmonic
% cancellations dependent on P, modelling pluck position.
%
% Note:
% To make the effect clearly audible, this script runs two extreme pick
% positions (near-bridge vs near-centre) using the SAME excitation x[n].
%
% Reference:
% Jaffe, D. A., & Smith, J. O. (1983).
% "Extensions of the Karplus-Strong Plucked-String Algorithm."
% Computer Music Journal.
%
% Hrishikesh N Raj, 16/02/2026
%------------------------------------------------------------------------- 


% Clearing variables and workspace
close all;
clear;
clc;



% Setting the parameters
Fs    = 44.1e3;          % sampling rate in Hz
T_dur = 2;               % duration in seconds
f0    = 880;             % higher pitch makes timbre differences clearer

R     = 0.95;            % dynamics parameter 
rho   = 0.9995;          % longer sustain helps hear the difference

pickPos_A = 0.05;        % near bridge (bright)
pickPos_B = 0.50;        % near centre (dark)

g_pick = 0.90;           % comb depth (try 0.6 to 1.0)



% Derived quantities
M = round(T_dur * Fs);                 
N = floor((Fs / f0) - 0.5);



% Vector initialisation
v = 2 * rand(N,1) - 1;                 
x = zeros(N,1);



% Pre-filter (Dynamics Filter)
%
% x[n] = (1 - R)*v[n] + R*x[n-1]

x(1) = (1 - R) * v(1);

for n = 2:N
    
    x(n) = (1 - R) * v(n) + R * x(n-1);
    
end



% -------------------------------------------------------------------------
% Pick Position A (near bridge)
% -------------------------------------------------------------------------

P = round(pickPos_A * N);        % delay in samples

x_pick = x;

for n = (P+1):N
    
    x_pick(n) = x(n) - g_pick * x(n-P);
    
end



% Basic Karplus-Strong (A)

yA = zeros(M,1);

yA(1:N) = x_pick;

if (N+1) <= M
    
    yA(N+1) = (rho/2) * ( yA(1) + 0 );
    
end

for n = N+2:M
    
    yA(n) = (rho/2) * ( yA(n-N) + yA(n-N-1) );
    
end



% -------------------------------------------------------------------------
% Pick Position B (near centre)
% -------------------------------------------------------------------------

P = round(pickPos_B * N);        % delay in samples

x_pick = x;

for n = (P+1):N
    
    x_pick(n) = x(n) - g_pick * x(n-P);
    
end



% Basic Karplus-Strong (B)

yB = zeros(M,1);

yB(1:N) = x_pick;

if (N+1) <= M
    
    yB(N+1) = (rho/2) * ( yB(1) + 0 );
    
end

for n = N+2:M
    
    yB(n) = (rho/2) * ( yB(n-N) + yB(n-N-1) );
    
end



% Sound playback (A then B)
soundsc(yA, Fs);
pause(T_dur + 0.25);
soundsc(yB, Fs);



% Plotting and analysis
t = (0:M-1).' / Fs;



% Spectrum for A

FFTlen   = 2^nextpow2(M);

Y_fft_A  = fft(yA, FFTlen);
freqAxis = (0:FFTlen-1).' * (Fs / FFTlen);

nyqIndex = floor(FFTlen/2) + 1;
freqHalf = freqAxis(1:nyqIndex);

magA     = abs(Y_fft_A(1:nyqIndex));
magA_dB  = 20 * log10(magA + eps);



% Spectrum for B

Y_fft_B  = fft(yB, FFTlen);

magB     = abs(Y_fft_B(1:nyqIndex));
magB_dB  = 20 * log10(magB + eps);



% Figure 1: waveform comparison

figure;

subplot(2,1,1);
plot(t, yA);
grid on;
xlabel('Time (s)');
ylabel('Amplitude');
title('Pick Position A (near bridge) – Waveform');

subplot(2,1,2);
plot(t, yB);
grid on;
xlabel('Time (s)');
ylabel('Amplitude');
title('Pick Position B (near centre) – Waveform');



% Figure 2: spectrum comparison

figure;

subplot(2,1,1);
plot(freqHalf, magA_dB);
grid on;
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Pick Position A (near bridge) – Spectrum');
xlim([0, Fs/2]);

hold on;
xline(f0, '--');
hold off;

subplot(2,1,2);
plot(freqHalf, magB_dB);
grid on;
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Pick Position B (near centre) – Spectrum');
xlim([0, Fs/2]);

hold on;
xline(f0, '--');
hold off;



% -------------------------------------------------------------------------
% Audio Observation:
%
% Pick Position A (near bridge) sounds noticeably brighter and more "twangy"
% because more high-frequency content is present.
%
% Pick Position B (near centre) sounds softer and darker because more
% harmonics are cancelled by the comb filtering.
%
% The pitch stays the same, but the harmonic balance changes a lot.
% -------------------------------------------------------------------------
