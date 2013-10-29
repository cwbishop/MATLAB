function stim_storage_to_wav(finals,parents,freq,freqn,t)
%
%
%
%

i = 1;

while i < 11
   j = 1;
   pops(:,:) = parents(i,1,:);
   while j <= 181
       temp(:,:) = finals(i,j,:);
       sig = PE_stim_hardline(pops,temp,t,freq);
       co = (((j - 1) * .005) + .1) * 1000;
       if j == 181
           fname = sprintf('C:\\Documents and Settings\\slondon\\My Documents\\Fine Structure Transition Experiment\\Stim Wavs\\PEstim_%d_%d_%4.0f.wav',freqn,i,co);
       else
           fname = sprintf('C:\\Documents and Settings\\slondon\\My Documents\\Fine Structure Transition Experiment\\Stim Wavs\\PEstim_%d_%d_%3.0f.wav',freqn,i,co);
       end
       wavwrite(sig, 48000, fname);
       j = j + 5;
   end
   i = i + 1;
end