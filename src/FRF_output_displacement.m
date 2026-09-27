%% --- 3. PUNTO 4.2: Calcolo Risposta in Frequenza (Output in A e B) ---

% 1. Preparazione Vettore Spostamenti Vincolati X_C(omega)
% Dobbiamo creare una matrice [Nc x N] dove ogni riga corrisponde a un vincolo
% e contiene la FFT dello spostamento imposto.

% Inizializzazione matrice X_C nel dominio della frequenza (complessa)
U_C_freq = zeros(Nc, N);

% Trova gli indici (righe) corretti dentro 'dofC' dove applicare gli input sismici
% dofC contiene [dofO1_x, dofO1_y, dofO2_y] (o ordine simile)
idx_O1_in_C = find(dofC == dofO1_y);
idx_O2_in_C = find(dofC == dofO2_y);

% Assegna le FFT complete (raw) calcolate nel punto 4.1
% Nota: Y_O1_fft e Y_O2_fft devono essere vettori riga (o trasposti se colonna)
U_C_freq(idx_O1_in_C, :) = Y_O1_fft.'; 
U_C_freq(idx_O2_in_C, :) = Y_O2_fft.';
% Nota: Il GdL orizzontale di O1 (dofO1_x) rimane a 0 (cerniera ferma in x).

% 2. Risoluzione dell'Equazione del Moto nel Dominio della Frequenza
% Obiettivo: Trovare X_0 (spostamenti dei gradi di libertà liberi)
% Equazione: X_0 = (A)^-1 * Q_f0
% Dove Q_f0 = -(-om^2*M_FC+i*om*C_FC+K_FC)* X_C (Forza inerziale/elastica trasmessa dai vincoli)


U_F_freq = zeros(Nf, N); % Matrice risultati (Nf dofs x N campioni)
omega_vec = 2*pi * f_vec; % Pulsazioni corrispondenti alle frequenze [rad/s]

for k = 1:nPos 
    % Lavoriamo solo sulle frequenze positive (fino a Nyquist) per efficienza
    wk = omega_vec(k);
    
    % A. Matrice di Rigidezza Dinamica (Dynamic Stiffness) dei GdL Liberi
    % Rif: L10 Slide 39
    D_FF_k = -wk^2 * M_FF + 1i*wk * C_FF + K_FF;
    
    % B. Matrice di Accoppiamento Vincoli-Struttura
    % Rif: L10 Slide 40 (Termine a destra dell'uguale)
    D_FC_k = -wk^2 * M_FC + 1i*wk * C_FC + K_FC;
    
    % C. Calcolo del Termine Noto (Forza Equivalente Sismica)
    % Rif: L10 Slide 40 
    % F_eq = - ( -w^2 M_fc + iw C_fc + K_fc ) * X_c
    F_eq_k = - D_FC_k * U_C_freq(:, k);
    
    % D. Soluzione del sistema lineare U = D \ F
    U_F_freq(:, k) = D_FF_k \ F_eq_k;
    
    % E. Ricostruzione parte negativa dello spettro (Simmetria Coniugata)
    % Serve per avere la FFT completa e corretta se volessimo tornare nel tempo
    if k > 1 && k < nPos
        idx_neg = N - k + 2; 
        U_F_freq(:, idx_neg) = conj(U_F_freq(:, k));
    end
end

% 3. Estrazione Spettri per Nodi A e B
% Definizione nodi (Node 8 = A, Node 5 = B con mesh L=5m)
nodeA = 8;
nodeB = 5;

% Recupero ID globali dei GdL verticali (Y = colonna 2 di idb)
dofA_y = idb(nodeA, 2); 
dofB_y = idb(nodeB, 2);

% Trova la posizione di questi GdL dentro il vettore 'dofF'
idx_A_in_F = find(dofF == dofA_y);
idx_B_in_F = find(dofF == dofB_y);

% Estrazione della FFT complessa dai risultati
Y_A_fft = U_F_freq(idx_A_in_F, :);
Y_B_fft = U_F_freq(idx_B_in_F, :);

% 4. Calcolo Ampiezza Fisica (Single-Sided Spectrum)
% Stessa procedura usata nel 4.1 per coerenza

% Nodo A
P1_A = abs(Y_A_fft(1:nPos))/N; 
P1_A(2:end-1) = 2*P1_A(2:end-1);

% Nodo B
P1_B = abs(Y_B_fft(1:nPos))/N; 
P1_B(2:end-1) = 2*P1_B(2:end-1);

% 5. Plot Risultati (Confronto A e B)
figure('Name', '4.2 Output Spectra', 'Color', 'w');

%%
subplot(2,1,1);
semilogx(f_vec, P1_A, 'b', 'LineWidth', 1.2);
xlim([0.1 30]); grid on;
title(['Spectrum of Vertical Displacement at Node A (Node ' num2str(nodeA) ')']);
xlabel('Frequency [Hz]'); ylabel('|Y_A| [m]');
hold on
add_nat_freq_lines(Nat_freq);
%%

%{
figure('Name', '4.2 Output Spectra', 'Color', 'w');

subplot(2,1,1);
semilogx(f_vec, P1_B, 'b', 'LineWidth', 1.2);
xlim([0.1 30]); grid on;
title(['Spectrum of Vertical Displacement at Node B (Node ' num2str(nodeB) ')']);
xlabel('Frequency [Hz]'); ylabel('|Y_B| [m]');
hold on
add_nat_freq_lines(Nat_freq);
%}

subplot(2,1,2);
semilogx(f_vec, P1_B, 'b', 'LineWidth', 1.2);
xlim([2 30]); grid on;
title(['Spectrum of Vertical Displacement at Node B (Node ' num2str(nodeB) ')']);
xlabel('Frequency [Hz]'); ylabel('|Y_B| [m]');
hold on
add_nat_freq_lines(Nat_freq);

% Alias for compatibility with acceleration scripts
X_0_freq = U_F_freq;