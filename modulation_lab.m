clear all
close all
clc

%% PARAMETERS (CHANGE THESE)

modType = "16QAM";      % "BPSK" "QPSK" "16QAM"
numSymbols = 20;
fc = 5;                 % carrier frequency
fs = 200;               % sampling rate
Ts = 1;                 % symbol duration
SNR_dB = 20;

%% TIME AXIS
t = 0:1/fs:Ts-1/fs;

signal = [];
carrier = [];
symbols = [];

%% MODULATION

if strcmp(modType,"BPSK")
          %%1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0
    bits = [1 0 1 1 0 1 0 0 1 1 1 0 0 1 0 0 1 0 1 0];

    for k=1:numSymbols

        sym = 2*bits(k)-1;
        wave = sym*cos(2*pi*fc*t);

        signal = [signal wave];
        carrier = [carrier cos(2*pi*fc*t)];
        symbols = [symbols sym];

    endfor

elseif strcmp(modType,"QPSK")

    bits = randi([0 1],1,2*numSymbols);
    bits = reshape(bits,2,[]);

    for k=1:numSymbols

        I = 2*bits(1,k)-1;
        Q = 2*bits(2,k)-1;

        wave = I*cos(2*pi*fc*t) - Q*sin(2*pi*fc*t);

        signal = [signal wave];
        carrier = [carrier cos(2*pi*fc*t)];

        symbols = [symbols I + 1i*Q];

    endfor

elseif strcmp(modType,"16QAM")

    bits = randi([0 1],1,4*numSymbols);
    bits = reshape(bits,4,[]);

    for k=1:numSymbols

        b = bits(:,k);

        I = (2*b(1)+b(2))*2 - 3;
        Q = (2*b(3)+b(4))*2 - 3;

        wave = I*cos(2*pi*fc*t) - Q*sin(2*pi*fc*t);

        signal = [signal wave];
        carrier = [carrier cos(2*pi*fc*t)];

        symbols = [symbols I + 1i*Q];

    endfor

endif

%% ADD AWGN NOISE

signal_power = mean(signal.^2);
SNR = 10^(SNR_dB/10);
noise_power = signal_power/SNR;

noise = sqrt(noise_power)*randn(size(signal));

rx = signal + noise;

%% PLOTS

figure

subplot(4,1,1)
plot(carrier)
title("Carrier Wave")

subplot(4,1,2)
plot(signal)
title(["Modulated Waveform - ",modType])

subplot(4,1,3)
plot(rx)
title(["Received Waveform with AWGN (SNR=",num2str(SNR_dB)," dB)"])

subplot(4,1,4)
stem(real(symbols))
title("Symbol Amplitudes")

%% CONSTELLATION

figure

subplot(1,2,1)
plot(real(symbols), imag(symbols),'bo')
grid on
title("Transmitted Constellation")

subplot(1,2,2)
rx_sym = symbols + 0.3*(randn(size(symbols))+1i*randn(size(symbols)));
plot(real(rx_sym), imag(rx_sym),'r.')
grid on
title("Constellation with Noise")
