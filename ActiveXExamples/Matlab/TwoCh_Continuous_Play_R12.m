% Two-channel continuous play example using a serial buffer
% This program writes to the rambuffer once it has cyled half way through the buffer

npts=100000;  % Size of the serial buffer
bufpts = npts/2; % Number of points to write to buffer

RP = Circuit_Loader('C:\TDT\ActiveX\ActXExamples\RP_files\TwoCh_Continuous_Play.rcx');

if all(bitget(invoke(RP,'GetStatus'),1:3))
   
   % Generate two tone signals to play out in MATLAB
   
    freq1=1000;
    freq2=5000;
    fs=97656.25;
    
    t=(1:bufpts)/fs;
    s1=round(sin(2*pi*t*freq1)*32760);
    s2=round(sin(2*pi*t*freq2)*32760);
    
    % Serial buffer will be divided into two buffers A & B
    % Load up entire buffer with segments A and B
    
    s=[s1;s2]; % Concatenate two arrays into a matrix
    invoke(RP, 'WriteTagVEX', 'datain', 0, 'I16', s);  
    
    freq1=freq1+1000;
    freq2=freq2+1000;
    s3=round(sin(2*pi*t*freq1)*32760);
    s4=round(sin(2*pi*t*freq2)*32760);
    
    s=[s3;s4];
    invoke(RP, 'WriteTagVEX', 'datain', bufpts,'I16', s);
   
    % Start Playing
    invoke(RP, 'SoftTrg', 1);
    curindex=invoke(RP, 'GetTagVal', 'index');
    disp(['Current index: ' num2str(curindex)]);
    
    % Main Looping Section
    for i = 1:5
   	    s=[s1;s3];
        
        % Wait until done playing A
	    while(curindex<bufpts) % Checks to see if it has played from half the buffer
  	        curindex=invoke(RP, 'GetTagVal', 'index');
        end
        
        % Loads the next signal segment
	    invoke(RP, 'WriteTagVEX', 'datain', 0,'I16', s);
        
	    % Checks to see if the data transfer rate is fast enough
	    curindex=invoke(RP, 'GetTagVal', 'index');
        disp(['Current index: ' num2str(curindex)]);
	    if(curindex<bufpts)
   	        disp('Transfer rate is too slow');
        end
        
	    % Wait until start playing A 
	    while(curindex>bufpts)
   	        curindex=invoke(RP, 'GetTagVal', 'index');
        end
        
        % Load B
        s=[s4;s2];
        invoke(RP, 'WriteTagVEX', 'datain', bufpts,'I16', s);

        % Make sure still playing A 
	    curindex=invoke(RP, 'GetTagVal', 'index');
        disp(['Current index: ' num2str(curindex)]);
	    if(curindex>bufpts)
   	        disp('Transfer rate too slow');
        end
        
	    % Loop back to wait until done playing A
    end

    % Stop Playing
    invoke(RP, 'SoftTrg', 2);
    invoke(RP, 'Halt');
end






   