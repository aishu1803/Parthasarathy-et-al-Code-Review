function [shift_clusters,m_intra_dist_d1,m_intra_dist_d2,inter_dist_d1,inter_dist_d2] =  ShiftofClusters(projected_data,testing_label,xc1,xc2)
loc = unique(testing_label(1,:));
tmp = projected_data;
tmp3 = squeeze(mean(tmp(:,:,xc1(1):xc1(2)),3));
tmp4 = squeeze(mean(tmp(:,:,xc2(1):xc2(2)),3));
for j = 1:length(loc)
    ind_tri = find(testing_label==loc(j));
    m2 = mean(squeeze(mean(tmp(:,ind_tri,xc1(1):xc1(2)),3)),2);
    m1 = mean(squeeze(mean(tmp(:,ind_tri,xc2(1):xc2(2)),3)),2);
    tmp2 = 0;
    for k = 1:length(m1)
        tmp2 = tmp2 + (m2(k) - m1(k))^2;
    end
    shift_clusters(j) = sqrt(tmp2);combi = nchoosek(1:50,2);
    for k = 1:size(combi,1)
        tmp_dist_d1 = 0;tmp_dist_d2 = 0;
        for l = 1:size(tmp3,1)
            tmp_dist_d1 = tmp_dist_d1 + (squeeze(tmp3(l,ind_tri(combi(k,1)),1)) - squeeze(tmp3(l,ind_tri(combi(k,2)),1)))^2; 
            tmp_dist_d2 = tmp_dist_d2 + (squeeze(tmp4(l,ind_tri(combi(k,1)),1)) - squeeze(tmp4(l,ind_tri(combi(k,2)),1)))^2; 
        end
        intra_dist_d1(k) = sqrt(tmp_dist_d1);
        intra_dist_d2(k) = sqrt(tmp_dist_d2);
    end
    m_intra_dist_d1(j,:) = mean(intra_dist_d1);
    m_intra_dist_d2(j,:) = mean(intra_dist_d2);
end
for i = 1:length(loc)
    tmp_ind = find(testing_label==loc(i));
%     ind = tmp_ind(randsample(length(tmp_ind),50));
    m_projected_data_d1(:,i,:) = mean(tmp3(:,tmp_ind,:),2);
    m_projected_data_d2(:,i,:) = mean(tmp4(:,tmp_ind,:),2);
end
combi = nchoosek(1:length(loc),2);
for j = 1:size(combi,1)
    tmp_d1 = 0;tmp_d2 = 0;
    for k = 1:size(projected_data,1)
        tmp_d1 = tmp_d1 + (squeeze(m_projected_data_d1(k,combi(j,1),1)) - squeeze(m_projected_data_d1(k,combi(j,2),1)))^2;
        tmp_d2 = tmp_d2 + (squeeze(m_projected_data_d2(k,combi(j,1),1)) - squeeze(m_projected_data_d2(k,combi(j,2),1)))^2;
    end
    dist_d1(j,1) = sqrt(tmp_d1);
    dist_d2(j,1) = sqrt(tmp_d2);
    
end
inter_dist_d1  = mean(dist_d1);
inter_dist_d2 = mean(dist_d2);
