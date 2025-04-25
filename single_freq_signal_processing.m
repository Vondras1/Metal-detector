%% ------------------------------------------
% This script estimates the phase shift between two signals. It is assumed 
% that both signals consist of a single frequency component. It is possible 
% to either generate synthetic data by setting `synthetic_data = true`,
% or to work with real measurement data obtained from an oscilloscope. 
% In both cases, it is necessary to set the sampling frequency `fs` 
% and the carrier frequency `f0`.
%
% Two methods are implemented. The first method is based on something similar to 
% synchronous detection; the second one uses the Fast Fourier Transform (FFT) 
% to estimate the phase difference.
% -------------------------------------------

clear all;
clc;

synthetic_data = true;

if (synthetic_data == false)
    fs = 100000;         % sampling frequency (Hz)
    f0 = 1000;           % cerrier frequency (Hz)

    with = "with_obj_sine1khz.mat";
    without = "without_obj_sine1khz.mat";

    reference_signal_I = load("without_obj_sine1khz.mat").data_ch1;
    reference_signal_Q = [zeros(25,1)', reference_signal_I(1:(end-25))]; % Shift by 90° 
    
    measured_signal = load("without_obj_sine1khz.mat").data_ch2;
else
    fs = 10000;         % sampling frequency (Hz)
    f0 = 1000;          % cerrier frequency (Hz)
    t = 0:1/fs:1;       % time axis
    
    % Reference signal
    reference_signal_I = sin(2*pi*f0*t);    % In-phase
    
    % Shift reference signal by 90°
    reference_signal_Q = cos(2*pi*f0*t);    % shifted by 90°
    
    % Simulate received signal with phase shift
    phase_shift = pi/4;
    measured_signal = sin(2*pi*f0*t + phase_shift);
    % Amplitude modulation
    ampl = 0.2;
    measured_signal = ampl * measured_signal;
    % Add noise
    measured_signal = measured_signal + 0.1 * randn(size(t));
end

N = length(reference_signal_I); % I assume that both signals have the same length

%% First method - something like synchronous detection

% Multiply the measured signal by the reference signals 
I_samples  = measured_signal .* reference_signal_I;
Q_samples  = measured_signal .* reference_signal_Q;

% Sum (Integrate)
I_val = sum(I_samples);
Q_val = sum(Q_samples);

% Calculate the phase
phase_estimated = atan2(Q_val, I_val);

% Display the result
% fprintf('True phase shift:     %f rad\n', phase_shift);
fprintf('Method1, Etimated phase shift:   %f deg\n', rad2deg(phase_estimated));
% fprintf('Difference (error):           %f rad\n', phase_estimated - phase_shift);

%% Second method - FFT

reference = fft(reference_signal_I);
measured = fft(measured_signal);

% Index corresponding to carrier frequency f0
f_axis = (0:N-1)*(fs/N);

% Span around carrier frequency f0
span_Hz = 40; % ±20 Hz around f0

% Find indices around carrier frequency f0
freq_indices = find(f_axis >= (f0 - span_Hz/2) & f_axis <= (f0 + span_Hz/2));

% Find index with max amplitude in selected span - measured signal
[~, measured_max_idx] = max(abs(measured(freq_indices)));
measured_idx = freq_indices(measured_max_idx);
phase_measured = angle(measured(measured_idx));

% Find index with max amplitude in selected span - reference signal
[~, reference_max_idx] = max(abs(reference(freq_indices)));
reference_idx = freq_indices(reference_max_idx);
phase_reference = angle(reference(reference_idx));

% [~, f0_index] = min(abs(f_axis - f0))

phase_diff = rad2deg(phase_measured - phase_reference);

fprintf("FFT, Estimated phase shift: %f deg\n", phase_diff);

%% Plot signals
figure(1);
plot(measured_signal, 'b', 'LineWidth', 1); % Measured signal
hold on;
plot(reference_signal_I, 'r', 'LineWidth', 1); % Reference signal
title('Signals');
xlabel('Sample index');
ylabel('Amplitude');
legend('Measured signal', 'reference signal');
xlim([0, 1000]);
grid on;
