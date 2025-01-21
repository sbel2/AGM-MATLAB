p = [0.100000000293092	-0.323616754458959	-0.0127522991210891	0.0492025249221758	0.0492025249221758	2.84905039514987e-09];
%p = [0.431359656601654 -0.0356175702280543 0.0356311077787321 0.542490765585691 0.542490765585691 3.28653259070916e-09];
% p = [0.100000000000000 0 0 0.100000000000000 0.100000000000000 0.500000000000000];
disp('Loading data from X.mat...');
data = load('X.mat');
X = data.X;
disp('Data loaded successfully.');

temp      = p(1);
bias_i   = p(2);
bias_j   = p(3);
slope_i    = p(4);
slope_j    = p(5);
weight   = p(6);

num_participants = 189;
num_trials = 1060;
num_choices = 3180;

pAB_a = zeros(num_participants, num_trials);
pAD_a = zeros(num_participants, num_trials);
pBD_a = zeros(num_participants, num_trials);


for i = 1:189;
    participant_data.att1 = squeeze(X.att1(i, :, :));
    participant_data.att2 = squeeze(X.att2(i, :, :));
    participant_data.choice = X.choice(i, :, :);
    participant_data.prefAtoB = X.prefAtoB(i, :);
    participant_data.prefAtoD = X.prefAtoD(i, :);
    participant_data.prefBtoD = X.prefBtoD(i,:);

    [nll,sim] = decoy_adaptive_gain_model(participant_data, p)

    pAB_a(i, :) = sim.pAB;
    pAD_a(i, :) = sim.pAD;
    pBD_a(i, :) = sim.pBD;
end;

sim_struct = struct('pAB_a', pAB_a, ...
                    'pAD_a', pAD_a, ...
                    'pBD_a', pBD_a);

save('rep_sim_struct.mat', 'sim_struct');
