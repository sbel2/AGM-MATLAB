load decoy_233_participants.mat
load sim_3_adaptive_gain_models.mat
load sim2.mat

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

%% check what proportion of human top choices coincide with model top choices
totalMatches = 0;   % Will accumulate the total number of matching choices
totalTrials  = 0;   % Will accumulate the total number of trials

for s = 1:length(submat)
    sub = submat(s);

    % Indices of valid trials
    indx = find(~isnan(data.prefAtoB(sub,:)));

    % model_pref is the model's top choice on each trial
    [~, model_pref] = max(squeeze(sim2.cp(s,:,indx)));  % model_pref is row vector

    % Human top choice (X(s).choice(:, 1)) vs. model's top choice (model_pref')
    matches = sum(X(s).choice(:,1) == model_pref');
    trials  = length(model_pref);

    % Accumulate for all subjects
    totalMatches = totalMatches + matches;
    totalTrials  = totalTrials + trials;
end

% Compute overall accuracy
overallAccuracy = totalMatches / totalTrials;

disp('Aggregate model fit across all subjects and all trials')
disp(['Proportion of trials where model and human first choice coincide: ' num2str(overallAccuracy)]);
