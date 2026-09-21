clear all
close all
clc

%% PARAMETERS (CHANGE THESE TO EXPERIMENT)
numSymbols = 10000;  % Increased to 1000 to get a statistically meaningful BER
plotSymbols = 20;   % Keep the plot zoomed in to the first 15 symbols to see the waves
fc = 5;             % Carrier frequency
fs = 200;           % Sampling frequency
Ts = 1;             % Symbol duration
SNR_dB = 8;         % Lowered to 8 dB so we actually force some errors to occur!
K_factor = 5;       % Rician K-factor (Higher = stronger Line of Sight)

%% FADING CHANNEL GENERATION
t_total = 0 : 1/fs : (numSymbols*Ts) - 1/fs;
t_sym = 0 : 1/fs : Ts - 1/fs; % Time vector for a single symbol
samples_per_sym = length(t_sym);

% 1. Create a slow-varying Rayleigh fading envelope
num_paths = 6;
h_rayleigh = zeros(size(t_total));
for p = 1:num_paths
    fd = 0.1 + 0.2*rand(); % Slow fading frequencies (Doppler shift)
    phase = 2*pi*rand();
    h_rayleigh = h_rayleigh + (randn() + 1i*randn()) * exp(1i*(2*pi*fd*t_total + phase));
end
h_rayleigh = h_rayleigh ./ sqrt(mean(abs(h_rayleigh).^2)); % Normalize

% 2. Create Rician fading by adding a dominant LOS path
h_rician = sqrt(K_factor/(K_factor+1)) + sqrt(1/(K_factor+1)) * h_rayleigh;

%% MODULATION & APPLYING CHANNEL
bits = randi([0 1], 1, numSymbols);

tx_rf = zeros(1, length(t_total));
rx_rayleigh_rf = zeros(1, length(t_total));
rx_rician_rf = zeros(1, length(t_total));
envelope_rayleigh = abs(h_rayleigh);
envelope_rician = abs(h_rician);

for k = 1:numSymbols
    % BPSK Modulation Baseband
    I = 2*bits(k) - 1;
    Q = 0;

    idx_start = (k-1)*samples_per_sym + 1;
    idx_end = k*samples_per_sym;

    % Ideal transmitted RF signal
    tx_rf(idx_start:idx_end) = I*cos(2*pi*fc*t_sym);

    h_ray_seg = h_rayleigh(idx_start:idx_end);
    h_ric_seg = h_rician(idx_start:idx_end);

    % Apply Rayleigh fading
    I_ray = I .* real(h_ray_seg) - Q .* imag(h_ray_seg);
    Q_ray = I .* imag(h_ray_seg) + Q .* real(h_ray_seg);
    rx_rayleigh_rf(idx_start:idx_end) = I_ray.*cos(2*pi*fc*t_sym) - Q_ray.*sin(2*pi*fc*t_sym);

    % Apply Rician fading
    I_ric = I .* real(h_ric_seg) - Q .* imag(h_ric_seg);
    Q_ric = I .* imag(h_ric_seg) + Q .* real(h_ric_seg);
    rx_rician_rf(idx_start:idx_end) = I_ric.*cos(2*pi*fc*t_sym) - Q_ric.*sin(2*pi*fc*t_sym);
end

%% ADD AWGN NOISE
signal_power = mean(tx_rf.^2);
noise_power = signal_power / (10^(SNR_dB/10));

rx_rayleigh_rf = rx_rayleigh_rf + sqrt(noise_power) * randn(size(tx_rf));
rx_rician_rf = rx_rician_rf + sqrt(noise_power) * randn(size(tx_rf));

%% DEMODULATION & BER CALCULATION
rx_bits_rayleigh = zeros(1, numSymbols);
rx_bits_rician = zeros(1, numSymbols);

for k = 1:numSymbols
    idx_start = (k-1)*samples_per_sym + 1;
    idx_end = k*samples_per_sym;

    rx_ray_seg = rx_rayleigh_rf(idx_start:idx_end);
    rx_ric_seg = rx_rician_rf(idx_start:idx_end);

    % Receiver assumes perfect Channel State Information (CSI) for phase
    phase_ray = angle(mean(h_rayleigh(idx_start:idx_end)));
    phase_ric = angle(mean(h_rician(idx_start:idx_end)));

    % Coherent Local Oscillator (phase matched to the channel)
    lo_ray = 2 * cos(2*pi*fc*t_sym + phase_ray);
    lo_ric = 2 * cos(2*pi*fc*t_sym + phase_ric);

    % Correlator (Integrate over symbol period)
    corr_ray = sum(rx_ray_seg .* lo_ray);
    corr_ric = sum(rx_ric_seg .* lo_ric);

    % Decision Maker (Threshold at 0 for BPSK)
    rx_bits_rayleigh(k) = corr_ray > 0;
    rx_bits_rician(k) = corr_ric > 0;
end

% Calculate Errors
errors_ray = sum(bits ~= rx_bits_rayleigh);
errors_ric = sum(bits ~= rx_bits_rician);

% Print Results to Command Window
fprintf('\n--- BIT ERROR RATE (BER) RESULTS ---\n');
fprintf('Simulated Symbols: %d\n', numSymbols);
fprintf('SNR: %d dB\n', SNR_dB);
fprintf('Rician K-Factor: %d\n', K_factor);
fprintf('------------------------------------\n');
fprintf('Rayleigh BER: %f (%d errors)\n', errors_ray/numSymbols, errors_ray);
fprintf('Rician BER:   %f (%d errors)\n', errors_ric/numSymbols, errors_ric);
fprintf('------------------------------------\n\n');

%% PLOTS (Only plotting the first 'plotSymbols' so waves are visible)
plot_idx = 1 : (plotSymbols * samples_per_sym);
t_plot = t_total(plot_idx);

figure(1);

subplot(4,1,1);
plot(t_plot, tx_rf(plot_idx), 'b');
title(sprintf('Ideal Transmitted RF Signal (First %d Symbols)', plotSymbols));
xlabel('Time'); ylabel('Amplitude'); grid on; ylim([-1.5 1.5]);

subplot(4,1,2);
plot(t_plot, envelope_rayleigh(plot_idx), 'r', 'LineWidth', 2); hold on;
plot(t_plot, envelope_rician(plot_idx), 'g', 'LineWidth', 2);
title('Channel Fading Envelopes |h(t)|');
legend('Rayleigh (No LOS)', 'Rician (With LOS)');
xlabel('Time'); ylabel('Magnitude'); grid on;

subplot(4,1,3);
plot(t_plot, rx_rayleigh_rf(plot_idx), 'r'); hold on;
plot(t_plot, envelope_rayleigh(plot_idx), 'k--', 'LineWidth', 1.5);
plot(t_plot, -envelope_rayleigh(plot_idx), 'k--', 'LineWidth', 1.5);
title('Received Signal: Rayleigh Channel + AWGN');
xlabel('Time'); ylabel('Amplitude'); grid on;

subplot(4,1,4);
plot(t_plot, rx_rician_rf(plot_idx), 'g'); hold on;
plot(t_plot, envelope_rician(plot_idx), 'k--', 'LineWidth', 1.5);
plot(t_plot, -envelope_rician(plot_idx), 'k--', 'LineWidth', 1.5);
title('Received Signal: Rician Channel + AWGN');
xlabel('Time'); ylabel('Amplitude'); grid on;
