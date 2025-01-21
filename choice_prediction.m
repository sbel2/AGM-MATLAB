% bestp = [0.100000000293092	-0.323616754458959	-0.0127522991210891	0.0492025249221758	0.0492025249221758	2.84905039514987e-09];
%bestp = [0.431359656601654 -0.0356175702280543 0.0356311077787321 0.542490765585691 0.542490765585691 3.28653259070916e-09];
bestp = [0.100000000000000 0 0 0.100000000000000 0.100000000000000 0.500000000000000];
disp('Loading data from X.mat...');
data = load('X.mat');
X = data.X;
disp('Data loaded successfully.');

num_participants = size(X.att1, 1);
num_trials = 1060;
num_choices = 3180;

pAB_all = zeros(num_participants, num_trials);
pAD_all = zeros(num_participants, num_trials);
pBD_all = zeros(num_participants, num_trials);
flattened_cp = zeros(num_participants, num_choices);


disp(['Total participants to process: ', num2str(num_participants)]);
disp(['Each participant has ', num2str(num_trials), ' trials.']);

for i = 1:num_participants
    disp(['Processing participant ', num2str(i), ' of ', num2str(num_participants)]);
    
    participant_data.att1 = X.att1(i, :, :);
    participant_data.att2 = X.att2(i, :, :);
    participant_data.choice = X.choice(i, :, :);
    participant_data.prefAtoB = X.prefAtoB(i, :);
    participant_data.prefAtoD = X.prefAtoD(i, :);
    participant_data.prefBtoD = X.prefBtoD(i, :);

    disp('Running decoy adaptive gain model...');
    [nLL, sim_ind] = decoy_adaptive_gain_model(participant_data, bestp);
    disp('Model computation completed.');

    cp_flat = reshape(sim_ind.cp, 1, num_choices);
    flattened_cp(i, :) = cp_flat;
    pAB_all(i, :) = sim_ind.pAB;
    pAD_all(i, :) = sim_ind.pAD;
    pBD_all(i, :) = sim_ind.pBD;
    DV(i, :, :) = sim_ind.DV;

    disp(['Participant ', num2str(i), ' processing complete.']);
end

disp('All participants processed. Compiling results into a table...');
sim_struct = struct('pAB_all', pAB_all, ...
                    'pAD_all', pAD_all, ...
                    'pBD_all', pBD_all, ...
                    'flattened_cp', flattened_cp,...
                    'DV', DV);

disp('Data compilation complete.');
disp('Data processing and table creation complete.');

save('rep_sim_struct.mat', 'sim_struct');