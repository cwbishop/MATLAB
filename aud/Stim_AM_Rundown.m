function Stim_AM_Rundown(freq, cut, num)
%
%
%
%

%Continues where stim_cutoff_filter left off.
load (sprintf('%dHz %d good stims.mat',freq,num))

testbat = mainbat;

i = 1;
c = 1;
%Valid pairs contains matrix of all signal combos that have correlation
%below .1.
validpairs = zeros(15000, 2);
%This nested loop pair travels through all possible permutations of good
%signals and records those that are under the correct correlation.
while i < size(testbat, 1) - 1;
    j = i + 1;
    while j <= size(testbat, 1);
        pri = testbat(i,:);
        sec = testbat(j,:);
        co = corr(pri', sec');
        if  0 < co && co < .1025 
            validpairs(c, 1) = i;
            validpairs(c, 2) = j;
            c = c + 1;
        end
        j = j + 1;
    end
    i = i + 1;
end

if c > 1
AM_curve_store = zeros(c, 10);
AM_curve_comp = zeros(c, 2, 4801);
c = 1;

while validpairs(c,1) ~= 0
   j = 1;
   %Extracts signals from validpairs and uses them to generate a
   %correlation matrix.
   testgroup(1,1,:) = testbat(validpairs(c,1),:);
   testgroup(1,2,:) = testbat(validpairs(c,2),:);
   AM_curve_comp(c, 1, :) = testgroup(1, 1, :);
   AM_curve_comp(c, 2, :) = testgroup(1, 2, :);
   t = generate_corr_table(testgroup);
     
   env = elope(((testgroup(1,1,:) .* t(1, 1)) + (testgroup(1,2,:) .* (1 - t(1, 1)))), 0, 5000, 0, 50, 48000);
   clip = env(1200:3600);
   AM_curve_store(c, 1) = max(abs((clip - mean(clip))/mean(clip)));
     
   while j < 10
      if j == 9
      env = elope(((testgroup(1,1,:) .* t(181, 1)) + (testgroup(1,2,:) .* (1 - t(181, 1)))), 0, 5000, 0, 50, 48000);
      else
      env = elope(((testgroup(1,1,:) .* t(j * 20, 1)) + (testgroup(1,2,:) .* (1 - t(j * 20, 1)))), 0, 5000, 0, 50, 48000);
      end
      clip = env(1200:3600);
      AM_curve_store(c, j + 1) = max(abs((clip - mean(clip))/mean(clip)));
      j = j + 1;
   end
   c = c + 1;
  
end

save(sprintf('%dHz %0.3f cutoff %d AM_Rundown.mat', freq, cut, num),'AM_curve_comp','AM_curve_store')
else
    disp('No valid pairs in data set.');
end