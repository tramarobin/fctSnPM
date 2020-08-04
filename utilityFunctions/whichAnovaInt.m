function [nAnovaInt, nNames]=whichAnovaInt(mainEffect)


if mainEffect==1
    nAnovaInt=[4 5];
    nNames=[1 2; 1 3];
elseif mainEffect==2
    nAnovaInt=[4 6];
    nNames=[1 2; 2 3];
elseif mainEffect==3
    nAnovaInt=[5 6];
    nNames=[1 3; 2 3];
end



end