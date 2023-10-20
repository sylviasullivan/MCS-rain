clear all
cape = load('scaling-and-cape-output/exported_CAPE_and_precip_300.mat'); 
    %_280, _290, _295, _300,_305

%%  280 K = 1268:1368 and j = 20
% 285 K = 768:850 and j = 7
% 290 K = 190:390 and j = 1
% 295 K = 2050:2200 and j = 1
% 300 K = 2835:3068 and j = 100
% 305 K = 1935:2068 and j = 5
j = 5; i1 = 1; i2 = size(cape.x,1);
clf
figure(4)
ax1 = subplot_tight(2,1,1,[0.09,0.09]);
hold on
field = cape.CAPE(i1:i2,:,j)';
xx = cape.x(i1:i2)./1000;
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
capeA = cape.CAPE(i1:i2,:,j)' - mean(mean(cape.CAPE(i1:i2,:,j)'));
imagesc(xx,yy,capeA(:,:))   % 2935:3102
colormap(ax2,redblue)
xlim([xx(1),xx(end)])
ylim([yy(1),yy(end)])
caxis([-3000,3000])
ylabel('Latitudinal distance [km]')
xlabel('Longitudinal distance [km]')
text(0.025,0.925,'\bf{(b)}','fontsize',16,'units','normalized')
h = colorbar;
ylabel(h,'CAPE anomaly [J kg^{-1}]')

%%
% find the 200 largest elements
Nmax = 200;
[Avec, ind] = sort(field(:),1,'descend');
maxVals = Avec(1:Nmax);
[ind_row, ind_col] = ind2sub(size(field), ind(1:Nmax));

% spatially cluster these maximum values
xx2 = xx(ind_col);
yy2 = yy(ind_row);
fid = fopen('xx2yy2.txt','w');
check = [xx2 yy2];
fprintf(fid,'%10d %10d\r\n',check');
fclose all;

clear Nmax check fid ind

%%
[centroids,geomedian,clusters] = clusterXYpoints('xx2yy2.txt',50,15,...
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

%%
set(ax1,'fontsize',13); set(ax2,'fontsize',13)
set(gcf,'PaperOrientation','landscape','PaperPosition',[0.25,0.1,11,6])
print(gcf,'-dpdf','-r200','capeRCE_305K')