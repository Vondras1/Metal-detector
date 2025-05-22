clear all;
clc;

% Parametry
fs = 1e6;         % Sampling frequency (Hz)
f0 = 8e3;         % Carrier frequency (Hz)

% Count the number of samples required to shift the signal by 90°
n_period = floor(fs/f0); % number of samples per period
k_shift = floor(n_period / 4); % number of samples to shift signal by 90°

% Paths to files with data
materials = ["bronze", "brass", "iron"];
poses = [1, 2, 3, 4];

% Matrices to save results
results_method1 = zeros(length(materials), length(poses));
results_fft = zeros(length(materials), length(poses)); 

for i = 1:length(materials)
    for j = 1:length(poses)
        % Create path to the files
        data_path = sprintf("singlefreq_data/%s_8k_pose_%d.mat", materials(i), poses(j));
        data = load(data_path);
    
        reference_signal_I = data.data_ch1;
        reference_signal_Q = [zeros(k_shift,1)', reference_signal_I(1:(end-k_shift))]; % Shift by 90° 
        
        measured_signal = data.data_ch2;

        N = length(reference_signal_I); % I assume that both signals have the same length
        
        %%% First method - something like synchronous detection
        % Multiply the measured signal by the reference signals 
        I_samples  = measured_signal .* reference_signal_I;
        Q_samples  = measured_signal .* reference_signal_Q;
        
        % Sum (Integrate)
        I_val = sum(I_samples);
        Q_val = sum(Q_samples);
        
        % Calculate the phase
        phase_estimated = atan2(Q_val, I_val);

        results_method1(i,j) = rad2deg(phase_estimated);

%         % Print it out
%         fprintf("Material: %s, Pose: %d => Phase shift: %.2f°\n", ...
%                 materials(i), poses(j), results_method1(i,j));
    end
end

results_method1
results_fft

