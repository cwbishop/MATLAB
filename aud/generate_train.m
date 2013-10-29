function train = generate_train(signal, cars, offset, jump, fs, alt)
%train = generate_train(signal, cars, offset, jump, fs, alt)
%
%Creates a train for testing with the Build-up Effect.
%If an alternative signal is provided it is used at the 
%test signal. If alt is not specified the same signal as
%the train is used.
%
%INPUTS:
%  signal - Signal used for the train
%  cars   - Number of signals presented in body of train
%  offset - Offset in seconds between cars in train
%  jump   - Offset in seconds between final car and test stimuli
%  fs     - Sampling frequency. Default is 48000.
%  alt    - Signal used for test stimuli. Defaults to train signal

if ~exist('fs', 'var') || isempty(fs)
    fs = 48000;
end

%The offset is created and then applied to create
%a start buffer for the train.
toffset = offset * fs;
off = zeros(toffset, 2);
train = off;

%The function loops to add the number of signals 
%to the train that were specified with the given offset.  
i = 0;
while (i < cars)
    train = vertcat(train, off);
    train = vertcat(train, signal);
    i=i+1;
end

%The jump is offset is created for the end of the train.
%jmp = zeros(jump*fs, 2);
%train = vertcat(train, jmp);

%Either the provided alternate signal or the default provided
%are added to the end of the train as the test stimuli.
%if exist('alt', 'var') && ~isempty(alt)
%    train = vertcat(train, alt);
%else
%train = vertcat(train, signal);
%end