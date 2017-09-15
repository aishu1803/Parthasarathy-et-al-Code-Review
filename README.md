# Parthasarathy-et-al-Code-Review
All the necessary codes for generating non-representative figures in the main paper (Parthasarathy et al)

To create a figure from the paper, please run GenerateFigx.m section by section after reading the comments. All the results are generated from spiketimes. The following variables are stored in a .mat file in the "Dataset" folder. For more information about the task, check Parthasarathy et al.

Dataset: size Nneurons x Ntrials x 2900.
Spiketimes for all neurons in each region (LPFC/FEF) in 1 ms resolution. 2900 is the number of time bins for the trial (-300 to 2600ms where 0 is target onset) in 1 ms resolution. If there was a spike in that ms, the bin takes the value 1 and 0 otherwise. . Ntrials is the maximum number of trials recorded by the neurons. If a neuron is recorded with less than Ntrials trials, then the rest of the values in the matrix till Ntrials is zero-padded. Nneurons is the number of neurons in the LPFC or FEF population. Dataset for LPFC and FEF are named dataset_lpfc and dataset_fef respectively.

session: Size - Nneurons x 2
Each element in the first column refers to the session in which the neuron was recorded. The data used in this paper were recorded from 2 monkeys (4 sessions each). The session is numbered from 1 to 8 - first 4 belonging to Monkey B and second 4 to Monkey A. Also, this value as the index of the trials variable fetches all the trials performed in the session where the said neuron was recorded.

trials: Size - struct 1 x Nsession. 
Nsession is the number of recorded sessions from which we pool neurons to form dataset. Nsession also equals the number of unique values in the first column of the sessions array.


Please note that the code takes quite a while to run as it consists of 1000 iterations each and each iteration might take anywhere between 30-110 seconds depending on the section you are running. To save time, the Data folder contains a separate folder that contains all the intermediate results for 1000 iterations. You can choose to use this dataset after verifying the algorithm to generate the result for a few iterations. To use these intermediate results, add the folder containing the intermediate results to the path. Make sure you do not have the intermediate results in the path if you want to verify the algorithm. If you want to run all 1000 iterations for all the figures in this repository - it will approximately take about two weeks. The figures generated by these codes will not be identical to the figures in the paper as there will be minute changes every time you generate a new iteration. However, the qualitative results remain the same.


Any questions?? Please contact - Aishwarya Parthasarathy at aishu.parth@gmail.com

