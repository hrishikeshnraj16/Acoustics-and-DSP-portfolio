% Code 3 – Angle-Dependent Reflections
%
% This script extends the stereo image source model by making the
% reflection coefficient depend on the angle of incidence.
%
% Hrishikesh N Raj, 09/03/2026


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
Fs   = 48e3;                    % sampling rate (Hz)
cAir = 343;                     % speed of sound in air 


% Receiver positions
a1 = Lx / sqrt(2);
b1 = Ly / pi;
c1 = 1.30;

a2 = a1 + 0.17;
b2 = b1;
c2 = c1;


% Absorption coefficients for the six walls
alpha_x1 = 0.04;                % brick wall
alpha_x2 = 0.55;                % plaster wall

alpha_y1 = 0.17;                % wood wall
alpha_y2 = 0.26;                % carpet wall

alpha_z1 = 0.17;                % wooden floor
alpha_z2 = 0.55;                % plaster ceiling


% Estimate reverberation time
V  = Lx * Ly * Lz;

Ax = Ly * Lz;
Ay = Lx * Lz;
Az = Lx * Ly;

alphaBar = (alpha_x1 + alpha_x2) * Ax + ...
           (alpha_y1 + alpha_y2) * Ay + ...
           (alpha_z1 + alpha_z2) * Az;

T60 = (24 * log(10) / cAir) * (V / alphaBar);


% Maximum image source orders
Nx = ceil((cAir * T60) / Lx);
Ny = ceil((cAir * T60) / Ly);
Nz = ceil((cAir * T60) / Lz);


% Allocate impulse response
IRLength = ceil(1.2 * Fs * T60);
h = zeros(IRLength,2);


% Image source loop
for d = -Nx:Nx
    for e = -Ny:Ny
        for f = -Nz:Nz


            % x-direction offsets
            if mod(d,2) == 0
                Ad1 = d * Lx + p - a1;
                Ad2 = d * Lx + p - a2;
            else
                Ad1 = (d + 1) * Lx - p - a1;
                Ad2 = (d + 1) * Lx - p - a2;
            end


            % y-direction offsets
            if mod(e,2) == 0
                Be1 = e * Ly + q - b1;
                Be2 = e * Ly + q - b2;
            else
                Be1 = (e + 1) * Ly - q - b1;
                Be2 = (e + 1) * Ly - q - b2;
            end


            % z-direction offsets
            if mod(f,2) == 0
                Cf1 = f * Lz + r - c1;
                Cf2 = f * Lz + r - c2;
            else
                Cf1 = (f + 1) * Lz - r - c1;
                Cf2 = (f + 1) * Lz - r - c2;
            end


            % Distance from virtual source to receivers
            l1 = sqrt(Ad1^2 + Be1^2 + Cf1^2);
            l2 = sqrt(Ad2^2 + Be2^2 + Cf2^2);


            % Count reflections at each wall
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


            % Direction cosines
            cosThetaX1 = abs(Ad1) / l1;
            cosThetaY1 = abs(Be1) / l1;
            cosThetaZ1 = abs(Cf1) / l1;

            cosThetaX2 = abs(Ad2) / l2;
            cosThetaY2 = abs(Be2) / l2;
            cosThetaZ2 = abs(Cf2) / l2;


            % Angle-dependent reflection coefficients
            Rx1_1 = (cosThetaX1 - alpha_x1/8) / (cosThetaX1 + alpha_x1/8);
            Rx2_1 = (cosThetaX1 - alpha_x2/8) / (cosThetaX1 + alpha_x2/8);

            Ry1_1 = (cosThetaY1 - alpha_y1/8) / (cosThetaY1 + alpha_y1/8);
            Ry2_1 = (cosThetaY1 - alpha_y2/8) / (cosThetaY1 + alpha_y2/8);

            Rz1_1 = (cosThetaZ1 - alpha_z1/8) / (cosThetaZ1 + alpha_z1/8);
            Rz2_1 = (cosThetaZ1 - alpha_z2/8) / (cosThetaZ1 + alpha_z2/8);

            Rx1_2 = (cosThetaX2 - alpha_x1/8) / (cosThetaX2 + alpha_x1/8);
            Rx2_2 = (cosThetaX2 - alpha_x2/8) / (cosThetaX2 + alpha_x2/8);

            Ry1_2 = (cosThetaY2 - alpha_y1/8) / (cosThetaY2 + alpha_y1/8);
            Ry2_2 = (cosThetaY2 - alpha_y2/8) / (cosThetaY2 + alpha_y2/8);

            Rz1_2 = (cosThetaZ2 - alpha_z1/8) / (cosThetaZ2 + alpha_z1/8);
            Rz2_2 = (cosThetaZ2 - alpha_z2/8) / (cosThetaZ2 + alpha_z2/8);


            % Total reflection gain
            Rtotal1 = (Rx1_1^nx1) * (Rx2_1^nx2) * ...
                      (Ry1_1^ny1) * (Ry2_1^ny2) * ...
                      (Rz1_1^nz1) * (Rz2_1^nz2);

            Rtotal2 = (Rx1_2^nx1) * (Rx2_2^nx2) * ...
                      (Ry1_2^ny1) * (Ry2_2^ny2) * ...
                      (Rz1_2^nz1) * (Rz2_2^nz2);


            % Arrival times
            t1 = l1 / cAir;
            t2 = l2 / cAir;


            % Reflection amplitudes
            g1 = Rtotal1 / l1;
            g2 = Rtotal2 / l2;


            % Convert arrival times to sample indices
            n1 = round(t1 * Fs) + 1;
            n2 = round(t2 * Fs) + 1;


            % Accumulate impulses into the IR
            if n1 <= IRLength
                h(n1,1) = h(n1,1) + g1;
            end

            if n2 <= IRLength
                h(n2,2) = h(n2,2) + g2;
            end


        end
    end
end


% Analyse the impulse response
analyse_IR(h, Fs);


% Load dry audio
[x,FsIn] = audioread('DryGuitar_mono.wav');

if size(x,2) == 2
    x = (x(:,1) + x(:,2))/2;
end

if FsIn ~= Fs
    x = resample(x,Fs,FsIn);
end


% Convolve with impulse responses
y1 = conv(x,h(:,1));
y2 = conv(x,h(:,2));

y = [y1 y2];


% Play stereo output
sound(y,Fs);


% What I observed from the plots:
% Compared to Task 2, the overall decay shape is still similar, but the
% frequency response and spectrogram look slightly less uniform. The
% reflections are shaped more by the path direction, so the decay appears
% smoother and less regular than in the constant-reflection case.

% What I observed from the playback:
% The playback sounds slightly more natural compared to the basic model.
% Reflections vary depending on the angle of incidence, which reduces the
% uniform character of the reverberation and produces a smoother tail.