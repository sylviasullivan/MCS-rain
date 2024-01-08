% CAPE-PMAX relationship in ERA5 files
% iterate through years and read in cape and pmax values
cape = []; pmax = [];
for year = 1983:2008
    fi = strcat('colloc_',num2str(year),'_NZ.nc');
    cape = [cape; ncread(fi,'cape')];
    pmax = [pmax; ncread(fi,'pmax')];
end
cape(cape < 0) = NaN;
pmax(pmax < 0) = NaN;

%%
% create bins in CAPE, iterate through, taking the mean / 95th / 99th perc
bb = 25;   % number of bins
cc = linspace(10,5000,bb);  
capebin = zeros(bb,1);
pmax95bin = zeros(bb,1);
pmax99bin = zeros(bb,1);
pmaxbin = zeros(bb,1);

for ii = 1:length(cc)-1
    jj = find(cape >= cc(ii) & cape < cc(ii+1));
    % only take the statistics if you have at least 20 values
    if length(jj) > 20
        capebin(ii) = mean(cape(jj));
        pmaxbin(ii) = mean(pmax(jj));
    
        pmax95bin(ii) = prctile(pmax(jj),95);
        pmax99bin(ii) = prctile(pmax(jj),99.99);
    end
end

%%
figure(1)
scatter(capebin,pmaxbin,'filled','blue')
ylabel('P_{max} [mm h^{-1}]')
xlabel('CAPE (pre6) [J kg^{-1}]')
set(gca,'fontsize',13)
% print(gcf,'-dpdf','cape-pmax-reproduced')

%%
% CAPE-CWVC relationship in ERA5 files
% iterate through years and read in qv and pmax values
qv = []; pmax = [];
for year = 1983 %:2008
    disp(year)
    fi = strcat('colloc_',num2str(year),'_NZ.nc');
    qv = [qv, ncread(fi,'qvpre6')];
    pmax = [pmax; ncread(fi,'pmax')];
end
pmax(pmax < 0) = NaN;
plev = double(ncread(fi,'pressure'));
rho = 1000;  % density of water kg m-3
g = 9.8;  % gravitational acceleration, m s-2

% integrate the specific humidity over the pressure levels to get CWVC
% 100 for hPa to Pa in plev, 1000 for m to mm in the final variable
cwvc = 1./(rho.*g).*trapz(plev.*100,qv,1).*1000;

%%
% create bins in CWVC, iterate through, taking the mean / 95th / 99th perc
bb = 25;   % number of bins
cc = linspace(5,65,bb);  
cwvcbin = zeros(bb,1);
pmax95bin = zeros(bb,1);
pmax99bin = zeros(bb,1);
pmaxbin = zeros(bb,1);

for ii = 1:length(cc)-1
    jj = find(cwvc >= cc(ii) & cwvc < cc(ii+1));
    cwvcbin(ii) = mean(cwvc(jj));
    pmaxbin(ii) = mean(pmax(jj));
    
    pmax95bin(ii) = prctile(pmax(jj),95);
    pmax99bin(ii) = prctile(pmax(jj),99.99);
end

%%
figure(2)
scatter(cwvcbin,pmaxbin,'filled','blue')
ylabel('P_{max} [mm h^{-1}]')
xlabel('CWVC (pre6) [mm]')
set(gca,'fontsize',13)
% print(gcf,'-dpdf','cwvc-pmax-reproduced')
