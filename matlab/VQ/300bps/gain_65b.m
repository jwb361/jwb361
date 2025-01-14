%MELP300 8帧6-5两级 增益码本训练
clear all;
load('./gain_res.mat'); %gain_res
%8帧联合训练
comb = 8;
[len_temp, dimen_temp] = size(gain_res);
length = fix(len_temp/comb);
codebook_dimen = dimen_temp*comb;
train_signal = zeros(length, codebook_dimen);

for i=1:length    
    train_signal(i,1:2) = gain_res(comb*i-7, :);
    train_signal(i,3:4) = gain_res(comb*i-6, :);
    train_signal(i,5:6) = gain_res(comb*i-5, :);
    train_signal(i,7:8) = gain_res(comb*i-4, :);
    train_signal(i,9:10) = gain_res(comb*i-3, :);
    train_signal(i,11:12) = gain_res(comb*i-2, :);
    train_signal(i,13:14) = gain_res(comb*i-1, :);
    train_signal(i,15:16) = gain_res(comb*i, :);
end

stage1_b = 6;
stage2_b = 5;
VQ1 = zeros(length, 1);
residStage1 = zeros(length, codebook_dimen);
VQ2 = zeros(length, 1);
residStage2 = zeros(length, codebook_dimen);

%stage1, train with origin signal
gainCB_65_6 = codeBookTrain(train_signal, stage1_b);
%Vector Quantization
for i = 1:length
    distance = pdist2(train_signal(i,:), gainCB_65_6);
    [value, idx] = min(distance);
    VQ1(i) = idx;
    residStage1(i,:) = train_signal(i,:) - gainCB_65_6(idx,:);    
end
disp('gain_65b stage1 completed');

%stage2, train with residual of stage1
gainCB_65_5 = codeBookTrain(residStage1, stage2_b);
save('gainCB_65b.mat', 'gainCB_65_6', 'gainCB_65_5');
%Vector Quantization
for i = 1:length
    distance = pdist2(residStage1(i,:), gainCB_65_5);
    [value, idx] = min(distance);
    VQ2(i) = idx;
    residStage2(i,:) = residStage1(i,:) - gainCB_65_5(idx,:);  
end
disp('gain_65b completed');
save('gain_65b.mat');
