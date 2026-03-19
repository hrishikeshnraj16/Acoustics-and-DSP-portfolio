%-------------------------------------------------------------------------
% PBMMI Assessment 1 – Beyond the Basics 1
%
% Major 7th Chord using Modified Karplus-Strong Algorithm
%
% This script generates a Major 7th chord using equal temperament
% frequency ratios and mixes the four notes together.

% Here, the frequency is set to 220 Hz. The program will generate A major7th
%
% Hrishikesh N Raj, 16/02/2026
%------------------------------------------------------------------------- 


% Clearing variables and workspace
close all;
clear;
clc;



% Setting parameters
Fs    = 44.1e3;
T_dur = 3;
R     = 0.95;

f_root = 220;                % Root frequency (Hz)

% Major 7th chord intervals (equal temperament)
f1 = f_root;                 % Root
f2 = f_root * 2^(4/12);      % Major 3rd
f3 = f_root * 2^(7/12);      % Perfect 5th
f4 = f_root * 2^(11/12);     % Major 7th



% Duration in samples
M = round(T_dur * Fs);




% Note 1 (Root)

f0 = f1;

Nexact = (Fs / f0) - 0.5;
N      = floor(Nexact);
Nfrac  = Nexact - N;
C      = (1 - Nfrac) / (1 + Nfrac);

rho = 0.998;

v = 2 * rand(N,1) - 1;
x = zeros(N,1);
y1 = zeros(M,1);

x(1) = (1 - R) * v(1);
for n = 2:N
    x(n) = (1 - R) * v(n) + R * x(n-1);
end

y1(1:N) = x;

w  = 0;
w1 = 0;

if (N+1) <= M
    w = (rho/2) * ( y1(1) + 0 );
    y1(N+1) = C * w + w1 - C * y1(N);
    w1 = w;
end

for n = N+2:M
    w = (rho/2) * ( y1(n-N) + y1(n-N-1) );
    y1(n) = C * w + w1 - C * y1(n-1);
    w1 = w;
end



% Note 2 (Major 3rd)


f0 = f2;

Nexact = (Fs / f0) - 0.5;
N      = floor(Nexact);
Nfrac  = Nexact - N;
C      = (1 - Nfrac) / (1 + Nfrac);

v = 2 * rand(N,1) - 1;
x = zeros(N,1);
y2 = zeros(M,1);

x(1) = (1 - R) * v(1);
for n = 2:N
    x(n) = (1 - R) * v(n) + R * x(n-1);
end

y2(1:N) = x;

w  = 0;
w1 = 0;

if (N+1) <= M
    w = (rho/2) * ( y2(1) + 0 );
    y2(N+1) = C * w + w1 - C * y2(N);
    w1 = w;
end

for n = N+2:M
    w = (rho/2) * ( y2(n-N) + y2(n-N-1) );
    y2(n) = C * w + w1 - C * y2(n-1);
    w1 = w;
end




% Note 3 (Perfect 5th)

f0 = f3;

Nexact = (Fs / f0) - 0.5;
N      = floor(Nexact);
Nfrac  = Nexact - N;
C      = (1 - Nfrac) / (1 + Nfrac);

v = 2 * rand(N,1) - 1;
x = zeros(N,1);
y3 = zeros(M,1);

x(1) = (1 - R) * v(1);
for n = 2:N
    x(n) = (1 - R) * v(n) + R * x(n-1);
end

y3(1:N) = x;

w  = 0;
w1 = 0;

if (N+1) <= M
    w = (rho/2) * ( y3(1) + 0 );
    y3(N+1) = C * w + w1 - C * y3(N);
    w1 = w;
end

for n = N+2:M
    w = (rho/2) * ( y3(n-N) + y3(n-N-1) );
    y3(n) = C * w + w1 - C * y3(n-1);
    w1 = w;
end




% Note 4 (Major 7th)

f0 = f4;

Nexact = (Fs / f0) - 0.5;
N      = floor(Nexact);
Nfrac  = Nexact - N;
C      = (1 - Nfrac) / (1 + Nfrac);

v = 2 * rand(N,1) - 1;
x = zeros(N,1);
y4 = zeros(M,1);

x(1) = (1 - R) * v(1);
for n = 2:N
    x(n) = (1 - R) * v(n) + R * x(n-1);
end

y4(1:N) = x;

w  = 0;
w1 = 0;

if (N+1) <= M
    w = (rho/2) * ( y4(1) + 0 );
    y4(N+1) = C * w + w1 - C * y4(N);
    w1 = w;
end

for n = N+2:M
    w = (rho/2) * ( y4(n-N) + y4(n-N-1) );
    y4(n) = C * w + w1 - C * y4(n-1);
    w1 = w;
end



% Mix and normalise

yMaj7 = y1 + y2 + y3 + y4;
yMaj7 = yMaj7 / (max(abs(yMaj7)) + eps);

soundsc(yMaj7, Fs);
