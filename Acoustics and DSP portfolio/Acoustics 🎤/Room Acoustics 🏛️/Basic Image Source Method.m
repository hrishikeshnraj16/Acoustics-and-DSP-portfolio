% Basic Image Source Method
%
% This Matlab script implements the basic image source method for a
% shoebox room with a mono source and receiver.
%
% Hrishikesh N Raj, 10/03/2026
%--------------------------------------------------------------------------

% Clearing variables and workspace
close all;
clear;
clc;


% Room dimensions
Lx = 7;
Ly = 13;
Lz = 3;

% Receiver position
a = 2;
b = 3.7;
c = 1.3;

% Source position
p = 6.5;
q = 8;
r = 2.4;


% Setting the parameters
Fs    = 48e3;          % sampling rate in Hz
cAir  = 343;           % speed of sound in air (m/s)
alpha = 0.15;          % wall absorption coefficient


% Reflection coefficient
R = sqrt(1 - alpha);


% Estimating reverberation time T60
V   = Lx * Ly * Lz;
Axy = Lx * Ly;
Axz = Lx * Lz;
Ayz = Ly * Lz;

alphaBar = alpha * (2*Axy + 2*Axz + 2*Ayz);

T60 = (24 * log(10) / cAir) * (V / alphaBar);


% Estimating the maximum image source order
N = ceil((cAir * T60) / min([Lx Ly Lz]));


% Allocating the impulse response
IRLength = ceil(1.2 * Fs * T60);
h = zeros(IRLength, 1);


% Building the impulse response using the image source method
for d = -N:N
    for e = -N:N
        for f = -N:N

            % x-direction image source offset
            if mod(d,2) == 0
                Ad = d * Lx + p - a;
            else
                Ad = (d + 1) * Lx - p - a;
            end

            % y-direction image source offset
            if mod(e,2) == 0
                Be = e * Ly + q - b;
            else
                Be = (e + 1) * Ly - q - b;
            end

            % z-direction image source offset
            if mod(f,2) == 0
                Cf = f * Lz + r - c;
            else
                Cf = (f + 1) * Lz - r - c;
            end

            % Distance from image source to receiver
            lDef = sqrt(Ad^2 + Be^2 + Cf^2);

            % Number of wall collisions
            w = abs(d) + abs(e) + abs(f);

            % Arrival time
            ArrivalTime = lDef / cAir;

            % Reflected impulse amplitude
            gDef = (R^w) / lDef;

            % Nearest sample bin
            SampleIndex = round(ArrivalTime * Fs) + 1;

            % Accumulating into the impulse response
            if SampleIndex <= IRLength
                h(SampleIndex) = h(SampleIndex) + gDef;
            end

        end
    end
end


% Analysing the impulse response
analyse_IR(h, Fs);


% Reading a dry audio file
[x, FsIn] = audioread('DryGuitar_mono.wav');

% Converting stereo input to mono if needed
if size(x,2) == 2
    x = (x(:,1) + x(:,2)) / 2;
end

% Resampling input if needed
if FsIn ~= Fs
    x = resample(x, Fs, FsIn);
end


% Convolution with the room impulse response
y = conv(x, h);


% Listening to the reverberated output
sound(y, Fs);


% What I observed from the plots:
% The time-domain plot shows a strong early part followed by a gradual
% decay. The frequency response is broadband, while the EDC shows a
% clear downward decay, consistent with a reverberant room response.

% What I observed from the playback:
% The playback sounds like the guitar is placed inside a room rather than
% recorded dry. The notes sustain slightly longer and a clear reverberant
% tail follows each note, giving a sense of space around the instrument.