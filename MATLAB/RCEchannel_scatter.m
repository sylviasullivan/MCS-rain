c = 1;  % counter
prALLM = struct(); sdALLM = struct(); capeALLM = struct();
prALL95 = struct(); sdALL95 = struct(); capeALL95 = struct();
prALL99 = struct(); sdALL99 = struct(); capeALL99 = struct();

for ii = 5400:1800:72000
    disp(strcat(num2str(c),' of 37.'))
    
    % convert the iterator to a string
    iistr = num2str(ii);
    
    % calculate the length of that string
    iilen = size(iistr,2);
    
    % all files have a timestamp of 10 characters so calculate the diff
    % in character count from 10.
    add0 = 10 - iilen;
    
    % use that difference to generate a format string for leading zeros.
    fmt = strcat('%0',num2str(add0),'d');
    nothing = sprintf(fmt,0);
    
    % append the leading zeros
    fullstamp = strcat(nothing,iistr);
    [pr,sd,cape] = rceVars_2(fullstamp,12,0);
    prALLM.(strcat('pr',num2str(c))) = pr.M;
    sdALLM.(strcat('sd',num2str(c))) = sd.M;
    capeALLM.(strcat('cape',num2str(c))) = cape.M;
    
    prALL95.(strcat('pr',num2str(c))) = pr.p95;
    sdALL95.(strcat('sd',num2str(c))) = sd.p95;
    capeALL95.(strcat('cape',num2str(c))) = cape.p95;
    
    prALL99.(strcat('pr',num2str(c))) = pr.p99;
    sdALL99.(strcat('sd',num2str(c))) = sd.p99;
    capeALL99.(strcat('cape',num2str(c))) = cape.p99;

    c = c + 1;
end

clear c add0 cape pr sd fullstamp fmt ii iilen iistr nothing
%%
clf
figure(3)
fs = 14; x1 = 0; x2 = 6; y1 = 200; y2 = 3000; y3 = 0; y4 = 3.5; sz = 15;

subplot_tight(2,3,1,[0.09,0.05])
hold on
for i = 1:10
    scatter(sdALLM.(strcat('sd',num2str(i))),capeALL99.(strcat('cape',num2str(i)))/8,...
        sz,'filled','b','markerfacealpha',0.75)
end
ylabel('CAPE$^{(99)}$','interpreter','latex')
xlabel('$\overline{<S_D>}$','interpreter','latex')
text(0.01,0.93,'\bf{(a)}','fontsize',fs+2,'units','normalized')
xlim([x1,x2]); ylim([y1,y2])
set(gca,'fontsize',fs)

subplot_tight(2,3,2,[0.09,0.05])
hold on
for i = 1:37
    scatter(sdALLM.(strcat('sd',num2str(i))),capeALL95.(strcat('cape',num2str(i)))/8,...
        sz,'filled','b','markerfacealpha',0.75)
end
ylabel('CAPE$^{(95)}$','interpreter','latex')
xlabel('$\overline{<S_D>}$','interpreter','latex')
text(0.01,0.93,'\bf{(b)}','fontsize',fs+2,'units','normalized')
xlim([x1,x2]); ylim([y1,y2])
set(gca,'fontsize',fs)

subplot_tight(2,3,3,[0.09,0.05])
hold on
for i = 1:37
    scatter(sdALLM.(strcat('sd',num2str(i))),capeALLM.(strcat('cape',num2str(i)))/8,...
        sz,'filled','b','markerfacealpha',0.75)
end
ylabel('$\overline{CAPE}$','interpreter','latex')
xlabel('$\overline{<S_D>}$','interpreter','latex')
text(0.01,0.93,'\bf{(c)}','fontsize',fs+2,'units','normalized')
xlim([x1,x2]); ylim([y1,y2])
set(gca,'fontsize',fs)

subplot_tight(2,3,4,[0.09,0.05])
hold on
for i = 1:37
    scatter(sdALLM.(strcat('sd',num2str(i))),prALL99.(strcat('pr',num2str(i))),...
        sz,'filled','b','markerfacealpha',0.75)
end
ylabel('$\dot{P}_z^{(99)}$','interpreter','latex')
xlabel('$\overline{<S_D>}$','interpreter','latex')
text(0.01,0.93,'\bf{(d)}','fontsize',fs+2,'units','normalized')
xlim([x1,x2]); ylim([y3,y4])
set(gca,'fontsize',fs)

subplot_tight(2,3,5,[0.09,0.05])
hold on
for i = 1:37
    scatter(sdALLM.(strcat('sd',num2str(i))),prALL95.(strcat('pr',num2str(i))),...
        sz,'filled','b','markerfacealpha',0.75)
end
ylabel('$\dot{P}_z^{(95)}$','interpreter','latex')
xlabel('$\overline{<S_D>}$','interpreter','latex')
text(0.01,0.93,'\bf{(e)}','fontsize',fs+2,'units','normalized')
xlim([x1,x2]); ylim([y3,y4])
set(gca,'fontsize',fs)

subplot_tight(2,3,6,[0.09,0.05])
hold on
for i = 1:37
    scatter(sdALLM.(strcat('sd',num2str(i))),prALLM.(strcat('pr',num2str(i))),...
        sz,'filled','b','markerfacealpha',0.75)
end
ylabel('$\overline{\dot{P}_z}$','interpreter','latex')
xlabel('$\overline{<S_D>}$','interpreter','latex')
text(0.01,0.93,'\bf{(f)}','fontsize',fs+2,'units','normalized')
xlim([x1,x2]); ylim([y3,y4])
set(gca,'fontsize',fs)

set(gcf,'paperunits','inches','PaperOrientation','landscape','PaperSize',[13 9])
print(gcf,'-dpdf','-fillpage','-r250','binning-by-sd-SIMS')