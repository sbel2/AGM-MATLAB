% Input distribution

%% Load Human input
load('X.mat');
H.att1 = squeeze(X.att1(1, :, :)); % Trials x 3
H.att2 = squeeze(X.att2(1, :, :)); % Trials x 3

valid_rows = all(~isnan(H.att1), 2);
H.att1 = H.att1(valid_rows, :);
H.att2 = H.att2(valid_rows, :);

%% Generate Simulated input
decoy_x = rand(530, 1) * 0.9 + 0.1;
decoy_y = rand(530, 1) * 0.9 + 0.1;

S.att1 = [ones(530, 1) * 0.8, ones(530, 1) * 0.3, decoy_x];
S.att2 = [ones(530, 1) * 0.3, ones(530, 1) * 0.8, decoy_y];

% % Define labels for A, B, D
% categories = {'A', 'B', 'D'};
% 
% % Function to plot histograms
% plot_histograms(H.att1, H.att2, 'Human Data: Attribute Distributions', categories);
% plot_histograms(S.att1, S.att2, 'Simulated Data: Attribute Distributions', categories);
% 
% % Function for plotting histograms
% function plot_histograms(att1, att2, title_str, categories)
%     figure;
%     for i = 1:3
%         subplot(3,2,2*i-1);
%         histogram(att1(:, i), 'Normalization', 'pdf','BinWidth', 0.1);
%         title([' ', categories{i}, ' Att1']);
%         xlabel('Value');
%         ylabel('Density');
%         xlim([-0.5 1.5]);
% 
%         subplot(3,2,2*i);
%         histogram(att2(:, i), 'Normalization', 'pdf','BinWidth', 0.1);
%         title([' ', categories{i}, ' Att2']);
%         xlabel('Value');
%         ylabel('Density');
%         xlim([-0.5 1.5]);
%     end
%     sgtitle(title_str);
% end

% Output distribution

%% Output from human input
load('rep_sim_struct.mat')
Hsim.pAB = sim_struct.pAB_a(1,:)';
Hsim.pAD = sim_struct.pAD_a(1,:)';
Hsim.pBD = sim_struct.pBD_a(1,:)';
valid_rows = all(~isnan(Hsim.pAB), 2);
Hsim.pAB = Hsim.pAB(valid_rows, :);
Hsim.pAD = Hsim.pAD(valid_rows, :);
Hsim.pBD = Hsim.pBD(valid_rows, :);

%% Output from simulated input
p = [0.100000000000000 0 0 0.100000000000000 0.100000000000000 0.500000000000000];
[nLL,Ssim] = decoy_adaptive_gain_model(S,p);

%% Plot output

function plot_probabilities(Hsim, Ssim)
    figure;
    prob_types = {'pAB', 'pAD', 'pBD'};
    
    for i = 1:3
        % Human Data
        subplot(3,2,2*i-1);
        histogram(Hsim.(prob_types{i}), 'Normalization', 'pdf', 'BinWidth', 0.05);
        title(['Human ', prob_types{i}]);
        xlabel('Value');
        ylabel('Density');
        xlim([-0.5 1.5]);

        % Simulated Data
        subplot(3,2,2*i);
        histogram(Ssim.(prob_types{i}), 'Normalization', 'pdf', 'BinWidth', 0.05);
        title(['Simulated ', prob_types{i}]);
        xlabel('Value');
        ylabel('Density');
        xlim([-0.5 1.5]);
    end

    sgtitle('Comparison of Human vs Simulated Probabilities');
end

plot_probabilities(Hsim, Ssim);


