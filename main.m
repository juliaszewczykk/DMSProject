function main(step)
% MAIN - Central Execution Pipeline for Bridge Seismic & Dynamic Analysis
%
% Syntax:
%   main         - Interactive prompt (or runs full analysis in non-GUI mode)
%   main(4.1)    - Point 4.1: Seismic input spectra (O1, O2)
%   main(4.2)    - Point 4.2: Output displacement FRF spectra (A, B)
%   main(4.3)    - Point 4.3: Displacement time histories (iFFT)
%   main(4.4)    - Point 4.4: Acceleration spectra & time histories
%   main('all')  - Complete analysis pipeline (Points 4.1 - 4.4)
%
% Course: Dynamics of Mechanical Systems
% Politecnico di Milano | A.Y. 2025/2026
% Author: Julia Szewczyk

clc;
close all;

% Set up paths
rootDir = fileparts(mfilename('fullpath'));
addpath(fullfile(rootDir, 'src'));
addpath(fullfile(rootDir, 'data'));

% Load structural matrices and natural frequencies
fprintf('Loading FE model matrices and modal parameters...\n');
load('bridge_mkr.mat');
load('bridge_fre.mat', 'freq');
Nat_freq = freq(freq < 30);
add_nat_freq_lines = @(freqs) xline(freqs, '--r', 'Alpha', 0.6, 'LineWidth', 1);

% Interactive menu if no argument provided
if nargin < 1 || isempty(step)
    if usejava('desktop')
        fprintf('\nPunti di analisi disponibili:\n');
        fprintf('  [4.1] Spettro degli spostamenti di input sismico (O1, O2)\n');
        fprintf('  [4.2] Spettro della risposta in frequenza (FRF) degli spostamenti (A, B)\n');
        fprintf('  [4.3] Storie temporali degli spostamenti verticali (iFFT)\n');
        fprintf('  [4.4] Spettro e storie temporali delle accelerazioni verticali\n');
        fprintf('  [all] Esegui l''intera pipeline (4.1 -> 4.4)\n\n');
        choice = input('Seleziona il punto da eseguire [4.1 / 4.2 / 4.3 / 4.4 / all] (default: all): ', 's');
        if isempty(strtrim(choice))
            step = 'all';
        else
            step = strtrim(choice);
        end
    else
        step = 'all';
    end
end

% Normalize input argument
if isnumeric(step)
    stepStr = num2str(step);
else
    stepStr = lower(strtrim(string(step)));
end

fprintf('\n=======================================================\n');
fprintf('>>> Avvio analisi dinamica: Step %s <<<\n', stepStr);
fprintf('=======================================================\n\n');

switch stepStr
    case '4.1'
        fprintf('[Step 4.1] Calcolo spettro spostamenti di input...\n');
        FRF_input_displacement;
        
    case '4.2'
        fprintf('[Step 4.1] Calcolo spettro spostamenti di input...\n');
        FRF_input_displacement;
        fprintf('[Step 4.2] Partizionamento matrici e calcolo FRF spostamento...\n');
        Partizionando_matrici;
        FRF_output_displacement;
        
    case '4.3'
        fprintf('[Step 4.1] Calcolo spettro spostamenti di input...\n');
        FRF_input_displacement;
        fprintf('[Step 4.2] Partizionamento matrici e calcolo FRF spostamento...\n');
        Partizionando_matrici;
        FRF_output_displacement;
        fprintf('[Step 4.3] Ricostruzione storie temporali spostamenti (iFFT)...\n');
        TH_output_displacement;
        
    case {'4.4', 'all', '4'}
        fprintf('[Step 4.1] Calcolo spettro spostamenti di input...\n');
        FRF_input_displacement;
        fprintf('[Step 4.2] Partizionamento matrici e calcolo FRF spostamento...\n');
        Partizionando_matrici;
        FRF_output_displacement;
        fprintf('[Step 4.3] Ricostruzione storie temporali spostamenti (iFFT)...\n');
        TH_output_displacement;
        fprintf('[Step 4.4] Calcolo spettri e storie temporali accelerazioni...\n');
        FRF_TH_acceleration_output;
        
    otherwise
        error('Opzione non valida: "%s". Scegli tra: 4.1, 4.2, 4.3, 4.4, all.', stepStr);
end

fprintf('\n=======================================================\n');
fprintf('>>> Analisi completata con successo! <<<\n');
fprintf('=======================================================\n');
end
