%-------------------------------------------------------------------------
% Flanger Effect
%
% TThis script will perform a flanger effect, based on feedforward time-varying comb filtering of a
% mono input signal.
%
% Recommended values for the parameters 
%
% DelayTime = 0.005   % 5 ms gives me a clear flanger depth
% f0        = 0.8     
% g         = 0.8     % flanger gain - strong but not too extreme
% a         = 1       % set to 1
%
% Hrishikesh N Raj, 01/12/2025
%------------------------------------------------------------------------- 


% Clearing variables and workspace

close all;
clear;
clc;


% Setting the parameters
DelayTime = 0.005;       % delay line time (seconds)
f0        = 0.8;         % LFO frequency (Hz)
g         = 0.8;         % flanger gain
a         = 1;           % modulation depth


audio = 'Slow Dancing In The Burning Room - John Mayer Isolated Guitar.wav';

% used this audio because the song's slow, sustained guitar playing reveals
% the delay and flanger effect clearly. 


% To read audio file and convert it to mono.

[x, Fs] = audioread(audio);   % x contains audio and Fs is the sample rate


% If stereo, convert to mono by averaging the two channels
if size(x,2) == 2
    x = (x(:,1) + x(:,2)) / 2;
end

L = length(x);                % Length of the mono input signal



% delay line used for the flanger effect
%
%   y[n] = x[n] + g * x[n - M[n]]
%
% delay M[n]:
%
%   M[n] = M0 * (1 + a * sin(2*pi*f0 * n / Fs))
%
% M[n] is bounded by a maximum value Mmax
%
%   1 <= M[n] <= Mmax
%
% We choose M0 to be half of the maximum delay, so it is the average delay.


% Maximum delay and central delay M0 in samples

Mmax = round(DelayTime * Fs);   % maximum delay (samples)
M0   = Mmax / 2;                % centre value of modulation (samples)



% Pre-computing M[n] 

M = zeros(L,1);                 % pre-allocating with zeros         

for n = 1:L
    M(n) = M0 * (1 + a * sin(2 * pi * f0 * n / Fs));   
end

M = round(M);                   % rounding to get integer delay values


% Limit M to the valid range [1, Mmax]
for n = 1:L
    if M(n) < 1
        M(n) = 1;
    elseif M(n) > Mmax
        M(n) = Mmax;
    end
end



% Pre-allocating output 

y = zeros(L,1);                 % output signal



% Pre-allocating delay-line buffer (similar idea to comb filter code)

dlinebuf = zeros(Mmax,1);       % delay-line buffer for flanger
delayLineSize = Mmax;           % size of the delay line 


% y[n] = x[n] + g * x[n - M[n]]
for n = 1:L
    
    Inputsample = x(n);            
    
    % Current delay M[n] 
    CurrentDelay = M(n);            % delay length for this sample
    
    % Read delayed sample from delay-line buffer
    DelayedSample = dlinebuf(CurrentDelay);  
    
    % Flanger equation
    y(n) = Inputsample + g * DelayedSample;    
    
    % write current input sample at the end of the buffer
    dlinebuf(delayLineSize) = Inputsample;              
    
    % shift buffer so that newer samples move toward index 1
    dlinebuf = circshift(dlinebuf, 1);  
    
end



% Listen to the input and output

% sound(x, Fs);   % Uncomment to listen to the original clean guitar 
% sound(y, Fs);   % Uncomment to listen to the flanged signal 

% From listening, I could feel that the flanger making the guitar sound more "whooshy"
% and adds some texture. 
