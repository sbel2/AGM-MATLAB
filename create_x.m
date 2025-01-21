% Load the .mat file and create X
load('decoy_233_participants.mat');

submat = find(data.sig_sub>0.99);

% Assuming 'data' is a structure array with fields as mentioned
Acost = data.Acost;
Bcost = data.Bcost;
Dcost = data.Dcost;
Arate = data.Arate;
Brate = data.Brate;
Drate = data.Drate;
choice = data.choice;
prefAtoB = data.prefAtoB;
prefAtoD = data.prefAtoD;
prefBtoD = data.prefBtoD;

% Filter the data using sigsubs
Acost = Acost(submat, :, :);
Bcost = Bcost(submat, :, :);
Dcost = Dcost(submat, :, :);
Arate = Arate(submat, :, :);
Brate = Brate(submat, :, :);
Drate = Drate(submat, :, :);
choice = choice(submat, :, :);
prefAtoB = prefAtoB(submat, :);
prefAtoD = prefAtoD(submat, :);
prefBtoD = prefBtoD(submat, :);

% Create att1 and att2 with the correct dimensions
num_participants = size(Acost, 1);
num_trials = size(Acost, 2);

att1 = zeros(num_participants, num_trials, 3);
att2 = zeros(num_participants, num_trials, 3);

att1(:, :, 1) = Acost;
att1(:, :, 2) = Bcost;
att1(:, :, 3) = Dcost;

att2(:, :, 1) = Arate;
att2(:, :, 2) = Brate;
att2(:, :, 3) = Drate;

% Combine into structure X
X.att1 = att1;
X.att1 = (X.att1 - min(X.att1)) ./ (max(X.att1) - min(X.att1));
X.att2 = att2;
X.att2 = (X.att2 - min(X.att2)) ./ (max(X.att2) - min(X.att2));

X.choice = choice;
X.prefAtoB = prefAtoB;
X.prefAtoD = prefAtoD;
X.prefBtoD = prefBtoD;

% Save X to a new .mat file
save('X.mat', 'X');