clear all;
close all;
clc;

fprintf('--- PART 1: Generating Waveform Visualizations (15 Symbols) ---\n');

%% ========================================================================
%% PART 1: WAVEFORM VISUALIZATION (FIGURE 1 & 2)
%% ========================================================================
numSymbols_vis = 15;
fc = 5;
fs = 200;
Ts = 1;
SNR_vis_dB = 12;

t = 0 : 1/fs : (numSymbols_vis*Ts) - 1/fs;
samples_per_sym = fs * Ts;

% Channels
h1 = zeros(1, length(t)); h2 = zeros(1, length(t));
for p = 1:6
    h1 = h1 + (randn()+1i*randn()) * exp(1i*(2*pi*(0.1+0.2*rand())*t + 2*pi*rand()));
    h2 = h2 + (randn()+1i*randn()) * exp(1i*(2*pi*(0.1+0.2*rand())*t + 2*pi*rand()));
end
h1 = h1 ./ sqrt(mean(abs(h1).^2)); h2 = h2 ./ sqrt(mean(abs(h2).^2));

% Modulation
bits_vis = randi([0 1], 1, numSymbols_vis);
tx_bb = zeros(1, length(t));
for k = 1:numSymbols_vis
    tx_bb((k-1)*samples_per_sym + 1 : k*samples_per_sym) = 2*bits_vis(k) - 1;
end
tx_rf = real(tx_bb .* exp(1i*2*pi*fc*t));

% Noise & Received Signals
noise_pwr = mean(abs(tx_bb).^2) / (10^(SNR_vis_dB/10));
n1 = sqrt(noise_pwr/2) * (randn(1, length(t)) + 1i*randn(1, length(t)));
n2 = sqrt(noise_pwr/2) * (randn(1, length(t)) + 1i*randn(1, length(t)));

rx1_bb = h1 .* tx_bb + n1; rx2_bb = h2 .* tx_bb + n2;
rx1_rf = real(rx1_bb .* exp(1i*2*pi*fc*t)); rx2_rf = real(rx2_bb .* exp(1i*2*pi*fc*t));

% Combining
rx1_aligned = rx1_bb .* exp(-1i*angle(h1)); rx2_aligned = rx2_bb .* exp(-1i*angle(h2));
rx_sc_bb = zeros(1, length(t));
for k = 1:numSymbols_vis
    idx = (k-1)*samples_per_sym + 1 : k*samples_per_sym;
    if mean(abs(h1(idx))) > mean(abs(h2(idx))) rx_sc_bb(idx) = rx1_aligned(idx); else rx_sc_bb(idx) = rx2_aligned(idx); end
end
rx_egc_bb = rx1_aligned + rx2_aligned;
rx_mrc_bb = rx1_bb .* conj(h1) + rx2_bb .* conj(h2);

sc_rf = real(rx_sc_bb .* exp(1i*2*pi*fc*t)); egc_rf = real(rx_egc_bb .* exp(1i*2*pi*fc*t)); mrc_rf = real(rx_mrc_bb .* exp(1i*2*pi*fc*t));

% --- PLOT FIG 1 ---
figure(1);
subplot(4,1,1); plot(t, tx_rf, 'b'); title('Ideal Transmitted RF Signal'); grid on; ylim([-1.5 1.5]);
subplot(4,1,2); plot(t, abs(h1), 'r', 'LineWidth', 2); hold on; plot(t, abs(h2), 'm', 'LineWidth', 2); title('Fading Envelopes'); legend('|h_1|', '|h_2|'); grid on;
subplot(4,1,3); plot(t, rx1_rf, 'r'); hold on; plot(t, abs(h1), 'k--'); plot(t, -abs(h1), 'k--'); title('Raw Received Signal - Antenna 1'); grid on;
subplot(4,1,4); plot(t, rx2_rf, 'm'); hold on; plot(t, abs(h2), 'k--'); plot(t, -abs(h2), 'k--'); title('Raw Received Signal - Antenna 2'); grid on; xlabel('Time');

% --- PLOT FIG 2 ---
figure(2);
subplot(4,1,1); plot(t, tx_rf, 'k'); title('Ideal Transmitted RF Signal (Reference)'); grid on; ylim([-1.5 1.5]);
subplot(4,1,2); plot(t, sc_rf, 'g'); title('Selection Combining (SC) Output'); grid on;
subplot(4,1,3); plot(t, egc_rf, 'b'); title('Equal Gain Combining (EGC) Output'); grid on;
subplot(4,1,4); plot(t, mrc_rf, 'LineStyle', '-', 'Color', [0.8500 0.3250 0.0980]); title('Maximal Ratio Combining (MRC) Output'); grid on; xlabel('Time');

fprintf('--- PART 2: Running BER Monte Carlo Simulation (100,000 Symbols) ---\n');
fprintf('This may take a few seconds...\n');

%% ========================================================================
%% PART 2: BER SIMULATION (FIGURE 3)
%% ========================================================================
N_bits = 10^5;
SNR_dB = 0:2:20;
N_rx = 2;

BER_no_div = zeros(1, length(SNR_dB)); BER_SC = zeros(1, length(SNR_dB));
BER_EGC = zeros(1, length(SNR_dB)); BER_MRC = zeros(1, length(SNR_dB));

bits = randi([0 1], 1, N_bits);
x = 2*bits - 1;

for k = 1:length(SNR_dB)
    N0 = 1 / (10^(SNR_dB(k)/10));

    h = (randn(N_rx, N_bits) + 1i*randn(N_rx, N_bits)) / sqrt(2);
    noise = sqrt(N0/2) * (randn(N_rx, N_bits) + 1i*randn(N_rx, N_bits));

    y = repmat(x, N_rx, 1) .* h + noise;

    % No Diversity
    bits_no_div = real(y(1, :) .* exp(-1i*angle(h(1, :)))) > 0;
    BER_no_div(k) = sum(bits ~= bits_no_div) / N_bits;

    % SC
    [~, max_idx] = max(abs(h), [], 1);
    linear_idx = sub2ind(size(y), max_idx, 1:N_bits);
    bits_sc = real(y(linear_idx) .* exp(-1i*angle(h(linear_idx)))) > 0;
    BER_SC(k) = sum(bits ~= bits_sc) / N_bits;

    % EGC
    bits_egc = real(sum(y .* exp(-1i*angle(h)), 1)) > 0;
    BER_EGC(k) = sum(bits ~= bits_egc) / N_bits;

    % MRC
    bits_mrc = real(sum(y .* conj(h), 1)) > 0;
    BER_MRC(k) = sum(bits ~= bits_mrc) / N_bits;
end

BER_AWGN = 0.5 * erfc(sqrt(10.^(SNR_dB/10)));

% --- PLOT FIG 3 ---
figure(3);
semilogy(SNR_dB, BER_AWGN, 'k-', 'LineWidth', 2); hold on;
semilogy(SNR_dB, BER_no_div, 'm-o', 'LineWidth', 2);
semilogy(SNR_dB, BER_SC, 'r-s', 'LineWidth', 2);
semilogy(SNR_dB, BER_EGC, 'b-d', 'LineWidth', 2);
semilogy(SNR_dB, BER_MRC, 'g-^', 'LineWidth', 2);

grid on; axis([0 20 10^-5 1]);
legend('AWGN (Ideal, No Fading)', 'No Diversity (SISO)', ...
       'Selection Combining (SC)', 'Equal Gain Combining (EGC)', ...
       'Maximal Ratio Combining (MRC)', 'Location', 'southwest');
xlabel('SNR (E_b/N_0) in dB'); ylabel('Bit Error Rate (BER)');
title('Figure 3: BER Performance of Diversity Techniques (N=2)');
fprintf('Simulation Complete! Check Figures 1, 2, and 3.\n');
