clc
close all
clear all

load("bridge_mkr.mat");
load("bridge_fre.mat", "freq");
Nat_freq = freq(freq < 30);
add_nat_freq_lines = @(freqs) xline(freqs, '--r', 'Alpha', 0.6, 'LineWidth', 1);


es = input("Fino a che punto fare: ");

if es == 4.1
    FRF_input_displacement
elseif es == 4.2
    FRF_input_displacement;
    Partizionando_matrici
    FRF_output_displacement
end