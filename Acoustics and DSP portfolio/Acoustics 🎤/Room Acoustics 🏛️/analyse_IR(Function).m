function analyse_IR(ir,fs)

if size(ir,2) > size(ir,1); ir = ir'; end
if size(ir,2) > 2; ir = ir(:,1); end  % if more than 2 channels, assume it's ambisonic and just plot the first (w) channel

figure;

%% plot time-domain response:
subplot(2,2,1);

xvec = 1:1:(length(ir(:,1,1)));
timevec = xvec./fs;

% plot(timevec,(ir)); xlabel('Time (s)'); ylabel('Amplitude (db)');
plot(timevec,db(ir-eps)); xlabel('Time (s)'); ylabel('Amplitude (db)');
ylim([-80 0])
title('Time-domain')

%% plot frequency response:
subplot(2,2,2);

f = fs/length(ir(:,1)):fs/length(ir(:,1)):fs; % Frequency vector for plotting
semilogx(f,20*log10(abs(fft(ir)))); % Plot the fft

xlim([20 20000]); grid on;
title('Frequency response');
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');

%% spectrogram
subplot(2,2,3);

spectrogram(ir(:,1),kaiser(256,5),220/2,512,fs,'yaxis'); % just plot first channel
ylim([0 20]);
% yscale("log")
title('Spectrogram');

%% Plot Energy Decay Curve, linear regression and obtain RT60 value

% set parameters:
frequency_bands = [500 2000]; % usually reported for more than one frequency band
rt_fit_db = [-5 -20];

% bandpass filter
for f_band = 1:length(frequency_bands)
    [B_decay(f_band,:), A_decay(f_band,:)] = octdsgn(frequency_bands(f_band), fs, 3);
end

clear RT60_line RT60_ind

timevec = timevec(1:end-1);

for f_band = 1:length(frequency_bands) % number of frequency bands
    for lr = 1:size(ir,2) % number of channels in IR
        % filter and schroeder integration to get EDC:
        rir_input_filt = filter(B_decay(f_band,:),A_decay(f_band,:),ir(:,lr));

        % schroeder integration:
        int_sch = 1/length(rir_input_filt) * cumtrapz(flip(rir_input_filt /...
            max(abs(rir_input_filt))).^2);
        edc = flip(int_sch(2:end));
        edc = edc / max(edc); % normalise
        edc_db(:,lr,f_band) = 10*log10(edc); % EDC in dB

        % find values on EDC at which the decay has passed the values for the
        % linear regression:
        t1 = find(edc_db(:,lr,f_band) <= rt_fit_db(1),1,'first');
        t2 = find(edc_db(:,lr,f_band) <= rt_fit_db(2),1,'first');

        % get differences at these points, obtain regression:
        x  = t2-t1;
        y = edc_db(t2,lr,f_band) - edc_db(t1,lr,f_band);
        xy = y/x;
        yvec = (1:1:length(edc_db(:,1,1))*10)*xy;

        % threshold (in dB)
        rt_thresh = 60;

        % align regression line to correct y axis value:
        RT60_line(:,lr,f_band) = (yvec+edc_db(t1(1),lr,f_band)-yvec(t1(1)))';
        RT60_ind_0(lr,f_band) = find(RT60_line(:,lr,f_band) <= 0,1,'first'); % find when the regression passes 0dB
        RT60_ind_thresh(lr,f_band) = find(RT60_line(:,lr,f_band) <= -rt_thresh,1,'first'); % find when the regression passes -60dB
    end
end

RT60 = (RT60_ind_thresh-RT60_ind_0)/fs; % get RT60 in seconds

% plot EDC and regression:
subplot(2,2,4);
    plot(timevec,squeeze(edc_db(:,1,:)))
    hold on;
    plot(timevec,squeeze(RT60_line(1:length(timevec),1,:)),'--');
    ylabel('Energy (dB)');xlabel('Time (s)');
    title(['EDC: ',num2str(frequency_bands),' Hz, T',num2str(rt_fit_db(1)-...
        rt_fit_db(2),2),' = ',num2str(RT60(1,:),3),' s'])
    ylim([-60 0]);
end



%% octave filterbank design

function [B,A] = octdsgn(Fc,Fs,N)
% OCTDSGN  Design of an octave filter.
%    [B,A] = OCTDSGN(Fc,Fs,N) designs a digital octave filter with 
%    center frequency Fc for sampling frequency Fs. 
%    The filter are designed according to the Order-N specification 
%    of the ANSI S1.1-1986 standard. Default value for N is 3. 
%    Warning: for meaningful design results, center values used
%    should preferably be in range Fs/200 < Fc < Fs/5.
%    Usage of the filter: Y = FILTER(B,A,X). 
%
%    Requires the Signal Processing Toolbox. 
%
%    See also OCTSPEC, OCT3DSGN, OCT3SPEC.

% Author: Christophe Couvreur, Faculte Polytechnique de Mons (Belgium)
%         couvreur@thor.fpms.ac.be
% Last modification: Aug. 22, 1997, 9:00pm.

% References: 
%    [1] ANSI S1.1-1986 (ASA 65-1986): Specifications for
%        Octave-Band and Fractional-Octave-Band Analog and
%        Digital Filters, 1993.

if (nargin > 3) | (nargin < 2)
  error('Invalide number of arguments.');
end
if (nargin == 2)
  N = 3; 
end
if (Fc > 0.70*(Fs/2))
  error('Design not possible. Check frequencies.');
end

% Design Butterworth 2Nth-order octave filter 
% Note: BUTTER is based on a bilinear transformation, as suggested in [1]. 
%W1 = Fc/(Fs/2)*sqrt(1/2);
%W2 = Fc/(Fs/2)*sqrt(2); 
pi = 3.14159265358979;
beta = pi/2/N/sin(pi/2/N); 
alpha = (1+sqrt(1+8*beta^2))/4/beta;
W1 = Fc/(Fs/2)*sqrt(1/2)/alpha; 
W2 = Fc/(Fs/2)*sqrt(2)*alpha;
[B,A] = butter(N,[W1,W2]); 

end