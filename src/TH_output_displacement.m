%% --- 6. PUNTO 4.3: Time Histories (Back to Time Domain) ---

% OBIETTIVO: Ottenere lo spostamento nel tempo y(t) partendo dallo spettro Y(omega).
% METODO: Inverse Fast Fourier Transform (iFFT).

fprintf('Calcolo della iFFT per tornare nel dominio del tempo...\n');

% 1. Esecuzione della iFFT su tutti i gradi di libertà liberi
% U_F_freq è la matrice [Nf x N] calcolata nel punto 4.2.
% L'opzione 'symmetric' dice a MATLAB che il segnale originale era reale,
% eliminando eventuali parti immaginarie piccolissime dovute a errori di arrotondamento.
u_F_time = ifft(U_F_freq, N, 2, 'symmetric');

% 2. Estrazione delle storie temporali per i nodi A e B
% Usiamo gli stessi indici trovati nel punto 4.2
y_A_t = u_F_time(idx_A_in_F, :); % Vettore 1xN: Spostamento vert. A nel tempo
y_B_t = u_F_time(idx_B_in_F, :); % Vettore 1xN: Spostamento vert. B nel tempo

% 3. Plot Time History - Nodo A (Mezzeria)
figure('Name', '4.3 Time History Node A', 'Color', 'w');
plot(t, y_A_t, 'b', 'LineWidth', 1);
grid on;
title(['Time History of Vertical Displacement at Node A (Node ' num2str(nodeA) ')']);
xlabel('Time [s]');
ylabel('Displacement y_A(t) [m]');
xlim([0 max(t)]); 
% Mostra tutto l'intervallo temporale
% Zoom opzionale su una parte interessante (es. dove il sisma è forte)
% xlim([10 40]); 

% 4. Plot Time History - Nodo B (Laterale)
figure('Name', '4.3 Time History Node B', 'Color', 'w');
plot(t, y_B_t, 'r', 'LineWidth', 1);
grid on;
title(['Time History of Vertical Displacement at Node B (Node ' num2str(nodeB) ')']);
xlabel('Time [s]');
ylabel('Displacement y_B(t) [m]');
xlim([0 max(t)]);

% 5. (Opzionale ma consigliato) Confronto diretto A vs B nello stesso grafico
% Utile per vedere che A oscilla di più o per vedere sfasamenti
figure('Name', '4.3 Comparison A vs B', 'Color', 'w');
plot(t, y_A_t, 'b', 'LineWidth', 1);
hold on;
plot(t, y_B_t, 'r', 'LineWidth', 1);
grid on;
xlabel('Time [s]');
ylabel('Displacement [m]');
title('Comparison of Time Histories: Node A vs Node B');
legend('Node A (Mid-span)', 'Node B (Lateral)');
xlim([0 max(t)]);

% Calcolo valori massimi per il report
max_disp_A = max(abs(y_A_t));
max_disp_B = max(abs(y_B_t));
fprintf('--- Risultati Time History ---\n');
fprintf('Massimo spostamento assoluto Nodo A: %.4f m (%.1f cm)\n', max_disp_A, max_disp_A*100);
fprintf('Massimo spostamento assoluto Nodo B: %.4f m (%.1f cm)\n', max_disp_B, max_disp_B*100);