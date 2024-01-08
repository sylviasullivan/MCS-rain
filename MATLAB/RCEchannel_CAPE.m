clear all
cape = load('exported_CAPE_and_precip_285.mat');

%% CONVERT the RCE MAT FILE TO A NETCDF ONE
tt = '280';
nccreate(strcat('Tristan_CAPE_',tt,'.nc'),'cape','Dimensions',{'x',...
    length(cape.x),'y',length(cape.y),'t',length(cape.time)},'FillValue','disable')
nccreate(strcat('Tristan_CAPE_',tt,'.nc'),'time','Dimensions',{'t',...
    length(cape.time),},'FillValue','disable')
nccreate(strcat('Tristan_CAPE_',tt,'.nc'),'x','Dimensions',{'x',...
    length(cape.x),},'FillValue','disable')
nccreate(strcat('Tristan_CAPE_',tt','.nc'),'y','Dimensions',{'y',length(cape.y),},...
    'FillValue','disable')

ncwrite('Tristan_CAPE_280.nc','cape',cape.CAPE)
ncwrite('Tristan_CAPE_280.nc','time',cape.time)
ncwrite('Tristan_CAPE_280.nc','x',cape.x)
ncwrite('Tristan_CAPE_280.nc','y',cape.y)

%%  FIRST INSTANCE FIRST INSTANCE FIRST INSTANCE
j = 20;
clf
figure(4)
ax1 = subplot_tight(2,1,1,[0.09,0.09]);
hold on
field = cape.CAPE(1268:1368,:,j)';     % 2935:3102
xx = cape.x(1268:1368)./1000;  % 2935:3102
yy = cape.y./1000;
imagesc(xx,yy,field)
xlim([xx(1),xx(end)])
ylim([yy(1),yy(end)])
[X,Y] = meshgrid(xx,yy);
ylabel('Latitudinal distance [km]')
text(0.025,0.925,'\bf{(a)}','fontsize',16,'units','normalized')
h = colorbar;
ylabel(h,'CAPE [J kg^{-1}]')

ax2 = subplot_tight(2,1,2,[0.09,0.09]);
hold on
capeA = cape.CAPE(1268:1368,:,j)' - mean(mean(cape.CAPE(1268:1368,:,j)'));
imagesc(xx,yy,capeA(:,:))   % 2935:3102
colormap(ax2,redblue)
xlim([xx(1),xx(end)])
ylim([yy(1),yy(end)])
caxis([-750,750])
ylabel('Latitudinal distance [km]')
xlabel('Longitudinal distance [km]')
text(0.025,0.925,'\bf{(b)}','fontsize',16,'units','normalized')
h = colorbar;
ylabel(h,'CAPE anomaly [J kg^{-1}]')
% length(find(capeA(:,2935:3102) < 0))./(64*(3102-2935))

% clear capeA j

%%
% find the 10 largest elements
Nmax = 200;
[Avec, ind] = sort(field(:),1,'descend');
maxVals = Avec(1:Nmax);
[ind_row, ind_col] = ind2sub(size(field), ind(1:Nmax));

% randomly choose separated values from ind_row and ind_col
% ind_col = [115 75 140 111 88];
% ind_row = [42 54 28 9 12];

% spatially cluster these maximum values
xx2 = xx(ind_col);
yy2 = yy(ind_row);
fid = fopen('xx2yy2.txt','w');
check = [xx2 yy2];
fprintf(fid,'%10d %10d\r\n',check');
fclose all;

clear Nmax check fid ind

%%
[centroids,geomedian,clusters] = clusterXYpoints('xx2yy2.txt',55,15,...
    'centroid','merge');
for i = 1:length(clusters)
    scatter(clusters{i}(:,1),clusters{i}(:,2),45,'k','*')
    scatter(centroids(i,1),centroids(i,2),55,'g','d','filled','markeredgecolor','k')
end

% plot the lines connecting the centroids
ccdist = zeros(5,1);    % cluster centroid-to-cluster centroid distances
cpdist = {};            % cluster centroid-to-cluster points distances
for i = 1:5
    if i == 5
        j = 1;
    else
        j = i + 1;
    end
    plot([centroids(i,1),centroids(j,1)],[centroids(i,2),centroids(j,2)],'k',...
        'linewidth',1,'linestyle','--')
    ccdist(i) = sqrt((centroids(j,1)-centroids(i,1))^2+(centroids(j,2)-centroids(i,2))^2);
    cpdist{i} = zeros(length(clusters{i}),1);
    for k = 1:length(clusters{i})
        cpdist{i}(k,1) = sqrt((centroids(i,1)-clusters{i}(k,1))^2+(centroids(i,2)-clusters{i}(k,2))^2);
    end
end

set(ax1,'fontsize',13); set(ax2,'fontsize',13)
set(gcf,'PaperOrientation','landscape','PaperPosition',[0.25,0.1,11,6])
% print(gcf,'-dpdf','-r200','capeRCE')

%%  SECOND INSTANCE SECOND INSTANCE SECOND INSTANCE
j = 65;
clf
figure(4)
ax1 = subplot_tight(2,1,1,[0.09,0.09]);
hold on
field = cape.CAPE(3000:3150,:,j)';
xx = cape.x(3000:3150)./1000;
yy = cape.y./1000;
imagesc(xx,yy,field)
xlim([xx(1),xx(end)])
ylim([yy(1),yy(end)])
[X,Y] = meshgrid(xx,yy);
ylabel('Latitudinal distance [km]')
text(0.025,0.925,'\bf{(a)}','fontsize',16,'units','normalized')
h = colorbar;
ylabel(h,'CAPE [J kg^{-1}]')

ax2 = subplot_tight(2,1,2,[0.09,0.09]);
hold on
capeA = cape.CAPE(:,:,j)' - mean(mean(cape.CAPE(:,:,j)'));
imagesc(xx,yy,capeA(:,3000:3150))
colormap(ax2,redblue)
xlim([xx(1),xx(end)])
ylim([yy(1),yy(end)])
caxis([-3000,3000])
ylabel('Latitudinal distance [km]')
xlabel('Longitudinal distance [km]')
text(0.025,0.925,'\bf{(b)}','fontsize',16,'units','normalized')
h = colorbar;
ylabel(h,'CAPE anomaly [J kg^{-1}]')

length(find(capeA < 0))./(64*4096)

% clear capeA j

%%
% find the 200 largest elements
Nmax = 200;
[Avec, ind] = sort(field(:),1,'descend');
maxVals = Avec(1:Nmax);
[ind_row, ind_col] = ind2sub(size(field), ind(1:Nmax));

% randomly choose separated values from ind_row and ind_col
% ind_col = [115 75 140 111 88];
% ind_row = [42 54 28 9 12];

% spatially cluster these maximum values
xx2 = xx(ind_col);
yy2 = yy(ind_row);
fid = fopen('xx2yy2.txt','w');
check = [xx2 yy2];
fprintf(fid,'%10d %10d\r\n',check');
fclose all;

clear Nmax check fid ind

%%
[centroids,geomedian,clusters] = clusterXYpoints('xx2yy2.txt',100,15,...
    'centroid','merge');
for i = 1:length(clusters)
    scatter(clusters{i}(:,1),clusters{i}(:,2),45,'k','*')
    scatter(centroids(i,1),centroids(i,2),55,'g','d','filled','markeredgecolor','k')
end

% plot the lines connecting the centroids
ccdist = zeros(5,1);    % cluster centroid-to-cluster centroid distances
cpdist = {};            % cluster centroid-to-cluster points distances
for i = 1:5
    if i == 5
        j = 1;
    else
        j = i + 1;
    end
    plot([centroids(i,1),centroids(j,1)],[centroids(i,2),centroids(j,2)],'k',...
        'linewidth',1,'linestyle','--')
    ccdist(i) = sqrt((centroids(j,1)-centroids(i,1))^2+(centroids(j,2)-centroids(i,2))^2);
    cpdist{i} = zeros(length(clusters{i}),1);
    for k = 1:length(clusters{i})
        cpdist{i}(k,1) = sqrt((centroids(i,1)-clusters{i}(k,1))^2+(centroids(i,2)-clusters{i}(k,2))^2);
    end
end

set(ax1,'fontsize',13); set(ax2,'fontsize',13)
set(gcf,'PaperOrientation','landscape','PaperPosition',[0.25,0.1,11,6])
% print(gcf,'-dpdf','-r200','capeRCE2')
