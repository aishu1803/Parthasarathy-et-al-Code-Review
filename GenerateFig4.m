% This script generates fig 4 in Parthasarathy et al. Please feel free to
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
load('/Users/aishp/Documents/Data/color_map_fig4.mat');
% As the code takes a while to run (each iteration can take about 30-150 seconds depending
% on the analysis and we have 1000 iterations), we also have a folder with
% all the intermediate results saved. You can choose to run it for a few
% iterations to check the algorithm and opt to use the intermediate
% results. The intermediate results are in a separate folder (called Inter
% Results) in the Data folder. You can choose to add it to the path in case
% you want to work with the saved results.
% Change the path to Inter folder 
% Comment these lines in case you want dont want to use the saved dataset.
if exist('/Users/aishp/Documents/Data/perf_correrr_mat.mat','file') & exist('/Users/aishp/Documents/Data/perf_err_mat.mat','file') & exist('/Users/aishp/Documents/Data/proj_corr_err.mat','file')
    load('/Users/aishp/Documents/Data/perf_correrr_mat.mat')
    load('/Users/aishp/Documents/Data/perf_err_mat.mat')
    load('/Users/aishp/Documents/Data/proj_corr_err.mat')
end
%% %% Generating the cross-temporal decoding performance results for n bootstraps
% Check if the variables containing all the decoding performance from the
% error trials already exist in the workspace. If it does, it only runs
% the code if the variable contains decoding performance from less than
% 1000 iterations. In case you choose to load the intermediate result from
% the data folder, this entire code section will be skipped as the intermediate 
% result has data from 1000 iterations.
if ~(exist('perf_cc_dl','var') && exist('perf_cc_fef','var'))
    N_bootstraps = 1000; % Number of bootstraps
    bins = -300:50:2600;% Defining the bins to compute the decoding performance
    bins(2,:) = bins(1,:)+100;
    Trial_Label = 'target'; % Trial labels to decode. Could be target or distractor.
    % In the paper, for Fig 4, target locations are decoded.
    for i_boot = 1:N_bootstraps
        tic
        % Decoding error trials from LPFC and FEF populations using a
        % decoder that is trained on correct trials.
        perf_cc_dl(i_boot,:,:) = Decode_final_temporal_v2(dataset_dl,m_dl,st_dl,session_dl,Trial_Label,trials,bins,etrials,dataset_e_dl,m_e_dl,st_e_dl,'Error');
        perf_cc_fef(i_boot,:,:) = Decode_final_temporal_v2(dataset,m,st,session,Trial_Label,trials,bins,etrials,dataset_e,m_e,st_e,'Error');
        toc
        % Just saving every 100 iterations, incase of power outage or if
        % the computer crashes. You can choose to comment these lines. 
        if rem(i_boot,100)==0
            save('perf_err_mat','perf_cc_dl','perf_cc_fef','-v7.3');
        end
    end
% The next few lines of code will be executed if the variables of interest 
% do not contain data from all 1000 iterations.     
elseif size(perf_cc_dl,1) < 1000 & size(perf_cc_fef,1)<1000
    N_bootstraps = 1000; % Number of bootstraps
    bins = -300:50:2600;% Defining the bins to compute the decoding performance
    bins(2,:) = bins(1,:)+100;
    Trial_Label = 'target'; % Trial labels to decode. Could be target or distractor.
    % In the paper, for Fig 4, target locations are decoded.
    if size(perf_cc_dl,1)==size(perf_cc_fef,1)
        for i_boot = size(perf_cc_dl,1)+1:N_bootstraps
            tic
            perf_cc_dl(i_boot,:,:) = Decode_final_temporal_v2(dataset_dl,m_dl,st_dl,session_dl,Trial_Label,trials,bins,etrials,dataset_e_dl,m_e_dl,st_e_dl,'Error');
            perf_cc_fef(i_boot,:,:) = Decode_final_temporal_v2(dataset,m,st,session,Trial_Label,trials,bins,etrials,dataset_e,m_e,st_e,'Error');
            toc
            if rem(i_boot,100)==0
                save('perf_err_mat','perf_cc_dl','perf_cc_fef','-v7.3');
            end
        end
    else
        for i_boot = size(perf_cc_dl,1)+1:N_bootstraps
            tic
            perf_cc_dl(i_boot,:,:) = Decode_final_temporal_v2(dataset_dl,m_dl,st_dl,session_dl,Trial_Label,trials,bins,etrials,dataset_e_dl,m_e_dl,st_e_dl,'Error');
            toc
            if rem(i_boot,100)==0
                save('perf_err_mat','perf_cc_dl','perf_cc_fef','-v7.3');
            end
        end
        for i_boot = size(perf_cc_fef,1)+1:N_bootstraps
            tic
            perf_cc_fef(i_boot,:,:) = Decode_final_temporal_v2(dataset,m,st,session,Trial_Label,trials,bins,etrials,dataset_e,m_e,st_e,'Error');
            toc
            if rem(i_boot,100)==0
                save('perf_err_mat','perf_cc_dl','perf_cc_fef','-v7.3');
            end
        end
    end
end

%% %% Generating the cross-temporal decoding performance results for n bootstraps
% In figure 4b,c,g and h, the performance of the decoder during correct
% trials is compared to the performance during error trials. However, for
% error trials, we only trained and tested the decoder for 4 target
% locations due to the sparse distribution of error trials across target 
% locations. Therefore, this code section computes the decoding performance
% when the decoder is trained and tested using correct trials but only with 
% 4 target locations.
if ~(exist('perf_cc_dl_correrr','var') && exist('perf_cc_fef_correrr','var'))
    N_bootstraps = 1000; % Number of bootstraps
    bins = -300:50:2600;% Defining the bins to compute the decoding performance
    bins(2,:) = bins(1,:)+100;
    Trial_Label = 'target'; % Trial labels to decode. Could be target or distractor.
    % In the paper, for Fig 2, target locations are decoded.
    for i_boot = 1:N_bootstraps
        tic
        perf_cc_dl_correrr(i_boot,:,:) = Decode_final_temporal_v2(dataset_dl,m_dl,st_dl,session_dl,Trial_Label,trials,bins,etrials,dataset_e_dl,m_e_dl,st_e_dl,'CorrError');
        perf_cc_fef_correrr(i_boot,:,:) = Decode_final_temporal_v2(dataset,m,st,session,Trial_Label,trials,bins,etrials,dataset_e,m_e,st_e,'CorrError');
        toc
        if rem(i_boot,100)==0
            save('perf_correrr_mat','perf_cc_dl_correrr','perf_cc_fef_correrr','-v7.3');
        end
    end
else
    N_bootstraps = 1000; % Number of bootstraps
    bins = -300:50:2600;% Defining the bins to compute the decoding performance
    bins(2,:) = bins(1,:)+100;
    Trial_Label = 'target'; % Trial labels to decode. Could be target or distractor.
    % In the paper, for Fig 2, target locations are decoded.
    if size(perf_cc_dl_correrr,1)==size(perf_cc_fef_correrr,1)
        for i_boot = size(perf_cc_dl_correrr,1)+1:N_bootstraps
            tic
            perf_cc_dl_correrr(i_boot,:,:) = Decode_final_temporal_v2(dataset_dl,m_dl,st_dl,session_dl,Trial_Label,trials,bins,etrials,dataset_e_dl,m_e_dl,st_e_dl,'CorrError');
            perf_cc_fef_correrr(i_boot,:,:) = Decode_final_temporal_v2(dataset,m,st,session,Trial_Label,trials,bins,etrials,dataset_e,m_e,st_e,'CorrError');
            toc
            if rem(i_boot,100)==0
                save('perf_correrr_mat','perf_cc_dl_correrr','perf_cc_fef_correrr','-v7.3');
            end
        end
    else
        for i_boot = size(perf_cc_dl_correrr,1)+1:N_bootstraps
            tic
            perf_cc_dl_correrr(i_boot,:,:) = Decode_final_temporal_v2(dataset_dl,m_dl,st_dl,session_dl,Trial_Label,trials,bins,etrials,dataset_e_dl,m_e_dl,st_e_dl,'CorrError');
            toc
            if rem(i_boot,100)==0
                save('perf_correrr_mat','perf_cc_dl_correrr','perf_cc_fef_correrr','-v7.3');
            end
        end
        for i_boot = size(perf_cc_fef_correrr,1)+1:N_bootstraps
            tic
            perf_cc_fef_correrr(i_boot,:,:) = Decode_final_temporal_v2(dataset,m,st,session,Trial_Label,trials,bins,etrials,dataset_e,m_e,st_e,'CorrError');
            toc
            if rem(i_boot,100)==0
                save('perf_correrr_mat','perf_cc_dl_correrr','perf_cc_fef_correrr','-v7.3');
            end
        end
    end
end

%% Computing mean performance in LP11/FP11,LP22/FP22 for correct and error trials.
% Computing the mean performance during correct and error trials for fig
% 4b,c,g and h.

% identifying the start and end timebins for averaging
delay_1 = find(bins(2,:)==800);
delay_1(2) = find(bins(2,:)==1300);
delay_2 = find(bins(2,:)==1800);
delay_2(2) = find(bins(2,:)==2300);

% Computing the averages for decoding performance for correct and error
% trials from LPFC data
m_corr_d11_dl = mean(mean(perf_cc_dl_correrr(:,delay_1(1):delay_1(2),delay_1(1):delay_1(2)),2),3);
m_corr_d22_dl = mean(mean(perf_cc_dl_correrr(:,delay_2(1):delay_2(2),delay_2(1):delay_2(2)),2),3);
m_err_d11_dl = mean(mean(perf_cc_dl(:,delay_1(1):delay_1(2),delay_1(1):delay_1(2)),2),3);
m_err_d22_dl = mean(mean(perf_cc_dl(:,delay_2(1):delay_2(2),delay_2(1):delay_2(2)),2),3);

% Computing the averages for decoding performance for correct and error
% trials from FEF data
m_corr_d11_fef = mean(mean(perf_cc_fef_correrr(:,delay_1(1):delay_1(2),delay_1(1):delay_1(2)),2),3);
m_corr_d22_fef = mean(mean(perf_cc_fef_correrr(:,delay_2(1):delay_2(2),delay_2(1):delay_2(2)),2),3);
m_err_d11_fef = mean(mean(perf_cc_fef(:,delay_1(1):delay_1(2),delay_1(1):delay_1(2)),2),3);
m_err_d22_fef = mean(mean(perf_cc_fef(:,delay_2(1):delay_2(2),delay_2(1):delay_2(2)),2),3);

%% Computing the projections for correct and error trials

if ~(exist('shift_clusters_dl_d1','var') && exist('shift_clusters_fef_d1','var'))
    N_bootstraps = 1000; % Number of bootstraps
    bins = -300:50:2600;% Defining the bins to compute the decoding performance
    bins(2,:) = bins(1,:)+100;
    Trial_Label = 'target';
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
        % delay 2 data for correct and error trials in Delay 1 space for
        % LPFC data
        [proj_dl_d1,label_dl_d1,proj_dl_d1_e,label_dl_d1_e] = NeuralTraj_v2(dataset_dl,dataset_e_dl,trials,session_dl,etrials,size(dataset_dl,1),m_dl,st_dl,m_e_dl,st_e_dl,delay_1(1),delay_1(2),'Error');
        [shift_clusters_dl_d1(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_dl_d1,label_dl_d1,delay_1,delay_2);
        [shift_clusters_dl_d1_e(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_dl_d1_e,label_dl_d1_e,delay_1,delay_2);
        [shift_clusters_dl_d1_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_dl_d1,label_dl_d1,delay_11_ch,delay_12_ch);
        [shift_clusters_dl_d1_e_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_dl_d1_e,label_dl_d1_e,delay_11_ch,delay_12_ch);
        % Projections and shift in cluster centers between delay 1 and
        % delay 2 data for correct and error trials in Delay 2 space for
        % LPFC data
        [proj_dl_d2,label_dl_d2,proj_dl_d2_e,label_dl_d2_e] = NeuralTraj_v2(dataset_dl,dataset_e_dl,trials,session_dl,etrials,size(dataset_dl,1),m_dl,st_dl,m_e_dl,st_e_dl,delay_2(1),delay_2(2),'Error');
        [shift_clusters_dl_d2(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_dl_d2,label_dl_d2,delay_1,delay_2);
        [shift_clusters_dl_d2_e(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_dl_d2_e,label_dl_d2_e,delay_1,delay_2);
        [shift_clusters_dl_d2_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_dl_d2,label_dl_d2,delay_21_ch,delay_22_ch);
        [shift_clusters_dl_d2_e_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_dl_d2_e,label_dl_d2_e,delay_21_ch,delay_22_ch);
        % Projections and shift in cluster centers between delay 1 and
        % delay 2 data for correct and error trials in Delay 1 space for
        % FEF data
        [proj_fef_d1,label_fef_d1,proj_fef_d1_e,label_fef_d1_e] = NeuralTraj_v2(dataset,dataset_e,trials,session,etrials,size(dataset,1),m,st,m_e,st_e,delay_1(1),delay_1(2),'Error');
        [shift_clusters_fef_d1(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_fef_d1,label_fef_d1,delay_1,delay_2);
        [shift_clusters_fef_d1_e(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_fef_d1_e,label_fef_d1_e,delay_1,delay_2);
        [shift_clusters_fef_d1_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_fef_d1,label_fef_d1,delay_11_ch,delay_12_ch);
        [shift_clusters_fef_d1_e_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_fef_d1_e,label_fef_d1_e,delay_11_ch,delay_12_ch);
        % Projections and shift in cluster centers between delay 1 and
        % delay 2 data for correct and error trials in Delay 2 space for
        % FEF data
        [proj_fef_d2,label_fef_d2,proj_fef_d2_e,label_fef_d2_e] = NeuralTraj_v2(dataset,dataset_e,trials,session,etrials,size(dataset,1),m,st,m_e,st_e,delay_2(1),delay_2(2),'Error');
        [shift_clusters_fef_d2(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_fef_d2,label_fef_d2,delay_1,delay_2);
        [shift_clusters_fef_d2_e(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_fef_d2_e,label_fef_d2_e,delay_1,delay_2);
        [shift_clusters_fef_d2_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_fef_d2,label_fef_d2,delay_21_ch,delay_22_ch);
        [shift_clusters_fef_d2_e_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_fef_d2_e,label_fef_d2_e,delay_21_ch,delay_22_ch);
        toc
    end
    if rem(i_boot,100)==0
        save('proj_corr_err.mat','shift_clusters_dl_d1','shift_clusters_dl_d1_e','shift_clusters_dl_d2','shift_clusters_dl_d2_e','shift_clusters_dl_d1_ch','shift_clusters_dl_d1_e_ch','shift_clusters_dl_d2_ch','shift_clusters_dl_d2_e_ch','shift_clusters_fef_d1','shift_clusters_fef_d1_e','shift_clusters_fef_d2','shift_clusters_fef_d2_e','shift_clusters_fef_d1_ch','shift_clusters_fef_d1_e_ch','shift_clusters_fef_d2_ch','shift_clusters_fef_d2_e_ch')
    end
else
    N_bootstraps = 1000; % Number of bootstraps
    bins = -300:50:2600;% Defining the bins to compute the decoding performance
    bins(2,:) = bins(1,:)+100;
    Trial_Label = 'target'; % Trial labels to decode. Could be target or distractor.
    % In the paper, for Fig 2, target locations are decoded.
    for i_boot = size(shift_clusters_dl_d1,1)+1:N_bootstraps
        tic
        [proj_dl_d1,label_dl_d1,proj_dl_d1_e,label_dl_d1_e] = NeuralTraj_v2(dataset_dl,dataset_e_dl,trials,session_dl,etrials,size(dataset_dl,1),m_dl,st_dl,m_e_dl,st_e_dl,delay_1(1),delay_1(2),'Error');
        [shift_clusters_dl_d1(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_dl_d1,label_dl_d1,delay_1,delay_2);
        [shift_clusters_dl_d1_e(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_dl_d1_e,label_dl_d1_e,delay_1,delay_2);
        [shift_clusters_dl_d1_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_dl_d1,label_dl_d1,delay_11_ch,delay_12_ch);
        [shift_clusters_dl_d1_e_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_dl_d1_e,label_dl_d1_e,delay_11_ch,delay_12_ch);
        [proj_dl_d2,label_dl_d2,proj_dl_d2_e,label_dl_d2_e] = NeuralTraj_v2(dataset_dl,dataset_e_dl,trials,session_dl,etrials,size(dataset_dl,1),m_dl,st_dl,m_e_dl,st_e_dl,delay_2(1),delay_2(2),'Error');
        [shift_clusters_dl_d2(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_dl_d2,label_dl_d2,delay_1,delay_2);
        [shift_clusters_dl_d2_e(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_dl_d2_e,label_dl_d2_e,delay_1,delay_2);
        [shift_clusters_dl_d2_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_dl_d2,label_dl_d2,delay_21_ch,delay_22_ch);
        [shift_clusters_dl_d2_e_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_dl_d2_e,label_dl_d2_e,delay_21_ch,delay_22_ch);
        [proj_fef_d1,label_fef_d1,proj_fef_d1_e,label_fef_d1_e] = NeuralTraj_v2(dataset,dataset_e,trials,session,etrials,size(dataset,1),m,st,m_e,st_e,delay_1(1),delay_1(2),'Error');
        [shift_clusters_fef_d1(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_fef_d1,label_fef_d1,delay_1,delay_2);
        [shift_clusters_fef_d1_e(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_fef_d1_e,label_fef_d1_e,delay_1,delay_2);
        [shift_clusters_fef_d1_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_fef_d1,label_fef_d1,delay_11_ch,delay_12_ch);
        [shift_clusters_fef_d1_e_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_fef_d1_e,label_fef_d1_e,delay_11_ch,delay_12_ch);
        [proj_fef_d2,label_fef_d2,proj_fef_d2_e,label_fef_d2_e] = NeuralTraj_v2(dataset,dataset_e,trials,session,etrials,size(dataset,1),m,st,m_e,st_e,delay_2(1),delay_2(2),'Error');
        [shift_clusters_fef_d2(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_fef_d2,label_fef_d2,delay_1,delay_2);
        [shift_clusters_fef_d2_e(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_fef_d2_e,label_fef_d2_e,delay_1,delay_2);
        [shift_clusters_fef_d2_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_fef_d2,label_fef_d2,delay_21_ch,delay_22_ch);
        [shift_clusters_fef_d2_e_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_fef_d2_e,label_fef_d2_e,delay_21_ch,delay_22_ch);
        toc
    end
    if rem(i_boot,100)==0
        save('proj_corr_err.mat','shift_clusters_dl_d1','shift_clusters_dl_d1_e','shift_clusters_dl_d2','shift_clusters_dl_d2_e','shift_clusters_dl_d1_ch','shift_clusters_dl_d1_e_ch','shift_clusters_dl_d2_ch','shift_clusters_dl_d2_e_ch','shift_clusters_fef_d1','shift_clusters_fef_d1_e','shift_clusters_fef_d2','shift_clusters_fef_d2_e','shift_clusters_fef_d1_ch','shift_clusters_fef_d1_e_ch','shift_clusters_fef_d2_ch','shift_clusters_fef_d2_e_ch')
    end
end

%% Generating Figure 4a,4f
figure
Ticks = find(bins(1,:)==0 | bins(1,:)==300 | bins(1,:)==1300 | bins(1,:)==1600); % Target and Distractor onset and offset
% figure 4a(LPFC) - error trials
ax1 = subplot('Position',[0.045,0.6,0.20,0.275]);
imagesc(squeeze(mean(perf_cc_dl)),[15 70])
for i_line = 1:length(Ticks)
    line([Ticks(i_line) Ticks(i_line)],ylim,'color','white')
    line(xlim,[Ticks(i_line) Ticks(i_line)],'color','white')
end
set(ax1,'XTick',Ticks,'YTick',Ticks,'XTickLabel',{'0','0.3','1.3','1.6'},'YTickLabel',{'0','0.3','1.3','1.6'},'FontSize',6,'FontName','Helvetica','ydir','normal')
c = colorbar('Southoutside','Ticks',[20 30 40 50 60 70],'TickLabels',{'20','30','40','50','60','70'},'FontName','Helvetica','FontSize',6);
set(c,'Position',[0.045 0.525 0.20 0.020]);
c.Label.String = 'Performance (%)';
colormap(ax1,cmap_err)
xlabel('Testing Windows aligned to Target Onset (s)','FontSize',6,'FontName','Helvetica')
ylabel('Training Windows aligned to Target Onset (s)','FontSize',6,'FontName','Helvetica')

% Figure 4e (FEF) - error trials
ax2 = subplot('Position',[0.045,0.15,0.20,0.275]);
imagesc(squeeze(mean(perf_cc_fef)),[15 70])
for i_line = 1:length(Ticks)
    line([Ticks(i_line) Ticks(i_line)],ylim,'color','white')
    line(xlim,[Ticks(i_line) Ticks(i_line)],'color','white')
end
set(ax2,'XTick',Ticks,'YTick',Ticks,'XTickLabel',{'0','0.3','1.3','1.6'},'YTickLabel',{'0','0.3','1.3','1.6'},'FontSize',6,'FontName','Helvetica','ydir','normal')
c = colorbar('Southoutside','Ticks',[20 30 40 50 60 70],'TickLabels',{'20','30','40','50','60','70'},'FontName','Helvetica','FontSize',6);
set(c,'Position',[0.045 0.075 0.20 0.020]);
c.Label.String = 'Performance (%)';
colormap(ax2,cmap_err)
xlabel('Testing Windows aligned to Target Onset (s)','FontSize',6,'FontName','Helvetica')
ylabel('Training Windows aligned to Target Onset (s)','FontSize',6,'FontName','Helvetica')
%% Plotting Fig 4b,c,g,h
% Fig 4b, comparing decoding performance for correct and error trials in
% delay 1 (LPFC)
ax3 = subplot('Position',[0.29 0.6 0.06 0.275])
boxplot([m_corr_d11_dl m_err_d11_dl],'whisker',1.2,'symbol','','colors',[0.4 0.4 0.4],'notch','on')
set(ax3,'Box','off','XTickLabel',{'Correct','Error'},'FontSize',6,'FontName','Helvetica')
set(findobj(gcf,'LineStyle','--'),'LineStyle','-','color','black')
lines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(lines,'color','r')
ylim([35 85])
ylabel('Performance (%)','FontName','Helvetica','FontSize',6)

% Fig 4c, comparing decoding performance for correct and error trials in
% delay 2 (LPFC)
ax4 = subplot('Position',[0.4 0.6 0.06 0.275])
boxplot([m_corr_d22_dl m_err_d22_dl],'whisker',1.2,'symbol','','colors',[0.4 0.4 0.4],'notch','on')
set(ax4,'Box','off','XTickLabel',{'Correct','Error'},'FontSize',6,'FontName','Helvetica')
set(findobj(gcf,'LineStyle','--'),'LineStyle','-','color','black')
lines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(lines,'color','r')
ylim([35 85])

% Fig 4g, comparing decoding performance for correct and error trials in
% delay 1 (FEF data)
ax5 = subplot('Position',[0.29 0.15 0.06 0.275])
boxplot([m_corr_d11_fef m_err_d11_fef],'whisker',1.2,'symbol','','colors',[0.4 0.4 0.4],'notch','on')
set(ax5,'Box','off','XTickLabel',{'Correct','Error'},'FontSize',6,'FontName','Helvetica')
set(findobj(gcf,'LineStyle','--'),'LineStyle','-','color','black')
lines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(lines,'color','r')
ylim([30 70])
ylabel('Performance (%)','FontName','Helvetica','FontSize',6)

% Fig 4h, comparing decoding performance for correct and error trials in
% delay 2 (FEF data)
ax6 = subplot('Position',[0.4 0.15 0.075 0.275])
boxplot([m_corr_d22_fef m_err_d22_fef],'whisker',1.2,'symbol','','colors',[0.4 0.4 0.4],'notch','on')
set(ax6,'Box','off','XTickLabel',{'Correct','Error'},'FontSize',6,'FontName','Helvetica')
set(findobj(gcf,'LineStyle','--'),'LineStyle','-','color','black')
lines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(lines,'color','r')
ylim([30 70])

%% Figure 4d,e,i and j

%Fig 4d (LPFC)
ax7 = subplot('Position',[0.525 0.6 0.2 0.275])
% Location that needs to be plotted. In Fig 4d and i we only plot the
% projection for one location for clarity. The projections for all the locations are
% shown in the supplementary figure. This variable loc takes one of the
% following values - [2 3 5 6] depending on the example projection one
% wants to show. 
loc = 3;
% Projections to be plotted
tmp = proj_dl_d2(1:2,:,:);
% Acquiring the trials with the target location defined by loc
ind_tr = find(label_dl_d2==loc);
% Plotting the average delay 1 projections from correct trials
plot(squeeze(mean(tmp(1,ind_tr,delay_1(1):delay_1(2)),3)), squeeze(mean(tmp(2,ind_tr,delay_1(1):delay_1(2)),3)),'.c','MarkerSize',8)
hold on
% Plotting the average delay 2 projections from correct trials
plot(squeeze(mean(tmp(1,ind_tr,delay_2(1):delay_2(2)),3)), squeeze(mean(tmp(2,ind_tr,delay_2(1):delay_2(2)),3)),'.r','MarkerSize',8)
% Average projections from error trials during delay 1 and delay 2
tmp = proj_dl_d2_e(1:2,:,:);
ind_tr = find(label_dl_d2==loc);
plot(squeeze(mean(tmp(1,ind_tr,delay_2(1):delay_2(2)),3)), squeeze(mean(tmp(2,ind_tr,delay_2(1):delay_2(2)),3)),'Marker','.','LineStyle','none','MarkerSize',8,'color',[0.7 0 0])
plot(squeeze(mean(tmp(1,ind_tr,delay_1(1):delay_1(2)),3)), squeeze(mean(tmp(2,ind_tr,delay_1(1):delay_1(2)),3)),'Marker','.','LineStyle','none','MarkerSize',8,'color','b')
% Axes  properties
set(ax7,'Box','off','FontName','Helvetica','FontSize',6)
xlabel('PC1','FontName','Helvetica','FontSize',6)
ylabel('PC2','FontName','Helvetica','FontSize',6)

% Fig 4i (FEF)
ax8 = subplot('Position',[0.525 0.15 0.2 0.275])
% Location that needs to be plotted. In Fig 4d and i we only plot the
% projection for one location for clarity. The projections for all the locations are
% shown in the supplementary figure. This variable loc takes one of the
% following values - [2 3 5 6] depending on the example projection one
% wants to show. 
loc = 3;
tmp = proj_fef_d1(1:2,:,:);
ind_tr = find(label_fef_d1==loc);
plot(squeeze(mean(tmp(1,ind_tr,delay_1(1):delay_1(2)),3)), squeeze(mean(tmp(2,ind_tr,delay_1(1):delay_1(2)),3)),'.c','MarkerSize',8)
hold on
plot(squeeze(mean(tmp(1,ind_tr,delay_2(1):delay_2(2)),3)), squeeze(mean(tmp(2,ind_tr,delay_2(1):delay_2(2)),3)),'.r','MarkerSize',8)
tmp = proj_fef_d1_e(1:2,:,:);
ind_tr = find(label_fef_d2==loc);
plot(squeeze(mean(tmp(1,ind_tr,delay_2(1):delay_2(2)),3)), squeeze(mean(tmp(2,ind_tr,delay_2(1):delay_2(2)),3)),'Marker','.','LineStyle','none','MarkerSize',8,'color',[0.7 0 0])
plot(squeeze(mean(tmp(1,ind_tr,delay_1(1):delay_1(2)),3)), squeeze(mean(tmp(2,ind_tr,delay_1(1):delay_1(2)),3)),'Marker','.','LineStyle','none','MarkerSize',8,'color','b')
set(ax8,'Box','off','FontName','Helvetica','FontSize',6)
xlabel('PC1','FontName','Helvetica','FontSize',6)
ylabel('PC2','FontName','Helvetica','FontSize',6)
linkaxes([ax7,ax8])

% Fig 4e (LPFC)
ax9 = subplot('Position',[0.775 0.6 0.225 0.275])
% Average shift in cluster centers for correct and error trials in delay 1
% and delay 2 space 
boxplot([mean(shift_clusters_dl_d1,2) mean(shift_clusters_dl_d1_e,2) mean(shift_clusters_dl_d2,2) mean(shift_clusters_dl_d2_e,2)],'whisker',1.2,'symbol','','notch','on','Position',[0.8 1.2 1.8 2.2],'color',[0.4 0.4 0.4])
% Axes  and plot properties
set(ax9,'Box','off','FontName','Helvetica','FontSize',6)
set(ax9,'XTickLabel',{'Correct','Error','Correct','Error'},'FontSize',6,'FontName','Helvetica')
set(findobj(gcf,'LineStyle','--'),'LineStyle','-','color','black')
lines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(lines,'color','r')
ylim([5 11])
ylabel('Mean difference in cluster centers','FontName','Helvetica','FontSize',6)
% Plotting the chance levels (97.5th percentile of the shift within Delay 1 or Delay 2)
line([0.75 0.85],[prctile(mean(shift_clusters_dl_d1_ch,2),97.5) prctile(mean(shift_clusters_dl_d1_ch,2),97.5)],'color','black','LineStyle',':')
line([1.15 1.25],[prctile(mean(shift_clusters_dl_d1_e_ch,2),97.5) prctile(mean(shift_clusters_dl_d1_e_ch,2),97.5)],'color','black','LineStyle',':')
line([1.75 1.85],[prctile(mean(shift_clusters_dl_d2_ch,2),97.5) prctile(mean(shift_clusters_dl_d2_ch,2),97.5)],'color','black','LineStyle',':')
line([2.15 2.25],[prctile(mean(shift_clusters_dl_d2_e_ch,2),97.5) prctile(mean(shift_clusters_dl_d2_e_ch,2),97.5)],'color','black','LineStyle',':')

% Fig 4j (FEF)
ax10 = subplot('Position',[0.775 0.15 0.225 0.275])
boxplot([mean(shift_clusters_fef_d1,2) mean(shift_clusters_fef_d1_e,2) mean(shift_clusters_fef_d2,2) mean(shift_clusters_fef_d2_e,2)],'whisker',1.2,'symbol','','notch','on','Position',[0.8 1.2 1.8 2.2],'color',[0.4 0.4 0.4])
set(ax10,'Box','off','FontName','Helvetica','FontSize',6)
set(ax10,'Box','off','XTickLabel',{'Correct','Error','Correct','Error'},'FontSize',6,'FontName','Helvetica')
set(findobj(gcf,'LineStyle','--'),'LineStyle','-','color','black')
lines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(lines,'color','r')
ylim([3 5.5])
ylabel('Mean difference in cluster centers','FontName','Helvetica','FontSize',6)
line([0.75 0.85],[prctile(mean(shift_clusters_fef_d1_ch,2),97.5) prctile(mean(shift_clusters_fef_d1_ch,2),97.5)],'color','black','LineStyle',':')
line([1.15 1.25],[prctile(mean(shift_clusters_fef_d1_e_ch,2),97.5) prctile(mean(shift_clusters_fef_d1_e_ch,2),97.5)],'color','black','LineStyle',':')
line([1.75 1.85],[prctile(mean(shift_clusters_fef_d2_ch,2),97.5) prctile(mean(shift_clusters_fef_d2_ch,2),97.5)],'color','black','LineStyle',':')
line([2.15 2.25],[prctile(mean(shift_clusters_fef_d2_e_ch,2),97.5) prctile(mean(shift_clusters_fef_d2_e_ch,2),97.5)],'color','black','LineStyle',':')

% Adding all the titles to the plot.
axis = axes('Position',[0 0 1 1],'Visible','off')
text(axis,0.145,0.98,'Cross Temporal Decoding','Units','Normalized','FontName','Helvetica','FontSize',7,'FontWeight','bold','HorizontalAlignment','Center')
text(axis,[0.377 0.377],[0.99 0.97],{'Performance of the decoder','during correct and error trials'},'Units','Normalized','FontName','Helvetica','FontSize',7,'FontWeight','bold','HorizontalAlignment','Center')
text(axis,[0.625 0.625],[0.99 0.97],{'Projection of correct and error trial','data on principal components'},'Units','Normalized','FontName','Helvetica','FontSize',7,'FontWeight','bold','HorizontalAlignment','Center')
text(axis,[0.8875 0.8875],[0.99 0.97],{'Shift in cluster between','on principal components'},'Units','Normalized','FontName','Helvetica','FontSize',7,'FontWeight','bold','HorizontalAlignment','Center')
text(axis,0.47,0.92,'LPFC (n = 256 neurons)','Units','Normalized','FontName','Helvetica','FontSize',7,'FontWeight','bold','HorizontalAlignment','Center')
text(axis,0.47,0.48,'FEF (n = 137 neurons)','Units','Normalized','FontName','Helvetica','FontSize',7,'FontWeight','bold','HorizontalAlignment','Center')
text(axis,0.32,0.88,'Delay 1','Units','Normalized','FontName','Helvetica','FontSize',6,'HorizontalAlignment','Center')
text(axis,0.43,0.88,'Delay 2','Units','Normalized','FontName','Helvetica','FontSize',6,'HorizontalAlignment','Center')
text(axis,0.625,0.88,'Delay 2','Units','Normalized','FontName','Helvetica','FontSize',6,'HorizontalAlignment','Center')
text(axis,0.32,0.44,'Delay 1','Units','Normalized','FontName','Helvetica','FontSize',6,'HorizontalAlignment','Center')
text(axis,0.43,0.44,'Delay 2','Units','Normalized','FontName','Helvetica','FontSize',6,'HorizontalAlignment','Center')
text(axis,0.625,0.44,'Delay 1','Units','Normalized','FontName','Helvetica','FontSize',6,'HorizontalAlignment','Center')
