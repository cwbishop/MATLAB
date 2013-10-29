function [tv,f]=audiometry_conv(tv,f);

%Determine frequency vector, assumes same frequency vector for each ear
f=cellstr(f);

f=reshape(f,[],2);
tv=reshape(tv,[],2);

%Left channel should always be first collum
if strcmp(f{1,1}(end),'R'), tv=fliplr(tv); end

%Remove ear markers from end of frequency vector
f={f{:,1}};
for i=1:length(f)
    f{i}=f{i}(1:end-1);
end