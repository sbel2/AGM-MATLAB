p = [0.100000000293092	-0.323616754458959	-0.0127522991210891	0.0492025249221758	0.0492025249221758	2.84905039514987e-09];
%p = [0.431359656601654 -0.0356175702280543 0.0356311077787321 0.542490765585691 0.542490765585691 3.28653259070916e-09];
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

i=1;

participant_data.att1 = X.att1(i, :, :);
participant_data.att2 = X.att2(i, :, :);
participant_data.choice = X.choice(i, :, :);
participant_data.prefAtoB = X.prefAtoB(i, :);
participant_data.prefAtoD = X.prefAtoD(i, :);
participant_data.prefBtoD = X.prefBtoD(i, :);

mean_att1 = mean(participant_data.att1,2);
std_att1 = std(participant_data.att1, 0, 2);
n_att1 = (participant_data.att1-mean_att1)./std_att1;
%n_att1    = sigmoid(norm_x,0,1,bias_i,slope_i);

mean_att2 = mean(participant_data.att2,2);
std_att2 = std(participant_data.att2, 0, 2);
% n_att2    = sigmoid((participant_data.att2-mean_att2)./std_att2,0,1,bias_i,slope_i);
n_att2 = (participant_data.att2-mean_att2)./std_att2;

sim.DV = n_att1*weight + n_att2*(1-weight);

maxDV = max(sim.DV, [], 2);  % Find the maximum along each row
cp = exp(sim.DV - maxDV);    % Subtract the max from each element before exponentiating
cp = cp ./ sum(cp, 2);

sim.pAB = cp(1,1,:) ./ (cp(1,1,:) + cp(1,2,:));
sim.pAD = cp(1,1,:) ./ (cp(1,1,:) + cp(1,3,:));
sim.pBD = cp(1,2,:) ./ (cp(1,2,:) + cp(1,3,:));
sim.cp  = cp;