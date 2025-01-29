% Load the participant data from the newly created X.mat file
data = load('X.mat');
X = data.X;

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

% Precompute participant data
participant_data_array = cell(num_participants, 1);
for i = 1:num_participants
    participant_data = struct();
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
    
    participant_data_array{i} = participant_data;
end

% GlobalSearch setup for optimization
gs = GlobalSearch('Display', 'off', 'NumTrialPoints', 200);  % Fewer trial points

% Compile the objective function (if you have MATLAB Coder)
% codegen decoy_adaptive_gain_model -args {participant_data_array{1}, initial_params}

% Parallel processing
parpool('local', feature('numcores')); % Use all available cores

parfor i = 1:num_participants
    disp(['Processing participant ', num2str(i)]);
    
    participant_data = participant_data_array{i};
    
    problem = createOptimProblem('fmincon', ...
        'x0', initial_params, ...
        'objective', @(p) decoy_adaptive_gain_model(participant_data, p), ...
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
