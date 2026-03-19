% Code - 4
%
% Frequency Dependent Wall Absorption
%
% This version extends the angle-dependent reflection model by allowing
% the wall absorption to vary across frequency bands.
%
% A separate stereo impulse response is built for each band. These band
% responses are then combined through the same filterbank structure used
% on the dry signal.
%
% Hrishikesh N Raj, 9/03/2026
%------------------------------------------------------------------------


% Clearing workspace
close all;
clear;
clc;


% Room dimensions (m)
Lx = 7;
Ly = 13;
Lz = 3;

% Source position (m)
p = 6.5;
q = 8;
r = 2.4;


% Simulation parameters
Fs   = 48e3;
cAir = 343;


% Receiver positions
a1 = Lx / sqrt(2);
b1 = Ly / pi;
c1 = 1.30;

a2 = a1 + 0.17;
b2 = b1;
c2 = c1;


% Octave-band centres (Hz)
fc = [62.5 125 250 500 1000 2000 4000 8000];

% Band edges used for filtering
fEdge = [88.39 176.78 353.55 707.11 1414.21 2828.43 5656.85];


% Absorption coefficients for each wall and each band
%
% The low and high end bands are formed by repeating the nearest
% available values.

alpha_x1 = [0.02 0.02 0.02 0.03 0.04 0.05 0.05 0.05];
alpha_x2 = [0.35 0.35 0.30 0.20 0.55 0.10 0.04 0.04];

alpha_y1 = [0.30 0.30 0.25 0.20 0.17 0.15 0.10 0.10];
alpha_y2 = [0.09 0.09 0.08 0.21 0.26 0.27 0.37 0.37];

alpha_z1 = [0.30 0.30 0.25 0.20 0.17 0.15 0.10 0.10];
alpha_z2 = [0.35 0.35 0.30 0.20 0.55 0.10 0.04 0.04];


% Number of bands
NBands = length(fc);


% Room volume and surface areas
V  = Lx * Ly * Lz;

Ax = Ly * Lz;
Ay = Lx * Lz;
Az = Lx * Ly;


% T60 for each band
T60Band = zeros(NBands,1);

for k = 1:NBands

    alphaBar = (alpha_x1(k) + alpha_x2(k)) * Ax + ...
               (alpha_y1(k) + alpha_y2(k)) * Ay + ...
               (alpha_z1(k) + alpha_z2(k)) * Az;

    T60Band(k) = (24 * log(10) / cAir) * (V / alphaBar);

end


% One common IR length is used for all bands
T60Max   = max(T60Band);
IRLength = ceil(1.2 * Fs * T60Max);


% Each band has its own stereo impulse response because the wall
% absorption now changes with frequency.

hBand = zeros(IRLength,2,NBands);


% Here the image source method is repeated for each frequency band.
% The angle-dependent reflection model is kept, but the absorption
% values now change from band to band.

for k = 1:NBands

    Nx = ceil((cAir * T60Band(k)) / Lx);
    Ny = ceil((cAir * T60Band(k)) / Ly);
    Nz = ceil((cAir * T60Band(k)) / Lz);


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


                % direction cosines
                cosThetaX1 = abs(Ad1) / l1;
                cosThetaY1 = abs(Be1) / l1;
                cosThetaZ1 = abs(Cf1) / l1;

                cosThetaX2 = abs(Ad2) / l2;
                cosThetaY2 = abs(Be2) / l2;
                cosThetaZ2 = abs(Cf2) / l2;


                % angle-dependent reflection coefficients for this band
                Rx1_1 = (cosThetaX1 - alpha_x1(k)/8) / (cosThetaX1 + alpha_x1(k)/8);
                Rx2_1 = (cosThetaX1 - alpha_x2(k)/8) / (cosThetaX1 + alpha_x2(k)/8);

                Ry1_1 = (cosThetaY1 - alpha_y1(k)/8) / (cosThetaY1 + alpha_y1(k)/8);
                Ry2_1 = (cosThetaY1 - alpha_y2(k)/8) / (cosThetaY1 + alpha_y2(k)/8);

                Rz1_1 = (cosThetaZ1 - alpha_z1(k)/8) / (cosThetaZ1 + alpha_z1(k)/8);
                Rz2_1 = (cosThetaZ1 - alpha_z2(k)/8) / (cosThetaZ1 + alpha_z2(k)/8);

                Rx1_2 = (cosThetaX2 - alpha_x1(k)/8) / (cosThetaX2 + alpha_x1(k)/8);
                Rx2_2 = (cosThetaX2 - alpha_x2(k)/8) / (cosThetaX2 + alpha_x2(k)/8);

                Ry1_2 = (cosThetaY2 - alpha_y1(k)/8) / (cosThetaY2 + alpha_y1(k)/8);
                Ry2_2 = (cosThetaY2 - alpha_y2(k)/8) / (cosThetaY2 + alpha_y2(k)/8);

                Rz1_2 = (cosThetaZ2 - alpha_z1(k)/8) / (cosThetaZ2 + alpha_z1(k)/8);
                Rz2_2 = (cosThetaZ2 - alpha_z2(k)/8) / (cosThetaZ2 + alpha_z2(k)/8);


                % total reflection gain for this band
                Rtotal1 = (Rx1_1^nx1) * (Rx2_1^nx2) * ...
                          (Ry1_1^ny1) * (Ry2_1^ny2) * ...
                          (Rz1_1^nz1) * (Rz2_1^nz2);

                Rtotal2 = (Rx1_2^nx1) * (Rx2_2^nx2) * ...
                          (Ry1_2^ny1) * (Ry2_2^ny2) * ...
                          (Rz1_2^nz1) * (Rz2_2^nz2);


                % arrival times
                t1 = l1 / cAir;
                t2 = l2 / cAir;


                % amplitudes
                g1 = Rtotal1 / l1;
                g2 = Rtotal2 / l2;


                % sample bins
                n1 = round(t1 * Fs) + 1;
                n2 = round(t2 * Fs) + 1;


                if n1 <= IRLength
                    hBand(n1,1,k) = hBand(n1,1,k) + g1;
                end

                if n2 <= IRLength
                    hBand(n2,2,k) = hBand(n2,2,k) + g2;
                end


            end
        end
    end

end


% The full model does not produce one single IR directly, since the
% response is built separately for each band.
%
% So here a broadband stereo IR is formed by passing a unit impulse
% through the same band-splitting and summation process used later
% for the dry signal.

xImp = [1; zeros(IRLength-1,1)];
xImpBand = zeros(length(xImp),NBands);


% The unit impulse is filtered into the same bands so that the final
% analysed IR matches the frequency-dependent system actually used.

[b,a]         = butter(4, fEdge(1)/(Fs/2), 'low');
xImpBand(:,1) = filter(b,a,xImp);

[b,a]         = butter(4, [fEdge(1) fEdge(2)]/(Fs/2), 'bandpass');
xImpBand(:,2) = filter(b,a,xImp);

[b,a]         = butter(4, [fEdge(2) fEdge(3)]/(Fs/2), 'bandpass');
xImpBand(:,3) = filter(b,a,xImp);

[b,a]         = butter(4, [fEdge(3) fEdge(4)]/(Fs/2), 'bandpass');
xImpBand(:,4) = filter(b,a,xImp);

[b,a]         = butter(4, [fEdge(4) fEdge(5)]/(Fs/2), 'bandpass');
xImpBand(:,5) = filter(b,a,xImp);

[b,a]         = butter(4, [fEdge(5) fEdge(6)]/(Fs/2), 'bandpass');
xImpBand(:,6) = filter(b,a,xImp);

[b,a]         = butter(4, [fEdge(6) fEdge(7)]/(Fs/2), 'bandpass');
xImpBand(:,7) = filter(b,a,xImp);

[b,a]         = butter(4, fEdge(7)/(Fs/2), 'high');
xImpBand(:,8) = filter(b,a,xImp);


hEffL = zeros(IRLength + IRLength - 1,1);
hEffR = zeros(IRLength + IRLength - 1,1);

for k = 1:NBands

    hEffL = hEffL + conv(xImpBand(:,k), hBand(:,1,k));
    hEffR = hEffR + conv(xImpBand(:,k), hBand(:,2,k));

end

hEff = [hEffL hEffR];


% Analyse the effective broadband stereo impulse response
analyse_IR(hEff, Fs);


% Load dry audio
[x,FsIn] = audioread('DryGuitar_mono.wav');

if size(x,2) == 2
    x = (x(:,1) + x(:,2)) / 2;
end

if FsIn ~= Fs
    x = resample(x,Fs,FsIn);
end


% Butterworth filters are used to split the signal into bands.
% They provide a smooth and stable response, which works well here.

xBand = zeros(length(x),NBands);


% The dry input is split into matching bands, so each part of the
% signal is convolved with the corresponding band impulse response.

[b,a]      = butter(4, fEdge(1)/(Fs/2), 'low');
xBand(:,1) = filter(b,a,x);

[b,a]      = butter(4, [fEdge(1) fEdge(2)]/(Fs/2), 'bandpass');
xBand(:,2) = filter(b,a,x);

[b,a]      = butter(4, [fEdge(2) fEdge(3)]/(Fs/2), 'bandpass');
xBand(:,3) = filter(b,a,x);

[b,a]      = butter(4, [fEdge(3) fEdge(4)]/(Fs/2), 'bandpass');
xBand(:,4) = filter(b,a,x);

[b,a]      = butter(4, [fEdge(4) fEdge(5)]/(Fs/2), 'bandpass');
xBand(:,5) = filter(b,a,x);

[b,a]      = butter(4, [fEdge(5) fEdge(6)]/(Fs/2), 'bandpass');
xBand(:,6) = filter(b,a,x);

[b,a]      = butter(4, [fEdge(6) fEdge(7)]/(Fs/2), 'bandpass');
xBand(:,7) = filter(b,a,x);

[b,a]      = butter(4, fEdge(7)/(Fs/2), 'high');
xBand(:,8) = filter(b,a,x);


% Each band is convolved separately and the outputs are summed to
% produce the final stereo  signal.

yL = zeros(length(x) + IRLength - 1,1);
yR = zeros(length(x) + IRLength - 1,1);

for k = 1:NBands

    yL = yL + conv(xBand(:,k), hBand(:,1,k));
    yR = yR + conv(xBand(:,k), hBand(:,2,k));

end

y = [yL yR];


% Normalisation
y = y ./ max(abs(y(:)));


% Playback
sound(y,Fs);


% What I observed from the plots:
% Compared to the angle-dependent version, the time-domain decay now
% looks less broadband and the spectrogram shows a clearer change in
% frequency content over time. Higher frequencies lose energy faster,
% while the lower-frequency part remains stronger for longer. The
% frequency response is also more shaped, which is consistent with the
% use of band-dependent wall absorption.

% What I observed from the playback:
% The playback sounds more natural than the basic model. The reverb tail
% becomes warmer as higher frequencies decay faster, while the angle-
% dependent reflections also make the decay feel smoother.