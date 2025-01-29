% Load the .mat file and create X
load('decoy_233_participants.mat');
load('submat_file.mat');

load('quantileCostA.mat')
load('quantileCostB.mat')
load('quantileCostD.mat')
load('quantileRateA.mat')
load('quantileRateB.mat')
load('quantileRateD.mat')

% Filter the data using sigsubs
% Acost = data.Aatt1(submat, :, :);
% Bcost = data.Batt1(submat, :, :);
% Dcost = data.Datt1(submat, :, :);
% Arate = data.Aatt2(submat, :, :);
% Brate = data.Batt2(submat, :, :);
% Drate = data.Datt2(submat, :, :);

Acost = quantileCostA(submat,:,:);
Bcost = quantileCostB(submat,:,:);
Dcost = quantileCostD(submat,:,:);
Arate = quantileRateA(submat,:,:);
Brate = quantileRateB(submat,:,:);
Drate = quantileRateD(submat,:,:);

prefAtoB = data.prefAtoB(submat, :);
prefAtoD = data.prefAtoD(submat, :);
prefBtoD = data.prefBtoD(submat, :);
choice = data.choice;

% Create att1 and att2 with the correct dimensions
num_participants = 189;
num_trials = 1060;

att1 = zeros(189, num_trials, 3);
att2 = zeros(189, num_trials, 3);

att1(:, :, 1) = Acost;
att1(:, :, 2) = Bcost;
att1(:, :, 3) = Dcost;

att2(:, :, 1) = Arate;
att2(:, :, 2) = Brate;
att2(:, :, 3) = Drate;

% Combine into structure X
X.att1 = att1;
X.att2 = att2;
X.prefAtoB = prefAtoB;
X.prefAtoD = prefAtoD;
X.prefBtoD = prefBtoD;
X.choice = choice;

% Save X to a new .mat file
save('X.mat', 'X');