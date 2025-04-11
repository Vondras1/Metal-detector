
clear all;
clc;

synthetic_data = true;

if (synthetic_data == false)
    fs = 100000;
    
    reference_signal_I = load("with_obj_sine1khz.mat").data_ch2;
    reference_signal_Q = [zeros(25,1)', reference_signal_I(1:(end-25))];
    
    measured_signal = load("without_obj_sine1khz.mat").data_ch1;
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
    % % add noice
    measured_signal = measured_signal + 0.1 * randn(size(t));
end

% Multiply measured signal by reference signal 
I_samples  = measured_signal .* reference_signal_I;
Q_samples  = measured_signal .* reference_signal_Q;

% Sum (Integrate)
I_val = sum(I_samples);
Q_val = sum(Q_samples);

% Count phase
phase_estimated = atan2(Q_val, I_val);

% Result
% fprintf('True phase shift:     %f rad\n', phase_shift);
fprintf('Etimated phase shift:   %f rad\n', phase_estimated); % 2.475800
% fprintf('Difference (error):           %f rad\n', phase_estimated - phase_shift);

%% Plot signals

figure(1);
plot(measured_signal, 'b', 'LineWidth', 1);   % změřený signál
hold on;
plot(reference_signal_I, 'r', 'LineWidth', 1);   % referenční signál
title('Signals');
xlabel('Sample index');
ylabel('Amplitude');
legend('Measured signal', 'reference signal');
xlim([0, 1000]);    % např. omezíme na prvních 1000 vzorků pro přehlednost
grid on;
