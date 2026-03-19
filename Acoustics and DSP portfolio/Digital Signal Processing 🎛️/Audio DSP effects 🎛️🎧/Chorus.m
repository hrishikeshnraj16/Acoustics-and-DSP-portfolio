%-------------------------------------------------------------------------
% Chorus Effect
%
% This script implements a chorus effect using multiple feedforward
% comb filters applied to a mono input signal.
%
% Recommended values for parameters for this guitar track:
% delay1      = 0.020  % 20 ms average delay for first voice
% swingtime1  = 0.005  % 5 ms swing around this delay
% f1          = 0.5    % LFO for first voice
% g1          = 0.6    % moderate strength
% 
% delay2      = 0.030  % 30 ms average delay for second voice
% swingtime2  = 0.007  % 7 ms swing around this delay
% f2          = 0.7    % slightly faster LFO for second voice
% g2          = 0.6    % moderate strength
%
% These values give a clear but not too extreme chorus on the guitar.
%
% Hrishikesh N Raj, 01/12/2025
%------------------------------------------------------------------------- 


% Clearing variables and workspace

close all;
clear;
clc;



% Flanger feedforward form
%  y[n] = x[n] + g * x[n - M[n]]
%
% with a time-varying delay:
%  M[n] = M0 * (1 + a * sin(2π * f * n / Fs))
%
% Expanding:
%  M[n] = M0 + M0 * a * sin(2π * f * n / Fs)
%
% If we define,
%  P0 = M0         % centre value of modulation 
%  D  = M0 * a     % swing range 
%
% then,
%  M[n] = P0 + D * sin(2π * f * n / Fs)
%
% Chorus uses the same idea but with two LFOs and their own P0s and Ds
%
% For LFO1,
% M1[n] = P01 + D1 * sin(2π * f1 * n / Fs)
%
% For LFO2,
% M2[n] = P02 + D2 * sin(2π * f2 * n / Fs)




% Setting the parameters (time in seconds, frequency in Hz)

delay1      = 0.020;        % delay line time for LFO1 (sec)
swingtime1 = 0.005;         % swing range time for LFO1 (sec)
f1              = 0.5;      % LFO frequency for LFO1 (Hz)
g1              = 0.6;      % effect strength for LFO1

delay2      = 0.030;        % delay line time for LFO2 (sec)
swingtime2 = 0.007;         % swing range time for LFO2 (sec)
f2              = 0.7;      % LFO frequency for LFO2 (Hz)
g2              = 0.6;      % effect strength for LFO2


audio = 'Slow Dancing In The Burning Room - John Mayer Isolated Guitar.wav';

% used this audio because the slow, sustained guitar playing makes the
% chorus effect easy to hear.


% To read audio file and convert it to mono.

[x, Fs] = audioread(audio);   % x contains audio and Fs is the sample rate


% If stereo, convert to mono by averaging the two channels
if size(x,2) == 2
    x = (x(:,1) + x(:,2)) / 2;
end

L = length(x);                % Length of the mono input signal



% Chorus model (two time-varying delays):
%
%   y[n] = x[n] + g1 * x[n - M1[n]] + g2 * x[n - M2[n]]
%
% where
%
%   M1[n] = P01 + D1 * sin(2*pi*f1 * n / Fs)
%   M2[n] = P02 + D2 * sin(2*pi*f2 * n / Fs)
%
% P01, P02 are the average delays in samples (effect depths)
% D1, D2 are the swing ranges in samples.



% Convert depths and swing ranges from seconds to samples

P01 = delay1      * Fs;   % effect depth for LFO 1 
D1  = swingtime1 * Fs;    % swing range for LFO 1

P02 = delay2      * Fs;   % effect depth for LFO 2
D2  = swingtime2 * Fs;    % swing range for LFO 2 

% M1[n] = P01 + D1 * sin(2π*f1*n / Fs)
% sin(2π*f1*n / Fs) ranges between -1 and +1.
% Therefore,
% Min (M1) = P01 + D1*(-1) = P01 - D1
% Max (M1) = P01 + D1*(+1) = P01 + D1
% So the maximum possible delay is P01 + |D1| (same logic for M2)

MaxDelay1 = P01 + abs(D1);    % maximum delay for voice 1
MaxDelay2 = P02 + abs(D2);    % maximum delay for voice 2

delayLineSize = ceil(max(MaxDelay1, MaxDelay2));   % size of delay line 



% Pre-computing M1[n] and M2[n]

M1 = zeros(L,1);              % delay profile for first voice
M2 = zeros(L,1);              % delay profile for second voice

for n = 1:L
    M1(n) = P01 + D1 * sin(2 * pi * f1 * n / Fs);   % M1[n]
    M2(n) = P02 + D2 * sin(2 * pi * f2 * n / Fs);   % M2[n]
end

M1 = round(M1);               % integer delay values for M1
M2 = round(M2);               % integer delay values for M2


% Limit M1 and M2 to the valid range [1, delayLineSize]

for n = 1:L
    if M1(n) < 1
        M1(n) = 1;
    elseif M1(n) > delayLineSize
        M1(n) = delayLineSize;
    end
    
    if M2(n) < 1
        M2(n) = 1;
    elseif M2(n) > delayLineSize
        M2(n) = delayLineSize;
    end
end



% Pre-allocating output vector zeros

y = zeros(L,1);               



% Pre-allocating a single delay-line buffer

dlinebuf = zeros(delayLineSize,1);   % delay-line buffer used by both voices



% Chorus eqn:
% y[n] = x[n] + g1 * x[n - M1[n]] + g2 * x[n - M2[n]]


for n = 1:L
    
    Inputsample = x(n);       % x[n]
    
    % Current delays M1[n] and M2[n] in samples
    Delay1 = M1(n);
    Delay2 = M2(n);
    
    % Read delayed samples from delay-line buffer
    DelayedSample1 = dlinebuf(Delay1);   % x[n - M1[n]]    % dlinebuf(k) holds approximately x[n - k] at iteration n
    DelayedSample2 = dlinebuf(Delay2);   % x[n - M2[n]]
    
    % Chorus equation
    y(n) = Inputsample + g1 * DelayedSample1 + g2 * DelayedSample2;    
    
   
    % write current input sample at the end of the buffer
    dlinebuf(delayLineSize) = Inputsample;              
    
    % shift buffer so that newer samples move toward index 1
    dlinebuf = circshift(dlinebuf, 1);  
    
end



% Listen to the input and output

% sound(x, Fs);   % Uncomment to listen to the original clean guitar
% sound(y, Fs);   % Uncomment to listen to the chorused guitar 

% From listening, the chorus makes the guitar sound fuller and slightly
% wider and feels like multiple guitars playing,
% while the original track sounds clean.
