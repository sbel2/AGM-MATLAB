%% load raw data & model fits
clear all
close all
load('decoy_233_participants.mat');

% select participants on basis of performance
load('submat_file.mat');
load('decoybin.mat');


%% load fitted model & perform model comparison
% this requires the installation of VBA toolbox from https://mbb-team.github.io/VBA-toolbox/


load('rep_sim_struct');
%load('sim_3_adaptive_gain_models');

% Bayesian model comparison
%[posterior,out] = VBA_groupBMC(-BIC');

norm = 0;  % this is without normalisation
sm = 1;    % but with smoothing on


figure('color',[1 1 1],'position', [417 445 1003 503]);

compz = {'prefAtoB','prefAtoD','prefBtoD'};
mcompz = {'pAB_a','pAD_a','pBD_a'};
%mcompz = {'pAB','pAD','pBD'};

% range for AB, AD and BD
climz = [0.25 0.35; 0 1; 0 1; 0.25 0.35; 0 1; 0 1];

% number of components
numk = 5;

% loop over AB, AD and BD for both human and modeel
for c = 1:6
    disp(['generating ', num2str(c)]);
    subplot(2,3,c)
    
    if c < 4;
        eval(['RCS = makeCP(decoybin(submat,:,:),data.',compz{c},'(submat,:),0,sm);'])
    else
        %eval(['RCS = makeCP(data.decoybin(submat,:,:),sim(model).',mcompz{c-3},'(1:length(submat),:),0,sm);']);
        eval(['RCS = makeCP(decoybin(submat,:,:),sim_struct.',mcompz{c-3},'(1:length(submat),:),0,sm);']);
    end
    
    %mean_RCS = (squeeze(tsnanmean(RCS,1)));
    mean_RCS = (squeeze(tsnanmean(RCS,1)));
    
    imagesc(mean_RCS);colorbar;
    set(gca,'Ydir','normal');
    line([0.5 10.5],[10.5 0.5],'color','k','linestyle','--');
    
    set(gca,'xtick',[3 8]);
    set(gca,'xticklabel',{'low','high'});
    set(gca,'ytick',[3 8]);
    set(gca,'yticklabel',{'low','high'});
    
    if c>3
        xlabel('quality');
    end
    
    if c == 1 | c==4; ylabel('economy');end
    set(gca,'Fontsize',15);
    hold on;
    plot(3,8,'ko','markersize',10);
    plot(8,3,'ko','markersize',10);
    
    
    computed_range = max(mean_RCS(:)) - min(mean_RCS(:));
    disp(['human AB range: ', num2str(computed_range)]);
    set(gca,'clim',[climz(c,1) climz(c,2)]);
    if c < 4
        title(compz{c});
    end
end