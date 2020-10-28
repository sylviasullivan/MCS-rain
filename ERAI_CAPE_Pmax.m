%% REPRODUCING SCALING FROM NETCDF4 RATHER THAN NPY FILES
% load the nc files and pull out their precip, CAPE, and updraft velocities
clear all
pmax = []; cape = []; w = [];
for jahr = 1983:2008
    fi = strcat('C:\Users\Sylvia\Documents\MCS_clim\ausgabe\colloc_nc\colloc_',...
        num2str(jahr),'_NZ.nc');
    pmax = [pmax; ncread(fi,'pmax')];
    cape = [cape; ncread(fi,'cape')];
    omega = ncread(fi,'w');
    w = [w; omega(15,:)'];
end

%% 
% iterate over the CAPE bins and pull out the maximum 5 elements in each
num = 20; 
num2 = 5;
temps = linspace(50,5000,num);
pvals = []; 
cvals = [];
wvals = [];
for ii = 1:length(temps)-1
    jj = find(cape >= temps(ii) & cape < temps(ii+1));
    pp = pmax(jj); 
    cc = cape(jj);
    ww = w(jj);

    [~,jj] = maxk(pp,num2);
    pvals = [pvals; pp(jj)];
    cvals = [cvals; cc(jj)];
    wvals = [wvals; ww(jj)];
end

%% 
% plot the netcdf4 results
clf
figure(1)
scatter(log(cvals),pvals,20,'filled')