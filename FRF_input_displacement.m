%% 4.1 input specturm

filename = 'seismic_displ.txt'; 

data = load(filename);
t = data(:,1);      % Tempo [s]
y_O1 = data(:,2);         % Spostamento O1 [m]
y_O2 = data(:,3);         % Spostamento O2 [m]

% Parametri di campionamento
N = length(t);
dt = t(2) - t(1);
Fs = 1/dt;              
df = Fs/N;              
nPos = floor(N/2) + 1;          % Numero campioni spettro monolaterale
f_vec = (0:nPos-1)' * df;       % Vettore frequenze [Hz]

%% --- 2. PUNTO 4.1: Spettri degli Input (O1 e O2) ---

% Calcolo FFT
Y_O1_fft = fft(y_O1);
Y_O2_fft = fft(y_O2);

% Calcolo Ampiezza Fisica (Single-Sided Spectrum)
% Moltiplichiamo per 2 la parte positiva (esclusa DC e Nyquist) per conservare l'energia
P1_O1 = abs(Y_O1_fft(1:nPos))/N; 
P1_O1(2:end-1) = 2*P1_O1(2:end-1);
P1_O2 = abs(Y_O2_fft(1:nPos))/N; 
P1_O2(2:end-1) = 2*P1_O2(2:end-1);

% Plot Spettri Input
figure('Name', '4.1 Input Spectra', 'Color', 'w');
subplot(2,1,1);
semilogx(f_vec, P1_O1, 'b', 'LineWidth', 1.2);
xlim([0.1 30]); grid on;
title('Spectrum of Input Displacement O_1'); xlabel('Freq [Hz]'); ylabel('|Y_{O1}| [m]');
hold on
add_nat_freq_lines(Nat_freq);

subplot(2,1,2);
semilogx(f_vec, P1_O2, 'r', 'LineWidth', 1.2);
xlim([0.1 30]); grid on;
title('Spectrum of Input Displacement O_2'); xlabel('Freq [Hz]'); ylabel('|Y_{O2}| [m]');
hold on
add_nat_freq_lines(Nat_freq);

