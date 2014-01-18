function [HDR DATA]=bdf_write(PO, eeg)
%% DESCRIPTION
%
%   EEGLAB doesn't write BDFs correctly for two reasons:
%
%       1. it botches the header (no idea what they used as a ref)
%       2. it rounds data to the nearest integer value by providing a
%          scaling factor of 1 in the file.  
%
%   This is my clunky (but battle proven) attempt to do it correctly. It
%   does make several reasonable assumptions, such as that all channels are
%   sampled at the same rate (EEG.srate).  
%   
%   For a full description of BDF/EDF header information, see 
%       http://www.biosemi.com/faq/file_format.htm
%
% INPUT:
%
%   PO:     string, filename (full or relative path). 
%   eeg:    EEG structure (optional | default global EEG)
%
% OUTPUT:
%
%   HDR:    string, the header
%   DATA:   the raw data written to file
%
%   Biosemi BDF: written to file PO
%
% Bishop, Christopher W.
%   UC Davis
%   Miller Lab 2011
%   cwbishop@ucdavis.edu

    %% DEFAULTS:
    %   Use EEG structure unless user specifies something else.
    %   Define some default values important for later.
    global EEG; 
    if ~exist('eeg', 'var') || ~isstruct(eeg), eeg=EEG; end
    
    %% CONSTRUCT HEADER   
    %   EEGLAB botches these.
    Labels=[];
    Transducer=[]; 
    PhysDim=[];
    PhysMin=[];
    PhysMax=[];
    DigMin=[];
    DigMax=[]; 
    PreFilt=[];
    Srate=[]; 
    
    % Details for each channel
    for i=1:length(EEG.chanlocs)
        
        % Chanel Labels from EEG structure
        Labels=[Labels bp(eeg.chanlocs(i).labels, 16)];

        % Transducer types: Active Electrodes, usually
        Transducer=[Transducer bp('Active Electrode', 80)];
        
        % Physical Dimensions of the data
        PhysDim=[PhysDim bp('uV', 8)];
        
        % This is really the key difference between EEGLAB's botched call
        % to BIOSIG's sopen/swrite. Compare these values with writeeeg.m
        % lines 235-242.  writeeg provides inputs that provide a scaling
        % factor of 1 uV/unit instead of the native ~0.03125 uV/unit.
        PhysMin=[PhysMin bp('-262144', 8)]; 
        PhysMax=[PhysMax bp('262143', 8)];  % this value differs in files 
                                            % pulled directly off a Biosemi
                                            % system (262143) and the
                                            % example files online
                                            % (262144).  So, this function
                                            % will give you very slightly
                                            % different values depending on
                                            % which file you try to rewrite.                                                                                       
        DigMin=[DigMin bp('-8388608', 8)];  % signed 24 bit
        DigMax=[DigMax bp('8388607', 8)];
        
        % Prefiltering information  
        %   I left these fields empty, but they are normally populated in
        %   data taken directly from the Biosemi system.  However, it
        %   doesn't seem to affect how the data are handled in any way.
        %   Probably fine, but worth tinkering with if you're bored. 
        PreFilt=[PreFilt bp('HP:; LP:', 80)];
        
        % Sampling rate for each channel
        Srate=[Srate bp(num2str(eeg.srate), 8)];
        
    end % i=1:len...
    
    % Add Status Channel Information
    Labels=[Labels bp('Status', 16)];
    Transducer=[Transducer bp('Triggers and Status', 80)]; 
    PhysDim=[PhysDim bp('Boolean', 8)];     
    PhysMin=[PhysMin bp('-8388608', 8)];
    PhysMax=[PhysMax bp('8388607', 8)];
    DigMin=[DigMin bp('-8388608', 8)];
    DigMax=[DigMax bp('8388607', 8)];
    PreFilt=[PreFilt bp('No filtering', 80)];
    Srate=[Srate bp(num2str(eeg.srate), 8)];
    
    % Put everything together    
    HDR=[...
        '255BIOSEMI' ...            % Identification code
        bp('SID', 80) ...           % Subject identification
        bp('SITE', 80) ...          % Site information
        bp('dd.mm.yy', 8) ...       % Start date of recording
        bp('hh.mm.ss', 8) ...       % starttime of recording
        bp(num2str((size(eeg.data,1)+2)*256), 8) ...    % Number of bytes in header record ((N+1+1)*256, add an additional channel for status (added later)
        bp('24BIT', 44) ...         % Version of data format (24BIT)
        bp(num2str(ceil(eeg.xmax)), 8) ...   % number of data records
        bp('1', 8) ...              % Duration of a data record, in seconds
        bp(num2str(size(eeg.data,1)+1), 4)...% Number of channels (including status)
        Labels ...                  % Channel labels
        Transducer ...              % Transducer types (e.g. 'Active Electrode', 'Triggers and Status')
        PhysDim ...                 % Physical dimension (e.g. uV)
        PhysMin ...                 % Physical minimum
        PhysMax ...                 % Physical maximum
        DigMin ...                  % Digital minimum
        DigMax ...                  % Digital maximum
        PreFilt ...                 % Prefiltering information
        Srate ...                   % Sampling rate information
        blanks((size(eeg.data,1)+1)*32)];   % Reserved, additional channel added for status channel (added below)
        
    % Reconstruct status channel
    %   This is pretty straight forward, but see writeeeg.m lines
    %   203-207 for EEGLAB's handling of the same information.
    %
    % *NOTE*: I toss out the duration of the events, since the onsets
    %         are usually all we're after. 
    STATUS=zeros(1,size(eeg.data,2));
     
    for i=1:length(eeg.event)
        
        % Sometimes 'type' has been converted for a string label.  Try
        % converting it back to an integer first. 
        %
        %   *NOTE*: this crashes for " 'boundary' " events. Special case
        %   should be included if this poses a significant problem. 
        try
            type=str2num(eeg.event(i).type);
        catch 
            type=eeg.event(i).type;
        end % try catch
        
        % Set event
        %   Recall that latency is in samples, but not always whole
        %   samples, so we round the event to the nearest sample. 
        %
        %   Duration information is discarded. 
        STATUS(round(eeg.event(i).latency))=type;            
    end % for i=1:length(eeg.event)

    % Add STATUS channel to data structure
    DATA=[eeg.data]; 
        
    % Calculate scaling factor
    %   Derived from sopen.m line 582
    %       HDR.Cal = (HDR.PhysMax-HDR.PhysMin)./(HDR.DigMax-HDR.DigMin);    
    Cal=((262143+262144)./(8388607+8388608));
        
    % Calculate offsets
    %   When data are read in, sopen applies an offset to the data (I
    %   assume this is to make 0 uV = 0 units, but there are 0 comments, so
    %   this is indeed an assumption). 
    %
    %   Derived from sopen line 583:
    %       HDR.Off = HDR.PhysMin - HDR.Cal .* HDR.DigMin;    
    OFF=-262144-Cal.*-8388608; 
    
    % Undo what was done during reading in the data.
    %   Recall that data are scaled and an offset applied. 
    %
    %   Refer to the following lines to see what EEGLAB/BIOSIG does to the
    %   data as they are read in. We're just working backwards. 
    %
    %       sopen.m 618
    %           HDR.Calib  = [HDR.Off; diag(HDR.Cal)];
    %       sread 1537-1540
    %           for k = 1:size(Calib,2),
    %                   chan = find(Calib(2:end,k));
    %                   S(:,k) = double(tmp(:,chan)) * full(Calib(1+chan,k)) + Calib(1,k);
    %           end;
    DATA=(DATA-OFF)./Cal; % remove offset, scale data

    DATA=[DATA;STATUS]; 
    %% WRITE DATA
    
    % Open file for writing
    ptr=fopen(PO, 'w'); 
      
    % Write out non-ASCII values
    fwrite(ptr, str2num(HDR(1:3)), 'ubit8'); 
        
    % Write out the rest of the header
    fwrite(ptr, HDR(4:end), 'ubit8'); 
        
    % Write data out
    %   Data are written in a less than intuitive fashion. 1 sec blocks are
    %   interleaved. (see http://www.biosemi.com/faq/file_format.htm)
    for i=1:ceil(eeg.xmax)
        for c=1:size(DATA,1)
            fwrite(ptr, DATA(c, 1+(i-1)*eeg.srate:eeg.srate+(i-1)*eeg.srate), 'bit24'); 
        end % 
    end % for i
        
    % Close file
    fclose(ptr);     
end % bdf_write

function [STR]=bp(STR, N)
%% DESCRIPTION:
%
%   Pad a string with blanks to length N.
%
% INPUT:
%
%   STR:    string input
%   N:      length the string should ultimately be.
%
% OUTPUT:
%
%   STR:    blank padded string.
%
% Bishop, Christopher W.
%   UC Davis
%   Miller Lab 2011
%   cwbishop@ucdavis.edu

    STR=[STR blanks(N-length(STR))];
    
end % function blank_pad