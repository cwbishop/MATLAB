function signal = stim_storage_convert(freq, storage, table, index, comp1, offset)
%
%
%
%


sig1(:,:) = storage(index, 2, :);
sig2(:,:) = storage(index, 1, :);

comp1 = table(round((comp1 - .1) / .005) + 1, index);
comp2 = 1 - comp1;

hsig2 = (sig1 .* comp1) + (sig2 .* comp2);

if freq == 100
    sig1 = (.25 / rms(sig1)) .* sig1;
    hsig2 = (.25 / rms(hsig2)) .* hsig2;
end
%
if freq == 200
    sig1 = (.2 / rms(sig1)) .* sig1;
    hsig2 = (.2 / rms(hsig2)) .* hsig2;
end
%
if freq == 500
    sig1 = (.1267 / rms(sig1)) .* sig1;
    hsig2 = (.1267 / rms(hsig2)) .* hsig2;
end
if freq == 1000
    sig1 = (.10 / rms(sig1)) .* sig1;
    hsig2 = (.10 / rms(hsig2)) .* hsig2;
end
if freq == 1500
    sig1 = (.0817 / rms(sig1)) .* sig1;
    hsig2 = (.0817 / rms(hsig2)) .* hsig2;
end
if freq == 2500
    sig1 = (.0567 / rms(sig1)) .* sig1;
    hsig2 = (.0567 / rms(hsig2)) .* hsig2;
end
%
if freq == 4000
    sig1 = (.025 / rms(sig1)) .* sig1;
    hsig2 = (.025 / rms(hsig2)) .* hsig2;
end
%

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



