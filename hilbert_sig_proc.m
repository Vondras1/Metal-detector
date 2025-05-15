close all;

figure(1)
subplot(2,1,1)
title("pose 1 and 3")
ylim([0 200])
hold on;
for pose=[1 3]
    plot_data("iron", pose, 'r');
    plot_data("brass", pose, 'g');
    plot_data("bronze", pose,'b');
end
legend("iron", "brass", "bronze");

subplot(2,1,2)
title("pose 2 and 4")
hold on;
for pose=[2 4]
    plot_data("iron", pose, 'r');
    plot_data("brass", pose, 'g');
    plot_data("bronze", pose,'b');
end
legend("iron", "brass", "bronze");


function y = myfilter(x, order, cutoff_freq)
    chirp_period = 0.1; % (s)
    nsamples = 100000;
    
    fs = nsamples/chirp_period;
    
    % order = 4;              % filter order
    %cutoff_freq = 20000;         % Cutoff frequency in Hz
    Wn = cutoff_freq / (fs/2); % Normalized cutoff (Nyquist frequency)
    [b, a] = butter(order, Wn, 'low');
    
    % Apply the filter
    y = filtfilt(b, a, x);  % Zero-phase filtering
end

function [exc,pic] = get_filtered_signals(x)
    exc_ = detrend(x.data_ch1);
    pic_ = detrend(x.data_ch2);
    
    exc = myfilter(exc_, 4, 20000);
    pic = myfilter(pic_, 4, 20000);%.*2e3;
end

function plot_data(material, pose, color)
    fs = 1e6;                       % sampling frequency
    t = 0:1/fs:0.1-1/fs;
    degpoly = 2;
    data = load(sprintf("sweep_data/%s_sweep_pose_%d.mat", material, pose));
    
    [exc, pic] = get_filtered_signals(data);
    
    analyticexc = hilbert(exc);
    analyticpic = hilbert(pic);
    
    % Instantaneous phase
    phiexc = unwrap(angle(analyticexc));
    phipic = unwrap(angle(analyticpic));
    
    % Phase shift in time
    delta_phi = phipic - phiexc; % [rad]
    
    % Convert to degrees
    delta_phi_deg = rad2deg(delta_phi);

    if mean(delta_phi_deg) > 180
        delta_phi_deg = delta_phi_deg-360;
    elseif mean(delta_phi_deg) < -180
        delta_phi_deg = delta_phi_deg+360;
    end
    
    outlier_idx = 100; % reject values at the end and at the beginning of signal
    poly = polyfit(t(outlier_idx :end-outlier_idx), delta_phi_deg(outlier_idx :end-outlier_idx),degpoly);
    trend = polyval(poly,t);
    
    % Vizualization
    % plot(t, delta_phi_deg);
    plot(t, trend, color);
    xlabel('Time [s]');
    ylabel('Phase shift [°]');
    grid on;

%     figure(2)
%     plot(t,phiexc, t, phipic);
%     hold on;

end
