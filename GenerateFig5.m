% This script generates fig 5 in Parthasarathy et al. Please feel free to
% contact me (Aishwarya Parthasarathy) at aishu.parth@gmail.com

clear all;
close all;
% Loading the spike count dataset used in the paper. Please change the path
% of the folder accordingly.
load('/Users/aishp/Documents/Data/dataset_overlapbins_fefdl.mat');

%% Identifying the nms,lms,cs neurons from the LPFC and FEF populations.
bins = -300:50:2600;% Defining the bins to compute the decoding performance
bins(2,:) = bins(1,:)+100;
[nms_lp,lms_lp,f_nms_lp,~,~,~,~,~,~,cs_lp] = TwoWayAnova(dataset_dl,trials,session_dl,bins);
[nms_fef,lms_fef,f_nms_fef,~,~,~,~,~,~,cs_fef] = TwoWayAnova(dataset,trials,session,bins);
save('cell_lpfc','nms_lp','lms_lp','cs_lp','-v7.3')
save('cell_fef','nms_fef','lms_fef','cs_fef','-v7.3')
%% Comparing the strength of non-linear mixed selectivity between LPFC and FEF

N_bootstraps = 1000;
for i = 1:N_bootstraps
    ss_nms_lp = randsample(length(nms_lp),length(nms_fef));
    ss_f_nms_lp(i) = mean(f_nms_lp(ss_nms_lp));
end
[N,edges] = histcounts(ss_f_nms_lp);

%% Plotting Fig 5f
figure
plot(edges(2:end),N/1000,'LineStyle','-','color','red')
set(gca,'Box','off','FontName','Helvetica','FontSize',6)
line([prctile(ss_f_nms_lp,97.5) prctile(ss_f_nms_lp,97.5)],ylim,'LineStyle',':','color','red')
line([prctile(ss_f_nms_lp,2.5) prctile(ss_f_nms_lp,2.5)],ylim,'LineStyle',':','color','red')
line([mean(ss_f_nms_lp) mean(ss_f_nms_lp)],ylim,'LineStyle','-.','color','red')
line([mean(f_nms_fef) mean(f_nms_fef)],ylim,'LineStyle','-.','color','blue')
xlabel({'F-statistics of the Interaction between Task epoch and Target Location'},'FontName','Helvetica','FontSize',6)
ylabel({'Histogram of the subsampled mean'},'FontName','Helvetica','FontSize',6)
