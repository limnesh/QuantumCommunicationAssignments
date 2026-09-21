clear all;
close all;
clc;

%% 1. SYSTEM PARAMETERS
N = 64;             % Number of subcarriers (FFT size)
N_cp = 16;          % Length of Cyclic Prefix
SNR_dB = 20;        % Signal to Noise Ratio

%% 2. GENERATE DATA & MODULATE (16-QAM)
bits = randi([0 1], 4, N);

% Manual 16-QAM Mapping
I = (2*bits(1,:) + bits(2,:))*2 - 3;
Q = (2*bits(3,:) + bits(4,:))*2 - 3;
X_freq = I + 1i*Q;

%% 3. IFFT: CONVERT TO TIME DOMAIN OFDM SYMBOL
x_time = ifft(X_freq, N) * sqrt(N);

%% 4. ADD CYCLIC PREFIX (CP)
cp = x_time(N - N_cp + 1 : N);
x_tx = [cp, x_time];

%% 5. THE CHANNEL (FREQUENCY-SELECTIVE MULTIPATH)
h = [0.8+0.1i, -0.4+0.2i, 0.2-0.1i, -0.1+0.05i];
y_rx = filter(h, 1, x_tx);

signal_power = mean(abs(y_rx).^2);
noise_power = signal_power / (10^(SNR_dB/10));
noise = sqrt(noise_power/2) * (randn(1, length(y_rx)) + 1i*randn(1, length(y_rx)));
y_rx_noisy = y_rx + noise;

%% 6. RECEIVER: REMOVE CP & FFT
y_no_cp = y_rx_noisy(N_cp + 1 : end);
Y_freq = fft(y_no_cp, N) / sqrt(N);

%% 7. EQUALIZATION (Fixing the Frequency-Selective Fading)
H_exact = fft(h, N);
X_est = Y_freq ./ H_exact;

%% ========================================================================
%% PLOTTING THE VISUAL JOURNEY (OCTAVE SAFE)
%% ========================================================================

% --- FIGURE 1: The Raw Data ---
figure(1);
plot(real(X_freq), imag(X_freq), 'bo', 'MarkerFaceColor', 'b', 'MarkerSize', 8);
hold on;
plot([-4 4], [0 0], 'k-', 'LineWidth', 1.5); % Replaces yline(0)
plot([0 0], [-4 4], 'k-', 'LineWidth', 1.5); % Replaces xline(0)
grid on; axis([-4 4 -4 4]);
title('Figure 1: Original Transmitted 16-QAM Symbols');
xlabel('In-Phase (I)'); ylabel('Quadrature (Q)');
hold off;

% --- FIGURE 2: Time Domain & Cyclic Prefix ---
figure(2);
subplot(2,1,1);
plot(1:N, real(x_time), 'b-o', 'LineWidth', 1.5);
title('Figure 2A: Time-Domain OFDM Symbol (Before CP)');
grid on; xlim([1 N]); xlabel('Sample Index'); ylabel('Amplitude');

subplot(2,1,2);
plot(1:N_cp, real(cp), 'r-o', 'LineWidth', 1.5); hold on;
plot(N_cp+1 : N_cp+N, real(x_time), 'b-o', 'LineWidth', 1.5);
plot([N_cp N_cp], [-max(abs(x_time)) max(abs(x_time))], 'k--', 'LineWidth', 2); % Replaces xline(N_cp)
title('Figure 2B: Transmitted OFDM Symbol (Red = Cyclic Prefix Added)');
grid on; xlim([1 N+N_cp]); xlabel('Sample Index'); ylabel('Amplitude');
legend('Cyclic Prefix', 'Original Data Payload', 'Location', 'northeast');
hold off;

% --- FIGURE 3: The Frequency-Selective Channel ---
figure(3);
subplot(2,1,1);
stem(0:length(h)-1, abs(h), 'filled', 'r', 'LineWidth', 2);
title('Figure 3A: Channel Impulse Response (Time-Delayed Echoes)');
grid on; xlabel('Delay (Taps)'); ylabel('Magnitude'); xlim([-1 5]);

subplot(2,1,2);
plot(1:N, 20*log10(abs(H_exact)), 'm', 'LineWidth', 2);
title('Figure 3B: Channel Frequency Response (Frequency-Selective Fading)');
grid on; xlabel('Subcarrier Index'); ylabel('Magnitude (dB)');
xlim([1 N]);

% --- FIGURE 4: Receiver & Equalization ---
figure(4);
subplot(1,2,1);
plot(real(Y_freq), imag(Y_freq), 'ro');
hold on;
plot([-5 5], [0 0], 'k-'); % Replaces yline
plot([0 0], [-5 5], 'k-'); % Replaces xline
grid on; axis([-5 5 -5 5]);
title('Figure 4A: Received Symbols BEFORE Equalization');
xlabel('In-Phase (I)'); ylabel('Quadrature (Q)');
hold off;

subplot(1,2,2);
plot(real(X_est), imag(X_est), 'go', 'MarkerFaceColor', 'g');
hold on;
plot([-4 4], [0 0], 'k-'); % Replaces yline
plot([0 0], [-4 4], 'k-'); % Replaces xline
grid on; axis([-4 4 -4 4]);
title('Figure 4B: Received Symbols AFTER Equalization');
xlabel('In-Phase (I)'); ylabel('Quadrature (Q)');
hold off;
