%%% Values of Unit Pure Tone Left and Right Ear dbSPL 
%%%based on Left Ear Gold Standard 'tone_db' from cal_gold_080116_ety 
%%%Right ear corrected with ety_RL_dif (average of 3 right ety recordings -
%%%3 left ety recordings)
%%%Unit(1 to -1) Presentations at different frequencies)
freqs = [125 250 500 750 1000 1500 2000 3000 4000 6000 8000 11200 16000];

ety_dBSPL = [ 114.0457  114.2269  114.4846  115.1925  117.3692  122.8198  126.5557  127.1484  123.9427  118.2039  114.4546  110.335 123.1159;
              113.8462  114.0091  114.1717  114.8442  117.0025  122.1831  125.8833  126.7286  123.1531  117.7629  114.1295  112.4692  120.3216]';

ety_dBSPL = ety_dBSPL - 1.77; %%%correction for 4157 Ear Simulator response at 1000 Hz           
%%%based on Left Ear Gold Standard 'tone_db' from cal_gold_080116_akg
%%%Right ear corrected with akg_RL_dif 
akg_dBSPL = [  118.1490  107.4072  111.3573  109.1582  113.4551  116.1578  115.2488  111.6944  107.1242  119.5020  121.0461  122.0168  115.2959;
               116.6271  107.5449  111.4620  110.2162  113.2846  115.6920  114.7509  108.8018  109.6973  118.5399  124.1218  120.5036  115.5678;]'; 

akg_dBSPL = akg_dBSPL - 1.77; %%%correction for 4157 Ear Simulator response at 1000 Hz               
%%%Average of 15 subjects from Audiogram 'gold standard'
%%%Amount of attentuation of the unit sound at perceptual threshold
ety_thresh_attn =  [58.6667   73.3667   88.1667   93.4667   98.0333   99.5333  101.4333  101.8667  101.8333   97.2000   95.3667   81.1667   66.4667;
                    57.5333   74.8333   88.8667   95.3333   99.9667  104.1667  103.4000  105.7333  102.9333   98.3667   95.1667   83.7000   69.7667;]';         

  akg_thresh_attn =  [79.9000   88.1000   99.2333  100.5333  102.7667  103.5667  105.2000  105.1333   98.4000   95.5000   94.8333   88.9000   58.4000;
                      80.1333   89.9667  100.1000  100.5333  103.0333  106.7667  105.1667  107.5667   98.8333   97.2000   93.9333   93.9667   58.5333;]';
                  
 ety_dBSPL_thresh =  ety_dBSPL- ety_thresh_attn; %%%ety dBSPL at threshold  
 akg_dBSPL_thresh =  akg_dBSPL- akg_thresh_attn; %%%akg dBSPL at threshold
 
 ety_unitdBHL = ety_dBSPL -  ety_dBSPL_thresh;%%% ety dBHL of each pure tone at full amplitude (1) (Maximum dbHL volume at each frequency)
 akg_unitdBHL = akg_dBSPL - akg_dBSPL_thresh;%%% akg dBHL of each pure tone at full amplitude (1) (Maximum dbHL volume at each frequency)
 
 %%%Henry VA paper ETY dBSPL at thresh
 Henry_freqs = [ 500 620 800 1000 1260 1580 2000 2520 3180 4000 5040 6340 8000 10080 12700 16000];
 Henry_dBSPL_thresh = [ 14.15 11.55 9.75 10.75 12.40 13.00 18.55 20.05 19.40 18.80 18.35 19.45 17.30 35.70 47.50 66.00];
 