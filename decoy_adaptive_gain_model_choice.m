function [nLL, sim] = fit_ag(X,p)
% takes inputs: data (X) and parameter values (p)
% returns negative log likelihood and simulated preferences & choice
% probabilities

temp      = p(1);
bias_i   = p(2);
bias_j   = p(3);
slope_i    = p(4);
slope_j    = p(5);
weight   = p(6);

mean_att1 = mean(X.att1,2);
n_att1    = sigmoid(X.att1-mean_att1,0,1,bias_i,slope_i);

mean_att2 = mean(X.att2,2);
n_att2    = sigmoid(X.att2-mean_att2,0,1,bias_j,slope_j);

sim.DV = n_att1*weight + n_att2*(1-weight);

cp     = exp(sim.DV./temp);
cp     = cp./sum(cp,2);

sim.pAB = cp(:,1)./(cp(:,1)+cp(:,2));
sim.pAD = cp(:,1)./(cp(:,1)+cp(:,3));
sim.pBD = cp(:,2)./(cp(:,2)+cp(:,3));
sim.cp  = cp;


%% if choice is passed in, compute log likelihood

if isfield(X, 'choice')

    num_trials = length(X.choice);
    num_choices = size(cp, 2);  % Number of choice options

    % Initialize loss
    loss_values = zeros(num_trials, 1);

    for t = 1:num_trials
        ch = X.choice(t,1);  % Actual first choice (assuming it's a single value)

        % Convert `ch` into a one-hot encoded vector
        y_true = zeros(1, num_choices);
        y_true(ch) = 1;  % Set actual choice to 1

        % Compute cross-entropy loss for this trial
        loss_values(t) = -sum(y_true .* log(cp(t,:)));
    end

    % Compute mean loss across all trials
    nLL = mean(loss_values);

else
    nLL = NaN;
end

