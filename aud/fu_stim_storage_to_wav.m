function fu_stim_storage_to_wav(parents,freq,freqn)
%
%
%
%

i = 1;

while i < 11
   j = 1;
   t = .000;
   pops(:,:) = parents(i,1,:);
   while j <= 41
       sig = PE_stim_hardline(pops,pops,t,freq);
       fname = sprintf('C:\\Documents and Settings\\slondon\\My Documents\\MATLAB\\Stim Wavs\\Fusion Stims\\%dHz\\FUstim_%d_%d_%3.0f.wav',freqn,freqn,i,t*10000);
       wavwrite(sig, 48000, fname);
       t = t + .0001;
       j = j + 1;
   end
   i = i + 1;
end