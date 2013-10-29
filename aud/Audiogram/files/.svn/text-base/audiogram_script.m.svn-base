function audiogram(full_name, study_dir, Ind, type_string) 
global study_dir
%%% Called by Audiogram_GUI
%%% Press and hold Q to quit during a session. Then type ctrl-C and "clear mex" in the
%%% command window
%%%Added Rerun and FLev_Orig 080118 for rerun trials
    start_time =GetSecs;
 %   study_dir = pwd;

    max_amp = 1; % amplitude of sine wav without attenuation 
    min_lev = 140; %dB attenuation
%     insert_retspl = [28.0 17.5 9.5 6.0 5.5 9.5 11.5 13.0 15.0 16.0 15.5 20.5 40.5]; %%From ER-3A ANSI 3.6 SPL Reference thresholds for occulded ear. Last 2 values are estimates
%     circum_retspl = [29.5 18.0 9.5 6.5 6.5 5.5 3.0 3.0 8.5 9.5 16.0 21.0 58.0]; %% From RETSPL values of Sennheiser HDA200 IEC 318 with type 1 adaptor
%     max_spl_ety = [100.4611  100.6409  100.7782  101.4317  103.2503  107.9095  111.8633  113.8502  110.9777 106.7052  102.2079  103.2534  104.4770];%%%from gold_080115
%     max_spl_akg = [  101.9148   85.0845   93.7881   89.9004   93.0338   95.1865   94.2890   90.5793   85.3829  100.6594  103.1656  102.3364   93.7452]; %%%from gold_080115
%     tot_ety = max_spl_ety-insert_retspl;
%     tot_akg = max_spl_akg-circum_retspl;
%     exp_max_dbhl = 95;
%     deq_req_ety = -(tot_ety-exp_max_dbhl);
%     deq_req_akg = -(tot_akg-exp_max_dbhl);
%     tone_freq_short    =   [125 250 500 750 1000 1500 2000 3000 4000 6000 8000 11200 16000];
% Fout = logspace(log10(20),log10(20000),31)';
% ety_deq = min(max(spline(tone_freq_short, deq_req_ety, Fout),-15),15);
% akg_deq = min(max(spline(tone_freq_short, deq_req_akg, Fout),-15),15);
% ety_deq(1:6) = 0;
% akg_deq(1:6) = 0;
% if type_string == 'ety'
% deq_set(ety_deq)
% elseif type_string == 'akg'
% deq_set(akg_deq)    
% end


    s_lev = (ones(1,26)*min_lev)-[50 40 35 30 25 20 20 20 20 20 25 30 35 50 40 35 30 25 20 20 20 20 20 25 30 35]; %%%Loosely based on pilot thresholds
    vamp = .05;%% Maximum voice sound amplitude

    start_lev = 10; %Starting increasing increments in DB (ANSI standard)
    down_lev = 10; %Decreasing increments
    up_lev = 5; %Increasing increments
    s_direction = 1; %Starting direction (1 is increasing volume, 2 is decreasing volume)

    min_delay = 1; %minimum soa
    max_add_delay =.5; %random jittir added to minimum soa
    ratio = 2/3; %minimum number of acending trial hits (up_hits)
    fs = 44100; %framerate of stimulus



    tone_freq = [ 125 250 500 750 1000 1500 2000 3000 4000 6000 8000 11200 16000 125 250 500 750 1000 1500 2000 3000 4000 6000 8000 11200 16000]; %selected frequencies for both ears
    %tone_freq = [ 250 2000 4000 8000];

    stim_time = 0.2; %stimulus length in seconds
    ramp = 0.02; %linear onset/offset time
    
    envelope = [linspace(0,1,fs*ramp) ones(1,fs*stim_time-ramp*2*fs) linspace(1,0,fs*ramp)]';

    for i = 1:length(tone_freq)
        tone_tmp = (sin_gen(tone_freq(i),stim_time,fs).*envelope)*max_amp;
        if i <= length(tone_freq)/2
            tone{i} = [tone_tmp zeros(length(tone_tmp),1)];
        else
            tone{i} = [zeros(length(tone_tmp),1) tone_tmp];
        end
        
        if strmatch(type_string, 'custom')
            %tone{i} = tone{i}.*10; %%%Example (10 fold amplitude increase)
        end
    end

    rand('twister', sum(100*clock));
    rand_state = rand('state');




    FLev = zeros(1,length(tone_freq));
    FTime = zeros(1,length(tone_freq));
    Redo = zeros(1,length(tone_freq));
    FLev_Orig = zeros(1,length(tone_freq));
    
    
    s_order = randperm(length(tone_freq));
    if Ind
        if exist([study_dir '\data\' full_name '.mat'],'file')
        load([study_dir '\data\' full_name]);
        end
            
        s_order = Ind;
        FLev_Orig(Ind) = FLev(Ind);
        Redo(Ind) = 1;
    end

    try
        oldVisualDebugLevel = Screen('Preference', 'VisualDebugLevel', 3);
        oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
        screens=Screen('Screens');
        screenNumber=max(screens);
        rect=Screen('Rect', screenNumber);
        w=Screen('OpenWindow', screenNumber);
        Screen('FillRect',w,[0 0 0]);
        Screen('TextFont',w, 'Courier New');
        Screen('TextSize',w, 50);
        Screen('TextStyle',w, 1+2);
        HideCursor;
        Screen('DrawText', w, 'Press Enter when ready.', rect(3)/4, rect(4)/2, [255 255 255]);
        Screen('Flip',w);
        KbWait;
        Screen('DrawText', w, '+', rect(3)/2, rect(4)/2,  [255  255 255]);
        Screen('Flip',w);
        WaitSecs(1);
        FlushEvents;
        

    catch
        Screen('CloseAll');
        error('Initial')
    end

    bcnt = 0;
    for snum = s_order
        stime = GetSecs;
        up_hits = zeros(1,min_lev);
        down_hits = zeros(1,min_lev);
        total_up = zeros(1,min_lev);
        dtap = zeros(1,min_lev);
        lev_cnt =[];
        rt_cnt =[];
        resp_cnt = [];
        key_num = 0;

        lev = s_lev(snum);
        cnt = 0;
        last_count = 1;
        direction = s_direction;
        start_seq = 1;
        fa = 0;
        cr = 0;
        c_trial = 0;

        while total_up(last_count) < 3 || up_hits(last_count)/total_up(last_count) < 2/3 
            resp = 0;
            cnt = cnt +1;
            lev_cnt(cnt) = lev;
            last_count = lev;
            amp = 10^((-lev)/20);
            delay = min_delay + rand(1)*max_add_delay;
            FlushEvents;
            tic
            tstart_time = GetSecs;
            player = audioplayer(tone{snum}*amp,fs,24);
            play(player);

            while toc < delay
                if resp
                else
                    [resp,rtime,key_num] = KbCheck;
                end

            end
            if char(find(key_num)) == 'Q'
                Screen('CloseAll');
                clear mex;
            end
            
            if resp
                rt = rtime-tstart_time;
            else
                rt = 0;
            end


            if start_seq
                if resp
                    dtap(lev) = dtap(lev)+1;
                    if dtap(lev) == 2;
                        direction = -1;
                        up_hits(lev) = up_hits(lev)+1;
                        total_up(lev) = total_up(lev) + 1;
                        lev = lev + down_lev;
                        start_seq = 0;
                    end
                else
                    lev = lev - start_lev;
                end
            else
                if resp
                    if direction == 1
                        direction = -1;
                        up_hits(lev) = up_hits(lev)+1;
                        total_up(lev) = total_up(lev) + 1;
                        lev = lev + down_lev;
                    elseif direction == -1
                        direction = 1;
                        down_hits(lev) = down_hits(lev)+1;
                        lev = lev - up_lev;
                    end
                else
                    if direction == 1
                        total_up(lev) = total_up(lev) + 1;
                        lev = lev - up_lev;
                    elseif direction == -1
                        direction = 1;
                        lev = lev + down_lev;
                    end
                end
            end
            resp_cnt(cnt) = resp;
            rt_cnt(cnt) = rt;
            if lev <= 0
                lev_cnt(cnt) = 1;
                break;
            elseif lev >= min_lev
                lev_cnt(cnt) = min_lev;
                break;
            end

        end


        bcnt = bcnt + 1;
        

        fin_lev = lev_cnt(cnt);
        fin_time = GetSecs-stime;

        Resp{snum} = resp_cnt;
        Lev{snum} = lev_cnt;
        RT{snum} = rt_cnt;
        FLev(snum) = fin_lev;
        FTime(snum) = fin_time;
        try
            Screen('DrawText', w, 'Good job!!!', rect(3)/4, rect(4)/2, [255 255 255]);
            Screen('Flip',w);
            waitsecs(1);
        %wavplay(voices{18},vfs(18));
        save([study_dir 'data\' full_name], 'Resp','Lev','RT','FLev','FTime','Redo','FLev_Orig')
        if ~rem(bcnt,6)%Give a break every 6 freqs
        Screen('DrawText', w, 'Keep up the good work. Press Enter when ready.', rect(3)/4, rect(4)/2, [255 255 255]);
        Screen('Flip',w);
        KbWait;
        end
        Screen('DrawText', w, '+', rect(3)/2, rect(4)/2,  [255  255 255]);
        Screen('Flip',w);
        WaitSecs(1);
                catch
            Screen('CloseAll');
            error('Feedback')
        end
    end
try
    %sound(bye*vamp,byefs);
catch
            Screen('CloseAll');
            error('Feedback')
end
Screen('CloseAll');

