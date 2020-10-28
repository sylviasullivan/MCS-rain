% outputs the 3-hour preceding saturation deficit and precipitation 
% collocated with convective systems in RCE simulations
% timestr = 10-character string corresponding to simulation time step
% e.g. '0000012600'
% numbin = number of bins in saturation deficit
% hrdelay = number of hours of delay from which to draw sat deficit

function [pr,sd, cape] = rceVars_2(timestr,numbin,hrdelay)
    % load the RCE file for a certain time (designated by final digits)
    %fi = strcat('/data/rj2621/RCE-sims/ch_cam300ri0/ch_cam300ri0_4096x64x64_3km_12s_cam300ri0_64_',timestr,'.nc');
    fi = strcat('C:\Users\Sylvia\Downloads\ch_cam300ri0_4096x64x64_3km_12s_cam300ri0_64_',timestr,'.nc');
    t = ncread(fi,'TABS');
    precip = ncread(fi,'QP'); % precipitating water [g kg-1] rain + snow  
    qn = ncread(fi,'QN');     % non-precipitating water [g kg-1]
    psurf = precip(:,:,1);

    % use the above to identify where the mesoscale convective systems are
    % first filter for rainy grid cells
    mcs = ones(4096,64);
    mcs(psurf == 0) = 0;

    % second filter for where there is condensate aloft
    % find the Tb = 245 K level first, seems to always be index 24 = 8 km
    qn245 = zeros(4096,64);
    for yy = 1:4096
        for xx = 1:64
            tb245 = find(t(yy,xx,:) < 245,1);
            qn245(yy,xx) = qn(yy,xx,tb245);
        end
    end
    mcs(qn245 < 0) = 0;

    % third filter for a contiguous coverage of this condensate with
    % equivalent radius of 90 km or more = 314 grid cells of 9 km2 coverage
    % 4-point connectivity is employed below
    S = bwconncomp(mcs,4);
    numPixels = cellfun(@numel,S.PixelIdxList);
    S2 = S.PixelIdxList(numPixels < 310); 
    for yy = 1:length(S2)
        indx = S2{yy};
        mcs(indx) = 0;
    end
    clearvars -except mcs timestr psurf numbin hrdelay
    
    % now read in the file preceding the input one by <hrdelay> hours
    zeit = str2num(timestr);
    zeit = zeit - 3600*hrdelay;
    timestr = num2str(zeit);
    jj = 10 - length(timestr);
    while jj > 0
        timestr = strcat('0',timestr);
        jj = jj - 1;
    end
    fi = strcat('C:\Users\Sylvia\Downloads\ch_cam300ri0_4096x64x64_3km_12s_cam300ri0_64_',timestr,'.nc');
    qv = ncread(fi,'QV');
    qn = ncread(fi,'QN');
    press = ncread(fi,'p');
    z = ncread(fi,'z');
    t = ncread(fi,'TABS');
    
    % calculate the buoyancy profiles everywhere. environmental temperature
    % and spec. hum. are horizontal averages over all grid cells for a 
    % given vertical level
    g = 9.8; 
    MWa = 0.02897; % kg mol-1
    MWw = 0.01802; % kg mol-1
    tenv = mean(mean(t,2),1);  
    qvenv = mean(mean(qv,2),1);
    qnenv = mean(mean(qn,2),1);
    b = g.*(t - tenv)./tenv + MWw/MWa*(qvenv - qv) - (qnenv - qn);
    b(b < 0) = 0;  % do not calculate the integral where buoyancy is negative
    
    % integrate the buoyancy profiles everywhere for CAPE values.
    cape = zeros(4096,64);
    for yy = 1:4096
        for xx = 1:64
            bint = cumtrapz(z,b(yy,xx,:),3);
            cape(yy,xx) = bint(end);
        end
    end
    
    % calculate the saturation deficit at 550 hPa
    indx = find(press < 550,1);
    MWa = 0.02897; % kg mol-1
    MWw = 0.01802; % kg mol-1
    qv550 = reshape(qv(:,:,indx-1),4096*64,1); qv550 = qv550(mcs(:) == 1);
    t550 = reshape(t(:,:,indx-1),4096*64,1); t550 = t550(mcs(:) == 1);
    p550 = press(indx-1);
    qvsat550 = saturationMR(p550*100,t550);
    sd550 = qvsat550.*1000 - qv550;
    clear qv550 t550 p550 qvsat550

    % calculate the saturation deficit at 700 hPa
    indx = find(press < 700,1);
    size(indx)
    qv700 = reshape(qv(:,:,indx-1),4096*64,1); qv700 = qv700(mcs(:) == 1);
    t700 = reshape(t(:,:,indx-1),4096*64,1); t700 = t700(mcs(:) == 1);
    p700 = press(indx-1);
    qvsat700 = saturationMR(p700*100,t700); 
    sd700 = qvsat700.*1000 - qv700;
    clear qv700 t700 p700 qvsat700

    % calculate the saturation deficit at 850 hPa
    indx = find(press < 850,1);
    size(indx)
    qv850 = reshape(qv(:,:,indx-1),4096*64,1); qv850 = qv850(mcs(:) == 1);
    t850 = reshape(t(:,:,indx-1),4096*64,1); t850 = t850(mcs(:) == 1);
    p850 = press(indx-1);
    qvsat850 = saturationMR(p850*100,t850); 
    sd850 = qvsat850.*1000 - qv850;
    clear qv850 t850 p850 qvsat850

    % overall saturation deficit is the arithmetic mean of that at 550, 700,
    % and 850 hPa levels
    sd = (sd550 + sd700 + sd850)/3;

    % pick out the largest precip values in each saturation deficit bin
    min(sd)
    max(sd)
    temps = linspace(min(sd),max(sd),numbin);
    psurf = psurf(mcs == 1);  % filter the precip underlying MCS
    cape = cape(mcs == 1);    % filter the CAPE for MCS collocation
    sdM = []; prM = []; capeM = [];
    sdMED = []; prMED = []; capeMED = [];
    sd95 = []; pr95 = []; cape95 = [];
    sd99 = []; pr99 = []; cape99 = [];
    for ii = 1:length(temps)-1
        jj = find(sd >= temps(ii) & sd < temps(ii+1));
        ppp = psurf(jj);
        sss = sd(jj);
        ccc = cape(jj);
        
        sdM = [sdM; nanmean(sss)];
        prM = [prM; nanmean(ppp)];
        capeM = [capeM; nanmean(ccc)];
        
        sdMED = [sdMED; nanmedian(sss)];
        prMED = [prMED; nanmedian(ppp)];
        capeMED = [capeMED; nanmedian(ccc)];
        
        sd95 = [sd95; prctile(sss,95)];
        pr95 = [pr95; prctile(ppp,95)];
        cape95 = [cape95; prctile(ccc,95)];
        
        sd99 = [sd99; prctile(sss,99)];
        pr99 = [pr99; prctile(ppp,99)];
        cape99 = [cape99; prctile(ccc,99)];
    end
    sd = struct(); pr = struct(); cape = struct();
    sd.M = sdM; pr.M = prM; cape.M = capeM;
    sd.MED = sdMED; pr.MED = prMED; cape.MED = capeMED;
    sd.p95 = sd95; pr.p95 = pr95; cape.p95 = cape95;
    sd.p99 = sd99; pr.p99 = pr99; cape.p99 = cape99;
end
