function [highest_freq, lowest_freq, avg_freq, high_range_floor, high_range_ceiling, low_range_floor, low_range_ceiling, avg_high_interval_avg, avg_low_interval_avg] = analyze(file)    
    %     get audio's info
    [A,Fs] = audioread(file);
    file2 = strrep(file,'.wav','.mp3');
    mp3write(A,Fs,8,file2);
    
    [y,fs] = audioread(file2);
    len = length(y);
    if y(1,1) ~= 0 % binaural
        y = (y(:,1) + y(:,2)) / 2;
    end
    
    %     frequency analysis view
    new_y = fftshift(fft(y));
    mag = abs(new_y);
    frequency = (-len/2:len/2 - 1) * (fs/len);
    
    % 畫<頻率,響度>圖，需要時可打開
%     plot(frequency,mag);
%     title('Frequency Domain');
%     xlabel('Frequency(Hz)');
%     ylabel('Magnitude');

    % 去除圖的左半部分
    mag = mag(length(mag)/2+1 : length(mag));
    [max_mag, max_loc] = max(mag);

    goal_gap = 1; % hz
    val = goal_gap * length(mag)/24000;
    
    step = length(mag)/24000; % 1hz需走幾mag
    bottom = int32(82*step);
    
    if max_loc < bottom
        mag = mag(bottom : length(mag));
        [max_mag, max_loc] = max(mag);
    end

    % 拆兩threshold抓人聲，並合併
    mag_low = mag(1 : max_loc);
    mag_high = mag(max_loc+1 : length(mag));
    
    [pks_low, locs_low] = findpeaks(mag_low,'minpeakheight',max_mag/5,'MinPeakDistance',val);
    [pks_high, locs_high] = findpeaks(mag_high,'minpeakheight',max_mag*1/3,'MinPeakDistance',val);
    
    if isrow(pks_low)
        pks_low = transpose(pks_low);
    end
    if isrow(pks_high)
        pks_high = transpose(pks_high);
    end    
    if isrow(locs_low)
        locs_low = transpose(locs_low);
    end    
    if isrow(locs_high)
        locs_high = transpose(locs_high);
    end    

    pks = cat(1,pks_low,pks_high);
    locs_high = locs_high + length(mag_low);
    locs = cat(1,locs_low,locs_high);
    
    normal = pks/sum(pks);
    freq_locs = locs / length(mag) * 24000;
    
    s = 0; % 平均音高
    for i = 1:length(normal)
        s = s + freq_locs(i)*normal(i);
    end
    avg_freq = s; % 平均音
    
    highest_freq = 0;
    lowest_freq = 0;

    for i = 1:length(freq_locs)
        if freq_locs(i) >= 82
            lowest_freq = freq_locs(i); % 最低音
            break;
        end
    end
    
    for i = 1:length(freq_locs)
        j = length(freq_locs) - i + 1;
        if freq_locs(j) <= 1300
            highest_freq = freq_locs(j); % 最高音
            break;
        end
    end
    
    gap = highest_freq - lowest_freq;
    high_range_ceiling = highest_freq; % 平均高音區的上界
    high_range_floor = highest_freq - gap/3; % 平均高音區的下界
    low_range_ceiling = lowest_freq + gap/3; % 平均低音區的上界
    low_range_floor = lowest_freq; % 平均低音區的下界
    
    
    s2 = 0; 
    high_bottom = highest_freq - gap/3;
    target = 0;
    for i = 1:length(freq_locs)
        if freq_locs(i) >= high_bottom
            target = i;
            break;
        end
    end
    normal_high = pks(target:length(pks)) / sum(pks(target:length(pks)));
    for i = 1:length(normal_high)
        s2 = s2 + freq_locs(i+target-1)*normal_high(i);
    end
    avg_high_interval_avg = s2; % 平均高音區的平均頻率 (ppt沒要求，但想說給一下看會不會用到)

    s3 = 0;
    low_ceiling = lowest_freq + gap/3;
    target2 = 0;
    for i = 1:length(freq_locs)
        if freq_locs(i) > low_ceiling
            target2 = i-1;
            break;
        end
    end
    normal_low = pks(1:target2) / sum(pks(1:target2));
    for i = 1:length(normal_low)
        s3 = s3 + freq_locs(i)*normal_low(i);
    end
    avg_low_interval_avg = s3; % 平均低音區的平均頻率 (ppt沒要求，但想說給一下看會不會用到)

    % example usage
    fprintf("highest frequency : %.f hz\n",highest_freq);
    fprintf("lowest frequency : %.f hz\n",lowest_freq);
    fprintf("average frequency : %.f hz\n",avg_freq);
    fprintf("average high interval : %.f hz ~ %.f hz\n",high_range_floor,high_range_ceiling);
    fprintf("average low interval : %.f hz ~ %.f hz\n",low_range_floor,low_range_ceiling);
    fprintf("average high interval's average : %.f hz\n",avg_high_interval_avg);
    fprintf("average low interval's average : %.f hz\n",avg_low_interval_avg);
end