% Code 2 – Stereo Image Source Method
%
% Coding a stereo image source model with distinct materials
% for each wall
%
% Hrishikesh N Raj, 10/03/2026
%--------------------------------------------------------------------------

% Clearing workspace
close all;
clear;
clc;


% Room dimensions
Lx = 7;
Ly = 13;
Lz = 3;

% Source position
p = 6.5;
q = 8;
r = 2.4;


% Simulation parameters
Fs   = 48e3;      % sampling rate
cAir = 343;       % speed of sound in air


% Receiver positions
a1 = Lx / sqrt(2);
b1 = Ly / pi;
c1 = 1.30;

a2 = a1 + 0.17;
b2 = b1;
c2 = c1;


% Absorption coefficients for the six walls
alpha_x1 = 0.04;    % brick
alpha_x2 = 0.55;    % plaster

alpha_y1 = 0.17;    % wood
alpha_y2 = 0.26;    % carpet

alpha_z1 = 0.17;    % wood
alpha_z2 = 0.55;    % plaster


% Reflection coefficients
Rx1 = sqrt(1 - alpha_x1);
Rx2 = sqrt(1 - alpha_x2);

Ry1 = sqrt(1 - alpha_y1);
Ry2 = sqrt(1 - alpha_y2);

Rz1 = sqrt(1 - alpha_z1);
Rz2 = sqrt(1 - alpha_z2);


% Estimate T60
V = Lx * Ly * Lz;

Ax = Ly * Lz;
Ay = Lx * Lz;
Az = Lx * Ly;

alphaBar = (alpha_x1 + alpha_x2) * Ax + ...
           (alpha_y1 + alpha_y2) * Ay + ...
           (alpha_z1 + alpha_z2) * Az;

T60 = (24 * log(10) / cAir) * (V / alphaBar);


% Maximum image source orders in each direction
Nx = ceil((cAir * T60) / Lx);
Ny = ceil((cAir * T60) / Ly);
Nz = ceil((cAir * T60) / Lz);


% Allocating the stereo impulse response
IRLength = ceil(1.2 * Fs * T60);
h = zeros(IRLength,2);


% Main image source loop
for d = -Nx:Nx
    for e = -Ny:Ny
        for f = -Nz:Nz

            % x offsets
            if mod(d,2) == 0
                Ad1 = d * Lx + p - a1;
                Ad2 = d * Lx + p - a2;
            else
                Ad1 = (d + 1) * Lx - p - a1;
                Ad2 = (d + 1) * Lx - p - a2;
            end


            % y offsets
            if mod(e,2) == 0
                Be1 = e * Ly + q - b1;
                Be2 = e * Ly + q - b2;
            else
                Be1 = (e + 1) * Ly - q - b1;
                Be2 = (e + 1) * Ly - q - b2;
            end


            % z offsets
            if mod(f,2) == 0
                Cf1 = f * Lz + r - c1;
                Cf2 = f * Lz + r - c2;
            else
                Cf1 = (f + 1) * Lz - r - c1;
                Cf2 = (f + 1) * Lz - r - c2;
            end


            % distances
            l1 = sqrt(Ad1^2 + Be1^2 + Cf1^2);
            l2 = sqrt(Ad2^2 + Be2^2 + Cf2^2);


            % reflection counts
            if d >= 0
                nx1 = ceil(abs(d)/2);
                nx2 = floor(abs(d)/2);
            else
                nx1 = floor(abs(d)/2);
                nx2 = ceil(abs(d)/2);
            end

            if e >= 0
                ny1 = ceil(abs(e)/2);
                ny2 = floor(abs(e)/2);
            else
                ny1 = floor(abs(e)/2);
                ny2 = ceil(abs(e)/2);
            end

            if f >= 0
                nz1 = ceil(abs(f)/2);
                nz2 = floor(abs(f)/2);
            else
                nz1 = floor(abs(f)/2);
                nz2 = ceil(abs(f)/2);
            end


            % total reflection gain
            Rtotal = (Rx1^nx1) * (Rx2^nx2) * ...
                     (Ry1^ny1) * (Ry2^ny2) * ...
                     (Rz1^nz1) * (Rz2^nz2);


            % arrival times
            t1 = l1 / cAir;
            t2 = l2 / cAir;


            % amplitudes
            g1 = Rtotal / l1;
            g2 = Rtotal / l2;


            % sample bins
            n1 = round(t1 * Fs) + 1;
            n2 = round(t2 * Fs) + 1;


            % accumulate into stereo IR
            if n1 <= IRLength
                h(n1,1) = h(n1,1) + g1;
            end

            if n2 <= IRLength
                h(n2,2) = h(n2,2) + g2;
            end

        end
    end
end


% Analysing the impulse response
analyse_IR(h, Fs);


% Load dry audio
[x, FsIn] = audioread('DryGuitar_mono.wav');

% Convert stereo input to mono if needed
if size(x,2) == 2
    x = (x(:,1) + x(:,2)) / 2;
end

% Resample if needed
if FsIn ~= Fs
    x = resample(x, Fs, FsIn);
end


% Convolve the dry signal with each channel of the IR
y1 = conv(x, h(:,1));
y2 = conv(x, h(:,2));

y = [y1 y2];


% Play the stereo output
sound(y, Fs);


% What I observed from the plots:
% Compared to Task 1, the time-domain decay is less uniform because the
% six wall materials introduce different reflection strengths. The
% frequency response is also less even, showing more variation across
% frequency than the basic mono model. The EDC still shows a clear decay.

% What I observed from the playback:
% The stereo playback produces a wider spatial impression. The guitar no
% longer feels centred in a single point and the reverberation spreads
% across the left and right channels, creating a more immersive room
% effect compared to the mono result.