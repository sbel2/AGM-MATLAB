load decoy_233_participants.mat
submat = find(data.sig_sub>0.99);

for s = 1:length(submat)
    sub = submat(s);

    
    indx       = find(~isnan(data.prefAtoB(sub,:)));
    X(s).prefAtoB = squeeze(data.prefAtoB(sub,indx))';
    X(s).prefAtoD = squeeze(data.prefAtoD(sub,indx))';
    X(s).prefBtoD = squeeze(data.prefBtoD(sub,indx))';
    X(s).choice   = 1+squeeze(data.choice(sub,:,indx))';
    X(s).att1     = [data.Aatt1(sub,indx);data.Batt1(sub,indx);data.Datt1(sub,indx)]';
    X(s).att2     = [data.Aatt2(sub,indx);data.Batt2(sub,indx);data.Datt2(sub,indx)]';

end

% Define initial parameters and bounds
initial_params = [0.1, 0, 0, 0.1, 0.1, 0.5]; % 6 parameters
min_params = [0.001, -1, -1, 0.00001, 0.00001, 0]; % Lower bounds
max_params = [10, 1, 1, 1, 1, 1]; % Upper bounds

Aeq = [0 0 0 -1 1 0]; % Enforces the equality between b3 and b4
beq = 0;

% Loop through participants
num_participants = 189;
best_params = zeros(num_participants, length(initial_params));
nLLs = zeros(num_participants, 1);

% Optimization options
options = optimoptions('fmincon', 'Algorithm', 'interior-point', 'Display', 'off', ...
    'MaxIterations', 1000, 'MaxFunctionEvaluations', 2000);

rng default

% GlobalSearch setup for optimization
gs = GlobalSearch('Display', 'off', 'NumTrialPoints', 1000);

% Parallel processing
parpool('local', feature('numcores'));

parfor i = 1:num_participants
    disp(['Processing participant ', num2str(i)]);
    
    Xp = X(i)
    
    problem = createOptimProblem('fmincon', ...
        'x0', initial_params, ...
        'objective', @(p) decoy_adaptive_gain_model(Xp, p), ...
        'lb', min_params, ...
        'ub', max_params, ...
        'Aeq', Aeq, ...
        'beq', beq, ...
        'options', options);
    
    try
        [bestp, nLL] = run(gs, problem); % GlobalSearch execution
    catch ME
        warning('Participant %d encountered an error: %s', i, ME.message);
        bestp = NaN(size(initial_params));
        nLL = NaN;
    end

    % Store the results for each participant
    best_params(i, :) = bestp;
    nLLs(i) = nLL;

    % Display results for current participant
    disp(['Best parameters for participant ', num2str(i), ': ', mat2str(bestp)]);
    disp(['Negative log likelihood for participant ', num2str(i), ': ', num2str(nLL)]);
end

% Close parallel pool
delete(gcp('nocreate'));

save('bestp.mat',"best_params")
