%make a block Design

numAvgs = 640;
blockDesign = [];

for i = 1:numAvgs/2
    if mod(i,2)== 0
        blockDesign(i) = 1;  % even
    else
        blockDesign(i) = -1;  % odd
    end
end


    