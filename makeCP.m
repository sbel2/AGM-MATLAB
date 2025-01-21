function CP = makeCP(decoybin,pref,norm_on,smooth_on);

if nargin<3
    norm_on = 0;
end

if nargin<4
    smooth_on = 0;
end

decoybin = decoybin*10;

for s = 1:size(decoybin,1);
    
    allindx = find(~isnan(pref(s,:)));
    
    for i = 1:10;
        for j = 1:10;
            indx = find(decoybin(s,:,1)==i & decoybin(s,:,2)==j & ~isnan(pref(s,:)));
            
            if ~isempty(indx);
                if norm_on;
                CP(s,i,j) = mean(pref(s,indx)) - mean(pref(s,allindx));
                else
                CP(s,i,j) = mean(pref(s,indx));
                end
            else
                CP(s,i,j) = NaN;
            end
        end
    end
end

CP = nanny(CP);

if smooth_on
    
    for s = 1:size(CP,1);
         CPs(s,:,:) = smoothn(squeeze(CP(s,:,:)),3);
    end
    
    CP = CPs;
end
