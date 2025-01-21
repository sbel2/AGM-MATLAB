%% Fig.4
% here, we first make some surrogate data for proof-of-principle

% selected locations for decoy stimuli
boxes(:,:,1) =   [8 10 1 2;...   % compromise A
    1 2 8 10];     % compromise B
boxes(:,:,2) =   [3 7 1 2;...   % attraction A
    1 2 3 7];     % attraction B
boxes(:,:,3) =   [3 5 6 8;...   % simlarity A
    6 8 3 5];     % simlarity B
boxes(:,:,4) =   [9 10 4 8;...   % repulsion A
    4 8 9 10];     % repulsion B

[decoy_x,decoy_y] = ndgrid(0.1:0.1:1,0.1:0.1:1);
trials = length(squelch(decoy_x));

X.att1 = [ones(trials,1)*0.8 ones(trials,1)*0.3 squelch(decoy_x)];
X.att2 = [ones(trials,1)*0.3 ones(trials,1)*0.8 squelch(decoy_y)];
X.dbin = [squelch(round(decoy_x*10)) squelch(round(decoy_y*10))];


figure('color',[1 1 1],'position',[97 224 706 727]);

counter = 0;
nbins = 5;


for c = 1:4;
    
    switch c
        case 1
            % vary weighting parameter
            kmat = linspace(0.4,0.6,nbins);
        case 2
            % vary s
            kmat = linspace(0.01,0.1,nbins);
        case 3
            % vary b_i = -b_j
            kmat = linspace(-0.04,0.04,nbins);
        case 4
            % vary b_i = b_j
            kmat = linspace(-0.04,0.04,nbins);  
            
    end
    
    for k = 1:length(kmat);
        counter = counter+1;
        
        % generate smoothly varying parameters
        % [temp bias_i bias_j slope_i slope_j weight]
        switch c
            case 1
                px = [0.1 0 0 0.1 0.1 kmat(k)];
            case 2
                px = [0.1 0 0 kmat(k) kmat(k) 0.5];
            case 3
                px = [0.1 -kmat(k) kmat(k) 0.1 0.1 0.5];
            case 4
                px = [0.1 kmat(k) kmat(k) 0.1 0.1 0.5];
        end
        
        % generate choice probabilities
        [nLL, bigsim] = decoy_adaptive_gain_model(X,px);
        
        for i = 1:10;
            for j = 1:10;
                indx = find(X.dbin(:,1)==i & X.dbin(:,2)==j);
                CP_pAB_m(i,j) = mean(bigsim.pAB(indx));
                %CP_pAB_h(i,j) = mean(X.prefAB(indx));
            end
        end
        
        for t = 1:2
            for b =1:4
            decoy3(c,k,b,t) = mean(squelch(CP_pAB_m(boxes(t,1,b):boxes(t,2,b),boxes(t,3,b):boxes(t,4,b))));
            end
        end
        
        
        % smooth
        CP_pAB_m = smoothn(CP_pAB_m,3);
        
        subplot(4,nbins,counter);
        
        imagesc(CP_pAB_m);
        set(gca,'ydir','normal');
        set(gca,'clim',[0.25 0.75]);
        hold on;
        line([10.5 0.5],[0.5 10.5],'color','k','linestyle','--');
        %colorbar
        if k == 1
            ylabel('economy','fontsize',14);
        end
        if c == 4;
            xlabel('quality','fontsize',14);
        end
        set(gca,'xtick',[3 8],'xticklabel',{'low','high'});
        set(gca,'ytick',[3 8],'yticklabel',{'low','high'}); 
        %title(['b_i = ',num2str(kmat(k)), '; b_j = ',num2str(-kmat(k))],'fontsize',12);
        hold on
        plot(3,8,'ko');
        plot(8,3,'ko');
        
        lh = 12.5;
        wid = 1.5;
        ylim([0.5 lh+2]);
        line([0 10],[lh lh],'color',[0.5 0.5 0.5]);
        sc = -0.5+(squeeze(decoy3(c,k,:,1)+(1-decoy3(c,k,:,2))))./2;
        scl = {'C','A','S','R'};
        for b = 1:4;
        patch((b*wid)+[1;1+wid;1+wid;1],[lh;lh;lh+sc(b)*10;lh+sc(b)*10],[0.5 0.5 0.5]);
        text((b*wid)+1.5,15,scl{b},'FontSize',12);
        end
        box off;

                
    end
    
end
% 
% % Fig. 4e
% load('decoy_233_participants.mat');
% load('sim_3_adaptive_gain_models');
% 
% % select participants on basis of performance
% submat = find(data.sig_sub>0.99);
% 
% model = 2;
% 
% % Parameters for smoothing and normalization
% norm = 0;  % No normalization
% sm = 1;    % Smoothing enabled
% 
% % Compute decoy influence map for humans
% RCS_hum = makeCP(data.decoybin(submat,:,:), data.prefAtoB(submat,:), norm, sm);
% mean_RCS_hum = squeeze(mean(RCS_hum));
% 
% % Compute decoy influence map for the model
% RCS_mod = makeCP(data.decoybin(submat,:,:), sim(model).pAB(1:length(submat),:), norm, sm);
% mean_RCS_mod = squeeze(mean(RCS_mod));
% 
% % Initialize arrays for human and model data
% num_subjects = length(submat);
% num_decoy_types = size(boxes, 3); % Number of decoy types
% boxes_h = zeros(num_subjects, num_decoy_types, 2); % Human responses
% boxes_m = zeros(num_subjects, num_decoy_types, 2); % Model responses
% 
% % Loop over decoy types and targets
% for b = 1:num_decoy_types  % Loop over decoy types
%     for t = 1:2            % Loop over targets
%         for s = 1:num_subjects  % Loop over subjects
%             % Compute mean influence for humans
%             boxes_h(s, b, t) = mean(squelch(RCS_hum(s, boxes(t, 1, b):boxes(t, 2, b), ...
%                                                   boxes(t, 3, b):boxes(t, 4, b))));
%             % Compute mean influence for the model
%             boxes_m(s, b, t) = mean(squelch(RCS_mod(s, boxes(t, 1, b):boxes(t, 2, b), ...
%                                                   boxes(t, 3, b):boxes(t, 4, b))));
%         end
%     end
% end
% 
% % Normalize human responses using z-scores
% boxes_zh = zscore(boxes_h);
% 
% % Compute relative effects
% rel_C = boxes_zh(:, 1, 1) - boxes_zh(:, 1, 2);  % Normalized compromise effect
% rel_A = boxes_zh(:, 2, 1) - boxes_zh(:, 2, 2);  % Attraction
% rel_R = boxes_zh(:, 4, 1) - boxes_zh(:, 4, 2);  % Repulsion
% rel_absAR = abs(rel_A) - abs(rel_R);            % Relative attraction vs. repulsion
% 
% % Plotting the results
% figure('color', [1, 1, 1]);
% plot(rel_C, rel_absAR, 'ko', 'markerfacecolor', 'k', 'markersize', 12, 'markeredgecolor', 'w');
% xlabel('Normalized Compromise Effect', 'FontSize', 16);
% ylabel('Normalized Attraction - Repulsion Effect', 'FontSize', 16);
% 
% % Add a regression line
% pp = polyfit(rel_C, rel_absAR, 1); % Linear regression
% xx = get(gca, 'xlim');            % Get x-axis limits
% hold on;
% plot(xx(1):0.1:xx(2), polyval(pp, xx(1):0.1:xx(2)), 'r-', 'linewidth', 3);
% 
