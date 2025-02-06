
clear
load sim_3_adaptive_gain_models.mat
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

n_ppt = 189;
n_trials = 1060;

sim2.cp = nan(n_ppt, 3, 1060);
sim2.DV = nan(n_ppt, 3, 1060);
sim2.pAB = nan(n_ppt, 1060);
sim2.pAD = nan(n_ppt, 1060);
sim2.pBD = nan(n_ppt, 1060);


for s = 1:length(submat)

    sub = submat(s);

    [nll(s,:),temp_struct] = decoy_adaptive_gain_model(X(s),sim(2).paramz(s,:));

    indx       = find(~isnan(data.prefAtoB(sub,:)));
    sim2.cp(s,:,indx) = temp_struct.cp';
    sim2.DV(s,:,indx) = temp_struct.DV';
    sim2.pAB(s,indx) = temp_struct.pAB;
    sim2.pAD(s,indx) = temp_struct.pAD;
    sim2.pBD(s,indx) = temp_struct.pBD;
end

norm = 0;
sm = 1;

figure('color',[1 1 1],'position', [417 445 1003 503]);

compz = {'prefAtoB','prefAtoD','prefBtoD'};
mcompz = {'pAB','pAD','pBD'};

% range for AB, AD and BD
climz = [0.25 0.35; 0 1; 0 1; 0.25 0.35; 0 1; 0 1];

% number of components
numk = 5;

% loop over AB, AD and BD for both human and model
for c = 1:6
    subplot(2,3,c)
    
    if c < 4;
        eval(['RCS = makeCP(data.decoybin(submat,:,:),data.',compz{c},'(submat,:),0,sm);'])
    else
        eval(['RCS = makeCP(data.decoybin(submat,:,:),sim2.',mcompz{c-3},'(1:length(submat),:),0,sm);']);
    end
    
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