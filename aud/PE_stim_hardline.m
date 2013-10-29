function signal = PE_stim_hardline(sig1,hsig2,offset,freq)
%
%
%
%



if freq == 1000
    sig1 = (.1 ./ rms(sig1)) .* sig1;
    hsig2 = (.1 ./ rms(hsig2)) .* hsig2;
end
if freq == 2000
    sig1 = (.063 ./ rms(sig1)) .* sig1;
    hsig2 = (.063 ./ rms(hsig2)) .* hsig2;
end
if freq == 4000
    sig1 = (.026 ./ rms(sig1)) .* sig1;
    hsig2 = (.026 ./ rms(hsig2)) .* hsig2;
end
if freq == 8000
    sig1 = (.023 ./ rms(sig1)) .* sig1;
    hsig2 = (.023 ./ rms(hsig2)) .* hsig2;
end


dbdrop = 10 ^ ((- 6) / 20); 
%dbrise = 10 ^ ((3) / 20);

primary = sig1;
primaryid = vertcat(zeros(15,1),sig1);
primaryid = primaryid .* (dbdrop);
%primary = primary .* (dbrise);
primary = vertcat(primary, zeros(15,1));

echo = hsig2;
echoid = vertcat(zeros(15,1),hsig2);
echoid = echoid .* (dbdrop);
%echo = echo .* (dbrise);
echo = vertcat(echo, zeros(15,1));



stimuli = create_complex_PEstim(primary, primaryid, echo, echoid, offset, 48000);

signal = generate_train(stimuli,12,.02,1,48000);



