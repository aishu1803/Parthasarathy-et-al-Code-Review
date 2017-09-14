% This script generates fig 2 in Parthasarathy et al. Please feel free to
% contact me (Aishwarya Parthasarathy) at aishu.parth@gmail.com

clear all;
close all;
% Loading the spike count dataset used in the paper. Please change the path
% of the folder accordingly.
load('/Users/aishp/Documents/Data/dataset_overlapbins_fefdl.mat');
load('/Users/aishp/Documents/Data/color_map_fig2.mat')
% As the code takes a while to run (each iteration can take about 30-150 seconds depending
% on the analysis and we have 1000 iterations), we also have a folder with
% all the intermediate results saved. You can choose to run it for a few
% iterations to check the algorithm and opt to use the intermediate
% results. The intermediate results are in a separate folder (called Inter
% Results) in the Data folder. You can choose to add it to the path in case
% you want to work with the saved results.
% Change the path to Inter folder 
% Comment these lines in case you want dont want to use the saved dataset.
if exist('/Users/aishp/Documents/Data/perf_mat.mat','file')
    load('/Users/aishp/Documents/Data/perf_mat.mat')
end

%% Generating the cross-temporal decoding performance results for n bootstraps

N_bootstraps = 1000; % Number of bootstraps
bins = -300:50:2600;% Defining the bins to compute the decoding performance
bins(2,:) = bins(1,:)+100;
Trial_Label = 'target'; % Trial labels to decode. Could be target or distractor.
% In the paper, for Fig 2, target locations are decoded.

% Check if the variables containing the decoding results
% already exist in the workspace. If it does, it only runs
% the code, if the variable contains decoding performance from less than
% 1000 iterations. In case you choose to load the intermediate result from
% the data folder, this entire code section will be skipped as the intermediate
% result has data from 1000 iterations.
if ~(exist('perf_cc_dl','var') && exist('perf_cc_fef','var'))
    for i_boot = 1:N_bootstraps
        tic
        % Deccoding target labels from LPFC data
        perf_cc_dl(i_boot,:,:) = Decode_final_temporal_v2(dataset_dl,m_dl,st_dl,session_dl,Trial_Label,trials,bins,etrials,dataset_e_dl,m_e_dl,st_e_dl,'Correct');
        % Decoding target labels from FEF data
        perf_cc_fef(i_boot,:,:) = Decode_final_temporal_v2(dataset,m,st,session,Trial_Label,trials,bins,etrials,dataset_e,m_e,st_e,'Correct');
        toc
        % saving data every 100 iterations, incase of power outage or if
        % MATLAB crashes. You can choose to comment these lines.
        if rem(i_boot,100)==0
            save('perf_mat','perf_cc_dl','perf_cc_fef','-v7.3');
        end
    end
    % The next few lines of code will be executed if the variables of interest
    % do not contain data from all 1000 iterations
elseif size(perf_cc_dl,1) < 1000 || size(perf_cc_fef,1) < 1000
   
    if size(perf_cc_dl,1)==size(perf_cc_fef,1)
        for i_boot = size(perf_cc_dl,1)+1:N_bootstraps
            tic
            perf_cc_dl(i_boot,:,:) = Decode_final_temporal_v2(dataset_dl,m_dl,st_dl,session_dl,Trial_Label,trials,bins,etrials,dataset_e_dl,m_e_dl,st_e_dl,'Correct');
            perf_cc_fef(i_boot,:,:) = Decode_final_temporal_v2(dataset,m,st,session,Trial_Label,trials,bins,etrials,dataset_e,m_e,st_e,'Correct');
            toc
            if rem(i_boot,100)==0
                save('perf_mat','perf_cc_dl','perf_cc_fef','-v7.3');
            end
        end
    else
        for i_boot = size(perf_cc_dl,1)+1:N_bootstraps
            tic
            perf_cc_dl(i_boot,:,:) = Decode_final_temporal_v2(dataset_dl,m_dl,st_dl,session_dl,Trial_Label,trials,bins,etrials,dataset_e_dl,m_e_dl,st_e_dl,'Correct');
            toc
            if rem(i_boot,100)==0
                save('perf_mat','perf_cc_dl','perf_cc_fef','-v7.3');
            end
        end
        for i_boot = size(perf_cc_fef,1)+1:N_bootstraps
            tic
            perf_cc_fef(i_boot,:,:) = Decode_final_temporal_v2(dataset,m,st,session,Trial_Label,trials,bins,etrials,dataset_e,m_e,st_e,'Correct');
            toc
            if rem(i_boot,100)==0
                save('perf_mat','perf_cc_dl','perf_cc_fef','-v7.3');
            end
        end
    end
end

%% Computes change in performance (fig 2b,2f)
for i = 1:size(perf_cc_dl,1)
    for j = 1:size(perf_cc_dl,2)
        for k = 1:size(perf_cc_dl,3)-3
            diff_perf_dl(i,j,k) = perf_cc_dl(i,j,k) - perf_cc_dl(i,j,k+3); % difference in performance between time windows t and t+3
            diff_perf_fef(i,j,k) = perf_cc_fef(i,j,k) - perf_cc_fef(i,j,k+3);
        end
    end
end

%% Computes the average performance in Delay 1 and Delay 2 (for fig 2c,g)
delay_1_on = find(bins(2,:)==850);
delay_1_off = find(bins(2,:)==1350);
delay_2_on = find(bins(2,:)==1850);
delay_2_off = find(bins(2,:)==2350);
tr_delay1_dl = squeeze(mean(mean(perf_cc_dl(:,delay_1_on:delay_1_off,:),1),2));
tr_delay2_dl = squeeze(mean(mean(perf_cc_dl(:,delay_2_on:delay_2_off,:),1),2));
tr_delay1_fef = squeeze(mean(mean(perf_cc_fef(:,delay_1_on:delay_1_off,:),1),2));
tr_delay2_fef = squeeze(mean(mean(perf_cc_fef(:,delay_2_on:delay_2_off,:),1),2));

%% Fits for figure 2d and 2g
% Average LPFC performance in 4 quadrants (LP11,LP12,LP21,LP22)
tr_d11_dl = squeeze(mean(perf_cc_dl(:,delay_1_on:delay_1_off,delay_1_on:delay_1_off),2));
tr_d12_dl = squeeze(mean(perf_cc_dl(:,delay_1_on:delay_1_off,delay_2_on:delay_2_off),2));
tr_d21_dl = squeeze(mean(perf_cc_dl(:,delay_2_on:delay_2_off,delay_1_on:delay_1_off),2));
tr_d22_dl = squeeze(mean(perf_cc_dl(:,delay_2_on:delay_2_off,delay_2_on:delay_2_off),2));
% Average FEF performance in 4 quadrants (FP11,FP12,FP21,FP22)
tr_d11_fef = squeeze(mean(perf_cc_fef(:,delay_1_on:delay_1_off,delay_1_on:delay_1_off),2));
tr_d12_fef = squeeze(mean(perf_cc_fef(:,delay_1_on:delay_1_off,delay_2_on:delay_2_off),2));
tr_d21_fef = squeeze(mean(perf_cc_fef(:,delay_2_on:delay_2_off,delay_1_on:delay_1_off),2));
tr_d22_fef = squeeze(mean(perf_cc_fef(:,delay_2_on:delay_2_off,delay_2_on:delay_2_off),2));
% Fits for LPFc and FEF performance for all 4 quadrants.
for i = 1:size(tr_d11_dl,1)
    f_d11_dl = fit(bins(1,delay_1_on:delay_1_off)',tr_d11_dl(i,:)','poly1');
    p1_d11_dl(i) = f_d11_dl.p1;
    f_d12_dl = fit(bins(1,delay_2_on:delay_2_off)',tr_d12_dl(i,:)','poly1');
    p1_d12_dl(i) = f_d12_dl.p1;
    f_d22_dl = fit(bins(1,delay_2_on:delay_2_off)',tr_d22_dl(i,:)','poly1');
    p1_d22_dl(i) = f_d22_dl.p1;
    f_d21_dl = fit(bins(1,delay_1_on:delay_1_off)',tr_d21_dl(i,:)','poly1');
    p1_d21_dl(i) = f_d21_dl.p1;
    f_d11_fef = fit(bins(1,delay_1_on:delay_1_off)',tr_d11_fef(i,:)','poly1');
    p1_d11_fef(i) = f_d11_fef.p1;
    f_d12_fef = fit(bins(1,delay_2_on:delay_2_off)',tr_d12_fef(i,:)','poly1');
    p1_d12_fef(i) = f_d12_fef.p1;
    f_d22_fef = fit(bins(1,delay_2_on:delay_2_off)',tr_d22_fef(i,:)','poly1');
    p1_d22_fef(i) = f_d22_fef.p1;
    f_d21_fef = fit(bins(1,delay_1_on:delay_1_off)',tr_d21_fef(i,:)','poly1');
    p1_d21_fef(i) = f_d21_fef.p1;
    
end

%% Generating fig 2a and 2e
figure % New figure
Ticks = find(bins(1,:)==0 | bins(1,:)==300 | bins(1,:)==1300 | bins(1,:)==1600); % Target and Distractor onset and offset
% figure 2a(LPFC)
ax1 = subplot('Position',[0.045,0.65,0.20,0.275]);
imagesc(squeeze(mean(perf_cc_dl)),[7 65]) % Plots the heatmap
% Plots the lines denoting target/distractor onset and offset
for i_line = 1:length(Ticks)
    line([Ticks(i_line) Ticks(i_line)],ylim,'color','white')
    line(xlim,[Ticks(i_line) Ticks(i_line)],'color','white')
end
% Axes and Colorbar properties
set(ax1,'XTick',Ticks,'YTick',Ticks,'XTickLabel',{'0','0.3','1.3','1.6'},'YTickLabel',{'0','0.3','1.3','1.6'},'FontSize',6,'FontName','Helvetica','ydir','normal')
c = colorbar('Southoutside','Ticks',[10 20 30 40 50 60],'TickLabels',{'10','20','30','40','50','60'},'FontName','Helvetica','FontSize',6);
set(c,'Position',[0.045 0.575 0.20 0.020]);
c.Label.String = 'Performance (%)';
colormap(ax1,cmap) % Plots heatmap in desired colormap defined by cmap
xlabel('Testing Windows aligned to Target Onset (s)','FontSize',6,'FontName','Helvetica')
ylabel('Training Windows aligned to Target Onset (s)','FontSize',6,'FontName','Helvetica')

% Figure 2e (FEF)
ax2 = subplot('Position',[0.045,0.15,0.20,0.275]);
imagesc(squeeze(mean(perf_cc_fef)),[7 65])
for i_line = 1:length(Ticks)
    line([Ticks(i_line) Ticks(i_line)],ylim,'color','white')
    line(xlim,[Ticks(i_line) Ticks(i_line)],'color','white')
end
set(ax2,'XTick',Ticks,'YTick',Ticks,'XTickLabel',{'0','0.3','1.3','1.6'},'YTickLabel',{'0','0.3','1.3','1.6'},'FontSize',6,'FontName','Helvetica','ydir','normal')
c = colorbar('Southoutside','Ticks',[10 20 30 40 50 60],'TickLabels',{'10','20','30','40','50','60'},'FontName','Helvetica','FontSize',6);
set(c,'Position',[0.045 0.075 0.20 0.020]);
c.Label.String = 'Performance (%)';
colormap(ax2,cmap)
xlabel('Testing Windows aligned to Target Onset (s)','FontSize',6,'FontName','Helvetica')
ylabel('Training Windows aligned to Target Onset (s)','FontSize',6,'FontName','Helvetica')

%% Generating fig 2b and 2f

%Figure 2b(LPFC) - difference in performance
ax3 = subplot('Position',[0.295,0.65,0.20,0.275]);
imagesc(squeeze(mean(diff_perf_dl)),[-40 30])
for i_line = 1:length(Ticks)
    line([Ticks(i_line) Ticks(i_line)],ylim,'color','white')
    line(xlim,[Ticks(i_line) Ticks(i_line)],'color','white')
end
set(ax3,'XTick',Ticks,'YTick',Ticks,'XTickLabel',{'0','0.3','1.3','1.6'},'YTickLabel',{'0','0.3','1.3','1.6'},'FontSize',6,'FontName','Helvetica','ydir','normal')
c = colorbar('Southoutside','Ticks',[-40 -20 0 20],'TickLabels',{'-40','-20','0','20'},'FontName','Helvetica','FontSize',6);
c.Label.String = 'Performance (%)';
colormap(ax3,cmap2)
xlabel('Testing Windows (s)','FontSize',6,'FontName','Helvetica')
ylabel('Training Windows (s)','FontSize',6,'FontName','Helvetica')
set(c,'Position',[0.295 0.575 0.20 0.020]);

% Figure 2f (FEF) - difference in performance
ax4 = subplot('Position',[0.295,0.15,0.20,0.275]);
imagesc(squeeze(mean(diff_perf_fef)),[-40 30]);
for i_line = 1:length(Ticks)
    line([Ticks(i_line) Ticks(i_line)],ylim,'color','white')
    line(xlim,[Ticks(i_line) Ticks(i_line)],'color','white')
end
set(ax4,'XTick',Ticks,'YTick',Ticks,'XTickLabel',{'0','0.3','1.3','1.6'},'YTickLabel',{'0','0.3','1.3','1.6'},'FontSize',6,'FontName','Helvetica','ydir','normal')
c = colorbar('Southoutside','Ticks',[-40 -20 0 20],'TickLabels',{'-40','-20','0','20'},'FontName','Helvetica','FontSize',6);
c.Label.String = 'Performance (%)';
colormap(ax4,cmap2)
xlabel('Testing Windows (s)','FontSize',6,'FontName','Helvetica')
ylabel('Training Windows (s)','FontSize',6,'FontName','Helvetica')
set(c,'Position',[0.295 0.075 0.20 0.020]);

%% Generating fig 2c and 2g

% Figure 2c (LPFC) - Illustrative fit
ax5 = subplot('Position',[0.55,0.65,0.175,0.275]);
p1 = plot(bins(2,1:58),tr_delay1_dl,'color','blue','DisplayName','Trained in Delay 1');
hold on
p2 = plot(bins(2,1:58),tr_delay2_dl,'color','m','DisplayName','Trained in Delay 2');
set(ax5,'XTick',[0 300 1300 1600],'XTickLabel',{'0','0.3','1.3','1.6'},'FontSize',6,'FontName','Helvetica','ydir','normal','Box','off')
xlabel('Time from Target Onset (s)','FontSize',6,'FontName','Helvetica')
ylabel('Performance (%)','FontSize',6,'FontName','Helvetica')
xlim([-400 2600]),ylim([10 60])
% Plots the lines for target/distractor onset and offset
line([0 0],ylim,'color','black','LineStyle',':')
line([300 300],ylim,'color','black','LineStyle',':')
line([1300 1300],ylim,'color','black','LineStyle',':')
line([1600 1600],ylim,'color','black','LineStyle',':')
line([bins(2,delay_1_on) bins(2,delay_1_off)],[tr_delay1_dl(delay_1_on) tr_delay1_dl(delay_1_off)],'color','b','LineWidth',3)
line([bins(2,delay_2_on) bins(2,delay_2_off)],[tr_delay1_dl(delay_2_on) tr_delay1_dl(delay_2_off)],'color','b','LineWidth',3)
line([bins(2,delay_2_on) bins(2,delay_2_off)],[tr_delay2_dl(delay_2_on) tr_delay2_dl(delay_2_off)],'color','m','LineWidth',3)
line([bins(2,delay_1_on) bins(2,delay_1_off)],[tr_delay2_dl(delay_1_on) tr_delay2_dl(delay_1_off)],'color','m','LineWidth',3)
legend([p1 p2],'Location','southeast')
legend('boxoff')

%Figure 2g (FEF) - Illustrative fit
ax6 = subplot('Position',[0.55,0.15,0.175,0.275]);
p3 = plot(bins(2,1:58),tr_delay1_fef,'color','blue','DisplayName','Trained in Delay 1');
hold on
p4 = plot(bins(2,1:58),tr_delay2_fef,'color','m','DisplayName','Trained in Delay 2');
set(ax6,'XTick',[0 300 1300 1600],'XTickLabel',{'0','0.3','1.3','1.6'},'FontSize',6,'FontName','Helvetica','ydir','normal','Box','off')
xlabel('Time from Target Onset (s)','FontSize',6,'FontName','Helvetica')
ylabel('Performance (%)','FontSize',6,'FontName','Helvetica')
xlim([-400 2600]),ylim([10 60])
line([0 0],ylim,'color','black','LineStyle',':')
line([300 300],ylim,'color','black','LineStyle',':')
line([1300 1300],ylim,'color','black','LineStyle',':')
line([1600 1600],ylim,'color','black','LineStyle',':')
line([bins(2,delay_1_on) bins(2,delay_1_off)],[tr_delay1_fef(delay_1_on) tr_delay1_fef(delay_1_off)],'color','b','LineWidth',3)
line([bins(2,delay_2_on) bins(2,delay_2_off)],[tr_delay1_fef(delay_2_on) tr_delay1_fef(delay_2_off)],'color','b','LineWidth',3)
line([bins(2,delay_2_on) bins(2,delay_2_off)],[tr_delay2_fef(delay_2_on) tr_delay2_fef(delay_2_off)],'color','m','LineWidth',3)
line([bins(2,delay_1_on) bins(2,delay_1_off)],[tr_delay2_fef(delay_1_on) tr_delay2_fef(delay_1_off)],'color','m','LineWidth',3)
legend([p3 p4],'Location','southeast')
legend('boxoff')

%% Generating figure 2d and 2h
% Fig 2d - Slope of the fits - LPFC
ax7 = subplot('Position',[0.775,0.65,0.175,0.275]);
boxplot([p1_d11_dl' p1_d12_dl' p1_d21_dl' p1_d22_dl']*10^3,'notch','on','whisker',1.2,'symbol','','colors',[0.4 0.4 0.4],'Positions',[0.85 1.15 1.85 2.15])
set(gca,'Box','off')
set(findobj(gcf,'LineStyle','--'),'LineStyle','-','color','black')
xlabel('Trained in Delay 1/Delay 2','FontSize',6,'FontName','Helvetica')
ylabel('Slope of the curve (%/s)','FontSize',6,'FontName','Helvetica')
set(ax7,'XTick',[0.85 1.15 1.85 2.15],'XTickLabel',{'LP11','LP12','LP21','LP22'},'FontSize',6,'FontName','Helvetica','ydir','normal','Box','off')

lines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(lines,'color','r')
ylim([-30 40])

% Figure 2h - Slope of the fits - FEF
ax8 = subplot('Position',[0.775,0.15,0.175,0.275]);
boxplot([p1_d11_fef' p1_d12_fef' p1_d21_fef' p1_d22_fef']*10^3,'notch','on','whisker',1.2,'symbol','','colors',[0.4 0.4 0.4],'Positions',[0.85 1.15 1.85 2.15])
set(gca,'Box','off')
set(findobj(gcf,'LineStyle','--'),'LineStyle','-','color','black')
xlabel('Trained in Delay 1/Delay 2','FontSize',6,'FontName','Helvetica')
ylabel('Slope of the curve (%/s)','FontSize',6,'FontName','Helvetica')
set(ax8,'XTick',[0.85 1.15 1.85 2.15],'XTickLabel',{'FP11','FP12','FP21','FP22'},'FontSize',6,'FontName','Helvetica','ydir','normal','Box','off')
ylim([-30 40])
lines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(lines,'color','r')

% Titles for all the figures.
axis = axes('Position',[0 0 1 1],'Visible','off')
text(axis,0.145,0.98,'Cross-temporal decoding','FontName','Helvetica','FontSize',7,'FontWeight','Bold','HorizontalAlignment','center')
text(axis,0.395,0.98,'Change in performance','FontName','Helvetica','FontSize',7,'FontWeight','Bold','HorizontalAlignment','center')
text(axis,0.6375 ,0.98 ,{'Average performance of the','decoder'},'FontName','Helvetica','FontSize',7,'FontWeight','Bold','HorizontalAlignment','center')
text(axis,0.8625,0.98 ,{'Slope of the decoder','performance','at different time points'},'FontName','Helvetica','FontSize',7,'FontWeight','Bold','HorizontalAlignment','center')
text(axis,0.5,0.96,{'LPFC (n = 256 neurons)'},'FontName','Helvetica','FontSize',7,'FontWeight','Bold','HorizontalAlignment','center')
text(axis,0.5,0.48,{'FEF (n = 256 neurons)'},'FontName','Helvetica','FontSize',7,'FontWeight','Bold','HorizontalAlignment','center')
