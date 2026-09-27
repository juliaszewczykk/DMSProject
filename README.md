# Dynamics of Mechanical Systems: Truss Bridge Dynamic Analysis

[![MATLAB](https://img.shields.io/badge/MATLAB-R2024b%2B-orange.svg)](https://www.mathworks.com/products/matlab.html)
[![Institution](https://img.shields.io/badge/Politecnico%20di%20Milano-1863-blue.svg)](https://www.polimi.it/)
[![Course](https://img.shields.io/badge/Course-Dynamics%20of%20Mechanical%20Systems-darkgreen.svg)](#)

Dynamic characterization and vibration mitigation of a 70-meter single-span metallic truss railway bridge modeled via the Finite Element Method (FEM). The project investigates the structural behavior under multi-support seismic excitation, moving train loads at critical resonant speeds, and evaluates structural and damping optimization strategies to suppress peak accelerations.

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Theoretical & Algorithmic Architecture](#-theoretical--algorithmic-architecture)
  - [1. Finite Element Discretization & Mesh Design](#1-finite-element-discretization--mesh-design)
  - [2. Free Vibration & Modal Analysis](#2-free-vibration--modal-analysis)
  - [3. Multi-Support Seismic Base Excitation](#3-multi-support-seismic-base-excitation)
  - [4. Moving Train Load & Critical Resonant Speeds](#4-moving-train-load--critical-resonant-speeds)
  - [5. Structural Mitigation & Damping Optimization](#5-structural-mitigation--damping-optimization)
- [Repository Structure](#-repository-structure)
- [Prerequisites & Requirements](#-prerequisites--requirements)
- [Quickstart & Execution Guide](#-quickstart--execution-guide)
  - [Environment Setup](#environment-setup)
  - [Running the Main Pipeline](#running-the-main-pipeline)
  - [Running Individual Modular Steps](#running-individual-modular-steps)
  - [Expected Numerical Outputs](#expected-numerical-outputs)
- [Authors & Academic Credits](#-authors--academic-credits)

---

## 🔭 Overview

Railway bridges and civil truss structures are subjected to severe dynamic loads during operational lifetime, such as seismic ground motions and high-speed moving train axle passages. This repository provides a complete numerical modeling framework developed in **MATLAB** to:

1. **Discretize** the bridge using 1D Euler-Bernoulli beam elements complying with quasi-static frequency constraints ($f_{\max} = 30\text{ Hz}$).
2. **Solve** the generalized eigenvalue problem to extract natural frequencies and mode shapes.
3. **Partition** system mass, damping, and stiffness matrices to compute the frequency response under multi-support seismic base excitation ($O_1$ and $O_2$).
4. **Reconstruct** time histories for displacement and acceleration at key monitoring points (Node A at mid-span, Node B at quarter-span) via Inverse Fast Fourier Transform (iFFT).
5. **Identify** critical resonant train speeds ($V_{\text{res}}$) under periodic axle loads.
6. **Design, optimize, and validate** structural modifications (introducing additional truss members, a pyramid superstructure, and damping enhancements) to reduce peak vertical accelerations at Node B by $\ge 15\%$ under a strict $+5\%$ mass constraint.

---


## 📐 Theoretical & Algorithmic Architecture

```
                  +-------------------------------------------------+
                  |      FEM Structural Assembly (dmb_fem2)         |
                  |          [M], [K], [R] (126 x 126)              |
                  +-------------------------------------------------+
                                           |
                                           v
                  +-------------------------------------------------+
                  |      Modal Analysis: Natural Frequencies        |
                  |     (det(-w^2*M_FF + K_FF) = 0, 5 modes < 30Hz) |
                  +-------------------------------------------------+
                                           |
                    +----------------------+----------------------+
                    |                                             |
                    v                                             v
+---------------------------------------+     +---------------------------------------+
|        Point 4: Seismic Analysis      |     |       Point 5: Moving Train Loads     |
+---------------------------------------+     +---------------------------------------+
| 4.1: FFT of Seismic Inputs (O1, O2)   |     | Axle spacing d = 26 m, speed V        |
| 4.2: Partition Matrices & Solve FRF:  |     | Harmonic frequencies f_k = k * (V / d)|
|      D_FF(w) * U_F(w) = -D_FC(w)*U_C  |     | Critical speed: V_res = (f_1 * d) / k |
| 4.3: Displacement Time History (iFFT) |     | Worst-case: Mode 1, k=1 -> 217.1 km/h |
| 4.4: Acceleration Response & iFFT:    |     +---------------------------------------+
|      Acc(w) = -w^2 * U(w)             |                         |
+---------------------------------------+                         v
                    |                         +---------------------------------------+
                    +------------------------>|     Point 6: Structural Optimization  |
                                              +---------------------------------------+
                                              | Target: Acc_B <= 85% (-15% reduction) |
                                              | Mass budget: delta_M <= +5% (+1135 kg)|
                                              |                                       |
                                              | [1] Structural/Topological (Primary): |
                                              |   - Case 1: Additional Beams at Node 5|
                                              |     (HEA300 stiffeners -> -15.2% Acc) |
                                              |   - Case 2: Pyramid Superstructure    |
                                              |     (New nodes 43-44 -> -19.3% Acc)   |
                                              | [2] Cross-Section Resizing (-13.3%)   |
                                              | [3] Viscoelastic Damping (alpha=0.18) |
                                              +---------------------------------------+
```

### 1. Finite Element Discretization & Mesh Design
To guarantee that finite elements behave quasi-statically within the frequency range of interest ($0 \le f \le 30\text{ Hz}$), a safety coefficient $s = 1.5$ is applied, yielding $\Omega_{\max} = 2\pi \cdot 30\text{ rad/s} \approx 188.5\text{ rad/s}$. The maximum admissible element length $L_{\max}$ is derived from the pin-pin beam eigenfrequency:

$$L_{\max} = \left[ \frac{\pi^2}{s \, \Omega_{\max}} \sqrt{\frac{E \, J}{m}} \right]^{1/2}$$

With structural steel properties $E = 2.06 \times 10^{11}\text{ N/m}^2$ and $\rho = 7800\text{ kg/m}^3$:
- **Chords (IPE500)**: $L = 5.0\text{ m} < L_{\max} \approx 6.05\text{ m} \implies 1\text{ element / bay}$.
- **Verticals (IPE240)**: $L = 4.0\text{ m} < L_{\max} \approx 4.25\text{ m} \implies 1\text{ element / post}$.
- **Diagonals (HEA300)**: $L_{\text{diag}} = \sqrt{5^2 + 4^2} \approx 6.40\text{ m} > L_{\max} \approx 4.78\text{ m}$.  
  *Solution*: Each diagonal is split into two elements of $3.2\text{ m}$ by adding intermediate nodes (Nodes 29 to 42), giving a total of **42 nodes** and **53 beam elements** (126 DOFs).

### 2. Free Vibration & Modal Analysis
The bridge is supported by a hinge at Node 1 ($u_x = u_y = 0$) and a roller cart at Node 15 ($u_y = 0$), leaving $N_c = 3$ constrained DOFs and $N_f = 123$ free DOFs. The generalized undamped eigenvalue problem on the free degrees of freedom is:

$$\det\left( -\omega^2 [M_{FF}] + [K_{FF}] \right) = 0$$

The first 5 natural frequencies below $30\text{ Hz}$ are:

| Mode ($n$) | Frequency $f_n$ [Hz] | Characteristic Deformation Pattern |
|:----------:|:--------------------:|:-----------------------------------|
| **1** | **2.3199** | 1st Symmetric global vertical bending (mid-span anti-node) |
| **2** | **8.3120** | 1st Antisymmetric vertical bending (mid-span nodal point) |
| **3** | **12.7264** | 2nd Symmetric vertical bending |
| **4** | **17.6592** | 2nd Antisymmetric vertical bending |
| **5** | **26.4690** | 3rd Symmetric vertical bending |

Structural damping is modeled using the Rayleigh proportional damping formulation:

$$[C] = \alpha [M] + \beta [K], \quad \alpha = 0.15\text{ s}^{-1}, \quad \beta = 9.0 \times 10^{-5}\text{ s}$$

### 3. Multi-Support Seismic Base Excitation
Ground motion displacements $y_{O1}(t)$ and $y_{O2}(t)$ are applied at supports $O_1$ (Node 1) and $O_2$ (Node 15). The partitioned equations of motion in the frequency domain are:

$$\begin{bmatrix} M_{FF} & M_{FC} \\ M_{CF} & M_{CC} \end{bmatrix} \begin{bmatrix} \ddot{U}_F \\ \ddot{U}_C \end{bmatrix} + \begin{bmatrix} C_{FF} & C_{FC} \\ C_{CF} & C_{CC} \end{bmatrix} \begin{bmatrix} \dot{U}_F \\ \dot{U}_C \end{bmatrix} + \begin{bmatrix} K_{FF} & K_{FC} \\ K_{CF} & K_{CC} \end{bmatrix} \begin{bmatrix} U_F \\ U_C \end{bmatrix} = \begin{bmatrix} 0 \\ R_C \end{bmatrix}$$

Defining the dynamic stiffness matrices at angular frequency $\omega$:

$$D_{FF}(\omega) = -\omega^2 M_{FF} + i\omega C_{FF} + K_{FF}$$
$$D_{FC}(\omega) = -\omega^2 M_{FC} + i\omega C_{FC} + K_{FC}$$

The equivalent seismic force vector and steady-state displacement response are:

$$F_{\text{eq}}(\omega) = - D_{FC}(\omega) U_C(\omega) \implies U_F(\omega) = D_{FF}(\omega)^{-1} F_{\text{eq}}(\omega)$$

The vertical acceleration spectrum is obtained algebraically through the kinematic relation:

$$A_F(\omega) = -\omega^2 U_F(\omega)$$

The $-\omega^2$ factor acts as a high-pass filter, attenuating the slow quasi-static ground drift ($f < 1\text{ Hz}$) and amplifying the structural resonant modes. Time histories $y(t)$ and $\ddot{y}(t)$ are reconstructed via the Inverse Fast Fourier Transform (`ifft` with symmetric Hermite property).

### 4. Moving Train Load & Critical Resonant Speeds
A sequence of axles spaced at distance $d = 26\text{ m}$ traveling at constant speed $V$ generates a periodic excitation with fundamental frequency $f_0 = V / d$. Resonance occurs when a harmonic $k$ matches a bridge natural frequency $f_i$:

$$V_{i,k} = \frac{f_i \cdot d}{k} \quad [\text{m/s}] = 3.6 \frac{f_i \cdot d}{k} \quad [\text{km/h}]$$

- **Critical Worst-Case**: Mode 1 ($f_1 = 2.32\text{ Hz}$) excited by the fundamental harmonic ($k = 1$):
  $$V_{\text{res}, 1, 1} \approx 217.1\text{ km/h}$$
  Because $217.1\text{ km/h}$ falls directly within standard passenger railway operating speeds, sustained transit at this speed leads to dynamic amplification $H_{\max} \approx \frac{1}{2\zeta_1} \approx 86.2$, risking structural limit state exceedance.

### 5. Structural Mitigation & Dynamic Optimization (Point 6)

The design challenge requires defining a structural modification capable of suppressing the maximum vertical acceleration at **Node B** (quarter-span, Node 5) by at least **15%** under dynamic loading, while strictly respecting a **maximum total mass increase of +5%** ($\Delta M \le +5\%$) and without introducing new external boundary supports.

$$\text{Goal: } a_{\text{orig,max}} = 8.55 \times 10^{-3}\text{ m/s}^2 \implies a_{\text{goal,max}} \le 0.85 \cdot a_{\text{orig,max}} = 7.27 \times 10^{-3}\text{ m/s}^2$$
$$\text{Budget: } M_{\text{orig}} = 22698\text{ kg} \implies M_{\text{limit}} = 1.05 \cdot M_{\text{orig}} = 23833\text{ kg} \quad (\Delta M \le +1135\text{ kg})$$

To address this challenge, four distinct engineering strategies were evaluated:

#### 1. Primary Strategy: Geometric & Topological Modification (Additional Beams)
Modifying the bridge topology by adding structural members directly alters the load paths and significantly boosts local and global bending stiffness. Two concrete configurations were developed:

- **Case 1: Local Reinforcement at Node 5 (Additive Beams)**:
  - Rather than modifying existing elements, additional diagonal brace members with HEA300 cross-sections were inserted in the vicinity of Node 5 to stiffen the local deck zone.
  - **Total mass**: $23823\text{ kg}$ ($+4.975\%$ increase, within the $+5\%$ limit).
  - **Performance**: Peak acceleration reduced from $8.55 \times 10^{-3}\text{ m/s}^2$ to $7.25 \times 10^{-3}\text{ m/s}^2$ (**$-15.2\%$ reduction**), successfully achieving the project goal.

- **Case 2: "Pyramid" Superstructure over 2nd Mode Anti-Nodes (Optimal Bridge Version 2)**:
  - Modal analysis demonstrated that the acceleration response at Node B is predominantly governed by the **second vibration mode** ($f_2 \approx 8.31\text{ Hz}$, antisymmetric mode with large anti-nodes at quarters of the span: $x = 20\text{ m}$ and $x = 50\text{ m}$).
  - A dedicated **"pyramid" truss superstructure** was introduced at the anti-nodes by creating two new apex nodes (**Node 43** at $x = 20\text{ m}, y = 7\text{ m}$ and **Node 44** at $x = 50\text{ m}, y = 7\text{ m}$) above the top chord, connected with inclined beams.
  - The new pyramid elements were constructed using lightweight IPE240 profiles, and diagonal members 7-35-22 and 9-36-22 were resized from HEA300 to IPE240 to balance the mass budget.
  - **Engineering Rationale**: By projecting members vertically, the effective structural depth $h$ is greatly increased. Because structural bending stiffness is proportional to the moment of inertia ($I \propto h^2$), this topological modification delivers huge stiffness gains with negligible added mass.
  - **Total mass**: $23720\text{ kg}$ ($+4.5\%$ increase, well below the $23833\text{ kg}$ limit).
  - **Performance**: Peak vertical acceleration plummeted to **$0.0069\text{ m/s}^2$** (**$\approx 19.3\%$ reduction**), widely outperforming the mandatory $15\%$ threshold.

#### 2. Cross-Section Optimization (Sensitivity Study)
A parametric sensitivity study tested whether upgrading standard beam profiles within the mass budget could meet the requirement:
1. **IPE 500 $\to$ IPE 550 on Chords**: Upgraded 14 central chord elements ($L = 5\text{ m}$). Peak acceleration decreased from $0.0085\text{ m/s}^2$ to $0.0079\text{ m/s}^2$ (**$-7.0\%$ reduction**, insufficient).
2. **IPE 500 $\to$ IPE 600 on Chords**: Due to the heavier linear mass ($122.46\text{ kg/m}$ vs $90.1\text{ kg/m}$), only 6 elements between Point B and mid-span could be upgraded ($J = 92080\text{ cm}^4$). Peak acceleration dropped to $0.0074\text{ m/s}^2$ (**$-13.3\%$ reduction**, close but short of the $15\%$ target).
3. **HEA 300 $\to$ HEA 400 on Diagonals**: Stiffening the shear load path on 4 critical diagonals ($m_{\text{lin}} = 124.82\text{ kg/m}$) yielded $a_{\max} = 0.00745\text{ m/s}^2$ (**$-12.9\%$ reduction**).
- *Mesh Verification*: Since all upgraded sections feature higher $J/A$ ratios, the critical element length $L_{\max} \propto \sqrt[4]{J/A}$ increased, ensuring the FEM mesh remained strictly valid against spatial aliasing.

#### 3. Material Substitution Analysis (Why Infeasible)
- **High-Strength Steel**: Common intuition suggests substituting higher-grade steel. However, while yield strength $\sigma_y$ increases, Young's Modulus ($E \approx 206 - 210\text{ GPa}$) is practically identical across all structural steel grades. Because dynamic vibration is governed by stiffness and inertia, not yield failure, steel grade substitution provides **0% vibration reduction**.
- **Alternative Materials**: Aluminum ($E \approx 70\text{ GPa}, \rho \approx 2700\text{ kg/m}^3$) requires 3x larger sections to maintain equivalent stiffness, cancelling weight advantages. Titanium and Carbon Fiber Reinforced Polymers (CFRP) provide superior specific stiffness but are cost-prohibitive and introduce complex anisotropic joint redesigns incompatible with standard civil 1D beam infrastructure.

#### 4. Alternative Analytical Intervention: Viscoelastic Damping (VE Pads)
As an alternative purely dissipative approach, installing **Passive Viscoelastic Dampers (VE Pads)** at the connection joints of vertical members (IPE240) was analyzed:
- The peak resonance acceleration scales inversely with the modal damping ratio: $A_{\max} \propto \frac{1}{2\zeta}$.
- Achieving a $15\%$ reduction requires scaling the damping ratio by:
  $$\zeta_{\text{new}} = \frac{1}{0.85} \zeta_{\text{old}} \approx 1.1765 \cdot \zeta_{\text{old}} \quad (+17.65\%)$$
- Updating the mass-proportional Rayleigh parameter from $\alpha = 0.15\text{ s}^{-1}$ to $\alpha_{\text{new}} = 0.18\text{ s}^{-1}$ guarantees the required $\ge 15\%$ suppression while adding virtually no structural mass ($\Delta M \approx 0$).

---


## 📁 Repository Structure

```
DMSProject/
├── data/                                 # Datasets and FEM model definitions
│   ├── bridge.inp                        # FEM input file: nodes, elements, material, damping
│   ├── bridge_fre.mat                    # Modal properties: natural frequencies and eigenvectors
│   ├── bridge_mkr.mat                    # Structural matrices (M, K, R) and DOF mapping (idb)
│   └── seismic_displ.txt                 # Ground motion displacement time history (Time, O1, O2)
├── docs/                                 # Technical documentation and reports
│   └── Yearwork_Report.pdf               # Complete academic report (Politecnico di Milano)
├── src/                                  # Source code routines
│   ├── FRF_input_displacement.m          # Step 4.1: FFT & spectrum of seismic input signals
│   ├── Partizionando_matrici.m           # Step 4.2a: Boundary condition matrix partitioning
│   ├── FRF_output_displacement.m         # Step 4.2b: FRF calculation of output displacements
│   ├── TH_output_displacement.m          # Step 4.3: iFFT reconstruction of displacement time histories
│   └── FRF_TH_acceleration_output.m      # Step 4.4: Acceleration spectra & time histories via iFFT
├── .gitignore                            # Standard git exclusion rules for MATLAB & OS
├── main.m                                # Master execution pipeline (interactive & batch mode)
├── README.md                             # Comprehensive project documentation
└── startup.m                             # Automatic environment and path initialization
```

---

## 💻 Prerequisites & Requirements

- **MATLAB**: Version R2021a or newer recommended (tested and validated on **MATLAB R2024b**).
- **Toolboxes**: Uses standard MATLAB core linear algebra and signal processing functions (`fft`, `ifft`, `load`, `xline`, `semilogx`). No specialized proprietary toolboxes are required.
- **OS**: Cross-platform (Windows, Linux, macOS).

---

## 🚀 Quickstart & Execution Guide

### Environment Setup
1. Clone or download this repository:
   ```bash
   git clone https://github.com/juliaszewczykk/DMSProject.git
   cd DMSProject
   ```
2. Launch MATLAB and open the project directory. The root [`startup.m`](file:///c:/Users/julia/Desktop/DMSProject/startup.m) script runs automatically, adding `src/` and `data/` to your MATLAB search path.

### Running the Main Pipeline

#### 1. Interactive Mode (MATLAB Desktop)
In the MATLAB Command Window, simply run:
```matlab
main
```
You will be presented with an interactive menu to select the target analysis point:
```
Punti di analisi disponibili:
  [4.1] Spettro degli spostamenti di input sismico (O1, O2)
  [4.2] Spettro della risposta in frequenza (FRF) degli spostamenti (A, B)
  [4.3] Storie temporali degli spostamenti verticali (iFFT)
  [4.4] Spettro e storie temporali delle accelerazioni verticali
  [all] Esegui l'intera pipeline (4.1 -> 4.4)

Seleziona il punto da eseguire [4.1 / 4.2 / 4.3 / 4.4 / all] (default: all): 
```

#### 2. Programmatic / Batch Mode
Run specific steps or the entire suite directly:
```matlab
main(4.1);       % Step 4.1 only
main(4.2);       % Steps 4.1 + 4.2
main(4.3);       % Steps 4.1 + 4.2 + 4.3
main(4.4);       % Steps 4.1 to 4.4 (Full pipeline)
main('all');     % Full pipeline
```

To run non-interactively from the terminal:
```bash
matlab -batch "main('all')"
```

---

### Running Individual Modular Scripts
If you prefer running individual scripts directly from `src/`:
```matlab
% 1. Load base model
load('bridge_mkr.mat'); load('bridge_fre.mat', 'freq');
Nat_freq = freq(freq < 30);
add_nat_freq_lines = @(f) xline(f, '--r', 'Alpha', 0.6, 'LineWidth', 1);

% 2. Run steps
FRF_input_displacement;       % Analyzes ground motion FFT
Partizionando_matrici;        % Partitions system matrices
FRF_output_displacement;      % Computes frequency response functions
TH_output_displacement;       % Performs iFFT for displacement
FRF_TH_acceleration_output;   % Computes acceleration spectra and time history
```

---

### Expected Numerical Outputs

Running `main('all')` prints verification results to the console and generates comparative figures:

```text
Loading FE model matrices and modal parameters...

=======================================================
>>> Avvio analisi dinamica: Step all <<<
=======================================================

[Step 4.1] Calcolo spettro spostamenti di input...
[Step 4.2] Partizionamento matrici e calcolo FRF spostamento...
Free dofs: 123, constrained dofs: 3
[Step 4.3] Ricostruzione storie temporali spostamenti (iFFT)...
Calcolo della iFFT per tornare nel dominio del tempo...
--- Risultati Time History ---
Massimo spostamento assoluto Nodo A: 0.1724 m (17.2 cm)
Massimo spostamento assoluto Nodo B: 0.2094 m (20.9 cm)
[Step 4.4] Calcolo spettri e storie temporali accelerazioni...
Max Acceleration A: 3.215 m/s^2 (0.33 g)
Max Acceleration B: 3.659 m/s^2 (0.37 g)

=======================================================
>>> Analisi completata con successo! <<<
=======================================================
```

#### Generated Figures:
- **Figure 1**: Input displacement single-sided spectra $|Y_{O1}(f)|$ and $|Y_{O2}(f)|$ with natural frequency lines.
- **Figure 2**: Output vertical displacement spectra $|Y_A(f)|$ and $|Y_B(f)|$ highlighting quasi-static vs. resonant response.
- **Figure 3**: Time histories $y_A(t)$ and $y_B(t)$ with peak displacements and phase reversal.
- **Figure 4**: Acceleration frequency spectra $|Acc_A(f)|$ and $|Acc_B(f)|$ demonstrating high-pass modal filtering.
- **Figure 5**: Acceleration time histories $\ddot{y}_A(t)$ and $\ddot{y}_B(t)$ showing high-frequency structural oscillations.

---

## 👤 Authors & Academic Credits

- **Author**: **Julia Szewczyk** ([@juliaszewczykk](https://github.com/juliaszewczykk))
- **Institution**: **Politecnico di Milano** — School of Industrial and Information Engineering
- **Degree Course**: Master of Science in Mechanical Engineering
- **Course**: *Dynamics of Mechanical Systems* (Academic Year 2025/2026)
- **Course Instructors**:
  - Prof. **Giuseppe Bucca**
  - Prof. **Lorenzo Bernardini**
- **Reference Document**: The full technical paper detailing all derivations, FEM calculations, moving load analysis, and design optimizations is available in [`docs/Yearwork_Report.pdf`](file:///c:/Users/julia/Desktop/DMSProject/docs/Yearwork_Report.pdf).
