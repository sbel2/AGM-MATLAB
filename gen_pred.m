clear
% load sim_3_adaptive_gain_models.mat
load bestp.mat
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

pAB = NaN(189, 1060);
pAD = NaN(189, 1060);
pBD = NaN(189, 1060);

for s = 1:length(submat)

    sub = submat(s);
    [nll(s,:),temp_struct] = decoy_adaptive_gain_model(X(s),best_params(s,:));
    
    pAB(s, :) = [temp_struct.pAB', NaN(1, 1060 - length(temp_struct.pAB))];  % Pad with NaNs
    pAD(s, :) = [temp_struct.pAD', NaN(1, 1060 - length(temp_struct.pAD))];  % Pad with NaNs
    pBD(s, :) = [temp_struct.pBD', NaN(1, 1060 - length(temp_struct.pBD))];  % Pad with NaNs

end;

sim2 = struct('pAB', pAB, ...
                    'pAD', pAD, ...
                    'pBD', pBD);

save('sim2.mat', 'sim2');