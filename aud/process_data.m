function [freq perc data stim resp] = process_data(fid,prename)
%
%
%
i = 1;
data = zeros(3000,1);
perc = cell(3000,1);
freq = cell(3000,1);
stim = cell(3000,1);
resp = zeros(3000,2);

while ~feof(fid)

x = fgetl(fid);
C = textscan(x,'%[Sound]');
a = C{1,1};

if strcmp(a, 'Sound')
   C = textscan(x, '%*s %*s %s %s %s %s', 'delimiter', ',');
   
   freq{i} = C{1}{1};
   perc{i} = C{2}{1};
   data(i) = str2double(C{3}{1});
   stim{i} = C{4}{1};
   
   x = fgetl(fid);
   C = textscan(x, '%*s %s', 'delimiter', ',');
   a = str2double(C{1}{1});
   x = fgetl(fid);
   C = textscan(x, '%*s %s', 'delimiter', ',');
   b = str2double(C{1}{1});
   
   if a < 3
       resp(i, 1) = a;
       resp(i, 2) = b;
   else
       resp(i, 1) = b;
       resp(i, 2) = a;
   end
   
   i = i + 1;
end

end

save(sprintf('%s.mat',prename),'data','perc','freq','stim','resp')
show_data(freq,perc,data,stim,resp);