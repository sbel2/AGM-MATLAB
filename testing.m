% triggering commit
p = [0.00320251143319435	0.999993671378045	-0.0476159802216374	0.263655676777468	0.115566364760074	0.910984219321722];
%p = [0.0145506962991341	0.288382677329238	-0.124296939991718	0.149341547188185	0.149341547188185	0.456818527222530];
%p = [0.100000000000000 0 0 0.100000000000000 0.100000000000000 0.500000000000000];
disp('Loading data from X.mat...');
data = load('X.mat');
X = data.X;
disp('Data loaded successfully.');

num_participants = 189;
num_trials = 1060;
num_choices = 3180;

pAB_a = NaN(num_participants, num_trials);
pAD_a = NaN(num_participants, num_trials);
pBD_a = NaN(num_participants, num_trials);

temp     = p(1);
bias_i   = p(2);
bias_j   = p(3);
slope_i  = p(4);
slope_j  = p(5);
weight   = p(6);


for i = 1:189;
    participant_data.att1 = squeeze(X.att1(i, :, :));
    participant_data.att2 = squeeze(X.att2(i, :, :));
    participant_data.prefAtoB = X.prefAtoB(i, :)';
    participant_data.prefAtoD = X.prefAtoD(i, :)';
    participant_data.prefBtoD = X.prefBtoD(i, :)';
    participant_data.choice = X.choice(i,:,:);

    valid_rows = all(~isnan(participant_data.att1), 2);
    participant_data.att1 = participant_data.att1(valid_rows, :);
    participant_data.att2 = participant_data.att2(valid_rows, :);
    participant_data.prefAtoB = participant_data.prefAtoB(valid_rows, :);
    participant_data.prefAtoD = participant_data.prefAtoD(valid_rows, :);
    participant_data.prefBtoD = participant_data.prefBtoD(valid_rows, :);

    mean_att1 = mean(participant_data.att1,2);
    n_att1    = sigmoid(participant_data.att1-mean_att1,0,1,bias_i,slope_i);
    
    mean_att2 = mean(participant_data.att2,2);
    n_att2    = sigmoid(participant_data.att2-mean_att2,0,1,bias_j,slope_j);
    
    sim.DV = zeros(530, 3);
    sim.DV = n_att1*weight + n_att2*(1-weight);
    
    cp     = softmax(sim.DV./temp);
    
    sim.pAB = cp(:,1)./(cp(:,1)+cp(:,2));
    sim.pAD = cp(:,1)./(cp(:,1)+cp(:,3));
    sim.pBD = cp(:,2)./(cp(:,2)+cp(:,3));
    sim.cp  = cp;
    
    pAB_a(i, :) = [sim.pAB', NaN(1, num_trials - length(sim.pAB))];  % Pad with NaNs
    pAD_a(i, :) = [sim.pAD', NaN(1, num_trials - length(sim.pAD))];  % Pad with NaNs
    pBD_a(i, :) = [sim.pBD', NaN(1, num_trials - length(sim.pBD))];  % Pad with NaNs
end;

sim_struct = struct('pAB_a', pAB_a, ...
                    'pAD_a', pAD_a, ...
                    'pBD_a', pBD_a);

save('rep_sim_struct.mat', 'sim_struct');
