function stim_cutoff_filter(freq, num, cut)


k = 1;
while k <= num
load(sprintf('%dhz %d test stim bat.mat',freq,num))    
stimbat = storage;
u = 1;

%Normalizes all signals stored in stimbat.
while u < size(stimbat,1)
    stimbat(u,:) = stimbat(u,:) ./ max(abs(stimbat(u,:)));
    u = u + 1;
end

%Records all signal indices that have AM below the provided cutoff.
cutoffindices(:,1) = find(AM_activity < cut);
i = 1;
%Holder matrix is created.
testbat = zeros(length(cutoffindices), 4801);
while i < length(cutoffindices)
   testbat(i,:) = stimbat(cutoffindices(i),:);   
   i = i + 1;
end
%Transfers qualified signals over to main holder in preperation for write.
if k == 1
    mainbat = testbat;
else
    mainbat = vertcat(mainbat,testbat);
end

k = k + 1;
end

save (sprintf('%dHz good stims.mat',freq), 'mainbat')