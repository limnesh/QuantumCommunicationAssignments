clear all;
close all;
clc;

%% 1. SYSTEM PARAMETERS
N_samples = 10^6;
SNR_avg_dB = 0:2:30;
SNR_th_dB = 5;

gamma_th = 10^(SNR_th_dB / 10);

%% 2. VISUALIZER: What does an Outage look like? (FIXED)
t = 1:500;

% Generate pure, chaotic random Rayleigh fading (infinite multipath)
h_raw = (randn(1, 500) + 1i*randn(1, 500)) / sqrt(2);

% Pass it through a moving average filter to "slow" it down so we can see the curves
windowSize = 15;
h_slow = filter(ones(1,windowSize)/windowSize, 1, h_raw);

% Normalize the power back to 1
h_slow = h_slow ./ sqrt(mean(abs(h_slow).^2));

% Lower the Average SNR to 5 dB so it frequently crashes below the 5 dB threshold!
gamma_avg_vis = 10^(5/10);
instantaneous_SNR_vis = (abs(h_slow).^2) * gamma_avg_vis;
instantaneous_SNR_vis_dB = 10*log10(instantaneous_SNR_vis);

%% 3. MONTE CARLO SIMULATION ENGINE
P_out_simulated = zeros(1, length(SNR_avg_dB));
P_out_theoretical = zeros(1, length(SNR_avg_dB));

fprintf('Starting Monte Carlo Simulation with %d samples...\n', N_samples);

for k = 1:length(SNR_avg_dB)
    gamma_avg = 10^(SNR_avg_dB(k) / 10);

    h = (randn(1, N_samples) + 1i*randn(1, N_samples)) / sqrt(2);
    gamma_inst = (abs(h).^2) * gamma_avg;

    outage_count = sum(gamma_inst < gamma_th);
    P_out_simulated(k) = outage_count / N_samples;
    P_out_theoretical(k) = 1 - exp(-gamma_th / gamma_avg);
end

fprintf('Simulation Complete!\n');

%% ========================================================================
%% PLOTTING
%% ========================================================================

figure(1);

% --- SUBPLOT 1: The Outage Visualizer ---
subplot(2,1,1);
plot(t, instantaneous_SNR_vis_dB, 'b-', 'LineWidth', 1.5); hold on;
plot([1 500], [SNR_th_dB SNR_th_dB], 'r-', 'LineWidth', 2);
grid on;
title('Figure 1: Instantaneous SNR vs Time (Notice the Deep Fades)');
xlabel('Time (Samples)'); ylabel('Received SNR (dB)');

% Fill in the outage areas with red dots
outage_idx = instantaneous_SNR_vis_dB < SNR_th_dB;
plot(t(outage_idx), instantaneous_SNR_vis_dB(outage_idx), 'ro', 'MarkerSize', 4, 'MarkerFaceColor', 'r');
legend('Instantaneous Received SNR', sprintf('Outage Threshold (%d dB)', SNR_th_dB), 'Outage Events', 'Location', 'southwest');

% --- SUBPLOT 2: Monte Carlo vs Theory Curve ---
subplot(2,1,2);
semilogy(SNR_avg_dB, P_out_theoretical, 'k-', 'LineWidth', 2); hold on;
semilogy(SNR_avg_dB, P_out_simulated, 'ro', 'MarkerSize', 6);
grid on;
title('Figure 2: Outage Probability vs. Average Transmit SNR');
xlabel('Average Transmit SNR (\gamma_{avg}) in dB');
ylabel('Outage Probability');
legend('Exact Theoretical Calculus', 'Monte Carlo Simulation', 'Location', 'southwest');
axis([0 30 10^-5 1]);
