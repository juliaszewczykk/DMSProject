% STARTUP - DMSProject Initialization Script
% Dynamics of Mechanical Systems - Single-Span Truss Bridge Analysis
% Politecnico di Milano | A.Y. 2025/2026

rootDir = fileparts(mfilename('fullpath'));
addpath(fullfile(rootDir, 'src'));
addpath(fullfile(rootDir, 'data'));

disp('========================================================================');
disp('  Dynamics of Mechanical Systems - Truss Bridge Dynamic Analysis');
disp('  Politecnico di Milano | A.Y. 2025/2026');
disp('========================================================================');
disp('  Cartelle di progetto caricate nel percorso di ricerca MATLAB:');
disp('    - src/  : Codice sorgente e algoritmi di analisi dinamica');
disp('    - data/ : Matrici FEM (*.mat), modello di calcolo (*.inp), sisma (*.txt)');
disp('    - docs/ : Relazione tecnica del corso (Yearwork_Report.pdf)');
disp('------------------------------------------------------------------------');
disp('  Digita "main" per avviare la pipeline completa o selezionare un punto.');
disp('========================================================================');