% This script generates fig 6 in Parthasarathy et al. Please feel free to
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
% Loads all the different nms,lms,cs neurons generated and saved while running
% GenerateFig5.m
load('cell_lpfc.mat')
% Loads the colormap for all the heatmaps.
load('/Users/aishp/Documents/Data/cmap_fig6.mat')
% As the code takes a while to run (each iteration can take about 30-150 seconds depending
% on the analysis and we have 1000 iterations), we also have a folder with
% all the intermediate results saved. You can choose to run it for a few
% iterations to check the algorithm and opt to use the intermediate
% results. The intermediate results are in a separate folder (called Inter
% Results) in the Data folder. You can choose to add it to the path in case
% you want to work with the saved results.
% Change the path to Inter folder 
% Comment these lines in case you want dont want to use the saved dataset.
if exist('/Users/aishp/Documents/Data/perf_subpopn.mat','file') & exist('/Users/aishp/Documents/Data/proj_subpopn.mat','file')
    load('/Users/aishp/Documents/Data/perf_subpopn.mat')
    load('/Users/aishp/Documents/Data/proj_subpopn.mat')
end

%% Computing the cross-temporal decoding for 6 different subpopulations - without NMS, without LMS, without CS, only NMS, only LMS and only CS
N_bootstraps = 1000; % Number of bootstraps
    bins = -300:50:2600;% Defining the bins to compute the decoding performance
    bins(2,:) = bins(1,:)+100;
    Trial_Label = 'target'; % Trial labels to decode. Could be target or distractor.
    % In the paper, for Fig 6, target locations are decoded.
% Check if the variable containing all the decoding performance from the
% subpopulations already exists in the workspace. If it does, it only runs
% the code, if the variable contains decoding performance from less than
% 1000 iterations. In case you choose to load the intermediate result from
% the data folder, this entire code section will be skipped as the intermediate 
% result has data from 1000 iterations.
if ~(exist('perf_cc_wnms','var') && exist('perf_cc_cs','var'))
    
    for i_boot = 1:N_bootstraps
        tic
        % Creating a subpopulation without nms neurons. This subpopulation
        % has equal number of lms and cs neurons. The cs neurons have been
        % subsampled to match the number of lms neurons.
        wnms_lp = sort([lms_lp; cs_lp(randsample(length(cs_lp),length(lms_lp)))]);
        % Creating a subpopulation without lms neurons
        wlms_lp = sort([nms_lp(randsample(length(nms_lp),length(lms_lp))); cs_lp(randsample(length(cs_lp),length(lms_lp)))]);
        % Creating a subpopulation without cs neurons
        wcs_lp = sort([lms_lp; nms_lp(randsample(length(nms_lp),length(lms_lp)))]);
        % Creating a subpopulation of just cs neurons. The number of nms
        % neurons matches the number of lms neurons
        cs_ss_lp = sort(cs_lp(randsample(length(cs_lp),length(lms_lp))));
        % Creating a subpopulation of just nms neurons
        nms_ss_lp = sort(nms_lp(randsample(length(nms_lp),length(lms_lp))));
        % Computing the cross-temporal decoding for the 6 subpopulations
        % created above (including a subpopulation of just LMS neurons)
        perf_cc_wnms(i_boot,:,:) = Decode_final_temporal_v2(dataset_dl(wnms_lp,:,:),m_dl(wnms_lp),st_dl(wnms_lp),session_dl(wnms_lp,:),Trial_Label,trials,bins,etrials,dataset_e_dl,m_e_dl,st_e_dl,'Correct');
        perf_cc_wlms(i_boot,:,:) = Decode_final_temporal_v2(dataset_dl(wlms_lp,:,:),m_dl(wlms_lp),st_dl(wlms_lp),session_dl(wlms_lp,:),Trial_Label,trials,bins,etrials,dataset_e_dl,m_e_dl,st_e_dl,'Correct');
        perf_cc_wcs(i_boot,:,:) = Decode_final_temporal_v2(dataset_dl(wcs_lp,:,:),m_dl(wcs_lp),st_dl(wcs_lp),session_dl(wcs_lp,:),Trial_Label,trials,bins,etrials,dataset_e_dl,m_e_dl,st_e_dl,'Correct');
        perf_cc_nms(i_boot,:,:) = Decode_final_temporal_v2(dataset_dl(nms_ss_lp,:,:),m_dl(nms_ss_lp),st_dl(nms_ss_lp),session_dl(nms_ss_lp,:),Trial_Label,trials,bins,etrials,dataset_e_dl,m_e_dl,st_e_dl,'Correct');
        perf_cc_lms(i_boot,:,:) = Decode_final_temporal_v2(dataset_dl(lms_lp,:,:),m_dl(lms_lp),st_dl(lms_lp),session_dl(lms_lp,:),Trial_Label,trials,bins,etrials,dataset_e_dl,m_e_dl,st_e_dl,'Correct');
        perf_cc_cs(i_boot,:,:) = Decode_final_temporal_v2(dataset_dl(cs_ss_lp,:,:),m_dl(cs_ss_lp),st_dl(cs_ss_lp),session_dl(cs_ss_lp,:),Trial_Label,trials,bins,etrials,dataset_e_dl,m_e_dl,st_e_dl,'Correct');
        toc
        % saving every 100 iterations, incase of power outage or if
        % MATLAB crashes. You can choose to comment these lines. 
        if rem(i_boot,100)==0
            save('perf_subpopn.mat','perf_cc_wnms','perf_cc_wlms','perf_cc_wcs','perf_cc_nms','perf_cc_lms','perf_cc_cs','-v7.3')
        end
    end
% The next few lines of code will be executed if the variables of interest 
% do not contain data from all 1000 iterations. 
elseif (size(perf_cc_wnms,1)<1000 || size(perf_cc_cs,1)<1000)
    for i_boot = size(perf_cc_wnms,1)+1:N_bootstraps
        tic
        wnms_lp = sort([lms_lp; cs_lp(randsample(length(cs_lp),length(lms_lp)))]);
        wlms_lp = sort([nms_lp(randsample(length(nms_lp),length(lms_lp))); cs_lp(randsample(length(cs_lp),length(lms_lp)))]);
        wcs_lp = sort([lms_lp; nms_lp(randsample(length(nms_lp),length(lms_lp)))]);
        cs_ss_lp = sort(cs_lp(randsample(length(cs_lp),length(lms_lp))));
        nms_ss_lp = sort(nms_lp(randsample(length(nms_lp),length(lms_lp))));
        perf_cc_wnms(i_boot,:,:) = Decode_final_temporal_v2(dataset_dl(wnms_lp,:,:),m_dl(wnms_lp),st_dl(wnms_lp),session_dl(wnms_lp,:),Trial_Label,trials,bins,etrials,dataset_e_dl,m_e_dl,st_e_dl,'Correct');
        perf_cc_wlms(i_boot,:,:) = Decode_final_temporal_v2(dataset_dl(wlms_lp,:,:),m_dl(wlms_lp),st_dl(wlms_lp),session_dl(wlms_lp,:),Trial_Label,trials,bins,etrials,dataset_e_dl,m_e_dl,st_e_dl,'Correct');
        perf_cc_wcs(i_boot,:,:) = Decode_final_temporal_v2(dataset_dl(wcs_lp,:,:),m_dl(wcs_lp),st_dl(wcs_lp),session_dl(wcs_lp,:),Trial_Label,trials,bins,etrials,dataset_e_dl,m_e_dl,st_e_dl,'Correct');
        perf_cc_nms(i_boot,:,:) = Decode_final_temporal_v2(dataset_dl(nms_ss_lp,:,:),m_dl(nms_ss_lp),st_dl(nms_ss_lp),session_dl(nms_ss_lp,:),Trial_Label,trials,bins,etrials,dataset_e_dl,m_e_dl,st_e_dl,'Correct');
        perf_cc_lms(i_boot,:,:) = Decode_final_temporal_v2(dataset_dl(lms_lp,:,:),m_dl(lms_lp),st_dl(lms_lp),session_dl(lms_lp,:),Trial_Label,trials,bins,etrials,dataset_e_dl,m_e_dl,st_e_dl,'Correct');
        perf_cc_cs(i_boot,:,:) = Decode_final_temporal_v2(dataset_dl(cs_ss_lp,:,:),m_dl(cs_ss_lp),st_dl(cs_ss_lp),session_dl(cs_ss_lp,:),Trial_Label,trials,bins,etrials,dataset_e_dl,m_e_dl,st_e_dl,'Correct');
        toc
        if rem(i_boot,100)==0
            save('perf_subpopn.mat','perf_cc_wnms','perf_cc_wlms','perf_cc_wcs','perf_cc_nms','perf_cc_lms','perf_cc_cs','-v7.3')
        end
    end
end

%% Computing the projections and shift in cluster centers in Delay 1 and Delay 2 space for 6 different subpopulations - without NMS, without LMS, without CS, only NMS, only LMS and only CS

if ~(exist('shift_clusters_wnms_d1','var') && exist('shift_clusters_cs_d2_ch','var'))
    N_bootstraps = 1000; % Number of bootstraps
    bins = -300:50:2600;% Defining the bins to compute the decoding performance
    bins(2,:) = bins(1,:)+100;
    Trial_Label = 'target'; % Trial labels to project. Could be target or distractor.
    % In the paper, for Fig 6, data from different target locations were projected
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
        % Creating the different subpopulations 
        wnms_lp = sort([lms_lp; cs_lp(randsample(length(cs_lp),length(lms_lp)))]);
        wlms_lp = sort([nms_lp(randsample(length(nms_lp),length(lms_lp))); cs_lp(randsample(length(cs_lp),length(lms_lp)))]);
        wcs_lp = sort([lms_lp; nms_lp(randsample(length(nms_lp),length(lms_lp)))]);
        cs_ss_lp = sort(cs_lp(randsample(length(cs_lp),length(lms_lp))));
        nms_ss_lp = sort(nms_lp(randsample(length(nms_lp),length(lms_lp))));
        % Projections of subpopulations without nms neurons, without lms
        % neurons, without cs neurons in delay 1 space.
        [proj_wnms_d1,label_wnms_d1,~,~] = NeuralTraj_v2(dataset_dl(wnms_lp,:,:),dataset_e_dl(wnms_lp,:,:),trials,session_dl(wnms_lp,:),etrials,size(wnms_lp,1),m_dl(wnms_lp),st_dl(wnms_lp),m_e_dl(wnms_lp),st_e_dl(wnms_lp),delay_1(1),delay_1(2),'Correct');
        [proj_wlms_d1,label_wlms_d1,~,~] = NeuralTraj_v2(dataset_dl(wlms_lp,:,:),dataset_e_dl(wlms_lp,:,:),trials,session_dl(wlms_lp,:),etrials,size(wlms_lp,1),m_dl(wlms_lp),st_dl(wlms_lp),m_e_dl(wlms_lp),st_e_dl(wlms_lp),delay_1(1),delay_1(2),'Correct');
        [proj_wcs_d1,label_wcs_d1,~,~] = NeuralTraj_v2(dataset_dl(wcs_lp,:,:),dataset_e_dl(wcs_lp,:,:),trials,session_dl(wcs_lp,:),etrials,size(wcs_lp,1),m_dl(wcs_lp),st_dl(wcs_lp),m_e_dl(wcs_lp),st_e_dl(wcs_lp),delay_1(1),delay_1(2),'Correct');
        % Projections of subpopulations of only nms, lms and cs neurons in
        % delay 1 space
         [proj_nms_d1,label_nms_d1,~,~] = NeuralTraj_v2(dataset_dl(nms_ss_lp,:,:),dataset_e_dl(nms_ss_lp,:,:),trials,session_dl(nms_ss_lp,:),etrials,size(nms_ss_lp,1),m_dl(nms_ss_lp),st_dl(nms_ss_lp),m_e_dl(nms_ss_lp),st_e_dl(nms_ss_lp),delay_1(1),delay_1(2),'Correct');
        [proj_cs_d1,label_cs_d1,~,~] = NeuralTraj_v2(dataset_dl(cs_ss_lp,:,:),dataset_e_dl(cs_ss_lp,:,:),trials,session_dl(cs_ss_lp,:),etrials,size(cs_ss_lp,1),m_dl(cs_ss_lp),st_dl(cs_ss_lp),m_e_dl(cs_ss_lp),st_e_dl(cs_ss_lp),delay_1(1),delay_1(2),'Correct');
         [proj_lms_d1,label_lms_d1,~,~] = NeuralTraj_v2(dataset_dl(lms_lp,:,:),dataset_e_dl(lms_lp,:,:),trials,session_dl(lms_lp,:),etrials,size(lms_lp,1),m_dl(lms_lp),st_dl(lms_lp),m_e_dl(lms_lp),st_e_dl(lms_lp),delay_1(1),delay_1(2),'Correct');
        % Projections of subpopulations without nms neurons, without lms
        % neurons and without cs neurons in delay 2 space
        [proj_wnms_d2,label_wnms_d2,~,~] = NeuralTraj_v2(dataset_dl(wnms_lp,:,:),dataset_e_dl(wnms_lp,:,:),trials,session_dl(wnms_lp,:),etrials,size(wnms_lp,1),m_dl(wnms_lp),st_dl(wnms_lp),m_e_dl(wnms_lp),st_e_dl(wnms_lp),delay_2(1),delay_2(2),'Correct');
        [proj_wlms_d2,label_wlms_d2,~,~] = NeuralTraj_v2(dataset_dl(wlms_lp,:,:),dataset_e_dl(wlms_lp,:,:),trials,session_dl(wlms_lp,:),etrials,size(wlms_lp,1),m_dl(wlms_lp),st_dl(wlms_lp),m_e_dl(wlms_lp),st_e_dl(wlms_lp),delay_2(1),delay_2(2),'Correct');
        [proj_wcs_d2,label_wcs_d2,~,~] = NeuralTraj_v2(dataset_dl(wcs_lp,:,:),dataset_e_dl(wcs_lp,:,:),trials,session_dl(wcs_lp,:),etrials,size(wcs_lp,1),m_dl(wcs_lp),st_dl(wcs_lp),m_e_dl(wcs_lp),st_e_dl(wcs_lp),delay_2(1),delay_2(2),'Correct');
        % Projecctions of subpopulations of only nms, lms and cs neurons in
        % delay 2 space.
         [proj_nms_d2,label_nms_d2,~,~] = NeuralTraj_v2(dataset_dl(nms_ss_lp,:,:),dataset_e_dl(nms_ss_lp,:,:),trials,session_dl(nms_ss_lp,:),etrials,size(nms_ss_lp,1),m_dl(nms_ss_lp),st_dl(nms_ss_lp),m_e_dl(nms_ss_lp),st_e_dl(nms_ss_lp),delay_2(1),delay_2(2),'Correct');
        [proj_cs_d2,label_cs_d2,~,~] = NeuralTraj_v2(dataset_dl(cs_ss_lp,:,:),dataset_e_dl(cs_ss_lp,:,:),trials,session_dl(cs_ss_lp,:),etrials,size(cs_ss_lp,1),m_dl(cs_ss_lp),st_dl(cs_ss_lp),m_e_dl(cs_ss_lp),st_e_dl(cs_ss_lp),delay_2(1),delay_2(2),'Correct');
         [proj_lms_d2,label_lms_d2,~,~] = NeuralTraj_v2(dataset_dl(lms_lp,:,:),dataset_e_dl(lms_lp,:,:),trials,session_dl(lms_lp,:),etrials,size(lms_lp,1),m_dl(lms_lp),st_dl(lms_lp),m_e_dl(lms_lp),st_e_dl(lms_lp),delay_2(1),delay_2(2),'Correct');
        % Computing the shift in cluster centers for all locations in delay
        % 1 space, delay 2 space and the chance levels in delay 1 and delay
        % 2 space using the activity of the subpopulation without nms neurons.
        [shift_clusters_wnms_d1(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_wnms_d1,label_wnms_d1,delay_1,delay_2);
        [shift_clusters_wnms_d2(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_wnms_d2,label_wnms_d2,delay_1,delay_2);
        [shift_clusters_wnms_d1_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_wnms_d1,label_wnms_d1,delay_11_ch,delay_12_ch);
        [shift_clusters_wnms_d2_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_wnms_d2,label_wlms_d2,delay_21_ch,delay_22_ch);
        % Computing the shift in cluster centers for all locations in delay
        % 1 space, delay 2 space and the chance levels in delay 1 and delay
        % 2 space using the activity of the subpopulation without lms neurons
        [shift_clusters_wlms_d1(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_wlms_d1,label_wlms_d1,delay_1,delay_2);
        [shift_clusters_wlms_d2(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_wlms_d2,label_wlms_d2,delay_1,delay_2);
        [shift_clusters_wlms_d1_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_wlms_d1,label_wlms_d1,delay_11_ch,delay_12_ch);
        [shift_clusters_wlms_d2_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_wlms_d2,label_wlms_d2,delay_21_ch,delay_22_ch);
        % Computing the shift in cluster centers for all locations in delay
        % 1 space, delay 2 space and the chance levels in delay 1 and delay
        % 2 space using the activity of the subpopulation without cs neurons
        [shift_clusters_wcs_d1(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_wcs_d1,label_wcs_d1,delay_1,delay_2);
        [shift_clusters_wcs_d2(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_wcs_d2,label_wcs_d2,delay_1,delay_2);
        [shift_clusters_wcs_d1_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_wcs_d1,label_wcs_d1,delay_11_ch,delay_12_ch);
        [shift_clusters_wcs_d2_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_wcs_d2,label_wcs_d2,delay_21_ch,delay_22_ch);
        % Computing the shift in cluster centers for all locations in delay
        % 1 space, delay 2 space and the chance levels in delay 1 and delay
        % 2 space using the activity of the subpopulation with only nms neurons
        [shift_clusters_nms_d1(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_nms_d1,label_nms_d1,delay_1,delay_2);
        [shift_clusters_nms_d2(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_nms_d2,label_nms_d2,delay_1,delay_2);
        [shift_clusters_nms_d1_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_nms_d1,label_nms_d1,delay_11_ch,delay_12_ch);
        [shift_clusters_nms_d2_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_nms_d2,label_nms_d2,delay_21_ch,delay_22_ch);
        % Computing the shift in cluster centers for all locations in delay
        % 1 space, delay 2 space and the chance levels in delay 1 and delay
        % 2 space using the activity of the subpopulation with only lms neurons
        [shift_clusters_lms_d1(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_lms_d1,label_lms_d1,delay_1,delay_2);
        [shift_clusters_lms_d2(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_lms_d2,label_lms_d2,delay_1,delay_2);
        [shift_clusters_lms_d1_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_lms_d1,label_lms_d1,delay_11_ch,delay_12_ch);
        [shift_clusters_lms_d2_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_lms_d2,label_lms_d2,delay_21_ch,delay_22_ch);
        % Computing the shift in cluster centers for all locations in delay
        % 1 space, delay 2 space and the chance levels in delay 1 and delay
        % 2 space using the activity of the subpopulation with only cs neurons
        [shift_clusters_cs_d1(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_cs_d1,label_cs_d1,delay_1,delay_2);
        [shift_clusters_cs_d2(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_cs_d2,label_cs_d2,delay_1,delay_2);
        [shift_clusters_cs_d1_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_cs_d1,label_cs_d1,delay_11_ch,delay_12_ch);
        [shift_clusters_cs_d2_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_cs_d2,label_cs_d2,delay_21_ch,delay_22_ch);
        toc
        % Just saving every 100 iterations, incase of power outage or if
        % the computer crashes. You can choose to comment these lines. 
        if rem(i_boot,100)==0
            save('proj_subpopn.mat','shift_clusters_wnms_d1','shift_clusters_wnms_d2','shift_clusters_wnms_d1_ch','shift_clusters_wnms_d2_ch',...
            'shift_clusters_wlms_d1','shift_clusters_wlms_d2','shift_clusters_wlms_d1_ch','shift_clusters_wlms_d2_ch',...
            'shift_clusters_wcs_d1','shift_clusters_wcs_d2','shift_clusters_wcs_d1_ch','shift_clusters_wcs_d2_ch',...
            'shift_clusters_nms_d1','shift_clusters_nms_d2','shift_clusters_nms_d1_ch','shift_clusters_nms_d2_ch',...
            'shift_clusters_lms_d1','shift_clusters_lms_d2','shift_clusters_lms_d1_ch','shift_clusters_lms_d2_ch',...
            'shift_clusters_cs_d1','shift_clusters_cs_d2','shift_clusters_cs_d1_ch','shift_clusters_cs_d2_ch')
        end
    end
% The next few lines of code will be executed if the variables of interest 
% do not contain data from all 1000 iterations.     
elseif size(shift_clusters_wnms_d1,1)<1000 & size(shift_clusters_cs_d2_ch,1)<1000
    for i_boot = size(shift_clusters_wnms_d1,1)+1:N_bootstraps
       tic
        wnms_lp = sort([lms_lp; cs_lp(randsample(length(cs_lp),length(lms_lp)))]);
        wlms_lp = sort([nms_lp(randsample(length(nms_lp),length(lms_lp))); cs_lp(randsample(length(cs_lp),length(lms_lp)))]);
        wcs_lp = sort([lms_lp; nms_lp(randsample(length(nms_lp),length(lms_lp)))]);
        cs_ss_lp = sort(cs_lp(randsample(length(cs_lp),length(lms_lp))));
        nms_ss_lp = sort(nms_lp(randsample(length(nms_lp),length(lms_lp))));
        [proj_wnms_d1,label_wnms_d1,~,~] = NeuralTraj_v2(dataset_dl(wnms_lp,:,:),dataset_e_dl(wnms_lp,:,:),trials,session_dl(wnms_lp,:),etrials,size(wnms_lp,1),m_dl(wnms_lp),st_dl(wnms_lp),m_e_dl(wnms_lp),st_e_dl(wnms_lp),delay_1(1),delay_1(2),'Correct');
        [proj_wlms_d1,label_wlms_d1,~,~] = NeuralTraj_v2(dataset_dl(wlms_lp,:,:),dataset_e_dl(wlms_lp,:,:),trials,session_dl(wlms_lp,:),etrials,size(wlms_lp,1),m_dl(wlms_lp),st_dl(wlms_lp),m_e_dl(wlms_lp),st_e_dl(wlms_lp),delay_1(1),delay_1(2),'Correct');
        [proj_wcs_d1,label_wcs_d1,~,~] = NeuralTraj_v2(dataset_dl(wcs_lp,:,:),dataset_e_dl(wcs_lp,:,:),trials,session_dl(wcs_lp,:),etrials,size(wcs_lp,1),m_dl(wcs_lp),st_dl(wcs_lp),m_e_dl(wcs_lp),st_e_dl(wcs_lp),delay_1(1),delay_1(2),'Correct');
        [proj_nms_d1,label_nms_d1,~,~] = NeuralTraj_v2(dataset_dl(nms_ss_lp,:,:),dataset_e_dl(nms_ss_lp,:,:),trials,session_dl(nms_ss_lp,:),etrials,size(nms_ss_lp,1),m_dl(nms_ss_lp),st_dl(nms_ss_lp),m_e_dl(nms_ss_lp),st_e_dl(nms_ss_lp),delay_1(1),delay_1(2),'Correct');
        [proj_cs_d1,label_cs_d1,~,~] = NeuralTraj_v2(dataset_dl(cs_ss_lp,:,:),dataset_e_dl(cs_ss_lp,:,:),trials,session_dl(cs_ss_lp,:),etrials,size(cs_ss_lp,1),m_dl(cs_ss_lp),st_dl(cs_ss_lp),m_e_dl(cs_ss_lp),st_e_dl(cs_ss_lp),delay_1(1),delay_1(2),'Correct');
        [proj_lms_d1,label_lms_d1,~,~] = NeuralTraj_v2(dataset_dl(lms_lp,:,:),dataset_e_dl(lms_lp,:,:),trials,session_dl(lms_lp,:),etrials,size(lms_lp,1),m_dl(lms_lp),st_dl(lms_lp),m_e_dl(lms_lp),st_e_dl(lms_lp),delay_1(1),delay_1(2),'Correct');
        [proj_wnms_d2,label_wnms_d2,~,~] = NeuralTraj_v2(dataset_dl(wnms_lp,:,:),dataset_e_dl(wnms_lp,:,:),trials,session_dl(wnms_lp,:),etrials,size(wnms_lp,1),m_dl(wnms_lp),st_dl(wnms_lp),m_e_dl(wnms_lp),st_e_dl(wnms_lp),delay_2(1),delay_2(2),'Correct');
        [proj_wlms_d2,label_wlms_d2,~,~] = NeuralTraj_v2(dataset_dl(wlms_lp,:,:),dataset_e_dl(wlms_lp,:,:),trials,session_dl(wlms_lp,:),etrials,size(wlms_lp,1),m_dl(wlms_lp),st_dl(wlms_lp),m_e_dl(wlms_lp),st_e_dl(wlms_lp),delay_2(1),delay_2(2),'Correct');
        [proj_wcs_d2,label_wcs_d2,~,~] = NeuralTraj_v2(dataset_dl(wcs_lp,:,:),dataset_e_dl(wcs_lp,:,:),trials,session_dl(wcs_lp,:),etrials,size(wcs_lp,1),m_dl(wcs_lp),st_dl(wcs_lp),m_e_dl(wcs_lp),st_e_dl(wcs_lp),delay_2(1),delay_2(2),'Correct');
        [proj_nms_d2,label_nms_d2,~,~] = NeuralTraj_v2(dataset_dl(nms_ss_lp,:,:),dataset_e_dl(nms_ss_lp,:,:),trials,session_dl(nms_ss_lp,:),etrials,size(nms_ss_lp,1),m_dl(nms_ss_lp),st_dl(nms_ss_lp),m_e_dl(nms_ss_lp),st_e_dl(nms_ss_lp),delay_2(1),delay_2(2),'Correct');
        [proj_cs_d2,label_cs_d2,~,~] = NeuralTraj_v2(dataset_dl(cs_ss_lp,:,:),dataset_e_dl(cs_ss_lp,:,:),trials,session_dl(cs_ss_lp,:),etrials,size(cs_ss_lp,1),m_dl(cs_ss_lp),st_dl(cs_ss_lp),m_e_dl(cs_ss_lp),st_e_dl(cs_ss_lp),delay_2(1),delay_2(2),'Correct');
        [proj_lms_d2,label_lms_d2,~,~] = NeuralTraj_v2(dataset_dl(lms_lp,:,:),dataset_e_dl(lms_lp,:,:),trials,session_dl(lms_lp,:),etrials,size(lms_lp,1),m_dl(lms_lp),st_dl(lms_lp),m_e_dl(lms_lp),st_e_dl(lms_lp),delay_2(1),delay_2(2),'Correct');
        [shift_clusters_wnms_d1(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_wnms_d1,label_wnms_d1,delay_1,delay_2);
        [shift_clusters_wnms_d2(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_wnms_d2,label_wnms_d2,delay_1,delay_2);
        [shift_clusters_wnms_d1_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_wnms_d1,label_wnms_d1,delay_11_ch,delay_12_ch);
        [shift_clusters_wnms_d2_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_wnms_d2,label_wlms_d2,delay_21_ch,delay_22_ch);
        [shift_clusters_wlms_d1(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_wlms_d1,label_wlms_d1,delay_1,delay_2);
        [shift_clusters_wlms_d2(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_wlms_d2,label_wlms_d2,delay_1,delay_2);
        [shift_clusters_wlms_d1_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_wlms_d1,label_wlms_d1,delay_11_ch,delay_12_ch);
        [shift_clusters_wlms_d2_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_wlms_d2,label_wlms_d2,delay_21_ch,delay_22_ch);
        [shift_clusters_wcs_d1(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_wcs_d1,label_wcs_d1,delay_1,delay_2);
        [shift_clusters_wcs_d2(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_wcs_d2,label_wcs_d2,delay_1,delay_2);
        [shift_clusters_wcs_d1_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_wcs_d1,label_wcs_d1,delay_11_ch,delay_12_ch);
        [shift_clusters_wcs_d2_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_wcs_d2,label_wcs_d2,delay_21_ch,delay_22_ch);
        [shift_clusters_nms_d1(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_nms_d1,label_nms_d1,delay_1,delay_2);
        [shift_clusters_nms_d2(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_nms_d2,label_nms_d2,delay_1,delay_2);
        [shift_clusters_nms_d1_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_nms_d1,label_nms_d1,delay_11_ch,delay_12_ch);
        [shift_clusters_nms_d2_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_nms_d2,label_nms_d2,delay_21_ch,delay_22_ch);
        [shift_clusters_lms_d1(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_lms_d1,label_lms_d1,delay_1,delay_2);
        [shift_clusters_lms_d2(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_lms_d2,label_lms_d2,delay_1,delay_2);
        [shift_clusters_lms_d1_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_lms_d1,label_lms_d1,delay_11_ch,delay_12_ch);
        [shift_clusters_lms_d2_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_lms_d2,label_lms_d2,delay_21_ch,delay_22_ch);
        [shift_clusters_cs_d1(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_cs_d1,label_cs_d1,delay_1,delay_2);
        [shift_clusters_cs_d2(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_cs_d2,label_cs_d2,delay_1,delay_2);
        [shift_clusters_cs_d1_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_cs_d1,label_cs_d1,delay_11_ch,delay_12_ch);
        [shift_clusters_cs_d2_ch(i_boot,:),~,~,~,~] =  ShiftofClusters(proj_cs_d2,label_cs_d2,delay_21_ch,delay_22_ch);
        toc 
        if rem(i_boot,100)==0
            save('proj_subpopn.mat','shift_clusters_wnms_d1','shift_clusters_wnms_d2','shift_clusters_wnms_d1_ch','shift_clusters_wnms_d2_ch',...
            'shift_clusters_wlms_d1','shift_clusters_wlms_d2','shift_clusters_wlms_d1_ch','shift_clusters_wlms_d2_ch',...
            'shift_clusters_wcs_d1','shift_clusters_wcs_d2','shift_clusters_wcs_d1_ch','shift_clusters_wcs_d2_ch',...
            'shift_clusters_nms_d1','shift_clusters_nms_d2','shift_clusters_nms_d1_ch','shift_clusters_nms_d2_ch',...
            'shift_clusters_lms_d1','shift_clusters_lms_d2','shift_clusters_lms_d1_ch','shift_clusters_lms_d2_ch',...
            'shift_clusters_wcs_d1','shift_clusters_wcs_d2','shift_clusters_wcs_d1_ch','shift_clusters_wcs_d2_ch')
        end
    end
end

%% Plotting Fig 6a,b,c and e,f,g
% Opening a new figure
figure
Ticks = find(bins(1,:)==0 | bins(1,:)==300 | bins(1,:)==1300 | bins(1,:)==1600); % Target and Distractor onset and offset
% figure 6a(wnms)
ax1 = subplot('Position',[0.045,0.65,0.20,0.275]); % Position of the subplot
imagesc(squeeze(mean(perf_cc_wnms)),[0 50]) % Plotting the heatmap where the performance is limited between 0 and 50
% Plotting white line to mark onset and offset of target and distractor.
for i_line = 1:length(Ticks)
    line([Ticks(i_line) Ticks(i_line)],ylim,'color','white')
    line(xlim,[Ticks(i_line) Ticks(i_line)],'color','white')
end
% Setting ticklabels of the heatmap and colorbar.
set(ax1,'XTick',Ticks,'YTick',Ticks,'XTickLabel',{'0','0.3','1.3','1.6'},'YTickLabel',{'0','0.3','1.3','1.6'},'FontSize',6,'FontName','Helvetica','ydir','normal')
c = colorbar('Southoutside','Ticks',[0 10 20 30 40 50],'TickLabels',{'0','10','20','30','40','50'},'FontName','Helvetica','FontSize',6);
% Sets the position of the colorbar
set(c,'Position',[0.045 0.575 0.20 0.020]);
% Title for the colorbar
c.Label.String = 'Performance (%)';
% Sets the colormap using the variable cmap_fig6
colormap(ax1,cmap_fig6);
% Sets x and y label of the heatmap.
xlabel('Testing Windows aligned to Target Onset (s)','FontSize',6,'FontName','Helvetica')
ylabel('Training Windows aligned to Target Onset (s)','FontSize',6,'FontName','Helvetica')

% fig 6b(wlms)
ax2 = subplot('Position',[0.275,0.65,0.20,0.275]);
imagesc(squeeze(mean(perf_cc_wlms)),[0 50])
for i_line = 1:length(Ticks)
    line([Ticks(i_line) Ticks(i_line)],ylim,'color','white')
    line(xlim,[Ticks(i_line) Ticks(i_line)],'color','white')
end
set(ax2,'XTick',Ticks,'YTick',Ticks,'XTickLabel',{'0','0.3','1.3','1.6'},'YTickLabel',{'0','0.3','1.3','1.6'},'FontSize',6,'FontName','Helvetica','ydir','normal')
c = colorbar('Southoutside','Ticks',[0 10 20 30 40 50],'TickLabels',{'0','10','20','30','40','50'},'FontName','Helvetica','FontSize',6);
set(c,'Position',[0.275 0.575 0.20 0.020]);
c.Label.String = 'Performance (%)';
colormap(ax2,cmap_fig6)
xlabel('Testing Windows aligned to Target Onset (s)','FontSize',6,'FontName','Helvetica')

%Fig 6c(wcs)
ax3 = subplot('Position',[0.505,0.65,0.20,0.275]);
imagesc(squeeze(mean(perf_cc_wcs)),[0 50])
for i_line = 1:length(Ticks)
    line([Ticks(i_line) Ticks(i_line)],ylim,'color','white')
    line(xlim,[Ticks(i_line) Ticks(i_line)],'color','white')
end
set(ax3,'XTick',Ticks,'YTick',Ticks,'XTickLabel',{'0','0.3','1.3','1.6'},'YTickLabel',{'0','0.3','1.3','1.6'},'FontSize',6,'FontName','Helvetica','ydir','normal')
c = colorbar('Southoutside','Ticks',[0 10 20 30 40 50],'TickLabels',{'0','10','20','30','40','50'},'FontName','Helvetica','FontSize',6);
set(c,'Position',[0.505 0.575 0.20 0.020]);
c.Label.String = 'Performance (%)';
colormap(ax3,cmap_fig6)
xlabel('Testing Windows aligned to Target Onset (s)','FontSize',6,'FontName','Helvetica')

%Fig 6e(nms)
ax4 = subplot('Position',[0.045,0.15,0.20,0.275]);
imagesc(squeeze(mean(perf_cc_nms)),[0 50])
for i_line = 1:length(Ticks)
    line([Ticks(i_line) Ticks(i_line)],ylim,'color','white')
    line(xlim,[Ticks(i_line) Ticks(i_line)],'color','white')
end
set(ax4,'XTick',Ticks,'YTick',Ticks,'XTickLabel',{'0','0.3','1.3','1.6'},'YTickLabel',{'0','0.3','1.3','1.6'},'FontSize',6,'FontName','Helvetica','ydir','normal')
c = colorbar('Southoutside','Ticks',[0 10 20 30 40 50],'TickLabels',{'0','10','20','30','40','50'},'FontName','Helvetica','FontSize',6);
set(c,'Position',[0.045 0.075 0.20 0.020]);
c.Label.String = 'Performance (%)';
colormap(ax4,cmap_fig6)
xlabel('Testing Windows aligned to Target Onset (s)','FontSize',6,'FontName','Helvetica')

%Fig 6f(lms)
ax5 = subplot('Position',[0.275,0.15,0.20,0.275]);
imagesc(squeeze(mean(perf_cc_lms)),[0 50])
for i_line = 1:length(Ticks)
    line([Ticks(i_line) Ticks(i_line)],ylim,'color','white')
    line(xlim,[Ticks(i_line) Ticks(i_line)],'color','white')
end
set(ax5,'XTick',Ticks,'YTick',Ticks,'XTickLabel',{'0','0.3','1.3','1.6'},'YTickLabel',{'0','0.3','1.3','1.6'},'FontSize',6,'FontName','Helvetica','ydir','normal')
c = colorbar('Southoutside','Ticks',[0 10 20 30 40 50],'TickLabels',{'0','10','20','30','40','50'},'FontName','Helvetica','FontSize',6);
set(c,'Position',[0.275 0.075 0.20 0.020]);
c.Label.String = 'Performance (%)';
colormap(ax5,cmap_fig6)
xlabel('Testing Windows aligned to Target Onset (s)','FontSize',6,'FontName','Helvetica')

%Fig 6g(cs)
ax6 = subplot('Position',[0.505,0.15,0.20,0.275]);
imagesc(squeeze(mean(perf_cc_cs)),[0 50])
for i_line = 1:length(Ticks)
    line([Ticks(i_line) Ticks(i_line)],ylim,'color','white')
    line(xlim,[Ticks(i_line) Ticks(i_line)],'color','white')
end
set(ax6,'XTick',Ticks,'YTick',Ticks,'XTickLabel',{'0','0.3','1.3','1.6'},'YTickLabel',{'0','0.3','1.3','1.6'},'FontSize',6,'FontName','Helvetica','ydir','normal')
c = colorbar('Southoutside','Ticks',[0 10 20 30 40 50],'TickLabels',{'0','10','20','30','40','50'},'FontName','Helvetica','FontSize',6);
set(c,'Position',[0.505 0.075 0.20 0.020]);
c.Label.String = 'Performance (%)';
colormap(ax6,cmap_fig6)
xlabel('Testing Windows aligned to Target Onset (s)','FontSize',6,'FontName','Helvetica')

%% Plotting Fig 6d,h

% Fig 6d (shift in clusters for wnms,wlms and wcs in delay 1 and delay 2
% space)
ax7 = subplot('Position',[0.75 0.65 0.25 0.275])
boxplot([mean(shift_clusters_wnms_d1,2) mean(shift_clusters_wlms_d1,2) mean(shift_clusters_wcs_d1,2) mean(shift_clusters_wnms_d2,2) mean(shift_clusters_wlms_d2,2) mean(shift_clusters_wcs_d2,2)],'whisker',1.2,'notch','on','symbol','','color',[0.4 0.4 0.4],'Position',[0.65 0.85 1.05 1.65 1.85 2.05])
% Sets the properties for the plot - color of the boxplot, fontname, font
% size etc.
set(ax7,'Box','off','FontName','Helvetica','FontSize',6,'XTickLabel',{'Wnms','Wlms','Wcs','Wnms','Wlms','Wcs'})
set(findobj(gcf,'LineStyle','--'),'LineStyle','-','color','black')
lines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(lines,'color','r')
% y-limits.
ylim([0 10])
ylabel('Mean difference in cluster centers','FontName','Helvetica','FontSize',6)
xlabel('Delay 1                                            Delay 2','FontName','Helvetica','FontSize',6)
% Plotting the lines for the 97.5th percentile of the chance level
% distribution.
line([0.6 0.7],[prctile(mean(shift_clusters_wnms_d1_ch,2),97.5) prctile(mean(shift_clusters_wnms_d1_ch,2),97.5)],'LineStyle',':','color','black')
line([0.8 0.9],[prctile(mean(shift_clusters_wlms_d1_ch,2),97.5) prctile(mean(shift_clusters_wlms_d1_ch,2),97.5)],'LineStyle',':','color','black')
line([1 1.1],[prctile(mean(shift_clusters_wcs_d1_ch,2),97.5) prctile(mean(shift_clusters_wcs_d1_ch,2),97.5)],'LineStyle',':','color','black')
line([1.6 1.7],[prctile(mean(shift_clusters_wnms_d2_ch,2),97.5) prctile(mean(shift_clusters_wnms_d2_ch,2),97.5)],'LineStyle',':','color','black')
line([1.8 1.9],[prctile(mean(shift_clusters_wlms_d2_ch,2),97.5) prctile(mean(shift_clusters_wlms_d2_ch,2),97.5)],'LineStyle',':','color','black')
line([2 2.1],[prctile(mean(shift_clusters_wcs_d2_ch,2),97.5) prctile(mean(shift_clusters_wcs_d2_ch,2),97.5)],'LineStyle',':','color','black')

% Fig 6h (shift in clusters for nmslms and wcs in delay 1 and delay 2
% space)
ax8 = subplot('Position',[0.75 0.15 0.25 0.275])
boxplot([mean(shift_clusters_nms_d1,2) mean(shift_clusters_lms_d1,2) mean(shift_clusters_cs_d1,2) mean(shift_clusters_nms_d2,2) mean(shift_clusters_lms_d2,2) mean(shift_clusters_cs_d2,2)],'whisker',1.2,'notch','on','symbol','','color',[0.4 0.4 0.4],'Position',[0.65 0.85 1.05 1.65 1.85 2.05])
set(ax8,'Box','off','FontName','Helvetica','FontSize',6,'XTickLabel',{'nms','lms','cs','nms','lms','cs'})
set(findobj(gcf,'LineStyle','--'),'LineStyle','-','color','black')
lines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(lines,'color','r')
ylim([0 10])
ylabel('Mean difference in cluster centers','FontName','Helvetica','FontSize',6)
xlabel('Delay 1                                            Delay 2','FontName','Helvetica','FontSize',6)
line([0.6 0.7],[prctile(mean(shift_clusters_nms_d1_ch,2),97.5) prctile(mean(shift_clusters_nms_d1_ch,2),97.5)],'LineStyle',':','color','black')
line([0.8 0.9],[prctile(mean(shift_clusters_lms_d1_ch,2),97.5) prctile(mean(shift_clusters_lms_d1_ch,2),97.5)],'LineStyle',':','color','black')
line([1 1.1],[prctile(mean(shift_clusters_cs_d1_ch,2),97.5) prctile(mean(shift_clusters_cs_d1_ch,2),97.5)],'LineStyle',':','color','black')
line([1.6 1.7],[prctile(mean(shift_clusters_nms_d2_ch,2),97.5) prctile(mean(shift_clusters_nms_d2_ch,2),97.5)],'LineStyle',':','color','black')
line([1.8 1.9],[prctile(mean(shift_clusters_lms_d2_ch,2),97.5) prctile(mean(shift_clusters_lms_d2_ch,2),97.5)],'LineStyle',':','color','black')
line([2 2.1],[prctile(mean(shift_clusters_cs_d2_ch,2),97.5) prctile(mean(shift_clusters_cs_d2_ch,2),97.5)],'LineStyle',':','color','black')

% Sets the title for all the figures.
axis = axes('Position',[0 0 1 1],'Visible','off')
text(axis,0.375,0.98,'Cross-Temporal Decoding','FontName','Helvetica','FontSize',7,'FontWeight','Bold','HorizontalAlignment','center')
text(axis,0.145,0.96,'Without NMS neurons','FontName','Helvetica','FontSize',6,'HorizontalAlignment','center')
text(axis,0.375,0.96,'Without LMS neurons','FontName','Helvetica','FontSize',6,'HorizontalAlignment','center')
text(axis,0.605,0.96,'Without CS neurons','FontName','Helvetica','FontSize',6,'HorizontalAlignment','center')
text(axis,0.145,0.94,'(n = 54)','FontName','Helvetica','FontSize',6,'HorizontalAlignment','center')
text(axis,0.375,0.94,'(n = 54)','FontName','Helvetica','FontSize',6,'HorizontalAlignment','center')
text(axis,0.605,0.94,'(n = 54)','FontName','Helvetica','FontSize',6,'HorizontalAlignment','center')

text(axis,0.145,0.46,'NMS neurons','FontName','Helvetica','FontSize',6,'HorizontalAlignment','center')
text(axis,0.375,0.46,'LMS neurons','FontName','Helvetica','FontSize',6,'HorizontalAlignment','center')
text(axis,0.605,0.46,'CS neurons','FontName','Helvetica','FontSize',6,'HorizontalAlignment','center')
text(axis,0.145,0.44,'(n = 27)','FontName','Helvetica','FontSize',6,'HorizontalAlignment','center')
text(axis,0.375,0.44,'(n = 27)','FontName','Helvetica','FontSize',6,'HorizontalAlignment','center')
text(axis,0.605,0.44,'(n = 27)','FontName','Helvetica','FontSize',6,'HorizontalAlignment','center')

text(axis,[0.875 0.875],[0.99 0.97],{'Shift in clusters between','Delay 1 and Delay 2 activity'},'FontName','Helvetica','FontSize',7,'FontWeight','bold','HorizontalAlignment','center')
