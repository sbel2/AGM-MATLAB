
% Load the participant data from the newly created X.mat file
disp('Loading participant data from X.mat...');
data = load('X.mat');
X = data.X;
disp('Data loaded successfully.');

% Define initial parameters and bounds
initial_params = [0.1, 0, 0, 0.1, 0.1, 0.5]; % 5 parameters
min_params = [0.001, -1, -1, 0.00001, 0.00001,0]; % Lower bounds
max_params = [10, 1, 1, 1, 1, 1]; % Upper bounds

Aeq = [0 0 0 -1 1 0]; % Enforces the equality between b3 and b4
beq = 0;

% Loop through participants
num_participants = size(X.att1, 1);
best_params = zeros(num_participants, length(initial_params));
nLLs = zeros(num_participants, 1);

% Optimization options
options = optimoptions('fmincon', 'Algorithm', 'interior-point', 'Display', 'off', 'MaxIterations', 1000, 'MaxFunctionEvaluations', 2000);

rng default

for i = 1:num_participants
    disp(['Processing participant ', num2str(i)]);
    participant_data.att1 = X.att1(i, :, :);
    participant_data.att2 = X.att2(i, :, :);
    participant_data.choice = X.choice(i, :, :);
    participant_data.prefAtoB = X.prefAtoB(i, :);
    participant_data.prefAtoD = X.prefAtoD(i, :);
    participant_data.prefBtoD = X.prefBtoD(i, :);

    disp('Participant data:');
    disp(participant_data);

    gs = GlobalSearch('Display', 'off');
    problem = createOptimProblem('fmincon', ...
        'x0', initial_params, ...
        'objective', @(p) decoy_adaptive_gain_model(participant_data, p), ...
        'lb', min_params, ...
        'ub', max_params, ...
        'Aeq', Aeq, ...
        'beq', beq, ...
        'options', options);
    
    try
        disp('Starting optimization...');
        [bestp, nLL] = run(gs, problem); % Assuming `run` returns these
        disp('Optimization completed successfully.');
    catch ME
        warning('Participant %d encountered an error: %s', i, ME.message);
        fprintf('Detailed error for participant %d: %s\n', i, getReport(ME));
        bestp = NaN(size(initial_params));
        nLL = NaN;
    end

    % Store the results
    best_params(i, :) = bestp;
    nLLs(i) = nLL;

    disp(['Best parameters for participant ', num2str(i), ': ', mat2str(bestp)]);
    disp(['Negative log likelihood for participant ', num2str(i), ': ', num2str(nLL)]);
end

% Display results
for i = 1:num_participants
    fprintf('Participant %d: Best Parameters: %s, nLL: %f\n', i, mat2str(best_params(i, :)), nLLs(i));
end
