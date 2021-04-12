function y=transposeColmunIfNot(x)

if min(size(x))==1 % 1 vector
    if size(x,2)>1
        y=transpose(x);
    else
        y=x;
    end
    
else % several vectors
    
    %     if size(x,2)> size(x,1)
    %         y=transpose(x);
    %     else
    y=x;
    %     end
end

end