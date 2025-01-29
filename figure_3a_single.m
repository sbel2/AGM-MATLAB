% Load the .mat file
load('decoy_233_participants.mat');
load('decoybin.mat')


% Define the box areas for each decoy type
boxes(:,:,1) = [8 10 1 2;...   % compromise A
                1 2 8 10];     % compromise B
boxes(:,:,2) = [3 7 1 2;...   % attraction A
                1 2 3 7];     % attraction B
boxes(:,:,3) = [3 5 6 8;...   % similarity A
                6 8 3 5];     % similarity B
boxes(:,:,4) = [9 10 4 8;...  % repulsion A
                4 8 9 10];    % repulsion B

% Select a single participant (for this case, participant 1)
Acost = data.Aatt1(1, :)';  % Transpose to make it a column vector
Bcost = data.Batt1(1, :)';
Dcost = data.Datt1(1, :)';
Arate = data.Aatt2(1, :)';
Brate = data.Batt2(1, :)';
Drate = data.Datt2(1, :)';
decoybin = squeeze(decoybin(1,:,:)); 
decoybin = decoybin * 10;


prefAtoB = data.prefAtoB(1, :)'; % Transpose to 1060x1
prefAtoD = data.prefAtoD(1, :)'; % Transpose to 1060x1
prefBtoD = data.prefBtoD(1, :)'; % Transpose to 1060x1

% Get the number of trials for this participant
num_trials = 1060;

% Create att1 and att2 with dimensions trials x 3
att1 = [Acost, Bcost, Dcost];  % Combine cost attributes as columns
att2 = [Arate, Brate, Drate];  % Combine rate attributes as columns

% Normalize X.att1
X.att1 = att1(1:530, :);  % Extract the first 530 rows of att1  % Min-Max normalization

% Normalize X.att2
X.att2 = att2(1:530, :);  % Extract the first 530 rows of att2

X.dbin = decoybin(1:530,:);  % Decoy bin data

X.prefAtoB = prefAtoB(1:530, :); 
X.prefAtoD = prefAtoD(1:530, :); 
X.prefBtoD = prefBtoD(1:530, :);

% Set up figure for plotting
figure('color', [1, 1, 1], 'position', [97 224 706 727]);

% Fixed parameter
p = [0.1, 0, 0, 0.1, 0.1, 0.5];  % Fixed parameter vector
%p = [0.00320251143319435	0.999993671378045	-0.0476159802216374	0.263655676777468	0.115566364760074	0.910984219321722];

% Generate choice probabilities using the model (fixed parameter)
[nLL, bigsim] = decoy_adaptive_gain_model(X, p);

% Initialize CP_pAB_m for storing results
CP_pAB_m = zeros(10, 10);  % Assuming a 10x10 grid

% Compute the choice probabilities
for i = 1:10
    for j = 1:10
        indx = find(X.dbin(:, 1) == i & X.dbin(:, 2) == j);
        CP_pAB_m(i, j) = mean(bigsim.pAB(indx));
    end
end

% Smooth the results
CP_pAB_m = smoothn(CP_pAB_m, 3);

% Plot the results for this specific parameter
subplot(1, 1, 1);  % Single subplot for one graph
imagesc(CP_pAB_m);
set(gca, 'ydir', 'normal');
set(gca, 'clim', [0.25 0.75]);
hold on;
line([10.5 0.5], [0.5 10.5], 'color', 'k', 'linestyle', '--');  % Diagonal line
xlabel('Quality', 'fontsize', 14);
ylabel('Economy', 'fontsize', 14);
set(gca, 'xtick', [3 8], 'xticklabel', {'Low', 'High'});
set(gca, 'ytick', [3 8], 'yticklabel', {'Low', 'High'});

hold on;
plot(3, 8, 'ko');  % Example marker
plot(8, 3, 'ko');  % Example marker

% Adjust y-axis limits and add visual enhancements
lh = 12.5;
wid = 1.5;
ylim([0.5 lh + 2]);
line([0 10], [lh lh], 'color', [0.5 0.5 0.5]);  % Reference line

% Add dynamic bars based on decoy influence
sc = -0.5 + (squeeze(CP_pAB_m(1, :)) + (1 - squeeze(CP_pAB_m(2, :)))) / 2;
scl = {'C', 'A', 'S', 'R'};
for b = 1:4
    patch((b * wid) + [1; 1 + wid; 1 + wid; 1], ...
          [lh; lh; lh + sc(b) * 10; lh + sc(b) * 10], ...
          [0.5 0.5 0.5]);  % Gray bars
    text((b * wid) + 1.5, 15, scl{b}, 'FontSize', 12);  % Labels for bars
end
box off;