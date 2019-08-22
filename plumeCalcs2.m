% load the temperature, vapor mixing ratio, altitude, and pressure profiles
% and some constants
clear all
Tprof = zeros(6,32); qvprof = zeros(6,32);
Tprof(1,:) = mean(readNPY('scaling-and-cape-input/T_ENDJF1.npy'),1);
Tprof(2,:) = mean(readNPY('scaling-and-cape-input/T_ENDJF2.npy'),1);
Tprof(3,:) = mean(readNPY('scaling-and-cape-input/T_ENDJF3.npy'),1);
Tprof(4,:) = mean(readNPY('scaling-and-cape-input/T_LNDJF1.npy'),1);
Tprof(5,:) = mean(readNPY('scaling-and-cape-input/T_LNDJF2.npy'),1);
Tprof(6,:) = mean(readNPY('scaling-and-cape-input/T_LNDJF3.npy'),1);
Tprof1 = [repmat(Tprof(3,:),3,1); repmat(Tprof(6,:),3,1)];

qvprof(1,:) = mean(readNPY('scaling-and-cape-input/qv_ENDJF1.npy'),1);
qvprof(2,:) = mean(readNPY('scaling-and-cape-input/qv_ENDJF2.npy'),1);
qvprof(3,:) = mean(readNPY('scaling-and-cape-input/qv_ENDJF3.npy'),1);
qvprof(4,:) = mean(readNPY('scaling-and-cape-input/qv_LNDJF1.npy'),1);
qvprof(5,:) = mean(readNPY('scaling-and-cape-input/qv_LNDJF2.npy'),1);
qvprof(6,:) = mean(readNPY('scaling-and-cape-input/qv_LNDJF3.npy'),1);
qvprof1 = [repmat(qvprof(3,:),3,1); repmat(qvprof(6,:),3,1)];

z = [15418.43,14415.44,13470.22,12579.42,11739.87,10948.81,10191.54,...
     9458.63,8749.51,8064.40,7403.97,6769.08,6160.62,5579.46,5026.39,4502.09,...
     4007.11,3541.93,3106.86,2702.14,2327.89,1984.11,1670.7,1387.43,1133.93,...
     909.7,714.05,546.11,404.74,288.57,195.85,124.48];
press = [122.6137,142.9017,165.0886,189.1466,215.0251,242.6523,272.0593,...
      303.2174,336.0439,370.4072,406.1328,443.0086,480.7907,519.2093,557.9734,...
      596.7774,635.3060,673.2403,710.2627,746.0635,780.3455,812.8303,843.2634,...
      871.4203,897.1118,920.1893,940.5511,958.1477,972.9868,985.1399,994.7472,...
      1002.0236];
press = press.*100;   % convert hPa to Pa
cp = 1008;       % heat capacity (www.ohio.edu/mechanical/thermo) [J kg-1 K-1]
MWa  = 0.02897;  % molecular mass of air [kg mol-1]
MWw  = 0.01802;  % molecular mass of water vapor [kg mol-1]
densA = 1.395;   % density of air (assumed - 15 C) [kg m-3]
R = 8.314;       % gas constant [J mol-1 K-1]

%%
% From profiles and constants, calculate beta, entrainment, and saturation
% deficit. Vertically integrate the latter.

% read in the tropical temperature sounding of Ellingson (ambient)
fid = fopen('tropical_profile_ellingson_250m_no_header.txt','r');
tropicProf = transpose(reshape(fscanf(fid,'%f'),[9 81]));
tropicTemp = interp1(tropicProf(:,1).*1000,tropicProf(:,3),z);
tropicqv = interp1(tropicProf(:,1).*1000,tropicProf(:,6),z);

eps = MWw/MWa;
s = struct('dqdT',0,'beta',0,'qvsat',0,'RH',0,'integ',0,'visd',0,'buoy',0);        
% base structure
sT = struct('dqdT',0,'beta',0,'qvsat',0,'RH',0,'integ',0,'visd',0,'buoy',0);       
% hold the temperature profile constant between El Nino and La Nina
sRH = struct('dqdT',0,'beta',0,'qvsat',0,'RH',0,'integ',0,'visd',0,'buoy',0);      
% hold the RH profile constant 
sA = struct('dqdT',0,'beta',0,'qvsat',0,'RH',0,'integ',0,'visd',0,'buoy',0);       
% ambient conditions
s1T = struct('dqdT',0,'beta',0,'qvsat',0,'RH',0,'integ',0,'visd',0,'buoy',0);  
% hold the temperature profile constant to that of the deepest system
s1RH = struct('dqdT',0,'beta',0,'qvsat',0,'integ',0,'visd',0,'buoy',0);  
% hold the RH profile constant to that of the deepest system

% change in saturation vapor pressure with temperature
s.dqdT = eps/(densA*R)*(SATVPLIQUID(Tprof)./Tprof.^2 - Tprof.^(-1).*SATVPLIQDERIV(Tprof));
sT.dqdT = repmat(eps/(densA*R)*(SATVPLIQUID(Tprof(1:3,:))./Tprof(1:3,:).^2 - ...
    Tprof(1:3,:).^(-1).*SATVPLIQDERIV(Tprof(1:3,:))),2,1);
sRH.dqdT = eps/(densA*R)*(SATVPLIQUID(Tprof)./Tprof.^2 - Tprof.^(-1).*SATVPLIQDERIV(Tprof));
sA.dqdT = eps/(densA*R)*(SATVPLIQUID(tropicTemp)./tropicTemp.^2 - ...
    tropicTemp.^(-1).*SATVPLIQDERIV(tropicTemp));
s1T.dqdT = eps/(densA*R)*(SATVPLIQUID(Tprof1)./Tprof1.^2 - Tprof1.^(-1).*SATVPLIQDERIV(Tprof1));
s1RH.dqdT = eps/(densA*R)*(SATVPLIQUID(Tprof)./Tprof.^2 - Tprof.^(-1).*SATVPLIQDERIV(Tprof));

% beta coefficients
s.beta = (cp + HEATvap(Tprof).*s.dqdT)./1000;
sT.beta = (cp + HEATvap(repmat(Tprof(1:3,:),2,1)).*sT.dqdT)./1000;
sRH.beta = (cp + HEATvap(Tprof).*sRH.dqdT)./1000;
sA.beta = (cp + HEATvap(tropicTemp).*sA.dqdT)./1000;
s1T.beta = (cp + HEATvap(Tprof1).*s1T.dqdT)./1000;
s1RH.beta = (cp + HEATvap(Tprof).*s1RH.dqdT)./1000;

g = 9.8;
ent = 0.5./z;   % 1./z
Ra = 286.9;     % gas constant of dry air [J kg-1 K-1]

% saturation vapor mixing ratio
s.qvsat = SATVPLIQUID(Tprof)./(press - SATVPLIQUID(Tprof)).*MWw/MWa; 
sT.qvsat = repmat(SATVPLIQUID(Tprof(1:3,:))./(press - ...
    SATVPLIQUID(Tprof(1:3,:))).*MWw/MWa,2,1);
sRH.qvsat = SATVPLIQUID(Tprof)./(press - SATVPLIQUID(Tprof)).*MWw/MWa;
sA.qvsat = SATVPLIQUID(tropicTemp)./(press - SATVPLIQUID(tropicTemp)).*MWw/MWa;
s1T.qvsat = SATVPLIQUID(Tprof1)./(press - SATVPLIQUID(Tprof1)).*MWw/MWa; 
s1RH.qvsat = SATVPLIQUID(Tprof)./(press - SATVPLIQUID(Tprof)).*MWw/MWa;

% relative humidity
s.RH = qvprof./s.qvsat;
sT.RH = qvprof./s.qvsat;
sRH.RH = repmat(qvprof(1:3,:),2,1)./sT.qvsat;
sA.RH = tropicqv./sA.qvsat;
s1T.RH = qvprof./s.qvsat;
s1RH.RH = qvprof1./s1T.qvsat;

% integrand
s.integ = ent.*HEATvap(Tprof).*(1 - s.RH).*s.qvsat;
sT.integ = ent.*HEATvap(repmat(Tprof(1:3,:),2,1)).*(1 - sT.RH).*sT.qvsat;
sRH.integ = ent.*HEATvap(Tprof).*(1 - sRH.RH).*sRH.qvsat;
sA.integ = ent.*HEATvap(tropicTemp).*(1 - sA.RH).*sA.qvsat;
s1T.integ = ent.*HEATvap(Tprof1).*(1 - s1T.RH).*s1T.qvsat;
s1RH.integ = ent.*HEATvap(Tprof).*(1 - s1RH.RH).*s1RH.qvsat;

% vertical integrated saturation deficit
s.visd = fliplr(cumtrapz(fliplr(z),fliplr(s.integ),2));
sT.visd = fliplr(cumtrapz(fliplr(z),fliplr(sT.integ),2));
sRH.visd = fliplr(cumtrapz(fliplr(z),fliplr(sRH.integ),2));
sA.visd = fliplr(cumtrapz(fliplr(z),fliplr(sA.integ),2));
s1T.visd = fliplr(cumtrapz(fliplr(z),fliplr(s1T.integ),2));
s1RH.visd = fliplr(cumtrapz(fliplr(z),fliplr(s1RH.integ),2));

% buoyancy
% s.buoy = g*(s.beta.*1000).^(-1).*s.visd./Tprof; 
% sT.buoy = g*(sT.beta.*1000).^(-1).*sT.visd./repmat(Tprof(1:3,:),2,1);
% sRH.buoy = g*(sRH.beta.*1000).^(-1).*sRH.visd./Tprof;
% sA.buoy = g*(sA.beta.*1000).^(-1).*sA.visd./tropicTemp;
% s1T.buoy = g*(s1T.beta.*1000).^(-1).*s1T.visd./Tprof1;

s.buoy = g*(1000).^(-1).*s.visd./Tprof; 
sT.buoy = g*(1000).^(-1).*sT.visd./repmat(Tprof(1:3,:),2,1);
sRH.buoy = g*(1000).^(-1).*sRH.visd./Tprof;
sA.buoy = g*(1000).^(-1).*sA.visd./tropicTemp;
s1T.buoy = g*(1000).^(-1).*s1T.visd./Tprof1;

clear cp densA densMA densWV dqdT ent ent2 eps fid g 
clear MWa MWw R Ra

%%
clf
fig = figure(10);
set(fig,'PaperUnits','inches','PaperOrientation','landscape',...
    'PaperPosition',[0.1,0.1,11,8],'PaperUnits','inches')

fs = 13;
subplot_tight(2,3,1,[0.1,0.04])
plot(s.buoy(1,:),z./1000,'linewidth',1.5,'color','b')
hold on
plot(s.buoy(2,:),z./1000,'linewidth',1.5,'color',[0 0.5 0])
plot(s.buoy(3,:),z./1000,'linewidth',1.5,'color','r')
plot(s.buoy(4,:),z./1000,'linewidth',1.5,'color','b','linestyle','--')
plot(s.buoy(5,:),z./1000,'linewidth',1.5,'color',[0 0.5 0],'linestyle','--')
plot(s.buoy(6,:),z./1000,'linewidth',1.5,'color','r','linestyle','--')
plot(sA.buoy,z./1000,'linewidth',0.5,'color','k')
text(0.05,14.5,'\bf{a}','fontsize',fs+4)
ylim([0,15])
xlabel('Buoyancy [K]');
ylabel('Z [km]')
set(gca,'FontSize',fs)

subplot_tight(2,3,2,[0.1,0.04])
plot(s.visd(1,:)./1000,z./1000,'linewidth',1.5,'color','b')
hold on
plot(s.visd(2,:)./1000,z./1000,'linewidth',1.5,'color',[0 0.5 0])
plot(s.visd(3,:)./1000,z./1000,'linewidth',1.5,'color','r')
plot(s.visd(4,:)./1000,z./1000,'linewidth',1.5,'color','b','linestyle','--')
plot(s.visd(5,:)./1000,z./1000,'linewidth',1.5,'color',[0 0.5 0],'linestyle','--')
plot(s.visd(6,:)./1000,z./1000,'linewidth',1.5,'color','r','linestyle','--')
plot(sA.visd./1000,z./1000,'linewidth',0.5,'color','k')
text(0.05,14.5,'\bf{b}','fontsize',fs+4)
ylim([0,15])
xlabel('Integrated saturation deficit [kg m^{-2}]');
set(gca,'fontsize',fs)

ax1 = axes('Position',[0.4 0.715 0.06 0.15]);
plot((s.visd(1,:)-s.visd(4,:))./1000,z./1000,'linewidth',1.5,'color','b')
hold on
plot((s.visd(2,:)-s.visd(5,:))./1000,z./1000,'linewidth',1.5,'color',[0 0.5 0])
plot((s.visd(3,:)-s.visd(6,:))./1000,z./1000,'linewidth',1.5,'color','r')
plot([0,0],[0,15],'k','linestyle','--')
ylabel('Z')
xlabel('EN-LN \Delta SD')
ylim([0,15])
% xlim([-1,4.2])
set(gca,'fontsize',fs-3)

subplot_tight(2,3,3,[0.1,0.04])
plot(s.beta(1,:),z./1000,'linewidth',1.5,'color','b')
hold on
plot(s.beta(2,:),z./1000,'linewidth',1.5,'color',[0 0.5 0])
plot(s.beta(3,:),z./1000,'linewidth',1.5,'color','r')
plot(s.beta(4,:),z./1000,'linewidth',1.5,'color','b','linestyle','--')
plot(s.beta(5,:),z./1000,'linewidth',1.5,'color',[0 0.5 0],'linestyle','--')
plot(s.beta(6,:),z./1000,'linewidth',1.5,'color','r','linestyle','--')
plot(sA.beta,z./1000,'linewidth',0.5,'color','k')
plot([1.008,1.008],[0,15],'color','k','linestyle','--')
plot([0,1.011],[9.45,9.45],'color','k','linestyle','--')
xlabel('\beta [kJ kg^{-1} K^{-1}]')
text(0.6,1.5,'c_p','fontsize',12)
text(0.15,14.5,'\bf{c}','fontsize',fs+4)
ylim([0,15])
set(gca,'fontsize',fs)

ax1 = axes('Position',[0.82 0.7 0.08 0.17]);
plot(s.beta(1,:)-s.beta(4,:),z./1000,'linewidth',1.5,'color','b')
hold on
plot(s.beta(2,:)-s.beta(5,:),z./1000,'linewidth',1.5,'color',[0 0.5 0])
plot(s.beta(3,:)-s.beta(6,:),z./1000,'linewidth',1.5,'color','r')
ylabel('Z')
xlabel('EN-LN \Delta\beta')
ylim([0,15])
set(gca,'fontsize',fs-3)

subplot_tight(2,6,8:9,[0.1,0.04])
plot(sRH.buoy(1,:)-sRH.buoy(4,:),z./1000,'linewidth',1.5,'color','c')
hold on
plot(sRH.buoy(2,:)-sRH.buoy(5,:),z./1000,'linewidth',1.5,'color','g')
plot(sRH.buoy(3,:)-sRH.buoy(6,:),z./1000,'linewidth',1.5,'color',[1 0.6 0.4])
plot(sT.buoy(1,:)-sT.buoy(4,:),z./1000,'linewidth',1.5,'color',[0 0 0.25])
plot(sT.buoy(2,:)-sT.buoy(5,:),z./1000,'linewidth',1.5,'color',[0 0.25 0])
plot(sT.buoy(3,:)-sT.buoy(6,:),z./1000,'linewidth',1.5,'color',[0.25 0 0])
plot(s.buoy(1,:)-s.buoy(4,:),z./1000,'linewidth',1.5,'color','b')
plot(s.buoy(2,:)-s.buoy(5,:),z./1000,'linewidth',1.5,'color',[0 0.5 0])
plot(s.buoy(3,:)-s.buoy(6,:),z./1000,'linewidth',1.5,'color','r')
plot([0 0],[0,15],'k','linestyle','--')
text(0.05,0.925,'\bf{d}','fontsize',fs+4,'units','normalized')
ylim([0,15]); xlim([-0.15 0.15])
xlabel('EN-LN \Delta Buoyancy [K]');
ylabel('Z [km]')
rectangle('Position',[0.05 6 0.02 0.75],'FaceColor','b','EdgeColor','w')
rectangle('Position',[0.075 6 0.02 0.75],'FaceColor',[0 0.5 0],'EdgeColor','w')
rectangle('Position',[0.1 6 0.02 0.75],'FaceColor','r','EdgeColor','w')
text(0.05,5.5,'Combined','fontsize',11)
rectangle('Position',[0.05 4 0.02 0.75],'FaceColor',[0 0 0.25],'EdgeColor','w')
rectangle('Position',[0.075 4 0.02 0.75],'FaceColor',[0 0.25 0],'EdgeColor','w')
rectangle('Position',[0.1 4 0.02 0.75],'FaceColor',[0.25 0 0],'EdgeColor','w')
text(0.05,3.5,'Effect of RH','fontsize',11)
rectangle('Position',[0.05 2 0.02 0.75],'FaceColor','c','EdgeColor','w')
rectangle('Position',[0.075 2 0.02 0.75],'FaceColor','g','EdgeColor','w')
rectangle('Position',[0.1 2 0.02 0.75],'FaceColor',[1 0.6 0.4],'EdgeColor','w')
text(0.05,1.5,'Effect of T','fontsize',11)
set(gca,'fontsize',fs)

subplot_tight(2,6,10:11,[0.1,0.04])
plot(s1RH.buoy(2,:)-s.buoy(2,:),z./1000,'linewidth',1.5,'color','g')
hold on
plot(s1RH.buoy(1,:)-s.buoy(1,:),z./1000,'linewidth',1.5,'color','c')
plot(s1RH.buoy(5,:)-s.buoy(5,:),z./1000,'linewidth',1.5,'color','g','linestyle','--')
plot(s1RH.buoy(4,:)-s.buoy(4,:),z./1000,'linewidth',1.5,'color','c','linestyle','--')
plot(s1T.buoy(2,:)-s.buoy(2,:),z./1000,'linewidth',1.5,'color',[0 0.25 0])
plot(s1T.buoy(1,:)-s.buoy(1,:),z./1000,'linewidth',1.5,'color',[0 0 0.25])
plot(s1T.buoy(5,:)-s.buoy(5,:),z./1000,'linewidth',1.5,'color',[0 0.25 0],'linestyle','--')
plot(s1T.buoy(4,:)-s.buoy(4,:),z./1000,'linewidth',1.5,'color',[0 0 0.25],'linestyle','--')
plot([0 0],[0,15],'k','linestyle','--')
text(0.05,0.925,'\bf{e}','fontsize',fs+4,'units','normalized')
ylim([0,15]); xlim([-1 1])
xlabel('System depth-separated \Delta Buoyancy [K]');
rectangle('Position',[0.5 4 0.12 0.65],'FaceColor',[0 0 0.25],'EdgeColor','w')
rectangle('Position',[0.65 4 0.12 0.65],'FaceColor',[0 0.25 0],'EdgeColor','w')
text(0.5,3.5,'Effect of RH','fontsize',11)
rectangle('Position',[0.5 2 0.12 0.65],'FaceColor','c','EdgeColor','w')
rectangle('Position',[0.65 2 0.12 0.65],'FaceColor','g','EdgeColor','w')
text(0.5,1.5,'Effect of T','fontsize',11)
set(gca,'fontsize',fs)

% print(gcf,'-dpdf','-r250','ZBP-calcs')
