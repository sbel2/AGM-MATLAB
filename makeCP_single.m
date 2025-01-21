function CP = makeCP_single(decoybin,pref,norm_on,smooth_on);

if nargin<3
    norm_on = 0;
end

if nargin<4
    smooth_on = 0;
end

decoybin = decoybin*10;

    
allindx = find(~isnan(pref(:)));

for i = 1:10;
    for j = 1:10;
        indx = find(decoybin(:,1)==i & decoybin(:,2)==j & ~isnan(pref(:)));
        
        if ~isempty(indx);
            if norm_on;
            CP(i,j) = mean(pref(indx)) - mean(pref(allindx));
            else
            CP(i,j) = mean(pref(indx));
            end
        else
            CP(i,j) = NaN;
        end
    end
end

CP = nanny(CP);

if smooth_on
    
 CPs(:,:) = smoothn(squeeze(CP(:,:)),3);
    
 CP = CPs;
end