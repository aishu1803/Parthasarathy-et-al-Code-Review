function [m,st,dataset_count,dataset_e_count,m_e,st_e] = PreProcess(dataset,dataset_e,bins_overlap,trials,session,etrials)
bins = -300:1:2600;
bin_width = bins_overlap;

for i = 1:size(dataset,1)
        for k = 1:size(bin_width,2) - 1
            
            ind1 = find(bins==bin_width(1,k));
            ind2 = find(bins==bin_width(2,k));
            for j = 1:size(dataset,2)
            dataset_count(i,j,k) = squeeze(sum(dataset(i,j,ind1:ind2)));
            end
            for j = 1:size(dataset_e,2)
            dataset_e_count(i,j,k) = squeeze(sum(dataset_e(i,j,ind1:ind2)));
            end
        end
    end

baseline_ind = find(bins==0);
for i = 1:size(dataset,1)
    sess = session(i,1);
    tr = length(trials(sess).val);
    etr = length(etrials(sess).val);
    m(i) = squeeze(mean(mean(dataset(i,1:tr,1:baseline_ind),3),2));
    st(i) = squeeze(std(mean(dataset(i,1:tr,1:baseline_ind),3),[],2));
    m_e(i) = squeeze(mean(mean(dataset_e(i,1:etr,1:baseline_ind),3),2));
    st_e(i) = squeeze(std(mean(dataset_e(i,1:etr,1:baseline_ind),3),[],2));
end