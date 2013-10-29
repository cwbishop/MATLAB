function [rndArray] = rand_array(conds, arrayLength)
%[output] = randArray(conds, arrayLength)
%
%Creates an array of 'arrayLength' entries. Each entry is a random member
%of 'conds'. No condition repeats in adjacent entries.
%
%'conds' can be any vector such as [1:4], [1 9 3 5], or ['hml']
%'arrayLength' should be a single integer
%
%NOTE: RUN TIME IS VERY LONG WHEN YOU HAVE HIGH 'arrayLength' AND LOW
%'conds'. In general, try and keep 'arrayLength' <= 10*conds

repeats = 1;
rndArray =[];

%makes an array slightly longer than you need which is trimmed later
for i=1:ceil(arrayLength/size(conds,2))
    rndArray = [rndArray conds];
end

while repeats
    repeats = 0;
    
    rndArray = rndArray(randperm(length(rndArray)));
    
    for i=1:(arrayLength-1)
        if iscell(rndArray)
            if strcmp(rndArray(i),rndArray(i+1))
            repeats = 1;
            end
        else
            if rndArray(i) == rndArray(i+1)
                repeats = 1;
            end
        end
    end
end

rndArray = rndArray(1:arrayLength);