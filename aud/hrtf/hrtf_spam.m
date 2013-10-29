function spam=hrtf_spam(PHbase,PHitd,MAGild,MAGse,ID);
%compress all of the different magnitude and phase components into all
%possible combinations, or only a specific subset specified. It is designed
%to handle the results from hrtf_chop for a single location only. Place
%inside a for loop to handle multiple locations.
%
%spam=hrtf_spam(PHbase,PHitd,MAGild,MAGse,ID);
%
%INPUTS
%PHbase - this represents a small temporal shift, moving all IRs into the
%         positive time domain.
%PHitd  - this represents the interaural time delay as a phase component
%MAGild - this should represent the interaural level difference as a linear
%         magnitude
%MAGse  - this should represent the spectral envelope of each ear as a
%         linear magnitude
%ID     - A list of combinations to create, such as 'ild' or 'itd_se', it
%         defaults to a complete list
%
%OUTPUT
%spam   - a structure containing an hrtf and hrir for 

if ~exist('ID') || isempty(ID)
    ID={'se','ild','ild_se','itd','itd_se','ild_itd','ild_itd_se'};
end

for i=1:length(ID)
    switch ID{i}
        case 'se'
            mag=MAGse;
            ph=PHbase;
        case 'ild'
            mag=MAGild;
            ph=PHbase;
        case {'ild_se','se_ild'}
            mag=MAGild+MAGse;
            ph=PHbase;
        case 'itd'
            mag=ones(length(PHbase),2);
            ph=PHbase+PHitd;
        case {'itd_se','se_itd'}
            mag=MAGse;
            ph=PHbase+PHitd;
        case {'ild_itd','itd_ild'}
            mag=MAGild;
            ph=PHbase+PHitd;
        case {'itd_ild_se','itd_se_ild','ild_itd_se','ild_se_itd','se_ild_itd','se_itd_ild'}
            mag=MAGild+MAGse;
            ph=PHbase+PHitd;
        otherwise
            disp(['WARNING: Unknown combination ' ID{i}]);
            mag=0;
            ph=0;
    end
    
hrtf=mag.*cos(ph)+sqrt(-1)*mag.*sin(ph);
cell{i}=ifft(hrtf,'symmetric');
end

spam=cell2struct(cell,ID,2);