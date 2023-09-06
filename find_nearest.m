function T = find_nearest(inputfile)
    clc;
    %read data
    data = readtable('data.xlsx');
    %imput five indexes of user's voice
    [highest_freq,lowest_freq,avg_freq,high_range_floor,high_range_ceiling,low_range_floor,low_range_ceiling,avg_high_interval_avg,avg_low_interval_avg] = analyze(inputfile);
    
    song_name = data(:,1);
    high = table2array(data(:,2));
    low = table2array(data(:,3));
    avg = table2array(data(:,4));
    hrf = table2array(data(:,5));
    hrc = table2array(data(:,6));
    lrf = table2array(data(:,7));
    lrc = table2array(data(:,8));

    ten_rec = ones(10,2) * 100000000;
    rec_name = strings(10,1);
    
    for i = 1 : height(data)
        sum = 0;
        sum = sum + (highest_freq - high(i,1))^2;
        sum = sum + (lowest_freq - low(i,1))^2;
        sum = sum + (avg_freq - avg(i,1))^2;
        sum = sum + (high_range_floor - hrf(i,1))^2;
        sum = sum + (high_range_ceiling - hrc(i,1))^2;
        sum = sum + (low_range_floor - lrf(i,1))^2;
        sum = sum + (low_range_ceiling - lrc(i,1))^2;
        if(sum < ten_rec(10,2))
            ten_rec(10,1) = i;
            ten_rec(10,2) = sum;
            ten_rec = sortrows(ten_rec,2);
        end
    end
    

    for i = 1 : 10
        rec_name(i,1) = table2array(data(ten_rec(i,1),1));
        rec_name(i,2) = table2array(data(ten_rec(i,1),2));
        rec_name(i,3) = table2array(data(ten_rec(i,1),3));
        rec_name(i,4) = table2array(data(ten_rec(i,1),4));
        rec_name(i,5) = table2array(data(ten_rec(i,1),5));
        rec_name(i,6) = table2array(data(ten_rec(i,1),6));
        rec_name(i,7) = table2array(data(ten_rec(i,1),7));
        rec_name(i,8) = table2array(data(ten_rec(i,1),8));
    end
    names=rec_name(:,1);
    hn=rec_name(:,2);
    ln=rec_name(:,3);
    an=rec_name(:,4);
    ahf=rec_name(:,5);
    ahc=rec_name(:,6);
    alf=rec_name(:,7);
    alc=rec_name(:,8);
    T = table(names,hn,ln,an,ahf,ahc,alf,alc);