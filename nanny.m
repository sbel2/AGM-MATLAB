function out=nanny(in,verbose);

if nargin<2;
    verbose=0;
end

dimz=size(in);

if length(dimz)==4;

for d1=1:dimz(2);
    for d2=1:dimz(3);
        for d3=1:dimz(4);
            dat=in(:,d1,d2,d3);
            where=[isnan(dat) | isinf(dat)];
            if verbose;
                if sum(where(:))>0;
                disp([num2str(sum(where(:))),' NaN replacement(s)']);
                end
            end
            meanie=mean(dat(~where));
            dat(where)=meanie;
            out(:,d1,d2,d3)=dat;    
        end
    end
end


elseif length(dimz)==3;
    
for d1=1:dimz(2);
    for d2=1:dimz(3);
        dat=in(:,d1,d2);
        where=[isnan(dat) | isinf(dat)];
            if verbose;
                if sum(where(:))>0;
                disp([num2str(sum(where(:))),' NaN  replacement(s)']);
                end
            end
        meanie=mean(dat(~where));
        dat(where)=meanie;
        out(:,d1,d2)=dat;
    end
end

elseif length(dimz)==2;
    
for d1=1:dimz(2);
        dat=in(:,d1);
        where=[isnan(dat) | isinf(dat)];
            if verbose;
                if sum(where(:))>0;
                disp([num2str(sum(where(:))),' NaN  replacement(s)']);
                end
            end
        meanie=mean(dat(~where));
        dat(where)=meanie;
        out(:,d1)=dat;
end


end