%MELP600�뱾ѵ��
clear all;
load('../trainData/lsf_all.mat'); %lsf_all
lsf_temp = lsf_all';
lsf_temp = 4000*lsf_temp/pi;%
%��֡����ѵ��
[len_temp, dimen_temp] = size(lsf_temp);
length = fix(len_temp/2);
codebook_dimen = dimen_temp*2;
train_signal = zeros(length, codebook_dimen);
for i=1:length
    train_signal(i,1:10) = lsf_temp(2*i-1, :);
    train_signal(i,11:20) = lsf_temp(2*i, :);
end

stage1_b = 7;
stage2_b = 5;
stage3_b = 3;
VQ1 = zeros(length, 1);
residStage1 = zeros(length, codebook_dimen);
VQ2 = zeros(length, 1);
residStage2 = zeros(length, codebook_dimen);
VQ3 = zeros(length, 1);
residStage3 = zeros(length, codebook_dimen);

%stage1, train with origin signal
LSF_CB_7b = codeBookTrain(train_signal, stage1_b);
%Vector Quantization
for i = 1:length
    distance = pdist2(train_signal(i,:), LSF_CB_7b);
    [value, idx] = min(distance);
    VQ1(i) = idx;
    residStage1(i,:) = train_signal(i,:) - LSF_CB_7b(idx,:);    
end
disp('stage1 completed');

%stage2, train with residual of stage1
LSF_CB_5b = codeBookTrain(residStage1, stage2_b);
%Vector Quantization
for i = 1:length
    distance = pdist2(residStage1(i,:), LSF_CB_5b);
    [value, idx] = min(distance);
    VQ2(i) = idx;
    residStage2(i,:) = residStage1(i,:) - LSF_CB_5b(idx,:);  
end
disp('stage2 completed');

%stage3, train with residual of stage2
LSF_CB_3b = codeBookTrain(residStage2, stage3_b);
save('LSF_CB_753b.mat', 'codebook1', 'codebook2', 'codebook3');
%Vector Quantization
for i = 1:length
    distance = pdist2(residStage2(i,:), LSF_CB_3b);
    [value, idx] = min(distance);
    VQ3(i) = idx;
    residStage3(i,:) = residStage2(i,:) - LSF_CB_3b(idx,:);  
end
disp('LSF_753b completed');
save('LSF_753b.mat');