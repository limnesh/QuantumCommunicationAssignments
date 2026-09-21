clear all;
close all;
clc;

%% 1. SYSTEM PARAMETERS
N = 64;             % Total subcarriers
pilot_spacing = 8;  % Insert a pilot every 8 subcarriers
pilot_val = 3+3i;   % A known, strong pilot symbol
SNR_dB = 25;

% Define indices for Pilots and Data
pilot_idx = 1:pilot_spacing:N;
data_idx = setdiff(1:N, pilot_idx); % All other subcarriers

%% 2. GENERATE DATA AND PILOTS
% Generate 16-QAM Data
bits = randi([0 1], 4, length(data_idx));
I = (2*bits(1,:) + bits(2,:))*2 - 3;
Q = (2*bits(3,:) + bits(4,:))*2 - 3;
Data_freq = I + 1i*Q;

% Map Data and Pilots to the OFDM block
X_freq = zeros(1, N);
X_freq(pilot_idx) = pilot_val;      % Insert Pilots
X_freq(data_idx) = Data_freq;       % Insert Data

%% 3. TRANSMIT (IFFT) & CHANNEL
x_time = ifft(X_freq, N) * sqrt(N);

% Frequency-Selective Multipath Channel
h = [0.8, -0.4+0.2i, 0.2-0.1i, -0.1];
y_rx = filter(h, 1, x_time);

% Add AWGN Noise
noise_pwr = mean(abs(y_rx).^2) / (10^(SNR_dB/10));
y_rx = y_rx + sqrt(noise_pwr/2)*(randn(1,N) + 1i*randn(1,N));

%% 4. RECEIVER: FFT & EXTRACT PILOTS
Y_freq = fft(y_rx, N) / sqrt(N);

% Extract the received pilots
Y_pilots = Y_freq(pilot_idx);

%% 5. CHANNEL ESTIMATION & INTERPOLATION
% Least Squares (LS) Estimate at pilot locations: H = Y / X
H_ls_pilots = Y_pilots ./ pilot_val;

% Interpolate to find the channel at all other subcarriers
% 'spline' draws a smooth, curved line between the pilot estimates
H_est_full = interp1(pilot_idx, H_ls_pilots, 1:N, 'spline', 'extrap');

%% 6. EQUALIZATION
% Now we use our estimated channel to fix the received data
Y_data = Y_freq(data_idx);
H_est_data = H_est_full(data_idx);

% Zero-Forcing Equalization
X_data_est = Y_data ./ H_est_data;

%% ========================================================================
%% PLOTTING
%% ========================================================================

% Exact channel for comparison
H_exact = fft(h, N);

figure(1);
% --- SUBPLOT 1: The Channel Estimation Process ---
subplot(2,1,1);
plot(1:N, abs(H_exact), 'k-', 'LineWidth', 2); hold on;
plot(pilot_idx, abs(H_ls_pilots), 'ro', 'MarkerSize', 8, 'MarkerFaceColor', 'r');
plot(1:N, abs(H_est_full), 'b--', 'LineWidth', 1.5);
grid on;
title('OFDM Channel Estimation: True Channel vs. Estimated Channel');
xlabel('Subcarrier Index'); ylabel('Channel Magnitude |H|');
legend('True Channel (Unknown to Rx)', 'Pilot Estimates (LS)', 'Interpolated Estimate');

% --- SUBPLOT 2: The Equalized Constellation ---
subplot(2,1,2);
plot(real(Y_data), imag(Y_data), 'r.', 'MarkerSize', 10); hold on;
plot(real(X_data_est), imag(X_data_est), 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 6);
plot([-4 4], [0 0], 'k-'); plot([0 0], [-4 4], 'k-'); % Axes
grid on; axis([-5 5 -5 5]);
title('16-QAM Data Constellation');
xlabel('In-Phase (I)'); ylabel('Quadrature (Q)');
legend('Raw Received Data (Scrambled by Channel)', 'Equalized Data (Fixed using H_{est})', 'Location', 'southwest');
