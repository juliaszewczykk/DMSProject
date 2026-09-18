% 1. Generazione corretta del vettore pulsazioni COMPLETO (per FFT bilaterale)
% Questo ordine [0, pos, neg] è cruciale per la FFT di Matlab.
% Funziona sia per N pari che dispari.
w_full_vec = [0 : ceil(N/2)-1, -floor(N/2) : -1] * df * 2 * pi;

% Assicuriamoci che sia un vettore riga per moltiplicare la matrice [Nf x N]
if size(w_full_vec, 1) > 1, w_full_vec = w_full_vec.'; end

% 2. Calcolo Spettro Accelerazione Completo (Tutti i GdL)
% Formula: Acc(w) = -w^2 * U(w)
% Moltiplicazione elemento per elemento (con expansion implicita di w_full_vec)
Acc_0_freq = X_0_freq .* -(w_full_vec.^2);

% -------------------------------------------------------------------------
% PARTE B: ESTRAZIONE DATI PER NODI A E B
% -------------------------------------------------------------------------

% Indici già trovati in 4.2 (idx_A_in_F, idx_B_in_F)
% Estraiamo le righe corrispondenti dalla matrice delle accelerazioni
Acc_A_complex = Acc_0_freq(idx_A_in_F, :);
Acc_B_complex = Acc_0_freq(idx_B_in_F, :);

% -------------------------------------------------------------------------
% PARTE C: CALCOLO SPETTRI DI AMPIEZZA (Per il Grafico 1)
% -------------------------------------------------------------------------

% Prendiamo solo la prima metà (frequenze positive) per il plot
Acc_A_half = Acc_A_complex(1:nPos);
Acc_B_half = Acc_B_complex(1:nPos);

% Calcolo modulo e scaling (Single-Sided Spectrum)
Spec_Acc_A = abs(Acc_A_half)/N;
Spec_Acc_A(2:end-1) = 2 * Spec_Acc_A(2:end-1);

Spec_Acc_B = abs(Acc_B_half)/N;
Spec_Acc_B(2:end-1) = 2 * Spec_Acc_B(2:end-1);

% PLOT SPETTRI ACCELERAZIONE
figure('Name', '4.4 Acceleration Spectra', 'Color', 'w');

%subplot(2,1,1);
% Nota: Uso f_vec (che è il vettore frequenze positive definito in 4.1)
semilogx(f_vec, Spec_Acc_A, 'b', 'LineWidth', 1.2); 
hold on;
add_nat_freq_lines(Nat_freq);
grid on; 
xlim([0.1 30]); % Fondamentale: non guardare oltre 30Hz dove c'è solo rumore!
title(['Vertical Acceleration Spectrum at Node A (Node ' num2str(nodeA) ')']);
xlabel('Frequency [Hz]'); ylabel('|Acc_A| [m/s^2]');
hold on
%subplot(2,1,2);
semilogx(f_vec, Spec_Acc_B, 'g', 'LineWidth', 1.2);
hold on;
add_nat_freq_lines(Nat_freq);
grid on; 
xlim([0.1 30]); 
title(['Vertical Acceleration Spectrum at Node B (Node ' num2str(nodeB) ')']);
xlabel('Frequency [Hz]'); ylabel('|Acc_B| [m/s^2]');

% -------------------------------------------------------------------------
% PARTE D: CALCOLO STORIE TEMPORALI (Per il Grafico 2)
% -------------------------------------------------------------------------

% Facciamo la iFFT direttamente sui vettori complessi completi calcolati prima
acc_A_t = ifft(Acc_A_complex, N, 2, 'symmetric');
acc_B_t = ifft(Acc_B_complex, N, 2, 'symmetric');

% PLOT TIME HISTORIES ACCELERAZIONE
figure('Name', '4.4 Acceleration Time History', 'Color', 'w');

subplot(2,1,1);
plot(t, acc_A_t, 'b', 'LineWidth', 0.8);
grid on; xlim([0 max(t)]);
title(['Acceleration Time History - Node A']);
xlabel('Time [s]'); ylabel('Acc [m/s^2]');

subplot(2,1,2);
plot(t, acc_B_t, 'g', 'LineWidth', 0.8);
grid on; xlim([0 max(t)]);
title(['Acceleration Time History - Node B']);
xlabel('Time [s]'); ylabel('Acc [m/s^2]');

% Report valori massimi
max_acc_A = max(abs(acc_A_t));
max_acc_B = max(abs(acc_B_t));
fprintf('Max Acceleration A: %.3f m/s^2 (%.2f g)\n', max_acc_A, max_acc_A/9.81);
fprintf('Max Acceleration B: %.3f m/s^2 (%.2f g)\n', max_acc_B, max_acc_B/9.81);