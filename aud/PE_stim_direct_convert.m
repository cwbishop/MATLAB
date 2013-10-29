function signal = PE_stim_direct_convert(sig1,sigs,comp1,offset,rmsval)
%
%
%
%



hsig2 = sigs(round((comp1 - .1) / .005) + 1,:);
sig1 = sig1;
hsig2 = hsig2';

sig1 = (rmsval ./ rms(sig1)) .* sig1;
hsig2 = (rmsval ./ rms(hsig2)) .* hsig2;

dbdrop = 10 ^ ((- 3) / 20); 
dbrise = 10 ^ ((3) / 20);

primary = sig1;
primaryid = vertcat(zeros(15,1),sig1);
primaryid = primaryid .* (dbdrop);
primary = primary .* (dbrise);
primary = vertcat(primary, zeros(15,1));

echo = hsig2;
echoid = vertcat(zeros(15,1),hsig2);
echoid = echoid .* (dbdrop);
echo = echo .* (dbrise);
echo = vertcat(echo, zeros(15,1));



stimuli = create_complex_PEstim(primary, primaryid, echo, echoid, offset, 48000);

signal = generate_train(stimuli,12,.02,1,48000);



