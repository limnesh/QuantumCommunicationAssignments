clear all
close all
clc

%% PARAMETERS (CHANGE THESE)

modType = "16QAM";      % BPSK / QPSK / 16QAM
numSymbols = 200;
fc = 5;
fs = 200;
Ts = 1;
SNR_dB = 10;

%% Time axis
t = 0:1/fs:Ts-1/fs;

I_signal = [];
Q_signal = [];
rf_signal = [];
symbols = [];

%% MODULATION

if strcmp(modType,"BPSK")

bits = randi([0 1],1,numSymbols);

for k=1:numSymbols

    I = 2*bits(k)-1;
    Q = 0;

    symbols = [symbols I];

    Iwave = I*ones(size(t));
    Qwave = Q*ones(size(t));

    rf = I*cos(2*pi*fc*t);

    I_signal = [I_signal Iwave];
    Q_signal = [Q_signal Qwave];
    rf_signal = [rf_signal rf];

end

elseif strcmp(modType,"QPSK")

bits = randi([0 1],1,2*numSymbols);
bits = reshape(bits,2,[]);

for k=1:numSymbols

    I = 2*bits(1,k)-1;
    Q = 2*bits(2,k)-1;

    symbols = [symbols I + 1i*Q];

    Iwave = I*ones(size(t));
    Qwave = Q*ones(size(t));

    rf = I*cos(2*pi*fc*t) - Q*sin(2*pi*fc*t);

    I_signal = [I_signal Iwave];
    Q_signal = [Q_signal Qwave];
    rf_signal = [rf_signal rf];

end

elseif strcmp(modType,"16QAM")

bits = randi([0 1],1,4*numSymbols);
bits = reshape(bits,4,[]);

for k=1:numSymbols

    b = bits(:,k);

    I = (2*b(1)+b(2))*2 - 3;
    Q = (2*b(3)+b(4))*2 - 3;

    symbols = [symbols I + 1i*Q];

    Iwave = I*ones(size(t));
    Qwave = Q*ones(size(t));

    rf = I*cos(2*pi*fc*t) - Q*sin(2*pi*fc*t);

    I_signal = [I_signal Iwave];
    Q_signal = [Q_signal Qwave];
    rf_signal = [rf_signal rf];

end

endif


%% AWGN CHANNEL

signal_power = mean(rf_signal.^2);
SNR = 10^(SNR_dB/10);
noise_power = signal_power/SNR;

noise = sqrt(noise_power)*randn(size(rf_signal));
rx = rf_signal + noise;

%% PLOTS

figure(1)

subplot(5,1,1)
plot(I_signal(1:500))
title("I(t) Baseband Signal")

subplot(5,1,2)
plot(Q_signal(1:500))
title("Q(t) Baseband Signal")

subplot(5,1,3)
plot(rf_signal(1:500))
title("RF Modulated Signal")

subplot(5,1,4)
plot(rx(1:500))
title("Received Signal with AWGN")

subplot(5,1,5)
hist(rx,50)
title("Noise Distribution")


%% CONSTELLATION

figure(2)

subplot(1,2,1)
plot(real(symbols),imag(symbols),'bo')
grid on
title("Transmitted Constellation")

rxsym = symbols + 0.5*(randn(size(symbols))+1i*randn(size(symbols)));

subplot(1,2,2)
plot(real(rxsym),imag(rxsym),'r.')
grid on
title("Received Constellation")
