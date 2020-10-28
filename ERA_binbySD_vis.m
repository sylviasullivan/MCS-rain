clf
figure(5)
ll = 298; uu = 303; fs = 16;
subplot_tight(2,3,1,[0.09,0.07]);
hold on
[~,~,tMAX,sdMAX,capeMAX,~] = ERA_binbySD_max(1,'cape',5,'sd',10);
x1 = sdMAX; y1 = capeMAX;
% [dataout, ~, ~, ~] = lowess([x1; y1]',0.6,0);
% plot(dataout(:,1),dataout(:,3),'Color','k','LineWidth',1);
scatter(x1,y1.*3,40,tMAX,'filled','markeredgecolor','k')
xlabel('$\overline{<S_D>}$ [g kg$^{-1}$]','interpreter','latex')
ylabel('CAPE$^{(max)}$ [J kg$^{-1}$]','interpreter','latex')
text(0.01,0.93,'\bf{(a)}','fontsize',fs+2,'units','normalized')
set(gca,'fontsize',fs)
caxis([ll uu])

subplot_tight(2,3,4,[0.09,0.07]);
hold on
[prMAX,~,tMAX,sdMAX,~,~] = ERA_binbySD_max(1,'precip',5,'sd',10);
x1 = sdMAX; y1 = prMAX;
% [dataout, ~, ~, ~] = lowess([x1; y1]',0.6,0);
% plot(dataout(:,1),dataout(:,3),'Color','k','LineWidth',1);
scatter(x1,y1,40,tMAX,'filled','markeredgecolor','k')
xlabel('$<S_D>$ [g kg$^{-1}$]','interpreter','latex')
ylabel('$\dot{P}_z^{(max)}$','interpreter','latex')
text(0.01,0.93,'\bf{(d)}','fontsize',fs+2,'units','normalized')
set(gca,'fontsize',fs)
% c = colorbar;
% set(get(c,'label'),'string','SST_{med} [K]')
caxis([ll uu])

subplot_tight(2,3,2,[0.09,0.07]);
hold on
[pr,~,tstruct,sd,cape,depth] = ERA_binbySD_stats(1,'sd',25);
x1 = sd.M; y1 = cape.p99;
% [dataout, ~, ~, ~] = lowess([x1; y1]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','k','LineWidth',1);
scatter(x1,y1.*3,40,tstruct.MED,'filled','markeredgecolor','k')
xlabel('$\overline{<S_D>}$ [g kg$^{-1}$]','interpreter','latex')
ylabel('CAPE$^{(99)}$ [J kg$^{-1}$]','interpreter','latex')
text(0.01,0.93,'\bf{(b)}','fontsize',fs+2,'units','normalized')
set(gca,'fontsize',fs)
caxis([ll uu])

subplot_tight(2,3,5,[0.09,0.07]);
hold on
x1 = sd.M; y1 = pr.p99;
% [dataout, ~, ~, ~] = lowess([x1; y1]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','k','LineWidth',1);
scatter(x1,y1,40,tstruct.MED,'filled','markeredgecolor','k')
xlabel('$\overline{<S_D>}$','interpreter','latex')
ylabel('$\dot{P}_z^{(99)}$','interpreter','latex')
text(0.01,0.93,'\bf{(e)}','fontsize',fs+2,'units','normalized')
set(gca,'fontsize',fs)
% c = colorbar;
% set(get(c,'label'),'string','SST_{med} [K]')
caxis([ll uu])

subplot_tight(2,3,3,[0.09,0.07]);
hold on
x1 = sd.M; y1 = cape.M;
% [dataout, ~, ~, ~] = lowess([x1; y1]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','k','LineWidth',1);
scatter(x1,y1.*3,35,tstruct.MED,'filled','markeredgecolor','k')
xlabel('$\overline{<S_D>}$ [g kg$^{-1}$]','interpreter','latex')
ylabel('$\overline{CAPE}$ [J kg$^{-1}$]','interpreter','latex')
text(0.01,0.93,'\bf{(c)}','fontsize',fs+2,'units','normalized')
set(gca,'fontsize',fs)
caxis([ll uu])

subplot_tight(2,3,6,[0.09,0.07]);
hold on
x1 = sd.M; y1 = pr.M;
% [dataout, ~, ~, ~] = lowess([x1; y1]',0.75,1);
% plot(dataout(:,1),dataout(:,3),'Color','k','LineWidth',1);
scatter(x1,y1,35,tstruct.MED,'filled','markeredgecolor','k')
xlabel('$\overline{<S_D>}$ [g kg$^{-1}$]','interpreter','latex')
ylabel('$\overline{P_z}$','interpreter','latex')
text(0.01,0.93,'\bf{(f)}','fontsize',fs+2,'units','normalized')
set(gca,'fontsize',fs)
caxis([ll uu])

set(gcf,'paperorientation','landscape','paperunits','inches','papersize',...
    [15 7.5])
%print(gcf,'-dpdf','cape-sd-pr-max-99-mean')
