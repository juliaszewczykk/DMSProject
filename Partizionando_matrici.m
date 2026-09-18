%% Partition matrix

Ndof = size(M,1);

% nodi vincolati
nodeO1 = 1;    % hinge
nodeO2 = 15;   % cart

% DOF globali corrispondenti ai vincoli:
% hinge in O1: x e y bloccati
dofO1_x = idb(nodeO1, 1);
dofO1_y = idb(nodeO1, 2);

% cart in O2: y bloccato 
dofO2_y = idb(nodeO2, 2);

% vettore dei DOF vincolati (C)
dofC = unique([dofO1_x, dofO1_y, dofO2_y]);

% tutti i DOF globali
allDofs = 1:Ndof;

% DOF liberi (F) = tutti tranne quelli vincolati
dofF = setdiff(allDofs, dofC);

Nf = numel(dofF);
Nc = numel(dofC);
fprintf('Free dofs: %d, constrained dofs: %d\n', Nf, Nc);

M_FF = M(dofF, dofF);
M_FC = M(dofF, dofC);
M_CF = M(dofC, dofF);
M_CC = M(dofC, dofC);

C_FF = R(dofF, dofF);
C_FC = R(dofF, dofC);
C_CF = R(dofC, dofF);
C_CC = R(dofC, dofC);

K_FF = K(dofF, dofF);
K_FC = K(dofF, dofC);
K_CF = K(dofC, dofF);
K_CC = K(dofC, dofC);