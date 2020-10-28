%%
% FIGURE 1: saturation deficit (as in Singh et al. 2017 -- averaged over
% 850, 700, 500 hPa) versus CAPE and now convective depth in both model and
% observations
clf
figure(5)
subplot_tight(4,3,1,[0.09,0.09]);
hold on
[~,~,tMAX,sdMAX,capeMAX,~] = ERA_binbySD_max(1,'cape',5,'sd',10);
x1 = sdMAX; y1 = capeMAX;
% [dataout, ~, ~, ~] = lowess([x1; y1]',0.6,0);
% plot(dataout(:,1),dataout(:,3),'Color','k','LineWidth',1);
scatter(x1,y1,40,tMAX,'filled','markeredgecolor','k')
xlabel('$<S_D>$','interpreter','latex')
ylabel('CAPE$^{(max)}$','interpreter','latex')
text(0.01,0.93,'\bf{(a)}','fontsize',14,'units','normalized')
set(gca,'fontsize',14)
caxis([295 303])

subplot_tight(4,3,2,[0.09,0.09]);
hold on
[~,~,tMAX,sdMAX,~,depthMAX] = ERA_binbySD_max(1,'depth',5,'sd',10);
x1 = sdMAX; y1 = depthMAX;
% [dataout, ~, ~, ~] = lowess([x1; y1]',0.6,0);
% plot(dataout(:,1),dataout(:,3),'Color','k','LineWidth',1);
scatter(x1,y1,40,tMAX,'filled','markeredgecolor','k')
xlabel('$<S_D>$','interpreter','latex')
ylabel('(SST-$T_{top}$)$^{(max)}$','interpreter','latex')
text(0.01,0.93,'\bf{(b)}','fontsize',14,'units','normalized')
set(gca,'fontsize',14)
caxis([295 303])

subplot_tight(4,3,3,[0.09,0.09]);
hold on
[prMAX,~,tMAX,sdMAX,~,~] = ERA_binbySD_max(1,'precip',5,'sd',10);
x1 = sdMAX; y1 = prMAX;
% [dataout, ~, ~, ~] = lowess([x1; y1]',0.6,0);
% plot(dataout(:,1),dataout(:,3),'Color','k','LineWidth',1);
scatter(x1,y1,40,tMAX,'filled','markeredgecolor','k')
xlabel('$<S_D>$','interpreter','latex')
ylabel('$\dot{P}_z^{(max)}$','interpreter','latex')
text(0.01,0.93,'\bf{(c)}','fontsize',14,'units','normalized')
set(gca,'fontsize',14)
c = colorbar;
set(get(c,'label'),'string','SST_{med} [K]')
caxis([298 306])

subplot_tight(4,3,4,[0.09,0.09]);
hold on
[pr,~,tstruct,sd,cape,depth] = ERA_binbySD_stats(1,'sd',25);
x1 = sd.M; y1 = cape.p99;
% [dataout, ~, ~, ~] = lowess([x1; y1]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','k','LineWidth',1);
scatter(x1,y1,40,tstruct.MED,'filled','markeredgecolor','k')
xlabel('$\overline{<S_D>}$','interpreter','latex')
ylabel('CAPE$^{(99.99)}$','interpreter','latex')
text(0.01,0.93,'\bf{(d)}','fontsize',14,'units','normalized')
set(gca,'fontsize',14)
caxis([299 302])

subplot_tight(4,3,5,[0.09,0.09]);
hold on
x1 = sd.M; y1 = depth.p99;
% [dataout, ~, ~, ~] = lowess([x1; y1]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','k','LineWidth',1);
scatter(x1,y1,40,tstruct.MED,'filled','markeredgecolor','k')
xlabel('$\overline{<S_D>}$','interpreter','latex')
ylabel('(SST - $T_{top}$)$^{(99.99)}$','interpreter','latex')
text(0.01,0.93,'\bf{(e)}','fontsize',14,'units','normalized')
set(gca,'fontsize',14)
caxis([299 302])

subplot_tight(4,3,6,[0.09,0.09]);
hold on
x1 = sd.M; y1 = pr.p99;
% [dataout, ~, ~, ~] = lowess([x1; y1]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','k','LineWidth',1);
scatter(x1,y1,40,tstruct.MED,'filled','markeredgecolor','k')
xlabel('$\overline{<S_D>}$','interpreter','latex')
ylabel('$\dot{P}_z^{(99.99)}$','interpreter','latex')
text(0.01,0.93,'\bf{(f)}','fontsize',14,'units','normalized')
set(gca,'fontsize',14)
c = colorbar;
set(get(c,'label'),'string','SST_{med} [K]')
caxis([299 302])

subplot_tight(4,3,7,[0.09,0.09]);
hold on
x1 = sd.M; y1 = cape.p95;
% [dataout, ~, ~, ~] = lowess([x1; y1]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','k','LineWidth',1);
scatter(x1,y1,35,tstruct.MED,'filled','markeredgecolor','k')
xlabel('$\overline{<S_D>}$','interpreter','latex')
ylabel('CAPE$^{(95)}$','interpreter','latex')
text(0.01,0.93,'\bf{(g)}','fontsize',14,'units','normalized')
set(gca,'fontsize',14)
caxis([299 302])

subplot_tight(4,3,8,[0.09,0.09]);
hold on
x1 = sd.M; y1 = depth.p95;
% [dataout, ~, ~, ~] = lowess([x1; y1]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','k','LineWidth',1);
scatter(x1,y1,35,tstruct.MED,'filled','markeredgecolor','k')
xlabel('$\overline{S_D}$','interpreter','latex')
ylabel('(SST - $T_{top}$)$^{(95)}$','interpreter','latex')
text(0.01,0.93,'\bf{(h)}','fontsize',14,'units','normalized')
set(gca,'fontsize',14)
caxis([299 302])

subplot_tight(4,3,9,[0.09,0.09]);
hold on
x1 = sd.M; y1 = pr.p95;
% [dataout, ~, ~, ~] = lowess([x1; y1]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','k','LineWidth',1);
scatter(x1,y1,35,tstruct.MED,'filled','markeredgecolor','k')
xlabel('$\overline{<S_D>}$','interpreter','latex')
ylabel('$\dot{P}_z^{(95)}$','interpreter','latex')
text(0.01,0.93,'\bf{(i)}','fontsize',14,'units','normalized')
c = colorbar;
set(get(c,'label'),'string','SST_{med} [K]')
set(gca,'fontsize',14)
caxis([299 302])

subplot_tight(4,3,10,[0.09,0.09]);
hold on
x1 = sd.M; y1 = cape.M;
% [dataout, ~, ~, ~] = lowess([x1; y1]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','k','LineWidth',1);
scatter(x1,y1,35,tstruct.MED,'filled','markeredgecolor','k')
xlabel('$\overline{<S_D>}$','interpreter','latex')
ylabel('$\overline{CAPE}$','interpreter','latex')
text(0.01,0.93,'\bf{(j)}','fontsize',14,'units','normalized')
set(gca,'fontsize',14)
caxis([299 302])

subplot_tight(4,3,11,[0.09,0.09]);
hold on
x1 = sd.M; y1 = depth.M;
% [dataout, ~, ~, ~] = lowess([x1; y1]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','k','LineWidth',1);
scatter(x1,y1,35,tstruct.MED,'filled','markeredgecolor','k')
xlabel('$\overline{S_D}$','interpreter','latex')
ylabel('$\overline{(SST - T_{top})}$','interpreter','latex')
text(0.01,0.93,'\bf{(k)}','fontsize',14,'units','normalized')
caxis([299 302])
set(gca,'fontsize',14)

subplot_tight(4,3,12,[0.09,0.09]);
hold on
x1 = sd.M; y1 = pr.M;
% [dataout, ~, ~, ~] = lowess([x1; y1]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','k','LineWidth',1);
scatter(x1,y1,35,tstruct.MED,'filled','markeredgecolor','k')
xlabel('$\overline{<S_D>}$','interpreter','latex')
ylabel('$\overline{\dot{P_z}}$','interpreter','latex')
text(0.01,0.93,'\bf{(l)}','fontsize',14,'units','normalized')
c = colorbar;
set(get(c,'label'),'string','SST_{med} [K]')
set(gca,'fontsize',14)
caxis([299 302])
set(gcf,'paperorientation','landscape','paperunits','inches','papersize',...
    [15 7.5])

% % plot the 3-hour preceding regressions
% [~,~,~,sd,cape,depth] = CCscalingCAPEnoENLN(1,'pre',30);
% [dataout, ~, ~, ~] = lowess([sd.MED; cape.p99]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','r','LineWidth',0.75,'Parent',ax1);
% [dataout, ~, ~, ~] = lowess([sd.MED; depth.p99]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','r','LineWidth',0.75,'Parent',ax2);
% [dataout, ~, ~, ~] = lowess([cape.p99; depth.p99]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','r','LineWidth',0.75,'Parent',ax3);
% [~,~,~,sd,cape,depth] = CCscalingCAPEnoENLN(0,'pre',30);
% cape.p99(cape.p99 < 2500) = nan;   % one outlier
% [dataout, ~, ~, ~] = lowess([sd.MED(~isnan(cape.p99)); ...
%     cape.p99(~isnan(cape.p99))]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','r','LineWidth',0.75,'Parent',ax4);
% [dataout, ~, ~, ~] = lowess([sd.MED; depth.p99]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','r','LineWidth',0.75,'Parent',ax5);
% [dataout, ~, ~, ~] = lowess([cape.p99(~isnan(cape.p99)); ...
%     depth.p99(~isnan(cape.p99))]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','r','LineWidth',0.75,'Parent',ax6);
% 
% % plot the coincident regressions
% [~,~,~,sd,cape,depth] = CCscalingCAPEnoENLN(1,'core',30);
% [dataout, ~, ~, ~] = lowess([sd.MED; cape.p99]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','b','LineWidth',0.75,'Parent',ax1);
% [dataout, ~, ~, ~] = lowess([sd.MED; depth.p99]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','b','LineWidth',0.75,'Parent',ax2);
% [dataout, ~, ~, ~] = lowess([cape.p99; depth.p99]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','b','LineWidth',0.75,'Parent',ax3);
% [~,~,~,sd,cape,depth] = CCscalingCAPEnoENLN(0,'core',30);
% cape.p99(cape.p99 < 2500) = nan;   % one outlier
% [dataout, ~, ~, ~] = lowess([sd.MED(~isnan(cape.p99)); ...
%     cape.p99(~isnan(cape.p99))]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','b','LineWidth',0.75,'Parent',ax4);
% [dataout, ~, ~, ~] = lowess([sd.MED; depth.p99]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','b','LineWidth',0.75,'Parent',ax5);
% [dataout, ~, ~, ~] = lowess([cape.p99(~isnan(cape.p99)); ...
%     depth.p99(~isnan(cape.p99))]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','b','LineWidth',0.75,'Parent',ax6);

% set(gcf,'paperunits','inches','PaperOrientation','landscape','PaperSize',[16 9])
% print(gcf,'-dpdf','-fillpage','-r250','binning-by-sd_pre')

%%
% FIGURE 2: precipitation intensity versus saturation deficit (as in Singh
% et al. 2017 -- averaged over 850, 700, 500 hPa) 
%clf
figure(6)
subplot_tight(4,2,1,[0.09,0.09]);
hold on
[~,~,tMAX,~,capeMAX,depthMAX] = ERA_binbySD_max(1,'depth',5,'cape',10);
x1 = capeMAX; y1 = depthMAX;
scatter(x1,y1,40,tMAX,'filled','markeredgecolor','k')
% [dataout, ~, ~, ~] = lowess([sd.MED; pr.p95]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','k','LineWidth',1);
xlabel('CAPE$^{(max)}$','interpreter','latex')
ylabel('(SST-T$_{top})^{(max)}$','interpreter','latex')
text(0.01,0.93,'\bf{(a)}','fontsize',14,'units','normalized')
set(gca,'fontsize',14)
caxis([300 304])

subplot_tight(4,2,2,[0.09,0.09]);
hold on
[prMAX,~,tMAX,~,capeMAX,~] = ERA_binbySD_max(1,'precip',5,'cape',10);
x1 = capeMAX; y1 = prMAX;
scatter(x1,y1,40,tMAX,'filled','markeredgecolor','k')
% [dataout, ~, ~, ~] = lowess([depth.p95; pr.p95]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','k','LineWidth',1.5);
xlabel('CAPE$^{(max)}$','interpreter','latex')
ylabel('$\dot{P}_z^{(max)}$','interpreter','latex')
text(0.01,0.93,'\bf{(b)}','fontsize',14,'units','normalized')
set(gca,'fontsize',12)
caxis([300 304])
c = colorbar;
set(get(c,'label'),'string','SST_{med} [K]')

subplot_tight(4,2,3,[0.09,0.09]);
hold on
[pr,~,tstruct,~,cape,depth] = ERA_binbySD_stats(1,'cape',25);
x1 = cape.M; y1 = depth.p99;
scatter(x1,y1,35,tstruct.MED,'filled','markeredgecolor','k')
% [dataout, ~, ~, ~] = lowess([sd.MED; pr.p99]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','k','LineWidth',1.5);
xlabel('$\overline{CAPE}$','interpreter','latex')
ylabel('(SST-T$_{top})^{(99.99)}$ [K]','interpreter','latex')
text(0.01,0.93,'\bf{(c)}','fontsize',14,'units','normalized')
set(gca,'fontsize',14)
caxis([300 303])

subplot_tight(4,2,4,[0.09,0.09]);
hold on
x1 = cape.M; y1 = pr.p99;
scatter(x1,y1,35,tstruct.MED,'filled','markeredgecolor','k')
% [dataout, ~, ~, ~] = lowess([depth.p99; pr.p99]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','k','LineWidth',1.5);
xlabel('$\overline{CAPE}$','interpreter','latex')
ylabel('$\dot{P}_z^{(99.99)}$','interpreter','latex')
text(0.01,0.93,'\bf{(d)}','fontsize',14,'units','normalized')
set(gca,'fontsize',14)
c = colorbar;
set(get(c,'label'),'string','SST_{med} [K]')
caxis([300 303])

subplot_tight(4,2,5,[0.09,0.09]);
hold on
x1 = cape.M; y1 = depth.p95;
scatter(x1,y1,35,tstruct.MED,'filled','markeredgecolor','k')
% [dataout, ~, ~, ~] = lowess([sd.MED; pr.p99]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','k','LineWidth',1.5);
xlabel('$\overline{CAPE}$','interpreter','latex')
ylabel('(SST-T$_{top})^{(95)}$','interpreter','latex')
text(0.01,0.93,'\bf{(e)}','fontsize',14,'units','normalized')
set(gca,'fontsize',14)
caxis([300 303])

subplot_tight(4,2,6,[0.09,0.09]);
hold on
x1 = cape.M; y1 = pr.p95;
scatter(x1,y1,35,tstruct.MED,'filled','markeredgecolor','k')
% [dataout, ~, ~, ~] = lowess([depth.p99; pr.p99]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','k','LineWidth',1.5);
xlabel('$\overline{CAPE}$','interpreter','latex')
ylabel('$\dot{P}_z^{(95)}$','interpreter','latex')
text(0.01,0.93,'\bf{(f)}','fontsize',14,'units','normalized')
set(gca,'fontsize',14)
caxis([300 303])

subplot_tight(4,2,7,[0.09,0.09]);
hold on
x1 = cape.M; y1 = depth.M;
scatter(x1,y1,35,tstruct.MED,'filled','markeredgecolor','k')
% [dataout, ~, ~, ~] = lowess([cape.p99; depth.p99]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','k','LineWidth',1.5);
xlabel('$\overline{CAPE}$','interpreter','latex')
ylabel('$\overline{(SST-T_{top})}$','interpreter','latex')
text(0.01,0.93,'\bf{(g)}','fontsize',14,'units','normalized')
set(gca,'fontsize',14)
caxis([300 303])

subplot_tight(4,2,8,[0.09,0.09]);
hold on
[pr,~,tstruct,~,cape,~] = ERA_binbySD_stats(1,'cape',25);
x1 = cape.M; y1 = pr.M;
scatter(x1,y1,35,tstruct.MED,'filled','markeredgecolor','k')
% [dataout, ~, ~, ~] = lowess([sd.MED; pr.p99]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','k','LineWidth',1.5);
xlabel('$\overline{CAPE}$','interpreter','latex')
ylabel('$\overline{\dot{P}_z}$','interpreter','latex')
text(0.01,0.95,'\bf{(h)}','fontsize',14,'units','normalized')
set(gca,'fontsize',14)
c = colorbar;
set(get(c,'label'),'string','SST_{med} [K]')
caxis([300 303])

% % plot the 3-hour preceding regressions
% [~,~,~,sd,cape,depth] = CCscalingCAPEnoENLN(1,'pre',30);
% [dataout, ~, ~, ~] = lowess([sd.MED; cape.p99]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','r','LineWidth',0.75,'Parent',ax1);
% [dataout, ~, ~, ~] = lowess([sd.MED; depth.p99]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','r','LineWidth',0.75,'Parent',ax2);
% [dataout, ~, ~, ~] = lowess([cape.p99; depth.p99]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','r','LineWidth',0.75,'Parent',ax3);
% [~,~,~,sd,cape,depth] = CCscalingCAPEnoENLN(0,'pre',30);
% cape.p99(cape.p99 < 2500) = nan;   % one outlier
% [dataout, ~, ~, ~] = lowess([sd.MED(~isnan(cape.p99)); ...
%     cape.p99(~isnan(cape.p99))]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','r','LineWidth',0.75,'Parent',ax4);
% [dataout, ~, ~, ~] = lowess([sd.MED; depth.p99]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','r','LineWidth',0.75,'Parent',ax5);
% [dataout, ~, ~, ~] = lowess([cape.p99(~isnan(cape.p99)); ...
%     depth.p99(~isnan(cape.p99))]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','r','LineWidth',0.75,'Parent',ax6);
% 
% % plot the coincident regressions
% [~,~,~,sd,cape,depth] = CCscalingCAPEnoENLN(1,'core',30);
% [dataout, ~, ~, ~] = lowess([sd.MED; cape.p99]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','b','LineWidth',0.75,'Parent',ax1);
% [dataout, ~, ~, ~] = lowess([sd.MED; depth.p99]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','b','LineWidth',0.75,'Parent',ax2);
% [dataout, ~, ~, ~] = lowess([cape.p99; depth.p99]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','b','LineWidth',0.75,'Parent',ax3);
% [~,~,~,sd,cape,depth] = CCscalingCAPEnoENLN(0,'core',30);
% cape.p99(cape.p99 < 2500) = nan;   % one outlier
% [dataout, ~, ~, ~] = lowess([sd.MED(~isnan(cape.p99)); ...
%     cape.p99(~isnan(cape.p99))]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','b','LineWidth',0.75,'Parent',ax4);
% [dataout, ~, ~, ~] = lowess([sd.MED; depth.p99]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','b','LineWidth',0.75,'Parent',ax5);
% [dataout, ~, ~, ~] = lowess([cape.p99(~isnan(cape.p99)); ...
%     depth.p99(~isnan(cape.p99))]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','b','LineWidth',0.75,'Parent',ax6);

set(gcf,'paperunits','inches','PaperOrientation','landscape','PaperSize',[16 9])
%print(gcf,'-dpdf','-fillpage','-r250','binning-by-cape')

%%

% ERA-Interim pressure levels
pINT = [122.6137,142.9017,165.0886,189.1466,215.0251,242.6523,272.0593,...
  303.2174,336.0439,370.4072,406.1328,443.0086,480.7907,519.2093,557.9734,...
  596.7774,635.3060,673.2403,710.2627,746.0635,780.3455,812.8303,843.2634,...
  871.4203,897.1118,920.1893,940.5511,958.1477,972.9868,985.1399,994.7472,...
  1002.0236];
% ERA-5 pressure levels
p5 = [125,150,175,220,225,250,300,350,400,450,500,550,600,650,700,750,775,...
    800,825,850,875,900,925,950,975,1000];
