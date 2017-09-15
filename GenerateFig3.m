% This script generates fig 3 in Parthasarathy et al. Please feel free to
% contact me (Aishwarya Parthasarathy) at aishu.parth@gmail.com

clear all;
close all;
% Loading the spike count dataset used in the paper. Please change the path
% of the folder accordingly.
load('/Users/aishp/Documents/Data/dataset_overlapbins_fefdl.mat');
% Pre-processing data to obtain spike counts and mean beaseline value in 100ms windows (50ms step) from spike times
% For lpfc
[m_dl,st_dl,dataset_dl,dataset_e_dl,m_e_dl,st_e_dl] = PreProcess(dataset_lpfc,dataset_e_lpfc);
% For fef
[m,st,dataset,dataset_e,m_e,st_e] = PreProcess(dataset_fef,dataset_e_fef);
% As the code takes a while to run (each iteration can take about 30-150 seconds depending
% on the analysis and we have 1000 iterations), we also have a folder with
% all the intermediate results saved. You can choose to run it for a few
% iterations to check the algorithm and opt to use the intermediate
% results. The intermediate results are in a separate folder (called Inter
% Results) in the Data folder. You can choose to add it to the path in case
% you want to work with the saved results.
% Change the path to Inter folder 
% Comment these lines in case you want dont want to use the saved dataset.
if exist('/Users/aishp/Documents/Data/proj_mat.mat','file')
    load('/Users/aishp/Documents/Data/proj_mat.mat');
end

%% Generating the PCA projections for n bootstraps
% Check if the variable containing all the shift in cluster centers from the
% projections already exists in the workspace. If it does, it only runs
% the code, if the variable contains shifts from less than
% 1000 iterations. In case you choose to load the intermediate result from
% the data folder, this entire code section will be skipped as the intermediate
% result has data from 1000 iterations.

if ~(exist('shift_clusters_dl_d1','var') && exist('shift_clusters_fef_d1','var'))
    N_bootstraps = 1000; % Number of bootstraps
    bins = -300:50:2600;% Defining the bins to compute the decoding performance
    bins(2,:) = bins(1,:)+100;
    Trial_Label = 'target';% Trial labels to project. Could be target or distractor.
    % In the paper, for Fig 3, data from different target locations were projected
    % onto the PCA space.
    % Defines the time period to create Delay 1 and Delay 2 data and define
    % compute the average projections over which the shift in cluster centers
    % were computed.
    delay_1 = find(bins(2,:)==800);
    delay_1(2) = find(bins(2,:)==1300);
    delay_2 = find(bins(2,:)==1800);
    delay_2(2) = find(bins(2,:)==2300);
    % Defining the delay 1 and delay 2 to compute the shifts at chance
    % level (within Delay 1 and within Delay 2)
    delay_11_ch = find(bins(2,:)==800);
    delay_11_ch(2) = find(bins(2,:)==1050);
    delay_12_ch = find(bins(2,:)==1100);
    delay_12_ch(2) = find(bins(2,:)==1350);
    delay_21_ch = find(bins(2,:)==1800);
    delay_21_ch(2) = find(bins(2,:)==2050);
    delay_22_ch = find(bins(2,:)==2100);
    delay_22_ch(2) = find(bins(2,:)==2350);
    for i_boot = 1:N_bootstraps
        tic
        % Projections and shift in cluster centers between delay 1 and
        % delay 2 data for correct trials across all locations in Delay 1 space for
        % LPFC data
        [proj_dl_d1,label_dl_d1,~,~] = NeuralTraj_v2(dataset_dl,dataset_e_dl,trials,session_dl,etrials,size(dataset_dl,1),m_dl,st_dl,m_e_dl,st_e_dl,delay_1(1),delay_1(2),'correct');
        [shift_clusters_dl_d1(i_boot,:),m_intra_dist_dl_d11(i_boot,:),~,inter_dist_dl_d11(i_boot),~] =  ShiftofClusters(proj_dl_d1,label_dl_d1,delay_1,delay_2);
        [shift_clusters_dl_d1_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_dl_d1,label_dl_d1,delay_11_ch,delay_12_ch);
        % Projections and shift in cluster centers between delay 1 and
        % delay 2 data for correct trials across all locations in Delay 1 space for
        % FEF data
        [proj_fef_d1,label_fef_d1,~,~] = NeuralTraj_v2(dataset,dataset_e,trials,session,etrials,size(dataset,1),m,st,m_e,st_e,delay_1(1),delay_1(2),'correct');
        [shift_clusters_fef_d1(i_boot,:),m_intra_dist_fef_d11(i_boot,:),~,inter_dist_fef_d11(i_boot),~] =  ShiftofClusters(proj_fef_d1,label_fef_d1,delay_1,delay_2);
        [shift_clusters_fef_d1_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_fef_d1,label_fef_d1,delay_11_ch,delay_12_ch);
        % Projections and shift in cluster centers between delay 1 and
        % delay 2 data for correct trials across all locations in Delay 2 space for
        % LPFC data
        [proj_dl_d2,label_dl_d2,~,~] = NeuralTraj_v2(dataset_dl,dataset_e_dl,trials,session_dl,etrials,size(dataset_dl,1),m_dl,st_dl,m_e_dl,st_e_dl,delay_2(1),delay_2(2),'correct');
        [shift_clusters_dl_d2(i_boot,:),~,m_intra_dist_dl_d22(i_boot,:),~,inter_dist_dl_d22(i_boot)] =  ShiftofClusters(proj_dl_d2,label_dl_d2,delay_1,delay_2);
        [shift_clusters_dl_d2_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_dl_d2,label_dl_d2,delay_21_ch,delay_22_ch);
        % Projections and shift in cluster centers between delay 1 and
        % delay 2 data for correct trials across all locations in Delay 2 space for
        % FEF data
        [proj_fef_d2,label_fef_d2,~,~] = NeuralTraj_v2(dataset,dataset_e,trials,session,etrials,size(dataset,1),m,st,m_e,st_e,delay_2(1),delay_2(2),'correct');
        [shift_clusters_fef_d2(i_boot,:),~,m_intra_dist_fef_d22(i_boot,:),~,inter_dist_fef_d22(i_boot)] =  ShiftofClusters(proj_fef_d2,label_fef_d2,delay_1,delay_2);
        [shift_clusters_fef_d2_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_fef_d2,label_fef_d2,delay_21_ch,delay_22_ch);
        toc
        % saving data every 100 iterations, incase of power outage or if
        % MATLAB crashes. You can choose to comment these lines.
        if rem(i_boot,100)==0
            save('proj_mat','proj_dl_d1','proj_fef_d1','proj_dl_d2','proj_fef_d2','shift_clusters_dl_d1','m_intra_dist_dl_d11','inter_dist_dl_d11',...
                'proj_dl_d2','proj_fef_d2','shift_clusters_dl_d2','m_intra_dist_dl_d22','inter_dist_dl_d22',...
                'shift_clusters_fef_d2','m_intra_dist_fef_d22','inter_dist_fef_d22',...
                'shift_clusters_fef_d1','m_intra_dist_fef_d11','inter_dist_fef_d11',...
                'shift_clusters_dl_d1_ch','shift_clusters_dl_d2_ch','shift_clusters_fef_d1_ch','shift_clusters_fef_d2_ch','-v7.3');
        end
    end
    % The next few lines of code will be executed if the variables of interest
    % do not contain data from all 1000 iterations
elseif (size(shift_clusters_dl_d1,1)<1000 || size(shift_clusters_fef_d1,1)<1000)
    N_bootstraps = 1000; % Number of bootstraps
    bins = -300:50:2600;% Defining the bins to compute the decoding performance
    bins(2,:) = bins(1,:)+100;
    Trial_Label = 'target';
    delay_1 = find(bins(2,:)==800);
    delay_1(2) = find(bins(2,:)==1300);
    delay_2 = find(bins(2,:)==1800);
    delay_2(2) = find(bins(2,:)==2300);
    for i_boot = size(shift_clusters_dl_d1,1)+1:N_bootstraps
        tic
        [proj_dl_d1,label_dl_d1,~,~] = NeuralTraj_v2(dataset_dl,dataset_e_dl,trials,session_dl,etrials,size(dataset_dl,1),m_dl,st_dl,m_e_dl,st_e_dl,delay_1(1),delay_1(2));
        [shift_clusters_dl_d1(i_boot,:),m_intra_dist_dl_d11(i_boot,:),~,inter_dist_dl_d11(i_boot),~] =  ShiftofClusters(proj_dl_d1,label_dl_d1,delay_1,delay_2);
        [shift_clusters_dl_d1_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_dl_d1,label_dl_d1,delay_11_ch,delay_12_ch);
        [proj_fef_d1,label_fef_d1,~,~] = NeuralTraj_v2(dataset,dataset_e,trials,session,etrials,size(dataset,1),m,st,m_e,st_e,delay_1(1),delay_1(2));
        [shift_clusters_fef_d1(i_boot,:),m_intra_dist_fef_d11(i_boot,:),~,inter_dist_fef_d11(i_boot),~] =  ShiftofClusters(proj_fef_d1,label_fef_d1,delay_1,delay_2);
        [shift_clusters_fef_d1_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_fef_d1,label_fef_d1,delay_11_ch,delay_12_ch);
        [proj_dl_d2,label_dl_d2,~,~] = NeuralTraj_v2(dataset_dl,dataset_e_dl,trials,session_dl,etrials,size(dataset_dl,1),m_dl,st_dl,m_e_dl,st_e_dl,delay_2(1),delay_2(2));
        [shift_clusters_dl_d2(i_boot,:),~,m_intra_dist_dl_d22(i_boot,:),~,inter_dist_dl_d22(i_boot)] =  ShiftofClusters(proj_dl_d2,label_dl_d2,delay_1,delay_2);
        [shift_clusters_dl_d2_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_dl_d2,label_dl_d2,delay_21_ch,delay_22_ch);
        [proj_fef_d1,label_fef_d1,~,~] = NeuralTraj_v2(dataset,dataset_e,trials,session,etrials,size(dataset,1),m,st,m_e,st_e,delay_2(1),delay_2(2));
        [shift_clusters_fef_d2(i_boot,:),~,m_intra_dist_fef_d22(i_boot,:),~,inter_dist_fef_d22(i_boot)] =  ShiftofClusters(proj_fef_d2,label_fef_d2,delay_1,delay_2);
        [shift_clusters_fef_d2_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_fef_d2,label_fef_d2,delay_21_ch,delay_22_ch);
        toc
        if rem(i_boot,100)==0
            save('proj_mat','proj_dl_d1','proj_fef_d1','proj_dl_d2','proj_fef_d2','shift_clusters_dl_d1','m_intra_dist_dl_d11','inter_dist_dl_d11',...
                'proj_dl_d2','proj_fef_d2','shift_clusters_dl_d2','m_intra_dist_dl_d22','inter_dist_dl_d22',...
                'shift_clusters_fef_d2','m_intra_dist_fef_d22','inter_dist_fef_d22',...
                'shift_clusters_fef_d1','m_intra_dist_fef_d11','inter_dist_fef_d11',...
                'shift_clusters_dl_d1_ch','shift_clusters_dl_d2_ch','shift_clusters_fef_d1_ch','shift_clusters_fef_d2_ch','-v7.3');
        end
    end
end

%% Plotting Figure 3a,b and 3e,f

% Figure 3a - projections for LPFC
figure
delay_1 = find(bins(2,:)==800);
delay_1(2) = find(bins(2,:)==1300);
delay_2 = find(bins(2,:)==1800);
delay_2(2) = find(bins(2,:)==2300);
label = unique(label_dl_d1); % Number of unique target label's projections calculated
pos_lpfc_d1 = [0.05 0.80 0.08 0.1]; % subplot positions for the top left corner plot.
tmp_proj = proj_dl_d1(1:2,:,:); % Top 2 dimensions for projection
% Plotting projections for each location
for i = 1:length(label)
    if label(i) < 5
        ind_tr = find(label_dl_d1==label(i));
        tmp_pos = pos_lpfc_d1;
        % Updating postition for each subplot in fig 3a. Note that for the
        % subplot in the top left corner - i==1 and tmp_pos==pos_lpfc_d1
        if i<4
            tmp_pos(1) = tmp_pos(1) + (i-1)*tmp_pos(3) + (i-1)*0.01;
        else
            tmp_pos(2) = tmp_pos(2) - (i-3)*tmp_pos(4) - (i-3)*0.01;
        end
        ax1 = subplot('Position',tmp_pos);
        % Plot average delay 1 projections
        plot(squeeze(mean(tmp_proj(1,ind_tr,delay_1(1):delay_1(2)),3)), squeeze(mean(tmp_proj(2,ind_tr,delay_1(1):delay_1(2)),3)),'b.','MarkerSize',4);
        hold on
        % Plot average delay 2 projecctions
        plot(squeeze(mean(tmp_proj(1,ind_tr,delay_2(1):delay_2(2)),3)), squeeze(mean(tmp_proj(2,ind_tr,delay_2(1):delay_2(2)),3)),'r.','MarkerSize',4);
        % Axes properties
        set(ax1,'XTick',[],'XTickLabel',{},'YTick',[],'YTickLabel',{},'Box','off');
    else
        ind_tr = find(label_dl_d1==label(i));
        if i==5
            pos_lpfc_d1 = tmp_pos;
            tmp_pos = pos_lpfc_d1;
            tmp_pos(1) = tmp_pos(1) + (i-3)*tmp_pos(3) + (i-3)*0.01;
            pos_lpfc_d1(2) = pos_lpfc_d1(2) - tmp_pos(4) - 0.01;
        else
            tmp_pos = pos_lpfc_d1;
            tmp_pos(1) = tmp_pos(1) + (i-6)*tmp_pos(3) + (i-6)*0.01;
        end
        ax1 = subplot('Position',tmp_pos);
        plot(squeeze(mean(tmp_proj(1,ind_tr,delay_1(1):delay_1(2)),3)), squeeze(mean(tmp_proj(2,ind_tr,delay_1(1):delay_1(2)),3)),'b.','MarkerSize',4);
        hold on
        plot(squeeze(mean(tmp_proj(1,ind_tr,delay_2(1):delay_2(2)),3)), squeeze(mean(tmp_proj(2,ind_tr,delay_2(1):delay_2(2)),3)),'r.','MarkerSize',4);
        if i~=6
            set(ax1,'XTick',[],'XTickLabel',{},'YTick',[],'YTickLabel',{});
        end
        set(ax1,'Box','off');
        if i==6
            set(ax1,'FontName','Helvetica','FontSize',6)
            xlabel('PC1','FontName','Helvetica','FontSize',6)
            ylabel('PC2','FontName','Helvetica','FontSize',6)
        end
    end
end
linkaxes

% Plotting projections for delay 2 space (LPFC data) - Fig 3b
pos_lpfc_d2 = [0.35 0.80 0.08 0.1]; % subplot positions for the top left corner plot.
tmp_proj = proj_dl_d2(1:2,:,:); % Top 2 dimensions for projection
for i = 1:length(label)
    if label(i) < 5
        ind_tr = find(label_dl_d2==label(i));
        tmp_pos = pos_lpfc_d2;
        if i<4
            tmp_pos(1) = tmp_pos(1) + (i-1)*tmp_pos(3) + (i-1)*0.01;
        else
            tmp_pos(2) = tmp_pos(2) - (i-3)*tmp_pos(4) - (i-3)*0.01;
        end
        ax1 = subplot('Position',tmp_pos);
        plot(squeeze(mean(tmp_proj(1,ind_tr,delay_1(1):delay_1(2)),3)), squeeze(mean(tmp_proj(2,ind_tr,delay_1(1):delay_1(2)),3)),'b.','MarkerSize',4);
        hold on
        plot(squeeze(mean(tmp_proj(1,ind_tr,delay_2(1):delay_2(2)),3)), squeeze(mean(tmp_proj(2,ind_tr,delay_2(1):delay_2(2)),3)),'r.','MarkerSize',4);
        set(ax1,'XTick',[],'XTickLabel',{},'YTick',[],'YTickLabel',{},'Box','off');
    else
        
        ind_tr = find(label_dl_d2==label(i));
        if i==5
            pos_lpfc_d2 = tmp_pos;
            tmp_pos = pos_lpfc_d2;
            tmp_pos(1) = tmp_pos(1) + (i-3)*tmp_pos(3) + (i-3)*0.01;
            pos_lpfc_d2(2) = pos_lpfc_d2(2) - tmp_pos(4) - 0.01;
        else
            tmp_pos = pos_lpfc_d2;
            tmp_pos(1) = tmp_pos(1) + (i-6)*tmp_pos(3) + (i-6)*0.01;
        end
        ax1 = subplot('Position',tmp_pos);
        plot(squeeze(mean(tmp_proj(1,ind_tr,delay_1(1):delay_1(2)),3)), squeeze(mean(tmp_proj(2,ind_tr,delay_1(1):delay_1(2)),3)),'b.','MarkerSize',4);
        hold on
        plot(squeeze(mean(tmp_proj(1,ind_tr,delay_2(1):delay_2(2)),3)), squeeze(mean(tmp_proj(2,ind_tr,delay_2(1):delay_2(2)),3)),'r.','MarkerSize',4);
        if i~=6
            set(ax1,'XTick',[],'XTickLabel',{},'YTick',[],'YTickLabel',{});
        end
        if i==6
            set(ax1,'FontName','Helvetica','FontSize',6)
            xlabel('PC1','FontName','Helvetica','FontSize',6)
            ylabel('PC2','FontName','Helvetica','FontSize',6)
        end
        set(ax1,'Box','off');
    end
end

% Plotting projections for Delay 1 space (FEF data) - Fig 3e
pos_fef_d1 = [0.05 0.350 0.08 0.1]; % subplot positions for the top left corner plot.
tmp_proj = proj_fef_d1(1:2,:,:); % Top 2 dimensions for projection
for i = 1:length(label)
    if label(i) < 5
        ind_tr = find(label_fef_d1==label(i));
        tmp_pos = pos_fef_d1;
        if i<4
            tmp_pos(1) = tmp_pos(1) + (i-1)*tmp_pos(3) + (i-1)*0.01;
        else
            tmp_pos(2) = tmp_pos(2) - (i-3)*tmp_pos(4) - (i-3)*0.01;
        end
        ax1 = subplot('Position',tmp_pos);
        plot(squeeze(mean(tmp_proj(1,ind_tr,delay_1(1):delay_1(2)),3)), squeeze(mean(tmp_proj(2,ind_tr,delay_1(1):delay_1(2)),3)),'b.','MarkerSize',4);
        hold on
        plot(squeeze(mean(tmp_proj(1,ind_tr,delay_2(1):delay_2(2)),3)), squeeze(mean(tmp_proj(2,ind_tr,delay_2(1):delay_2(2)),3)),'r.','MarkerSize',4);
        set(ax1,'XTick',[],'XTickLabel',{},'YTick',[],'YTickLabel',{},'Box','off');
    else
        
        ind_tr = find(label_fef_d1==label(i));
        if i==5
            pos_fef_d1 = tmp_pos;
            tmp_pos = pos_fef_d1;
            tmp_pos(1) = tmp_pos(1) + (i-3)*tmp_pos(3) + (i-3)*0.01;
            pos_fef_d1(2) = pos_fef_d1(2) - tmp_pos(4) - 0.01;
        else
            tmp_pos = pos_fef_d1;
            tmp_pos(1) = tmp_pos(1) + (i-6)*tmp_pos(3) + (i-6)*0.01;
        end
        ax1 = subplot('Position',tmp_pos);
        plot(squeeze(mean(tmp_proj(1,ind_tr,delay_1(1):delay_1(2)),3)), squeeze(mean(tmp_proj(2,ind_tr,delay_1(1):delay_1(2)),3)),'b.','MarkerSize',4);
        hold on
        plot(squeeze(mean(tmp_proj(1,ind_tr,delay_2(1):delay_2(2)),3)), squeeze(mean(tmp_proj(2,ind_tr,delay_2(1):delay_2(2)),3)),'r.','MarkerSize',4);
        if i~=6
            set(ax1,'XTick',[],'XTickLabel',{},'YTick',[],'YTickLabel',{});
        end
        if i==6
            set(ax1,'FontName','Helvetica','FontSize',6)
            xlabel('PC1','FontName','Helvetica','FontSize',6)
            ylabel('PC2','FontName','Helvetica','FontSize',6)
        end
        set(ax1,'Box','off');
    end
end
linkaxes

% Plotting projections for Delay 2 space (FEF data) - Fig 3f
pos_fef_d2 = [0.35 0.350 0.08 0.1]; % subplot positions for the top left corner plot.
tmp_proj = proj_fef_d2(1:2,:,:); % Top 2 dimensions for projection
for i = 1:length(label)
    if label(i) < 5
        ind_tr = find(label_fef_d2==label(i));
        tmp_pos = pos_fef_d2;
        if i<4
            tmp_pos(1) = tmp_pos(1) + (i-1)*tmp_pos(3) + (i-1)*0.01;
        else
            tmp_pos(2) = tmp_pos(2) - (i-3)*tmp_pos(4) - (i-3)*0.01;
        end
        ax1 = subplot('Position',tmp_pos);
        plot(squeeze(mean(tmp_proj(1,ind_tr,delay_1(1):delay_1(2)),3)), squeeze(mean(tmp_proj(2,ind_tr,delay_1(1):delay_1(2)),3)),'b.','MarkerSize',4);
        hold on
        plot(squeeze(mean(tmp_proj(1,ind_tr,delay_2(1):delay_2(2)),3)), squeeze(mean(tmp_proj(2,ind_tr,delay_2(1):delay_2(2)),3)),'r.','MarkerSize',4);
        set(ax1,'XTick',[],'XTickLabel',{},'YTick',[],'YTickLabel',{},'Box','off');
    else
        
        ind_tr = find(label_fef_d2==label(i));
        if i==5
            pos_fef_d2 = tmp_pos;
            tmp_pos = pos_fef_d2;
            tmp_pos(1) = tmp_pos(1) + (i-3)*tmp_pos(3) + (i-3)*0.01;
            pos_fef_d2(2) = pos_fef_d2(2) - tmp_pos(4) - 0.01;
        else
            tmp_pos = pos_fef_d2;
            tmp_pos(1) = tmp_pos(1) + (i-6)*tmp_pos(3) + (i-6)*0.01;
        end
        ax1 = subplot('Position',tmp_pos);
        plot(squeeze(mean(tmp_proj(1,ind_tr,delay_1(1):delay_1(2)),3)), squeeze(mean(tmp_proj(2,ind_tr,delay_1(1):delay_1(2)),3)),'b.','MarkerSize',4);
        hold on
        plot(squeeze(mean(tmp_proj(1,ind_tr,delay_2(1):delay_2(2)),3)), squeeze(mean(tmp_proj(2,ind_tr,delay_2(1):delay_2(2)),3)),'r.','MarkerSize',4);
        if i~=6
            set(ax1,'XTick',[],'XTickLabel',{},'YTick',[],'YTickLabel',{});
        end
        if i==6
            set(ax1,'FontName','Helvetica','FontSize',6)
            xlabel('PC1','FontName','Helvetica','FontSize',6)
            ylabel('PC2','FontName','Helvetica','FontSize',6)
        end
        set(ax1,'Box','off');
    end
end
linkaxes

%% Figure 3c,3g
% Average intracluster distance across 7 target locations in delay 1 and
% delay 2 space
mean_m_intra_dl_d11 = mean(m_intra_dist_dl_d11,2);
mean_m_intra_dl_d22 = mean(m_intra_dist_dl_d22,2);
mean_m_intra_fef_d11 = mean(m_intra_dist_fef_d11,2);
mean_m_intra_fef_d22 = mean(m_intra_dist_fef_d22,2);

%Fig 3c
ax3 = subplot('Position',[0.65 0.6 0.15 0.3])
boxplot([mean_m_intra_dl_d11 mean_m_intra_dl_d22 inter_dist_dl_d11' inter_dist_dl_d22'],'whisker',1.2,'symbol','','colors',[0.4 0.4 0.4],'Positions',[0.85 1.15 1.85 2.15],'notch','on')
set(ax3,'Box','off','XTickLabel',{'Del 1','Del 2','Del 1','Del 2'},'FontSize',6,'FontName','Helvetica')
set(findobj(gcf,'LineStyle','--'),'LineStyle','-','color','black')
lines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(lines,'color','r')
ylim([2 10])
xlabel('Intra                        Inter','FontName','Helvetica','FontSize',6)
ylabel('Cluster distances','FontName','Helvetica','FontSize',6)

% Fig 3g
ax4 = subplot('Position',[0.65 0.15 0.15 0.3])
boxplot([mean_m_intra_fef_d11 mean_m_intra_fef_d22 inter_dist_fef_d11' inter_dist_fef_d22'],'whisker',1.2,'symbol','','colors',[0.4 0.4 0.4],'Positions',[0.85 1.15 1.85 2.15],'notch','on')
set(ax4,'Box','off','XTickLabel',{'Del 1','Del 2','Del 1','Del 2'},'FontSize',6,'FontName','Helvetica')
set(findobj(gcf,'LineStyle','--'),'LineStyle','-','color','black')
lines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(lines,'color','r')
ylim([2 10])
xlabel('Intra                        Inter','FontName','Helvetica','FontSize',6)
ylabel('Cluster distances','FontName','Helvetica','FontSize',6)

%% Figure 3d,3h

% Average shift in cluster centers across all locations
m_shift_dl_d1 = mean(shift_clusters_dl_d1,2);
m_shift_dl_d1_ch = mean(shift_clusters_dl_d1_ch,2);
m_shift_dl_d2 = mean(shift_clusters_dl_d2,2);
m_shift_dl_d2_ch = mean(shift_clusters_dl_d2_ch,2);
m_shift_fef_d1 = mean(shift_clusters_fef_d1,2);
m_shift_fef_d1_ch = mean(shift_clusters_fef_d1_ch,2);
m_shift_fef_d2 = mean(shift_clusters_fef_d2,2);
m_shift_fef_d2_ch = mean(shift_clusters_fef_d2_ch,2);

% Fig 3d
ax4 = subplot('Position',[0.845 0.6 0.15 0.3]) % Position of the plot
boxplot([m_shift_dl_d1 m_shift_dl_d2],'whisker',1.2,'symbol','','colors',[0.4 0.4 0.4],'notch','on');
% Boxplot properties
set(findobj(gcf,'LineStyle','--'),'LineStyle','-','color','black')
lines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(lines,'color','r')
% Axes properties
ylabel('Cluster distances','FontName','Helvetica','FontSize',6)
set(ax4,'Box','off','XTickLabel',{'Del 1','Del 2'},'FontSize',6,'FontName','Helvetica')
ylim([3 10])
% Plotting chance levels (97.5th percentile of the shift within Delay 1 or Delay 2)
line([0.8 1.2],[prctile(m_shift_dl_d1_ch,97.5) prctile(m_shift_dl_d1_ch,97.5)],'color','black','LineStyle',':')
line([1.8 2.2],[prctile(m_shift_dl_d2_ch,97.5) prctile(m_shift_dl_d2_ch,97.5)],'color','black','LineStyle',':')

% Fig 3h
ax4 = subplot('Position',[0.845 0.15 0.15 0.3])
boxplot([m_shift_fef_d1 m_shift_fef_d2],'whisker',1.2,'symbol','','colors',[0.4 0.4 0.4],'notch','on');
set(findobj(gcf,'LineStyle','--'),'LineStyle','-','color','black')
lines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(lines,'color','r')
ylabel('Cluster distances','FontName','Helvetica','FontSize',6)
set(ax4,'Box','off','XTickLabel',{'Del 1','Del 2'},'FontSize',6,'FontName','Helvetica')
ylim([3 10])
line([0.8 1.2],[prctile(m_shift_fef_d1_ch,97.5) prctile(m_shift_fef_d1_ch,97.5)],'color','black','LineStyle',':')
line([1.8 2.2],[prctile(m_shift_fef_d2_ch,97.5) prctile(m_shift_fef_d2_ch,97.5)],'color','black','LineStyle',':')

% Titles for all the figures.
axis = axes('Position',[0 0 1 1],'Visible','off')
text(axis,0.31,0.98,'Projections on Principal Components','Units','Normalized','FontName','Helvetica','FontSize',7,'FontWeight','bold','HorizontalAlignment','center')
text(axis,[0.725 0.725 0.725],[0.995 0.98 0.965],{'Comparison of ','cluster Distances between','Delay 1 and Delay 2'},'Units','Normalized','FontName','Helvetica','FontSize',7,'FontWeight','bold','HorizontalAlignment','center')
text(axis,[0.92 0.92 0.92],[0.995 0.980 0.965],{'Shift in cluster','between','Delay 1 and Delay 2'},'Units','Normalized','Units','Normalized','FontName','Helvetica','FontSize',7,'FontWeight','bold','HorizontalAlignment','center')
text(axis,0.18,0.91,'Delay 1 space','Units','Normalized','FontName','Helvetica','FontSize',6,'HorizontalAlignment','center')
text(axis,0.48,0.91,'Delay 2 space','Units','Normalized','FontName','Helvetica','FontSize',6,'HorizontalAlignment','center')
text(axis,0.62,0.93,'LPFC (n = 256 neurons)','Units','Normalized','FontName','Helvetica','FontSize',7,'FontWeight','bold','HorizontalAlignment','center')
text(axis,0.62,0.50,'FEF (n = 137 neurons)','Units','Normalized','FontName','Helvetica','FontSize',7,'FontWeight','bold','HorizontalAlignment','center')
text(axis,0.18,0.46,'Delay 1 space','Units','Normalized','FontName','Helvetica','FontSize',6,'HorizontalAlignment','center')
text(axis,0.48,0.46,'Delay 2 space','Units','Normalized','FontName','Helvetica','FontSize',6,'HorizontalAlignment','center')
