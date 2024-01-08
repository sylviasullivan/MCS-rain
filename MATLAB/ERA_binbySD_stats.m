% This function will bin by saturation deficit and calculate the mean,
% median, 95th and 99.9th percentiles of CAPE, RH, precipitation intensity,
% and convective system depth in temperature coordinates for each bin. 
%
% avg = boolean for whether to calculate saturation deficits as the
% arithmetic average of values at 843, 710, and 550 hPa
% suffix = input file suffix that specifies time delay for CAPE (e.g.
% 'pre','pre6','core')
% field2 = field by which to bin: 'sd','cape'
% numbin = number of bins to use
function [pr,rh,tstruct,sd,cape,depth] = CCscalingCAPEnoENLN_2(avg,field2,numbin)
    eps = 0.01802/0.02897;
    % read in the files of collocated T, omega, CAPE, etc.
    p = ncread('colloc_nc/colloc_1983_NZ.nc','pressure');
    % pressure levels [hPa]
    p1 = 550; p2 = 700; p3 = 850; p4 = 470;
    % indices roughly corresponding to these pressure levels
    indx1 = find(p > p1,1);
    indx2 = find(p > p2,1);
    indx3 = find(p > p3,1);
    indx4 = find(p > p4,1);
    % lists in which to store specific humidity and temperature values for
    % all years
    qv1 = []; qv2 = []; qv3 = []; qv4 = [];
    t1 = []; t2 = []; t3 = []; t4 = [];
    pr = []; 
    epac = [];
    tss = [];
    pott = [];
    
    for jahr = 1983:2008
        fi = strcat('colloc_nc/colloc_',num2str(jahr),'_NZ.nc');
        temp = ncread(fi,'tpre6');
        qv = ncread(fi,'qvpre6');
        pmax = ncread(fi,'pmax')';
        sst = ncread(fi,'sst')';
        cape = ncread(fi,'capepre')';
        ttop = ncread(fi,'ctt')';
        
        % pull out the qv and temperature values at the levels
        % corresponding to 850, 700, 550 hPa and append them to the
        % corresponding list
        qv1 = [qv1 qv(indx1,:)]; t1 = [t1 temp(indx1,:)];
        qv2 = [qv2 qv(indx2,:)]; t2 = [t2 temp(indx2,:)];
        qv3 = [qv3 qv(indx3,:)]; t3 = [t3 temp(indx3,:)];
        qv4 = [qv4 qv(indx4,:)]; t4 = [t4 temp(indx4,:)];
        pr = [pr pmax];
        epac = [epac cape];
        tss = [tss sst];
        pott = [pott ttop];
    end
    
    % average over the three levels ... or not
    if avg == 1
        qv = (qv1 + qv2 + qv3)/3;
        t = (t1 + t2 + t3)/3;
        % calculate RH at each of the three levels and then average over
        rh1 = qv1./(eps.*SATVPLIQUID(t1)./(p1.*100 - SATVPLIQUID(t1)));
        rh2 = qv2./(eps.*SATVPLIQUID(t2)./(p2.*100 - SATVPLIQUID(t2)));
        rh3 = qv3./(eps.*SATVPLIQUID(t3)./(p3.*100 - SATVPLIQUID(t3)));
        rh = (rh1 + rh2 + rh3)/3;
        % calculate SD at each of the three levels and then average over  
        sd1 = (eps.*SATVPLIQUID(t1)./(p1.*100 - SATVPLIQUID(t1))) - qv1;
        sd2 = (eps.*SATVPLIQUID(t2)./(p2.*100 - SATVPLIQUID(t2))) - qv2;
        sd3 = (eps.*SATVPLIQUID(t3)./(p3.*100 - SATVPLIQUID(t3))) - qv3;
        sd = (sd1 + sd2 + sd3)/3.*1000;
        
    else
        qv = qv4;
        t = t4;
        % calculate RH at level of interest
        rh = qv4./(eps.*SATVPLIQUID(t4)./(p3.*100 - SATVPLIQUID(t4)));
        % calculate SD at level of interest
        sd = (eps.*SATVPLIQUID(t4)./(p4.*100 - SATVPLIQUID(t4))) - qv4;
    end
    upper = 6;

    % filter for instances where pmax is non-zero and there is underlying SST
    ii = find(~isnan(pr) & pr ~= 0 & tss > 0 & rh < 1 & epac > 1);
    pmax = pr(ii);
    sst = tss(ii);
    depth = sst - pott(ii);
    rh = rh(ii);
    qv = qv(ii);
    sd = sd(ii);
    cape = epac(ii);
    clear ii qv1 qv2 qv3 rh1 rh2 rh3 sd1 sd2 sd3

    % separate values into <numbin> <field2> bins and take the maximum <numext>
    % values of <field> from each
    if strcmp(field2,'sd')
        toto = sd;
        upper = 6;
    else if strcmp(field2,'cape')
            toto = cape;
            upper = 4000;
        else
            disp('Field 2 improperly set.')
            return
        end
    end
    temps = linspace(0,upper,numbin);
    tMED = []; prMED = []; rhMED = []; sdMED = []; capeMED = []; depthMED = [];
    tM = []; prM = []; rhM = []; sdM = []; capeM = []; depthM = [];
    t95 = []; pr95 = []; rh95 = []; sd95 = []; cape95 = []; depth95 = [];
    t99 = []; pr99 = []; rh99 = []; sd99 = []; cape99 = []; depth99 = [];
    for ii = 1:length(temps)-1
        jj = find(toto >= temps(ii) & toto < temps(ii+1));
        ppp = pmax(jj); 
        ttt = sst(jj); 
        rrr = rh(jj);
        qqq = sd(jj);
        ccc = cape(jj);
        ddd = depth(jj);
        if length(ppp) > 15
            prMED = [prMED, nanmedian(ppp)];
            tMED = [tMED, nanmedian(ttt)];
            rhMED = [rhMED, nanmedian(rrr)];
            sdMED = [sdMED, nanmedian(qqq)];
            capeMED = [capeMED, nanmedian(ccc)];
            depthMED = [depthMED, nanmedian(ddd)];

            prM = [prM, nanmean(ppp)];
            tM = [tM, nanmean(ttt)];
            rhM = [rhM, nanmean(rrr)];
            sdM = [sdM, nanmean(qqq)];
            capeM = [capeM, nanmean(ccc)];
            depthM = [depthM, nanmean(ddd)];

            pr95 = [pr95, prctile(ppp,95)];
            t95 = [t95, prctile(ttt,95)];
            rh95 = [rh95, prctile(rrr,95)];
            sd95 = [sd95, prctile(qqq,95)];
            cape95 = [cape95, prctile(ccc,95)];
            depth95 = [depth95,prctile(ddd,95)];

            pr99 = [pr99, prctile(ppp,99)];
            t99 = [t99, prctile(ttt,99)];
            rh99 = [rh99, prctile(rrr,99)];
            sd99 = [sd99, prctile(qqq,99)];
            cape99 = [cape99, prctile(ccc,99)];
            depth99 = [depth99, prctile(ddd,99)];
        end
    end
    pr = struct(); tstruct = struct(); rh = struct(); 
    sd = struct(); cape = struct(); depth = struct();
    pr.MED = prMED; 
    tstruct.MED = tMED; 
    rh.MED = rhMED;
    sd.MED = sdMED;
    cape.MED = capeMED;
    depth.MED = depthMED;
    clear prMED tMED rhMED sdMED capeMED depthMED

    pr.M = prM; 
    tstruct.M = tM; 
    rh.M = rhM;
    sd.M = sdM;
    cape.M = capeM;
    depth.M = depthM;
    clear prM tM rhM sdM capeM depthM

    pr.p95 = pr95; 
    tstruct.p95 = t95; 
    rh.p95 = rh95;
    sd.p95 = sd95;
    cape.p95 = cape95;
    depth.p95 = depth95;
    clear pr95 t95 rh95 sd95 cape95 depth95

    pr.p99 = pr99; 
    tstruct.p99 = t99; 
    rh.p99 = rh99;
    sd.p99 = sd99;
    cape.p99 = cape99;
    depth.p99 = depth99;
    clear pr99 t99 rh99 sd99 cape99 depth99
    clear ccc eps fi1 fi2 fi3 ii jj num2 pmax ppp press 
    clear qqq qv rrr sst ttt ddd temps
end