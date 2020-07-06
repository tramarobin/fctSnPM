function [ES,ESsd]=esCalculation(DATA)

n1 = size(DATA{1},1);
n2 = size(DATA{2},1);
nu = n1+n2-2;
Gnu = gamma(nu/2)/(sqrt(nu/2)*gamma((nu-1)/2));
if isnan(Gnu)
    Gnu=1;
end
SS1 = std(DATA{1}).^2*(n1-1);
SS2 = std(DATA{2}).^2*(n2-1);
pooledsd = sqrt((SS1 + SS2)/nu);
d = (mean(DATA{1})-mean(DATA{2}))./pooledsd;
ES =  abs(d*Gnu);

ESsd=sqrt((n1+n2)/(n1*n2)+(ES.^2)/(2*(n1+n2)));





end