% This function will bin by saturation deficit and calculate the mean,
% median, 95th and 99.9th percentiles of CAPE, RH, precipitation intensity,
% and convective system depth in temperature coordinates for each bin. 
%
% avg = boolean for whether to calculate saturation deficits as the
% arithmetic average of values at 843, 710, and 550 hPa
% suffix = input file suffix that specifies time delay for CAPE (e.g.
% 'pre','pre6','core')
% field = field from which to extract the maxima: 'cape','precip','depth'
% numext = how many maxima to extract
% field2 = field by which to bin: 'sd','cape'
% numbin = number of bins to use

function [prMAX,rhMAX,tMAX,sdMAX,capeMAX,depthMAX] = ERA_binbySD(avg,field,numext,field2,numbin)
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
        upper = 6;
        toto = sd;
    else if strcmp(field2,'cape')
            upper = 4000; 
            toto = cape;
        else
            disp('Field 2 improperly set.')
            return
        end
    end
    temps = linspace(0,upper,numbin);
    tMAX = []; prMAX = []; rhMAX = []; sdMAX = []; capeMAX = []; depthMAX = [];
    for ii = 1:length(temps)-1
        % otherwise there seems to be a problem "matrix dimensions do not
        % agree"
        clear fff
        jj = find(toto >= temps(ii) & toto < temps(ii+1));
        ppp = pmax(jj); 
        ttt = sst(jj); 
        rrr = rh(jj);
        qqq = sd(jj);
        ccc = cape(jj);
        ddd = depth(jj);
        
        % which field do we pull maxima from?
        if strcmp(field,'cape') == 1
            fff = ccc;
        else if strcmp(field,'precip') == 1
                fff = ppp;
            else if strcmp(field,'depth') == 1
                    fff = ddd;
                else
                    disp('Field improperly set.')
                    return
                end
            end
        end
        if length(ppp) > 10
            [~,kk] = maxk(fff,numext);
            prMAX = [prMAX, ppp(kk)];
            tMAX = [tMAX, ttt(kk)];
            rhMAX = [rhMAX, rrr(kk)];
            sdMAX = [sdMAX, qqq(kk)];
            capeMAX = [capeMAX, ccc(kk)];
            depthMAX = [depthMAX, ddd(kk)];
        end
    end
end
