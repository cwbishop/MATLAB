function addWavCue(foldername,filename,cuelat,cuelabl,newfilename)

%addWavCue(foldername,filename,cuelat,cuelabl)
%Add Cues to .wav files
%
%INPUTS:
% foldername  - the name of the folder containing the .wav file.
% filename    - name of the .wav file
% cuelat      - a vector containing latency in number of samples from the
%               start of the wav.
% cuelabl     - a cell array containing strings of numbers that correspond
%               to the desired port codes for each latency.
% newfilename - the file name for the newly created wav file with cues.
%
%WARNING: ANY PREVIOUS FILE WITH NEWFILENAME NAME WILL BE DELETED;
%
%Example:
% foldername = 'C:\Documents and Settings\tshahin\Desktop\AV_PR\words2\'
% filename = 'word_1.wav';
% cuelat(1) = 16000; %Cue latency (samples from sound start)
% cuelat(2) = 24000;
% cuelabl{1} = '111';
% cuelabl{2} = '133';
% newfilename = 'word_1.wav';

%if you want to know exactly what this does, work through code with:
%http://www.sonicspot.com/guide/wavefiles.html
%But basically, there are different types of chunks in a wav file. The
%standard is a Data chunk, but there can be others such as cue and label
%chunks which we use here

%Need to read the existing wav file
fid = fopen(fullfile(foldername,filename));
bits = fread(fid,'uint8');
fclose(fid);

%%First, we'll make a cue chunk. This actually marks the location in the
%%wav
chunkSize = typecast(int32(4+length(cuelat)*24), 'uint8');
NumCues = typecast(int32(length(cuelat)), 'uint8');

cueChunk =  [uint8('cue ') chunkSize NumCues]';
for i = 1:length(cuelat)
    cueNum = typecast(int32(i), 'uint8');
    cuePos = typecast(int32(cuelat(i)), 'uint8');
    
    chunkStart = [0 0 0 0];
    blockStart = [0 0 0 0];
    sampOff = cuePos;
    cueChunk = [cueChunk; [cueNum cuePos uint8('data') chunkStart blockStart sampOff]'];
end

%%Next, we need to label the cues
lablChunk = [];
for i = 1:length(cuelat)
    label = uint8(cuelabl{i});
    cueID = typecast(int32(i), 'uint8');
    
    %Must have a pad, must also be even length (with pad) so add 2 pads if
    %odd length
    if rem(length(label),2)
        label = [label 0];
    else
        label = [label 0 0];
    end
    
    dataSize = length(label)+4; %length of label in bytes, plus 4 for the cueID
    
    lablChunk = [lablChunk; [uint8('labl') typecast(int32(dataSize), 'uint8') cueID label]'];
end

%Associated Data List Chunk is basically a header for label (and other)
%chunks, but we didn't make it until we knew how long the labelChunk was.
listChunk = [uint8('LIST') typecast(int32(length(lablChunk)+4), 'uint8') uint8('adtl')]';

%add our chunks to the end of existing data
fOut = [bits; cueChunk; listChunk; lablChunk];

%There are 4 bytes that describe how long the file is, they need to change
fOut(5:8) = typecast(int32(length(fOut)-8), 'uint8');

%write the new file
outfid=fopen(fullfile(foldername,newfilename),'w');
fwrite(outfid,fOut,'ubit8');
fclose(fid);
