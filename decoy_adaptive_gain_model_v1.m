function [nLL, sim] = fit_ag(X,p)
% takes inputs: data (X) and parameter values (p)
% returns negative log likelihood and simulated preferences & choice
% probabilities

temp      = p(1);
bias_i   = p(2);
bias_j   = p(3);
slope_i    = p(4);
slope_j    = p(5);
weight   = p(6);

mean_att1 = mean(X.att1,2);
n_att1    = sigmoid(X.att1-mean_att1,0,1,bias_i,slope_i);

mean_att2 = mean(X.att2,2);
n_att2    = sigmoid(X.att2-mean_att2,0,1,bias_j,slope_j);

sim.DV = n_att1*weight + n_att2*(1-weight);

cp     = exp(sim.DV./temp);
cp     = cp./sum(cp,2);

sim.pAB = cp(:,1)./(cp(:,1)+cp(:,2));
sim.pAD = cp(:,1)./(cp(:,1)+cp(:,3));
sim.pBD = cp(:,2)./(cp(:,2)+cp(:,3));
sim.cp  = cp;


%% if choice is passed in, compute log likelihood

if isfield(X,'choice')
    
    for t = 1:length(X.choice)
        ch = X.choice(t,:);
        sim.prob6(t) = cp(t,ch(1)).*((cp(t,ch(2)))./(cp(t,ch(2))+cp(t,ch(3))));
    end
    s6 = 0.01+(sim.prob6.*0.98);
    
    nLL = -sum(log(s6));
    
else
    
    nLL = NaN;
end
