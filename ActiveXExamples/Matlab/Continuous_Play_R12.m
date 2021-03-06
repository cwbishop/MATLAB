% Continuous play example using a serial buffer
% This program writes to the rambuffer once it has cyled half way through the buffer

npts=100000;  % Size of the serial buffer
bufpts = npts/2; % Number of points to write to buffer

RP = Circuit_Loader('C:\TDT\ActiveX\ActXExamples\RP_files\Continuous_Play.rcx'); % Runs Circuit_Loader

if all(bitget(invoke(RP,'GetStatus'),1:3))

    % Generate two tone signals to play out in MATLAB
    freq1=1000;
    freq2=5000;
    fs=97656.25;
    
    t=(1:bufpts)/fs;
    s1=sin(2*pi*t*freq1);
    s2=sin(2*pi*t*freq2);
    
    
    % Serial Buffer will be divided into two Buffers A & B
    % Load up entire buffer with Segments A and B
    
    invoke(RP, 'WriteTagV', 'datain', 0, s1);
    invoke(RP, 'WriteTagV', 'datain', bufpts-1, s2);

    % Start Playing
    invoke(RP, 'SoftTrg', 1);
    curindex=invoke(RP, 'GetTagVal', 'index');
    
    % Main Looping Section
    for i = 1:10

        % Wait until done playing A
        while(curindex<bufpts) % Checks to see if it has played from half the buffer
            curindex=invoke(RP, 'GetTagVal', 'index');
        end

        % Loads the next signal segment
        freq1=freq1+1000;
        s1=sin(2*pi*t*freq1);
        invoke(RP, 'WriteTagV', 'datain', 0, s1);

        % Checks to see if the data transfer rate is fast enough
        curindex=invoke(RP, 'GetTagVal', 'index');
        if(curindex<bufpts)
            disp('Transfer rate is too slow');
        end

        % Wait until start playing A
        while(curindex>bufpts)
            curindex=invoke(RP, 'GetTagVal', 'index');
        end

        % Load B
        freq2=freq2+1000;
        s2=sin(2*pi*t*freq2);
        invoke(RP, 'WriteTagV', 'datain', bufpts,s2);

        % Make sure still playing A
        curindex=invoke(RP, 'GetTagVal', 'index');
        if(curindex>bufpts)
            disp('Transfer rate is too slow');
        end
        
        % Loop back to wait until done playing A
    end

    % Stop playing
    invoke(RP, 'SoftTrg', 2);
    invoke(RP, 'Halt');
end