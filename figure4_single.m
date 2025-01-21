% Selected locations for decoy stimuli (boxes remain the same)
boxes(:,:,1) = [8 10 1 2;...   % compromise A
                1 2 8 10];     % compromise B
boxes(:,:,2) = [3 7 1 2;...    % attraction A
                1 2 3 7];     % attraction B
boxes(:,:,3) = [3 5 6 8;...    % similarity A
                6 8 3 5];     % similarity B
boxes(:,:,4) = [9 10 4 8;...   % repulsion A
                4 8 9 10];    % repulsion B

% Generate decoy grid
[decoy_x, decoy_y] = ndgrid(0.1:0.1:1, 0.1:0.1:1);
trials = length(decoy_x(:)); % Flatten the grid to get the number of trials

% Initialize X structure
X.att1 = [ones(trials, 1)*0.8, ones(trials, 1)*0.3, decoy_x(:)]; 
X.att2 = [ones(trials, 1)*0.3, ones(trials, 1)*0.8, decoy_y(:)];
X.dbin = [round(decoy_x(:)*10), round(decoy_y(:)*10)];

% Set up figure for plotting
figure('color', [1, 1, 1], 'position', [97 224 706 727]);

% Fixed parameter
p = [0.1, 0, 0, 0.1, 0.1, 0.5];  % Fixed parameter vector

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
