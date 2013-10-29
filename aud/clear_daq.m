function clear_daq

openDAQ = daqfind;
for i = 1:length(openDAQ),
  delete(openDAQ(i));
end
