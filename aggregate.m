clear
load sim_3_adaptive_gain_models.mat
load decoy_233_participants.mat

submat = find(data.sig_sub>0.99);

n_trials = size(data.prefAtoD,2);
n_ppt = sum(data.sig_sub>0.99);

%% fit model to agregate data
% note that this section takes a while to run
% as a first step, you can skip this and load the fitted parameters from 
% the data file in the next section 
% note also that this section requires the Global Optimization Toolbox 
% (for the GlobalSearch function) 
% 
disp('now fitting...');
% 
% agregate data across participants
X_combined = struct('prefAtoB', [], 'prefAtoD', [], 'prefBtoD', [], 'choice', [], 'att1', [], 'att2', []);
% 
for s = 1:length(submat)
    sub = submat(s);

    indx       = find(~isnan(data.prefAtoB(sub,:)));
    X(s).prefAtoB = squeeze(data.prefAtoB(sub,indx))';
    X(s).prefAtoD = squeeze(data.prefAtoD(sub,indx))';
    X(s).prefBtoD = squeeze(data.prefBtoD(sub,indx))';
    X(s).choice   = 1+squeeze(data.choice(sub,:,indx))';
    X(s).att1     = [data.Aatt1(sub,indx);data.Batt1(sub,indx);data.Datt1(sub,indx)]';
    X(s).att2     = [data.Aatt2(sub,indx);data.Batt2(sub,indx);data.Datt2(sub,indx)]';


    % concatenate each field
    X_combined.prefAtoB = [X_combined.prefAtoB; X(s).prefAtoB];
    X_combined.prefAtoD = [X_combined.prefAtoD; X(s).prefAtoD];
    X_combined.prefBtoD = [X_combined.prefBtoD; X(s).prefBtoD];
    X_combined.choice   = [X_combined.choice; X(s).choice];
    X_combined.att1     = [X_combined.att1; X(s).att1];
    X_combined.att2     = [X_combined.att2; X(s).att2];
end

% set up model fitting 
fp =     [0.1,      0      0      0.1     0.1      0.5];
minp =   [0.001      -1     -1     0.00001   0.00001   0];
maxp =   [10,         1      1     1       1	      1];


oneslope = [0 0 0 -1 1 0];
onebias =  [0 -1 1 0 0 0];
onebias2 =  [0 -1 -1 0 0 0];

% fit the second version of the adaptive gain model (one slope)
for m = 2
    disp(['model ',num2str(m)]);

    mod.fp = fp;
    mod.minp = minp;
    mod.maxp = maxp;

    switch m
        case 1
            mod.Aeq = [];
            mod.Beq = [];
        case 2
            mod.Aeq = oneslope;
            mod.Beq = 0;
        case 3
            mod.Aeq = onebias;
            mod.Beq = 0;
        case 4
            mod.Aeq = [oneslope;onebias];
            mod.Beq = [0;0];
        case 5
            mod.Aeq = [oneslope;onebias2];
            mod.Beq = [0;0];

    end
 
    fp =     mod.fp;
    minp =   mod.minp;
    maxp =   mod.maxp;


    opt.Display = 'off';
 
    % Find global minimum
    gs              = GlobalSearch('Display','off');
    problem       	= createOptimProblem('fmincon','x0',fp,'objective',@(p) decoy_adaptive_gain_model_v1(X_combined,p),'lb',minp,'ub',maxp,'Aeq',[],'beq',[],'options',opt);
    [paramz,NLL]     = run(gs,problem);

end

%save fitted params in data file; commented out to avoid overwriting
save('agregate_model_fit.mat','paramz','NLL')

%% check choice matches against human data and visualize simulated decoy map

load('agregate_model_fit.mat')
X_combined = struct('prefAtoB', [], 'prefAtoD', [], 'prefBtoD', [], 'choice', [], 'att1', [], 'att2', []);

% agregate data across participants
for s = 1:length(submat)
    sub = submat(s);
    
    indx       = find(~isnan(data.prefAtoB(sub,:)));
    X(s).prefAtoB = squeeze(data.prefAtoB(sub,indx))';
    X(s).prefAtoD = squeeze(data.prefAtoD(sub,indx))';
    X(s).prefBtoD = squeeze(data.prefBtoD(sub,indx))';
    X(s).choice   = 1+squeeze(data.choice(sub,:,indx))';
    X(s).att1     = [data.Aatt1(sub,indx);data.Batt1(sub,indx);data.Datt1(sub,indx)]';
    X(s).att2     = [data.Aatt2(sub,indx);data.Batt2(sub,indx);data.Datt2(sub,indx)]';
    
    % concatenate each field
    X_combined.prefAtoB = [X_combined.prefAtoB; X(s).prefAtoB];
    X_combined.prefAtoD = [X_combined.prefAtoD; X(s).prefAtoD];
    X_combined.prefBtoD = [X_combined.prefBtoD; X(s).prefBtoD];
    X_combined.choice   = [X_combined.choice; X(s).choice];
    X_combined.att1     = [X_combined.att1; X(s).att1];
    X_combined.att2     = [X_combined.att2; X(s).att2];
end

total_matches = 0;
total_trials  = 0;

% simulate model choices based on agregate data
sim_agg.cp = nan(n_ppt, 3, 1060);
sim_agg.DV = nan(n_ppt, 3, 1060);
sim_agg.pAB = nan(n_ppt, 1060);
sim_agg.pAD = nan(n_ppt, 1060);
sim_agg.pBD = nan(n_ppt, 1060);

for s = 1:length(submat)

    sub = submat(s);


    [nll(s,:),temp_struct] = decoy_adaptive_gain_model_v1(X(s),paramz);

    indx       = find(~isnan(data.prefAtoB(sub,:)));
    sim_agg.cp(s,:,indx) = temp_struct.cp';
    sim_agg.DV(s,:,indx) = temp_struct.DV';
    sim_agg.pAB(s,indx) = temp_struct.pAB;
    sim_agg.pAD(s,indx) = temp_struct.pAD;
    sim_agg.pBD(s,indx) = temp_struct.pBD;


    indx       = find(~isnan(data.prefAtoB(sub,:)));
    [~,model_pref] = max(squeeze(sim_agg.cp(s,:,indx)));

    match_pref(s) = mean(X(s).choice(:,1) == model_pref');

    actual_pref = X(s).choice(:,1);
    this_matches = sum(actual_pref == model_pref');
    this_trials  = length(actual_pref);
    total_matches = total_matches + this_matches;
    total_trials  = total_trials + this_trials;
end


disp('Agregate-level model fit')
disp(['Proportion trials model and human first choice coincide: ' num2str(mean(match_pref)) ])

% Now compute the overall proportion of correct predictions
overall_accuracy = total_matches / total_trials;

disp('Aggregate-level model fit (by total matches):');
disp(['Proportion of trials model matches human first choice: ' num2str(overall_accuracy)]);

figure('Position',[455 373 652 381])
tiledlayout(2,3)
sm=1;

% human data
nexttile
CP_AB = makeCP(data.decoybin(submat,:,:),data.prefAtoB(submat,:),0,sm);
pCP = (squeeze(nanmean(CP_AB,1)));
imagesc(pCP);colorbar;
set(gca,'Ydir','normal');
set(gca,'clim',[0.25 0.35]);
title('human Pref AtoB')

nexttile
CP_AD = makeCP(data.decoybin(submat,:,:),data.prefAtoD(submat,:),0,sm);
pCP = (squeeze(nanmean(CP_AD,1)));
imagesc(pCP);colorbar
set(gca,'Ydir','normal');
set(gca,'clim',[0 1]);
title('human Pref AtoD')

nexttile
CP_BD = makeCP(data.decoybin(submat,:,:),data.prefBtoD(submat,:),0,sm);
pCP = (squeeze(nanmean(CP_BD,1)));
imagesc(pCP);colorbar
set(gca,'clim',[0 1]);
set(gca,'Ydir','normal');
title('human Pref BtoD')

% model
nexttile
CP_AB = makeCP(data.decoybin(submat,:,:),sim_agg.pAB(1:length(submat),:),0,sm);
pCP = (squeeze(nanmean(CP_AB,1)));
imagesc(pCP);colorbar
set(gca,'Ydir','normal');
set(gca,'clim',[0.25 0.35]);
title('model Pref AtoB')

nexttile
CP_AD = makeCP(data.decoybin(submat,:,:),sim_agg.pAD(1:length(submat),:),0,sm);
pCP = (squeeze(nanmean(CP_AD,1)));
imagesc(pCP);colorbar
set(gca,'clim',[0 1]);
set(gca,'Ydir','normal');
title('model Pref AtoD')

nexttile
CP_BD = makeCP(data.decoybin(submat,:,:),sim_agg.pBD(1:length(submat),:),0,sm);
pCP = (squeeze(nanmean(CP_BD,1)));
imagesc(pCP);colorbar
set(gca,'clim',[0 1]);
set(gca,'Ydir','normal');
title('model Pref BtoD')