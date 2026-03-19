%-------------------------------------------------------------------------
% Comb Filtering
%
% This script implements feedforward and feedback comb filtering for the 
% the inputted audio file. 
%
% Setting the parameters
% delay = 0.03;    % delay (seconds) - 30 ms gives me a clear comb effect on sustained guitar
% g     = 0.5;     % comb gain - moderate strength (audible but not too extreme)
%
%
% Hrishikesh N Raj, 30/11/2025
%------------------------------------------------------------------------- 


% Clearing variables and workspace

close all;
clear;
clc;


% Setting the parameters
delay = 0.03;                % delay (seconds)
g     = 0.5;                 % comb gain

audio = 'Slow Dancing In The Burning Room - John Mayer Isolated Guitar.wav';

% used this audio because the clean, sustained guitar notes make the comb
% filter effect easy to hear.




% To read audio file
[x, Fs] = audioread(audio); 

% If stereo, convert to mono by averaging the two channels
if size(x,2) == 2
    x = (x(:,1) + x(:,2)) / 2;
end

L = length(x);                % Length of the mono input signal



% Delay in samples and buffer initialisation
M = round(delay * Fs);                    % integer delay in samples (rounded to nearest integer)



% Pre-allocating output vectors 
y_ff = zeros(L,1);            % output of feedforward comb filter
y_fb = zeros(L,1);            % output of feedback comb filter


% Pre-allocating delay-line buffers with M zeros
dlinebuf_ff = zeros(M,1);     % delay-line buffer for feedforward comb
dlinebuf_fb = zeros(M,1);     % delay-line buffer for feedback comb



% Feedforward comb filter
% Equation:
% y_ff[n] = x[n] + g * x[n - M]


for n = 1:L
    
    Inputsample = x(n);          
    
    DelayedSample_ff = dlinebuf_ff(M);           % dlinebuf_ff(M) holds x[n - M] at each iteration
    
    y_ff(n) = Inputsample + g * DelayedSample_ff;
    
    dlinebuf_ff(M) = Inputsample;              
    dlinebuf_ff    = circshift(dlinebuf_ff, 1);  
    
end



% Feedback comb filter
% Equation:
% y_fb[n] = x[n] + g * y_fb[n - M]


for n = 1:L
    
    Inputsample = x(n);         

    DelayedSample_fb = dlinebuf_fb(M);         % dlinebuf_fb(M) holds y_fb[n - M]
    
    y_fb(n) = Inputsample + g * DelayedSample_fb;
    
    dlinebuf_fb(M) = y_fb(n);                     
    dlinebuf_fb    = circshift(dlinebuf_fb, 1);   
    
end


% Listen to the outputs

% sound(y_ff, Fs);   % Uncomment to listen to feedforward comb output
sound(y_fb, Fs);   % Uncomment to listen to feedback comb output


% Listen to the input 
% sound(x,Fs);   % To compare with the original

% From listening, I could feel that feedforward comb has a slightly brighter / hollow tone
% wheareas feedback comb has a bit more resonant and metallic tone. 
